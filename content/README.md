# content/

Study content is data, not code. It flows **in one direction**:

```
official source (textbook page, answer key, gazette, TNPSC site)
  -> syllabus/<exam>.yaml            subjects -> topics (lamps) -> textbook refs   (human-authored, reviewed)
  -> pipeline: import / AI draft     ai-gateway task "explain_question" (once per question version)
  -> pipeline: AI verify             task "verify_answer" on a DIFFERENT model family
  -> Review Desk (human)             100% of eligibility data; 100% of questions for the first 2 weeks;
                                     every user-reported item (blueprint §26.2 rule 5)
  -> content pack (versioned zip, SHA-256) -> cdn.heymey.app
```

| Folder | What |
|---|---|
| `syllabus/` | One YAML per exam. Topic ids are stable UUIDs: never reuse or renumber, the app's lamps point at them. |
| `pipeline/` | Scripts (import, draft, verify, pack). They call the API / ai-gateway; they never write to the database directly. |

Rules for agents:
- Every question cites a `source` (exam, year, question number or textbook page). No source, no question.
- Interface copy is English. **Tamil Language paper content stays in Tamil** and is written by Tamil experts, not translated.
- AI never publishes on its own. The verifier must run on a different model family from the writer.
- Copied third-party material is not allowed; explanations are our own writing.
