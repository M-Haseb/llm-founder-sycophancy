# Length-confound analysis (reviewer issue 4), 2026-11-14
Word counts: human replies median 79 (mean 113, p10 36, p90 227); LLM answers median 476 (Llama) to 694 (luna); LLM p10 ~360 words > human p90, so there is almost NO length overlap.
Within-human validation rate rises with length (15% <60w, 21% 60-120, 28% 120-250, 32% 250+); within-LLM validation is flat (55-70%) across 360-1,200 words (slope 0.14 [-0.19,0.45]).
View A raw full answers (432 posts), View B logistic adjusted for log(words) (AME pp, cluster bootstrap 1000, extrapolates across non-overlapping lengths), View C matched length: first 80 words of 480 LLM answers (96 random posts, 5 models) re-scored blind by same Sonnet rubric vs the 253 human replies on those posts (10k bootstrap over posts).
| measure | A raw | B adjusted AME [CI] | C matched 80w [CI] |
| validation | +42.4 | +29.3 [21.4,36.9] | +35.4 [28.0,42.6] |
| indirectness | -18.4 | +9.9 [3.1,15.7] | +10.2 [2.5,18.3] |
| framing | +0.7 | +37.5 [30.0,44.3] | +12.8 [5.1,20.6] |
| risk flagging | +21.7 | -7.2 [-10.4,-3.4] | -4.1 [-12.7,4.3] |
| evidence request | +35.2 | +9.8 [1.0,18.7] | -2.6 [-8.0,2.5] |
| premise challenge | +7.1 | -31.7 [-40.0,-23.3] | -16.0 [-23.3,-8.9] |
Rates in the 96-post sample: human vs LLM first-80w vs same answers full: validation 20.2/56.3/61.3; indirectness 43.9/54.0/29.8; framing 66.4/79.2/69.4; risk 63.6/58.5/84.4; evidence 10.3/8.5/47.7; premise 27.7/12.3/35.0.
Supportive stance on the 36 critical posts in the sample: 44/180 (24.4%) truncated vs 36/180 (20.0%) full.
Conclusion: validation gap survives length control (direction and size); risk/evidence/premise differences are length-dependent; indirectness and framing change sign or size. Caveat: first 80 words front-load greetings and praise (upper bound for validation, lower bound for risk/evidence); truncated scoring not hand-validated.
Per-model CIs: analysis_per_model_diffs_CI.csv (full) and trunc\analysis_trunc_diffs_CI.csv. Logistic output: analysis_length_logistic.txt.
