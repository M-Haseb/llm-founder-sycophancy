Add-Type -AssemblyName System.Web.Extensions
$js = New-Object System.Web.Script.Serialization.JavaScriptSerializer; $js.MaxJsonLength = [int]::MaxValue
$utf8 = New-Object Text.UTF8Encoding $false; $d = "E:\Claude_Folder\Research_phd\data"
$seen=@{}; $titles=@{}; $rows=New-Object System.Collections.ArrayList; $n0=0; $nday=0; $ndup=0; $ntit=0
foreach($f in Get-ChildItem "$d\posts_*.jsonl"){ foreach($l in [IO.File]::ReadLines($f.FullName)){ if(-not $l.Trim()){continue}; $n0++
  $r=$js.DeserializeObject($l); $dt=[DateTimeOffset]::FromUnixTimeSeconds([long]$r.created_utc).UtcDateTime
  if($dt.Day -gt 7){$nday++;continue}; if($seen.ContainsKey($r.post_id)){$ndup++;continue}; $seen[$r.post_id]=1
  $r.year=$dt.Year; [void]$rows.Add($r) } }
$out=New-Object System.Collections.ArrayList
foreach($r in ($rows | Sort-Object { [long]$_.created_utc })){ $k=$r.title.ToLower().Trim(); if($titles.ContainsKey($k)){$ntit++;continue}; $titles[$k]=1; [void]$out.Add($r) }
$sb=New-Object Text.StringBuilder; foreach($r in $out){ [void]$sb.AppendLine($js.Serialize($r)) }
[IO.File]::WriteAllText("$d\candidates.jsonl",$sb.ToString(),$utf8)
"read=$n0 dropped_outside_day1-7=$nday dup_ids=$ndup dup_titles=$ntit candidates=$($out.Count)"
$out | Group-Object { $_.subreddit + " " + $_.year } | Sort Name | % { "$($_.Name): $($_.Count)" }
