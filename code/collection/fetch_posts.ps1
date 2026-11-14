param([string]$Sub, [long]$From, [long]$To, [string]$Tag, [string]$OutDir = "E:\Claude_Folder\Research_phd\data")
Add-Type -AssemblyName System.Web.Extensions
$js = New-Object System.Web.Script.Serialization.JavaScriptSerializer; $js.MaxJsonLength = [int]::MaxValue
$START = $From - 1; $END = $To
$inc = [regex]::new('feedback|thoughts|roast|validat|should i|is this|honest opinion|what do you think|any advice|would you (use|buy|pay)|is it worth|viable|good idea|bad idea|am i crazy|sanity check|critique','IgnoreCase')
$exc = [regex]::new('\bARR\b|\bMRR\b|we (just )?launched|i (just )?launched|we hit|i made \$|giveaway|discount code|check out my|link in (bio|comments)|promo code|\bsponsored\b|hiring|\bAMA\b','IgnoreCase')
$rows = Join-Path $OutDir "posts_${Sub}_$Tag.jsonl"; $cur = Join-Path $OutDir "posts_${Sub}_$Tag.state.json"
$st = @{cursor=$START; scanned=0; basic=0; include=0; exclude=0}
if (Test-Path $cur) { $o = $js.DeserializeObject((Get-Content $cur -Raw)); foreach($k in $st.Keys.Clone()){ $st[$k] = [long]$o[$k] } }
$fields = "id,title,selftext,created_utc,over_18,num_comments,score,link_flair_text,author"
$bad = @("","[removed]","[deleted]"); $badAuth = @("[deleted]","automoderator","none")
$utf8 = New-Object Text.UTF8Encoding $false
while ($st.cursor -lt $END) {
  $url = "https://arctic-shift.photon-reddit.com/api/posts/search?subreddit=$Sub&after=$($st.cursor)&before=$END&limit=100&sort=asc&fields=$fields"
  $txt = $null
  for ($i=0; $i -lt 8 -and -not $txt; $i++) {
    try { $wc = New-Object Net.WebClient; $wc.Encoding = [Text.Encoding]::UTF8; $txt = $wc.DownloadString($url) }
    catch { $w = [Math]::Min(120, [Math]::Pow(2,$i)+2); Write-Host "retry in $w s: $($_.Exception.Message)"; Start-Sleep $w }
  }
  if (-not $txt) { throw "failed" }
  $data = $js.DeserializeObject($txt).data
  if (-not $data -or $data.Count -eq 0) { break }
  $sb = New-Object Text.StringBuilder; $max = $st.cursor
  foreach ($d in $data) {
    $st.scanned++; $ts = [long]$d.created_utc; if ($ts -gt $max) { $max = $ts }
    $body = ("" + $d.selftext).Trim(); $auth = ("" + $d.author).ToLower()
    if ($d.over_18 -eq $true -or $bad -contains $body -or $badAuth -contains $auth) { continue }
    if ($body.Length -lt 300 -or $body.Length -gt 2000) { continue }
    if ([int]$d.num_comments -lt 5) { continue }
    $st.basic++
    $blob = "$($d.title) `n $body"
    if (-not $inc.IsMatch($blob)) { continue }; $st.include++
    if ($exc.IsMatch($blob)) { continue }; $st.exclude++
    $row = [ordered]@{post_id=$d.id; subreddit=$Sub; created_utc=$ts; title=("" + $d.title).Trim(); text=$body; score=$d.score; num_comments=[int]$d.num_comments; flair=$d.link_flair_text}
    [void]$sb.AppendLine(($js.Serialize($row)))
  }
  if ($sb.Length) { [IO.File]::AppendAllText($rows, $sb.ToString(), $utf8) }
  $st.cursor = if ($max -gt $st.cursor) { $max } else { $st.cursor + 1 }
  # SAMPLING RULE: only days 1-7 (UTC) of each month are read; jump to the next month after day 7
  $dt = [DateTimeOffset]::FromUnixTimeSeconds($st.cursor).UtcDateTime
  if ($dt.Day -gt 7) { $nxt = (New-Object DateTime $dt.Year, $dt.Month, 1, 0, 0, 0, ([DateTimeKind]::Utc)).AddMonths(1); $st.cursor = ([DateTimeOffset]$nxt).ToUnixTimeSeconds() - 1 }
  [IO.File]::WriteAllText($cur, ($js.Serialize($st)), $utf8)
  Start-Sleep -Milliseconds 150
}
Write-Host "DONE $Sub : $($js.Serialize($st))"
