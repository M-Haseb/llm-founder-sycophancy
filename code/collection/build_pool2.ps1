Add-Type -AssemblyName System.Web.Extensions
$js = New-Object System.Web.Script.Serialization.JavaScriptSerializer; $js.MaxJsonLength = [int]::MaxValue
$utf8 = New-Object Text.UTF8Encoding $false; $d = "E:\Claude_Folder\Research_phd\data"
$posts=@{}; foreach($l in [IO.File]::ReadLines("$d\candidates.jsonl")){ $r=$js.DeserializeObject($l); $posts[$r.post_id]=$r }
$fetched=0; $with2=0; $sb=New-Object Text.StringBuilder; $yr=@{}; $sub=@{}
foreach($f in Get-ChildItem "$d\comments2_*.jsonl"){ foreach($l in [IO.File]::ReadLines($f.FullName)){ if(-not $l.Trim()){continue}; $c=$js.DeserializeObject($l); $fetched++
  $good=@($c.good | Sort-Object { -[int]$_.c_score } | Select-Object -First 3); if($good.Count -lt 2){continue}; $with2++
  $p=$posts[$c.post_id]; $p.replies=@($good | % { @{comment_id=$_.comment_id; score=$_.c_score; text=$_.comment} })
  [void]$sb.AppendLine($js.Serialize($p)); $yr["$($p.year)"]++; $sub[$p.subreddit]++ } }
[IO.File]::WriteAllText("$d\pool2_with_replies.jsonl",$sb.ToString(),$utf8)
"candidates_total=$($posts.Count) comments_fetched_for=$fetched posts_with_>=2_good_replies=$with2"
"by subreddit: " + (($sub.GetEnumerator() | Sort Name | % { "$($_.Name)=$($_.Value)" }) -join ", ")
"by year: " + (($yr.GetEnumerator() | Sort Name | % { "$($_.Name)=$($_.Value)" }) -join ", ")
