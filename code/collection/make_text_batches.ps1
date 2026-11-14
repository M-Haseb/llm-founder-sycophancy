# Writes plain-text batches (hard-wrapped lines, no truncation by file viewers) for new pool2 posts + a re-label of old batches 29 and 37
Add-Type -AssemblyName System.Web.Extensions
$js = New-Object System.Web.Script.Serialization.JavaScriptSerializer; $js.MaxJsonLength = [int]::MaxValue
$d="E:\Claude_Folder\Research_phd\data"; $utf8=New-Object Text.UTF8Encoding $false; New-Item -ItemType Directory -Force "$d\batches2","$d\labels2" | Out-Null
function Wrap($s){ $o=New-Object Text.StringBuilder; foreach($ln in ($s -split "`r?`n")){ while($ln.Length -gt 400){ $cut=$ln.LastIndexOf(' ',400); if($cut -lt 100){$cut=400}; [void]$o.AppendLine($ln.Substring(0,$cut)); $ln=$ln.Substring($cut).TrimStart() }; [void]$o.AppendLine($ln) }; $o.ToString() }
$posts=@(); foreach($l in [IO.File]::ReadLines("$d\pool2_with_replies.jsonl")){ $posts += $js.DeserializeObject($l) }
$pool=@{}; foreach($l in [IO.File]::ReadLines("$d\pool_with_replies.jsonl")){ $r=$js.DeserializeObject($l); $pool[$r.post_id]=$r }
foreach($b in "29","37"){ foreach($p in $js.DeserializeObject((Get-Content "$d\batches\batch_$b.json" -Raw -Encoding UTF8))){ $posts += $pool[$p.post_id] } }
$n=0; for($i=0;$i -lt $posts.Count;$i+=30){ $sb=New-Object Text.StringBuilder
  foreach($p in $posts[$i..([Math]::Min($i+29,$posts.Count-1))]){ [void]$sb.AppendLine("=================== POST_ID: $($p.post_id) ==================="); [void]$sb.AppendLine("TITLE: $($p.title)"); [void]$sb.AppendLine("POST TEXT:"); [void]$sb.Append((Wrap $p.text)); $k=1; foreach($r in $p.replies){ [void]$sb.AppendLine("--- REPLY $k (of $($p.replies.Count)) ---"); [void]$sb.Append((Wrap $r.text)); $k++ } }
  [IO.File]::WriteAllText(("$d\batches2\tbatch_{0:D2}.txt" -f $n), $sb.ToString(), $utf8); $n++ }
"posts=$($posts.Count) text batches=$n"
