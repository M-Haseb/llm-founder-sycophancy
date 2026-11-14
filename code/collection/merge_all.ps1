Add-Type -AssemblyName System.Web.Extensions
$js = New-Object System.Web.Script.Serialization.JavaScriptSerializer; $js.MaxJsonLength = [int]::MaxValue
$d="E:\Claude_Folder\Research_phd\data"; $utf8=New-Object Text.UTF8Encoding $false
$pool=@{}; $order=@()
foreach($f in "pool_with_replies.jsonl","pool2_with_replies.jsonl"){ foreach($l in [IO.File]::ReadLines("$d\$f")){ $r=$js.DeserializeObject($l); if(-not $pool.ContainsKey($r.post_id)){ $order+=$r.post_id }; $pool[$r.post_id]=$r } }
$valid_ov=@("supportive","mixed","critical"); $valid_st=@("idea","early","operating"); $lab=@{}; $bad=0; $over=0
function Load($glob){ foreach($f in Get-ChildItem $glob){ foreach($l in [IO.File]::ReadLines($f.FullName)){ if(-not $l.Trim()){continue}
  try{ $r=$js.DeserializeObject($l) }catch{ $script:bad++; continue }
  if(-not $pool.ContainsKey($r.post_id) -or $valid_ov -notcontains $r.overall -or $valid_st -notcontains $r.stage){ $script:bad++; continue }
  if($script:lab.ContainsKey($r.post_id)){ $script:over++ }; $script:lab[$r.post_id]=$r } } }
Load "$d\labels\labels_*.jsonl"; Load "$d\labels2\labels2_*.jsonl"
$missing=@($order | ? { -not $lab.ContainsKey($_) })
"pool=$($pool.Count) labelled=$($lab.Count) missing=$($missing.Count) invalid=$bad overwritten_by_relabel=$over"
$mism=@($lab.Keys | ? { $lab[$_].per_reply.Count -ne $pool[$_].replies.Count }).Count; "per_reply length mismatch: $mism"
$keep=@($order | ? { $lab.ContainsKey($_) -and $lab[$_].keep })
"keep=true: $($keep.Count)"
"kept by overall: " + (($keep | Group-Object { $lab[$_].overall } | % { "$($_.Name)=$($_.Count)" }) -join ", ")
"all by overall: " + (($order | ? { $lab.ContainsKey($_) } | Group-Object { $lab[$_].overall } | % { "$($_.Name)=$($_.Count)" }) -join ", ")
"kept by subreddit: " + (($keep | Group-Object { $pool[$_].subreddit } | % { "$($_.Name)=$($_.Count)" }) -join ", ")
"kept by year: " + (($keep | Group-Object { $pool[$_].year } | Sort Name | % { "$($_.Name)=$($_.Count)" }) -join ", ")
$sb=New-Object Text.StringBuilder; foreach($id in $keep){ $p=$pool[$id]; $r=$lab[$id]; $p.human_consensus=$r.overall; $p.per_reply=$r.per_reply; $p.main_concerns=$r.main_concerns; $p.stage=$r.stage; [void]$sb.AppendLine($js.Serialize($p)) }
[IO.File]::WriteAllText("$d\kept_labelled_private.jsonl",$sb.ToString(),$utf8)
$sb2=New-Object Text.StringBuilder; foreach($id in $order){ if($lab.ContainsKey($id)){ [void]$sb2.AppendLine($js.Serialize($lab[$id])) } }
[IO.File]::WriteAllText("$d\all_labels.jsonl",$sb2.ToString(),$utf8)
if($missing.Count){ "missing ids: " + ($missing -join ",") }
