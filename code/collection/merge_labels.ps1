Add-Type -AssemblyName System.Web.Extensions
$js = New-Object System.Web.Script.Serialization.JavaScriptSerializer; $js.MaxJsonLength = [int]::MaxValue
$d="E:\Claude_Folder\Research_phd\data"; $utf8=New-Object Text.UTF8Encoding $false
$pool=@{}; $order=@(); foreach($l in [IO.File]::ReadLines("$d\pool_with_replies.jsonl")){ $r=$js.DeserializeObject($l); $pool[$r.post_id]=$r; $order+=$r.post_id }
$lab=@{}; $bad=0; $dups=0; $valid_ov=@("supportive","mixed","critical"); $valid_st=@("idea","early","operating")
foreach($f in Get-ChildItem "$d\labels\labels_*.jsonl"){ foreach($l in [IO.File]::ReadLines($f.FullName)){ if(-not $l.Trim()){continue}
  try{ $r=$js.DeserializeObject($l) }catch{ $bad++; continue }
  if(-not $pool.ContainsKey($r.post_id) -or $valid_ov -notcontains $r.overall -or $valid_st -notcontains $r.stage){ $bad++; continue }
  if($lab.ContainsKey($r.post_id)){$dups++}; $lab[$r.post_id]=$r } }
$missing=@($order | ? { -not $lab.ContainsKey($_) })
"pool=$($pool.Count) labelled=$($lab.Count) missing=$($missing.Count) invalid=$bad dups=$dups"
$mism=0; foreach($id in $lab.Keys){ if($lab[$id].per_reply.Count -ne $pool[$id].replies.Count){$mism++} }; "per_reply length mismatch: $mism"
$keepOk=0; foreach($id in $lab.Keys){ $r=$lab[$id]; $exp=($r.asks_for_feedback -and $r.stage -ne "operating" -and $r.enough_detail -and -not $r.promo_or_brag); if([bool]$r.keep -ne [bool]$exp){$keepOk++} }; "keep flag inconsistent with its own fields: $keepOk"
$keep=@($order | ? { $lab.ContainsKey($_) -and $lab[$_].keep })
"keep=true: $($keep.Count)"
"overall among kept: " + (($keep | Group-Object { $lab[$_].overall } | % { "$($_.Name)=$($_.Count)" }) -join ", ")
"overall among all: " + (($lab.Values | Group-Object overall | % { "$($_.Name)=$($_.Count)" }) -join ", ")
"kept by subreddit: " + (($keep | Group-Object { $pool[$_].subreddit } | % { "$($_.Name)=$($_.Count)" }) -join ", ")
"kept by year: " + (($keep | Group-Object { $pool[$_].year } | Sort Name | % { "$($_.Name)=$($_.Count)" }) -join ", ")
$sb=New-Object Text.StringBuilder; foreach($id in $keep){ $p=$pool[$id]; $r=$lab[$id]; $p.human_consensus=$r.overall; $p.per_reply=$r.per_reply; $p.main_concerns=$r.main_concerns; $p.stage=$r.stage; [void]$sb.AppendLine($js.Serialize($p)) }
[IO.File]::WriteAllText("$d\kept_labelled_private.jsonl",$sb.ToString(),$utf8)
$sb2=New-Object Text.StringBuilder; foreach($id in $order){ if($lab.ContainsKey($id)){ [void]$sb2.AppendLine($js.Serialize($lab[$id])) } }
[IO.File]::WriteAllText("$d\all_labels.jsonl",$sb2.ToString(),$utf8)
if($missing.Count){ "missing ids: " + ($missing -join ",") }
