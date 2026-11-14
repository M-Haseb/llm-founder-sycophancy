Add-Type -AssemblyName System.Web.Extensions
$js=New-Object System.Web.Script.Serialization.JavaScriptSerializer;$js.MaxJsonLength=[int]::MaxValue
$d="E:\Claude_Folder\Research_phd\data";$utf8=New-Object Text.UTF8Encoding $false
function Wrap($s){$o=New-Object Text.StringBuilder;foreach($ln in ($s -split "`r?`n")){while($ln.Length -gt 400){$cut=$ln.LastIndexOf(' ',400);if($cut -lt 100){$cut=400};[void]$o.AppendLine($ln.Substring(0,$cut));$ln=$ln.Substring($cut).TrimStart()};[void]$o.AppendLine($ln)};$o.ToString()}
$posts=@();foreach($l in [IO.File]::ReadLines("$d\phase1_final_private.jsonl")){$posts+=$js.DeserializeObject($l)}
$n=0;for($i=0;$i -lt $posts.Count;$i+=50){$sb=New-Object Text.StringBuilder
 foreach($p in $posts[$i..([Math]::Min($i+49,$posts.Count-1))]){[void]$sb.AppendLine("=================== POST_ID: $($p.post_id) ===================");[void]$sb.AppendLine("TITLE: $($p.title)");[void]$sb.AppendLine("POST TEXT:");[void]$sb.Append((Wrap $p.text))}
 [IO.File]::WriteAllText(("$d\strict\batches\sb_{0:D2}.txt" -f $n),$sb.ToString(),$utf8);$n++}
"posts=$($posts.Count) batches=$n"
