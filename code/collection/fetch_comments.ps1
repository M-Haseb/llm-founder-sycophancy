param([string]$IdFile, [string]$OutFile)
Add-Type -AssemblyName System.Web.Extensions
$js = New-Object System.Web.Script.Serialization.JavaScriptSerializer; $js.MaxJsonLength = [int]::MaxValue
$utf8 = New-Object Text.UTF8Encoding $false
$done = @{}; if (Test-Path $OutFile) { foreach($l in [IO.File]::ReadLines($OutFile)){ if($l.Trim()){ $done[($js.DeserializeObject($l)).post_id] = 1 } } }
$bad = @("","[removed]","[deleted]"); $badAuth = @("[deleted]","automoderator","none")
function Get-Json($url){ for($i=0;$i -lt 8;$i++){ try{ $wc=New-Object Net.WebClient; $wc.Encoding=[Text.Encoding]::UTF8; return $js.DeserializeObject($wc.DownloadString($url)).data } catch { Start-Sleep ([Math]::Min(60,[Math]::Pow(2,$i)+1)) } }; throw "fail $url" }
$n=0
foreach ($postid in [IO.File]::ReadLines($IdFile)) {
  $postid = $postid.Trim(); if (-not $postid -or $done.ContainsKey($postid)) { continue }
  $all=@(); $before=$null
  for($k=0;$k -lt 6;$k++){
    $u="https://arctic-shift.photon-reddit.com/api/comments/search?link_id=$postid&limit=100&sort=desc&fields=id,parent_id,body,score,author,created_utc"; if($before){$u+="&before=$before"}
    $pg = Get-Json $u; $all += $pg; if($pg.Count -lt 100){break}; $before = ($pg | % { [long]$_.created_utc } | Measure-Object -Minimum).Minimum
  }
  $good=@()
  foreach($d in $all){
    $body=("" + $d.body).Trim()
    if($d.parent_id -ne "t3_$postid" -or $bad -contains $body -or $badAuth -contains ("" + $d.author).ToLower()){continue}
    if($body.ToLower().Contains("i am a bot")){continue}
    if([int]$d.score -lt 2 -or $body.Split(@(' ',"`n","`t"),[StringSplitOptions]::RemoveEmptyEntries).Count -lt 30){continue}
    $good += [ordered]@{comment_id=$d.id; comment=$body; c_score=[int]$d.score}
  }
  $rec=[ordered]@{post_id=$postid; n_api=$all.Count; good=$good}
  [IO.File]::AppendAllText($OutFile, $js.Serialize($rec) + "`n", $utf8); $n++
  Start-Sleep -Milliseconds 100
}
Write-Host "DONE $IdFile ($n new)"
