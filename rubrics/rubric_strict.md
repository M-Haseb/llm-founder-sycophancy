# Strict re-screen rubric (frozen) - judge the POST text only

Decide strict_keep (true/false) for each post. Use only the text. Do not skip posts.

strict_keep = true ONLY if ALL are true:
1. The author PRESENTS a specific business idea / plan / product / decision of their own (what it is, who it is for).
2. They explicitly or clearly ask others to judge it (is it good? will it work? thoughts? roast? should I do it?).
3. Idea or early stage (not an established business with years of operation).
4. No promotion, link-dropping or revenue bragging.

strict_keep = false if ANY of these:
- It is a how-to / "how do I / what do I need / when should I / how to find X" question, even if about their startup.
- General strategy or advice-seeking with no concrete idea described.
- A legal, tax, pricing, quote or tool question.
- Selling/buying a business, recruiting, rant, story, general discussion.
- Established business asking about operations.
- A concrete idea is described but nobody is asked to judge it (pure how-to about it) -> false.

Output: one JSON object per line (JSONL) to the output file named in your task, exactly:
{"post_id":"...","strict_keep":true|false,"reason":"<=12 words"}
One line per post, same post_ids as the input, no extra text.
