# Do LLMs Flatter Founders? Sycophancy in Business-Idea Feedback

Code, data and results for the paper **"Do LLMs Flatter Founders? Sycophancy in Business-Idea Feedback"**
(Muhammad Haseeb, University of Central Punjab, 2026). The study extends the social-sycophancy framework of ELEPHANT
(Cheng et al., ICLR 2026, [arXiv:2505.13995](https://arxiv.org/abs/2505.13995)) to feedback on business ideas.

> Status: draft manuscript v4. Numbers in `results/` are the ones reported in the paper.

## What was done

1. **Posts.** 440 Reddit posts asking for feedback on a business idea (r/Entrepreneur, r/startups, r/smallbusiness), 432 used in the analysis. The human reference label (supportive / mixed / critical) comes from the replies, labelled by the author.
2. **LLM answers.** 5 models answered each post (2,160 answers in the analysed set) through OpenRouter.
3. **Scoring.** A frozen rubric (`rubrics/rubric_v1_FROZEN.md`, SHA-256 recorded) was applied by a Claude Sonnet judge to all LLM answers and to 1,127 human replies, with blind batching.
4. **Validation.** 40 hand-labelled items and a second judge (GPT) check the three main measures (stance, validation, framing acceptance).
5. **Length control.** LLM answers are about 7x longer than human replies, so validation, framing and four exploratory measures were also re-scored on the first 80 words of 480 LLM answers (`data/length_control/`).

## Layout

| Folder | Content |
|---|---|
| `paper/` | Manuscript source (`paper.html`, tables and figures are generated in the page) and the PDF (12-page main text plus appendices A to F) |
| `rubrics/` | Judge rubric v0, frozen rubric v1 with hash, strict-subset rubric, labelling guide |
| `data/posts/` | The 440 posts with labels (`posts_440.jsonl`), post-level metadata, strict-subset flags, selection funnel |
| `data/llm_answers/` | Prompts and all raw LLM answers |
| `data/judge_scores/` | Judge scores for every LLM answer and every human reply (scores only) |
| `data/validation/` | Hand labels, second-judge replies, consensus labels used to validate the pipeline |
| `data/length_control/` | Flat tables and truncated-answer scores for the length analysis |
| `data/keys/` | Blind-batch keys (item id to post / model). Published after scoring was finished |
| `results/` | Analysis outputs: RQ1/RQ2 results, per-model confidence intervals, length robustness, logistic fits |
| `code/` | Data collection scripts (PowerShell, Arctic Shift API), answer collection (`api_cell.py`), analysis helpers |
| `notebooks/` | Colab notebooks used for phase 1 and for the API run |

## What is not included, and why

- **Human reply text.** Only reply *scores* are shared. Reddit replies belong to their authors.
- **Reddit post text** is included for reproducibility in `data/posts/posts_440.jsonl`. It stays the property of the original authors and is shared for research use only. Usernames were never collected into the analysis files. If you are an author of a post and want it removed, open an issue and it will be removed.
- Third-party papers (PDFs), API keys and the author's private thesis drafts.

## Reproducing the main numbers

Everything in `results/` was computed from `data/judge_scores/` and `data/length_control/` using a post-level cluster bootstrap (10,000 resamples, seed 20261113; 1,000 for the logistic fits). The scoring step itself needs an API key and is not re-runnable for free, but all raw model answers and scores are provided so that every table can be recomputed.

## Citation

```
Haseeb, M. (2026). Do LLMs Flatter Founders? Sycophancy in Business-Idea Feedback. Manuscript in preparation.
```

## License

Code: MIT. Own data (labels, judge scores, LLM answers, results): CC BY 4.0. Reddit text: see note above.
