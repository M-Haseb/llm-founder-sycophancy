Add-Type -AssemblyName System.Web.Extensions
$js = New-Object System.Web.Script.Serialization.JavaScriptSerializer; $js.MaxJsonLength = [int]::MaxValue
$d="E:\Claude_Folder\Research_phd\data"; $utf8=New-Object Text.UTF8Encoding $false
function Csv($v){ '"' + (("" + $v) -replace '"','""') + '"' }
$kept=@(); foreach($l in [IO.File]::ReadLines("$d\kept_labelled_private.jsonl")){ $kept += $js.DeserializeObject($l) }
$alllab=@{}; foreach($l in [IO.File]::ReadLines("$d\all_labels.jsonl")){ $r=$js.DeserializeObject($l); $alllab[$r.post_id]=$r }
$pool=@{}; foreach($f in "pool_with_replies.jsonl","pool2_with_replies.jsonl"){ foreach($l in [IO.File]::ReadLines("$d\$f")){ $r=$js.DeserializeObject($l); $pool[$r.post_id]=$r } }
$quota=@{critical=149; mixed=150; supportive=141}   # critical: take all; mixed: 150; supportive: all (141)
$final=@(); $left=@()
foreach($lab in "critical","mixed","supportive"){ $g=@($kept | ? { $_.human_consensus -eq $lab } | Sort-Object { $_.post_id } | Get-Random -SetSeed 42 -Count $kept.Count)
  $final += $g[0..([Math]::Min($quota[$lab],$g.Count)-1)]; if($g.Count -gt $quota[$lab]){ $left += $g[$quota[$lab]..($g.Count-1)] } }
$final=@($final | Get-Random -SetSeed 42 -Count $final.Count)
$sb=New-Object Text.StringBuilder; $sbp=New-Object Text.StringBuilder; $sbs=New-Object Text.StringBuilder
[void]$sbs.AppendLine("post_id,subreddit,year,human_consensus,score,num_comments")
foreach($p in $final){ [void]$sb.AppendLine($js.Serialize($p)); [void]$sbp.AppendLine($js.Serialize(@{post_id=$p.post_id; prompt=($p.title + "`n`n" + $p.text)}))
  [void]$sbs.AppendLine("$($p.post_id),$($p.subreddit),$($p.year),$($p.human_consensus),$($p.score),$($p.num_comments)") }
[IO.File]::WriteAllText("$d\phase1_final_private.jsonl",$sb.ToString(),$utf8); [IO.File]::WriteAllText("$d\phase1_prompts.jsonl",$sbp.ToString(),$utf8); [IO.File]::WriteAllText("$d\phase1_share_safe.csv",$sbs.ToString(),$utf8)
"FINAL: $($final.Count) = " + (($final | Group-Object human_consensus | % { "$($_.Name)=$($_.Count)" }) -join ", ")
"by subreddit: " + (($final | Group-Object subreddit | % { "$($_.Name)=$($_.Count)" }) -join ", ")
# development set: 40 kept posts NOT in final (never analysed)
$dev=@($left | Get-Random -SetSeed 7 -Count ([Math]::Min(40,$left.Count)))
$sbd=New-Object Text.StringBuilder; foreach($p in $dev){ [void]$sbd.AppendLine($js.Serialize($p)) }; [IO.File]::WriteAllText("$d\dev_set_private.jsonl",$sbd.ToString(),$utf8); "dev set: $($dev.Count) (not in final)"
# hand-check 1: consensus labels, 50 from final
$vc=@($final | Get-Random -SetSeed 2 -Count 50); $o=New-Object Text.StringBuilder; [void]$o.AppendLine("post_id,title,post_text,replies_text,llm_label,my_label")
foreach($p in $vc){ $rt=(($p.replies | % { $_.text }) -join "`n---`n"); [void]$o.AppendLine((@((Csv $p.post_id),(Csv $p.title),(Csv $p.text),(Csv $rt),(Csv $p.human_consensus),'""') -join ",")) }
[IO.File]::WriteAllText("$d\validation_consensus.csv",$o.ToString(),$utf8)
# hand-check 2: post screen, 25 kept + 25 dropped (from all labelled)
$ids=@($alllab.Keys); $k=@($ids | ? { $alllab[$_].keep } | Get-Random -SetSeed 3 -Count 25); $dr=@($ids | ? { -not $alllab[$_].keep } | Get-Random -SetSeed 4 -Count 25)
$vp=@($k + $dr | Get-Random -SetSeed 5 -Count 50); $o=New-Object Text.StringBuilder; [void]$o.AppendLine("post_id,title,post_text,llm_label,my_label")
foreach($id in $vp){ $p=$pool[$id]; $ll= if($alllab[$id].keep){"keep"}else{"drop"}; [void]$o.AppendLine((@((Csv $id),(Csv $p.title),(Csv $p.text),(Csv $ll),'""') -join ",")) }
[IO.File]::WriteAllText("$d\validation_post_filter.csv",$o.ToString(),$utf8); "validation files written"
