# ---- Data source: Arctic Shift API (no torrent / no huge files needed) -------------------------------------------
SOURCE = os.environ.get("P1_SOURCE", "api")      # "api" = fetch only what we need;  "dump" = use .zst files from Drive
API = "https://arctic-shift.photon-reddit.com/api"
POST_FIELDS = "id,title,selftext,created_utc,over_18,num_comments,score,link_flair_text,author"

def api_get(path, params, retries=8):
    import requests
    for i in range(retries):
        try:
            r = requests.get(f"{API}/{path}", params=params, timeout=90)
            if r.status_code == 200:
                js = r.json()
                if js.get("data") is None: raise RuntimeError(js.get("error"))
                if int(r.headers.get("x-ratelimit-remaining", 99)) <= 2:
                    time.sleep(int(r.headers.get("x-ratelimit-reset", 5)) + 1)
                return js["data"]
            wait = int(r.headers.get("x-ratelimit-reset", 2 ** i)) + 1 if r.status_code == 429 else 2 ** i
            print(f"  API status {r.status_code}, retry in {wait}s"); time.sleep(min(wait, 120))
        except Exception as e:
            wait = 2 ** i; print(f"  API error ({type(e).__name__}: {str(e)[:100]}), retry in {wait}s"); time.sleep(min(wait, 120))
    raise RuntimeError("API failed after retries: " + path)

def api_posts(sub):
    """Walk the subreddit oldest->newest in pages of 100; keep only posts passing the basic filters. Resumable."""
    rows_f, cur_f = OUT_DIR / f"api_posts_{sub}.jsonl", OUT_DIR / f"api_posts_{sub}.cursor"
    cur = int(cur_f.read_text()) if cur_f.exists() else START_TS - 1
    seen = kept = 0
    with open(rows_f, "a") as f:
        pbar = tqdm(desc=f"API posts r/{sub}", unit=" pages")
        while cur < END_TS:
            data = api_get("posts/search", {"subreddit": sub, "after": cur, "before": END_TS, "limit": 100, "sort": "asc", "fields": POST_FIELDS})
            if not data: break
            for d in data:
                seen += 1
                body = (d.get("selftext") or "").strip()
                if d.get("over_18") or body in BAD_TEXT: continue
                if (d.get("author") or "").lower() in BAD_AUTHORS: continue
                if not (MIN_CHARS <= len(body) <= MAX_CHARS): continue
                if int(d.get("num_comments") or 0) < MIN_COMMENTS_ON_POST: continue
                f.write(json.dumps({"post_id": d["id"], "subreddit": sub, "created_utc": int(d["created_utc"]), "title": (d.get("title") or "").strip(),
                                    "text": body, "score": d.get("score"), "num_comments": int(d.get("num_comments") or 0), "flair": d.get("link_flair_text")}) + "\n"); kept += 1
            f.flush()
            new = max(int(d["created_utc"]) for d in data)
            cur = new if new > cur else cur + 1
            cur_f.write_text(str(cur)); pbar.update(1); pbar.set_postfix(date=datetime.fromtimestamp(cur, timezone.utc).strftime("%Y-%m"))
            time.sleep(0.2)
    out = pd.read_json(rows_f, lines=True) if rows_f.exists() and rows_f.stat().st_size else pd.DataFrame()
    print(f"r/{sub}: kept {len(out):,} posts after basic filters (this session scanned {seen:,})")
    return out.drop_duplicates("post_id").to_dict("records") if len(out) else []

def api_comments(sub, ids):
    """For each candidate post, fetch its comments and keep good top-level replies. Resumable."""
    cache = OUT_DIR / f"api_comments_{sub}.jsonl"; done = set()
    if cache.exists():
        for ln in cache.read_text().splitlines():
            if ln.strip(): done.add(json.loads(ln)["post_id"])
    todo = [i for i in sorted(ids) if i not in done]
    print(f"r/{sub}: {len(done)} posts already fetched, {len(todo)} to do")
    def work(pid):
        data, before = [], None
        for _ in range(6):          # up to 600 comments per post
            q = {"link_id": pid, "limit": 100, "sort": "desc", "fields": "id,parent_id,link_id,body,score,author,created_utc"}
            if before: q["before"] = before
            pg = api_get("comments/search", q); data += pg
            if len(pg) < 100: break
            before = min(int(x["created_utc"]) for x in pg)
        good = []
        for d in data:
            body = (d.get("body") or "").strip()
            if d.get("parent_id") != "t3_" + pid or body in BAD_TEXT or (d.get("author") or "").lower() in BAD_AUTHORS: continue
            if "i am a bot" in body.lower(): continue
            try: score = int(d.get("score") or 0)
            except Exception: continue
            if score < MIN_COMMENT_SCORE or len(body.split()) < MIN_COMMENT_WORDS: continue
            good.append({"post_id": pid, "comment_id": d["id"], "comment": body, "c_score": score})
        return {"post_id": pid, "n_api": len(data), "good": good}
    with open(cache, "a") as f, ThreadPoolExecutor(3) as ex:
        futs = [ex.submit(work, p) for p in todo]
        for fu in tqdm(as_completed(futs), total=len(futs), desc=f"API comments r/{sub}"):
            try: f.write(json.dumps(fu.result()) + "\n"); f.flush()
            except Exception as e: print("failed", e)
    rows = []
    for ln in cache.read_text().splitlines():
        if ln.strip(): rows += json.loads(ln)["good"]
    return rows
print("API helpers ready. SOURCE =", SOURCE)
