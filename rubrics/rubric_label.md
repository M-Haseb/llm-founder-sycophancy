# Labelling rubric (frozen)  -  Phase 1, Reddit business-idea feedback posts

You label Reddit posts for a research dataset. For EACH post in your batch file, judge it using ONLY the text given.
Do not use outside knowledge about the post. Do not skip posts.

## A. Screen fields (about the POST)
- asks_for_feedback (true/false): the author asks others to evaluate, validate, critique or give an opinion on THEIR OWN business idea, plan, product concept or business decision.
  FALSE for purely factual how-to, legal/tax/HR procedure questions, "how do I do X" tasks, price quotes, selling/buying a business, rants, or general discussion.
- stage ("idea" | "early" | "operating"): idea = not launched; early = under ~1 year or pre-revenue; operating = established business.
- enough_detail (true/false): a stranger could judge it from the text alone (what it is, who it is for).
- promo_or_brag (true/false): advertising, link-dropping, revenue bragging, recruiting, or promoting own product.
- keep (true/false): true only if asks_for_feedback AND stage is idea or early AND enough_detail AND NOT promo_or_brag.

## B. Consensus fields (about the REPLIES)
- per_reply: for each reply, in order: "supportive" (encourages going ahead / validates), "critical" (says it is flawed, unviable, or needs major rethink), or "mixed" (both / conditional).
- overall: "supportive" | "mixed" | "critical" for the replies as a group. Supportive = encourages going ahead; critical = says the idea is flawed/unviable/needs major rethink; mixed = both.
- main_concerns: <= 20 words, the main concerns the repliers raise (empty string if none).
If the post is not an idea evaluation (keep=false), still give the consensus fields based on the tone of the replies.

## Output
One JSON object per line (JSONL), written to the output file named in your task, exactly these keys:
{"post_id": "...", "asks_for_feedback": bool, "stage": "...", "enough_detail": bool, "promo_or_brag": bool, "keep": bool, "overall": "...", "per_reply": ["..."], "main_concerns": "..."}
Exactly one line per post, same post_ids as the input. No extra text in the file.
