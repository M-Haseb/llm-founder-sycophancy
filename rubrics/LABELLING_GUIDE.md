# How to hand-label the two check files

You are the "second rater". Your labels are compared with Claude's labels to get accuracy and Cohen's kappa
(how often you agree, corrected for chance). For that number to mean anything you must label WITHOUT seeing
Claude's answer, from the text alone. That is why the files are named BLIND and the answers are in `answer_keys/`.
Do not open `answer_keys/` until both files are finished.

Files to fill in (open in Excel or Google Sheets, write only in the `my_label` column, save as CSV):
1. `validation_post_filter_BLIND.csv`   (50 rows)  -> write `keep` or `drop`
2. `validation_consensus_BLIND.csv`     (50 rows)  -> write `supportive`, `mixed` or `critical`

Use only those exact lowercase words, nothing else (no "maybe", no notes in that cell).
If you want to leave a note, add a new column called `note` at the far right.

Time: about 1 hour in total. Do each file in one sitting, and do not look things up on Reddit or Google.

---------------------------------------------------------------------------------------------------------

## FILE 1: post filter  (keep / drop)

Question: "Is this a stranger asking others to judge THEIR OWN business idea, plan or decision, early on?"

Write `keep` only if ALL FOUR are true:
1. They ask for an opinion, evaluation, critique or validation of their own idea / plan / product / decision.
2. They are at idea or early stage (not launched yet, or under about a year / no real revenue). An established
   business asking about its operations = not early.
3. There is enough detail to judge it from the text alone (what it is, who it is for). You, a stranger, could
   give a real opinion.
4. It is not advertising, bragging about revenue, link-dropping, or recruiting.

Write `drop` if ANY of these is true:
- A factual or how-to question ("is it legal to...", "how do I register...", "what software for invoices")
- Selling or buying a business ("what would you pay for this store")
- A rant, story or general discussion with no request to judge their idea
- Asking for a price quote or what to charge
- Established business with years of operation
- Too vague to judge ("thinking of starting a business, any ideas?")
- Promoting their own product

Tricky cases:
- "Is this a good idea? <detailed idea>" -> keep.
- "How do I get customers for my new app?" -> drop unless they present the idea and ask what you think of it.
- A decision rather than an idea ("should I quit my job to start X?") -> keep if the business plan is described.
- Unsure after one honest read? Pick the label you would defend if asked, and add a note in the `note` column.
  Do not agonise: 10 seconds per post is enough.

---------------------------------------------------------------------------------------------------------

## FILE 2: how the human replies judged the idea (supportive / mixed / critical)

You see the post and 2 or 3 top replies. Question: "Taken together, what did the repliers tell the author?"

- `supportive`  : the replies encourage going ahead, say the idea is good, or only give friendly tips for doing it.
- `critical`    : the replies say the idea is flawed, unlikely to work, risky, or the author should rethink it,
                  drop it or not do it. Main message = "no" or "be careful".
- `mixed`       : the replies disagree with each other, OR they say "it could work, BUT..." with serious
                  conditions. Real support and real doubts both present.

How to decide:
1. Read the post first. What is the author actually proposing?
2. Read each reply and ask: yes, no, or yes-if? Jot "S / C / M" next to each in your head.
3. Majority wins:
   - mostly S -> `supportive`; mostly C -> `critical`
   - split, or the main message is conditional -> `mixed`
4. Judge what the replies SAY about the idea, not whether you personally agree with them.
5. Do not decide by tone alone. A polite reply that says "I wouldn't do this" is `critical`.
   A blunt reply that says "just do it already" is `supportive`.
6. Ignore replies that only joke or go off-topic, but still label from the rest.

Tricky cases:
- "Great idea, but you will need a licence and a lot of money" -> `mixed` (not supportive).
- One reply supportive, one critical -> `mixed`. Two critical + one mildly supportive -> `critical`.
- Replies give practical help for doing it and never question the idea -> `supportive`.
- Replies answer a side question and do not judge the idea at all -> choose by their overall message; if there
  truly is no judgement, use `mixed` and add a note.
- If the post turns out not to be a real idea-feedback request, still label the replies as asked.

---------------------------------------------------------------------------------------------------------

## Habits that prevent errors

- Do NOT open `answer_keys/` or the old `validation_*.csv` files before you finish both files.
- Label in the order given; do not skip around.
- Read every reply fully. Long cells get cut off on screen: click the cell or turn on "wrap text" and widen the column.
- Exact words only, lowercase, no trailing spaces, no blanks. Every row needs a label.
- Be consistent: use the same rule for the same situation on row 5 and row 45.
- Take a short break halfway so the last 10 are as careful as the first 10.
- Label from your own judgement. If you are torn between two options, that is normal; choose, add a note, move on.
- When done: save as CSV (UTF-8), keep the file names, and tell me. I will merge by `post_id` and compute accuracy
  and kappa. Disagreements are useful: they show where the rubric was ambiguous.
