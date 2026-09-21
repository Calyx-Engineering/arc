# Camp's operating agreement — fixture

> A minimal agreement, carrying only what `tools/response-length.py` reads. The surrounding
> sections are omitted deliberately: a parser that needs the whole file to find one clause
> would break on the first repository that deleted a section it does not use.

## 1 Settings

### Report verbosity — completed actions

- [ ] **loud** — the machinery
- [x] **normal** — the outcome only
- [ ] **quiet** — silence unless something is wrong

### Response verbosity — the session's own replies

- [x] **brief** — the answer and nothing after it. **40 words** of prose
- [ ] **normal** — `chat-response`'s own table: ~150 words for a finding, ~200 for a proposal
- [ ] **full** — the reasoning before the conclusion, at whatever length that takes
- [ ] Other:
