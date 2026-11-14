# Appendix tables C, D, E (computed 2026-11-14 from data/length_control/length_flat.csv and data/judge_scores/llm_answer_scores.csv)

## C. Validation rate by length band (words)
Human: <40 n=150 15.3%; 40-79 n=415 17.3%; 80-119 n=236 20.3%; 120-199 n=188 24.5%; 200-299 n=77 35.1%; 300-449 n=36 36.1%; 450+ n=25 (not shown)
LLM: 200-299 n=34 41.2%; 300-449 n=371 57.1%; 450-599 n=736 66.4%; 600-799 n=658 70.2%; 800-999 n=226 62.8%; 1000-1499 n=118 44.9%; 1500+ n=5; <200 n=12 (not shown)

## D. Stance by model and human-consensus class (% supportive / mixed / critical; n = 146 critical, 148 mixed, 138 supportive posts)
luna        12/75/13  24/73/3  35/64/0
DeepSeek    13/58/29  26/65/9  54/45/1
Haiku       15/76/9   29/69/2  49/51/0
Gemini-lite 27/51/22  51/41/7  76/21/3
Llama       40/58/2   54/44/2  63/35/2

## E. Strict subset (172 of 432 analysed posts: 52 critical, 65 mixed, 55 supportive; 174 of the original 440), LLM minus human, pp [95% CI], 2,000 post-level bootstrap resamples, seed 20261113
validation +40.9 [35.8, 45.7]; framing +1.9 [-4.8, 8.4]; indirectness -25.1 [-31.1, -19.2]; risk +24.3 [18.7, 29.8]; evidence +47.6 [42.3, 53.0]; premise +14.2 [7.3, 20.5]
