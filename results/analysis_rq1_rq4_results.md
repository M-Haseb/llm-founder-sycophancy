# RQ1 / RQ4 results (Sonnet judge, frozen rubric v1; per-post LLM-minus-human differences; 10,000 bootstrap resamples of 432 posts; seed 20261113)
Human replies: 1,127 on 432 posts (mean 2.6 per post). LLM: 5 models x 432 posts. "Pooled" = mean of the 5 models, each post weighted equally.
Calibration check: 100 LLM answers mixed in with human replies and re-scored vs first run: agreement 85-98%, kappa 0.62-0.84 (stance 0.78).

| Measure | Human | LLM (avg 5) | Pooled difference, pp [95% CI] | Range across models (pp) |
|---|---|---|---|---|
| validation | 21.3% | 63.7% | +42.4 [+39.1, +45.7] | luna +9.3 ... gemini-lite/llama +58.6 |
| indirectness (suggestive language) | 47.1% | 28.7% | -18.4 [-22.1, -14.9] | llama +40.4 ... deepseek -40.9 |
| framing acceptance | 70.7% | 71.3% | +0.7 [-3.1, +4.4] | llama +26.8 ... deepseek -19.5 |
| risk flagging (RQ4) | 63.4% | 85.1% | +21.7 [+18.1, +25.3] | llama -10.6 ... deepseek +33.4 |
| evidence request (RQ4) | 12.8% | 48.0% | +35.2 [+31.8, +38.7] | gemini/llama +19 ... luna +53.2 |
| premise challenge (RQ4) | 26.8% | 33.9% | +7.1 [+3.4, +10.8] | llama -21.3 ... luna +24.3 |
| supportive stance | 29.7% | 37.4% | +7.7 [+4.1, +11.3] | luna -6.6 ... llama +22.4 |
| critical stance | 23.5% | 7.2% | -16.3 [-19.5, -13.2] | all models below humans |

Hypotheses: H1 supported for validation, NOT for framing acceptance (no pooled difference) and indirectness is LOWER for LLMs (except Llama). H4 (two-sided): LLMs flag more risks and ask for much more evidence than humans, but challenge the core premise only slightly more.
RQ2 (primary): false-affirmation on 146 critical-consensus posts 21% pooled (12-40% by model); human replies are 0% supportive on those posts by construction.
Caveats: LLM judge not hand-validated on human replies (optional check skipped by user); human replies are short (length confound); judge-human kappa checked on 40 LLM answers only for stance/validation/framing.
