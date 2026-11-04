# HeyMey — Master Document v1.2

**Company:** HeyMey Technologies Pvt Ltd (to be incorporated) · **Domain:** heymey.app · **Product:** one Flutter codebase → mobile app (Android + iOS) for everyone, plus a web "Desk" for partners and staff · **Market:** Indian competitive and professional exam aspirants; **launch wedge: Tamil Nadu government-job aspirants**, 18–35 first (Calm Mode for 35+), then more exam families in waves (§1a) *(changed 2026-10-22, D-2026-10-22-01)* · **Language:** English-first interface, in simple English (exam content follows the paper's language, §1 decision 3) · **Hosting:** free/starter tiers at launch: Supabase Postgres, Cloudflare R2, Vercel (marketing) *(changed 2026-11-04, D-2026-11-04-01)*, Firebase Hosting (Desk), one small VM in Docker for api/realtime/worker (ADR-0014) *(changed 2026-11-01, D-2026-11-01-01)* · **Login:** email OTP over SMTP · **Payments:** app stores + Razorpay · **AI:** OpenRouter (one API, many fallback models) · **Built by:** AI agents, with the founder as product owner

> This is the master document for the product, the business, and the engineering. Older documents are in `docs-archive/` for reference only and do not override anything here.

**What changed on 2026-10-22 (founder decisions, see `aidlc/decisions.md`):**
- **D-2026-10-22-01 Multi-exam scope:** HeyMey is for Indian competitive and professional exams (UPSC, SSC, Banking, Railways, CA, CS and more), launched with a Tamil Nadu wedge. New §1a. Every paragraph changed for this is marked *(changed 2026-10-22, D-2026-10-22-01)*.
- **D-2026-10-22-02 Study Rooms:** live group study with server-timed focus hours and study-hours boards. New §9.11. Marked *(changed 2026-10-22, D-2026-10-22-02)*.

**What changed in v1.2:**
- **Hosting:** at launch, managed free tiers plus one small VM in Docker Compose; one dedicated VPS once revenue justifies it (ADR-0014) *(changed 2026-11-01, D-2026-11-01-01)*.
- **Email OTP over SMTP** replaces SMS OTP, so DLT registration is no longer needed.
- **Build plan:** about 4 weeks of engineering, with content and legal work in parallel.
- **New Part J:** the full engineering specification (repository, modules, APIs, auth, sync, real-time, deployment, CI/CD, testing, migration from the old Next.js app, definition of done).

**What changed in v1.1:**
- English-only app.
- Plain English names everywhere.
- Open-source, self-hosted stack.
- App vs Desk access settled (Section 15).

---

## PART A — DECISIONS

## 1. Locked decisions

| # | Topic | Decision |
|---|---|---|
| 1 | What we are | A **product company**. HeyMey is a gamified preparation app **for Indian competitive and professional exams** (government jobs, UPSC, and professional courses such as CA and CS). Preparing for an exam feels like progressing in a game. We are not a coaching or course-selling company. *(changed 2026-10-22, D-2026-10-22-01)* |
| 2 | Platform | **One Flutter codebase.** It builds (a) the **HeyMey mobile app** for Android + iOS, used by every aspirant and everyone else, and (b) the **HeyMey Desk** web build, used **only** by partners and staff for heavy desk work (Section 15). **There is no web version for aspirants.** |
| 3 | Language | **English-first, written in simple English.** The **interface** is English only: no Tamil (or other Indian-language) words or letters in interface text. **Study content follows the language of the exam paper**, set per paper in the exam data: a paper that *tests* a language (for example, the **Tamil Language paper** in TNPSC Group 4) keeps its content in that language; every other paper's content is in English in version 1. Other languages for other exam families (for example, a language paper in another family, or Hindi-medium content) are decided per family before that wave starts (INT-006). This is study content, never interface text. *(changed 2026-10-22, D-2026-10-22-01)* |
| 4 | Backend | **TypeScript** (the founder's strength), on Node.js. |
| 5 | Hosting | **At launch: managed free tiers (Supabase Postgres, Cloudflare R2, Vercel for marketing *(changed 2026-11-04, D-2026-11-04-01)*, Firebase Hosting) plus one small always-on VM running the long-lived services in Docker Compose; paid plans only once revenue comes in (ADR-0014)** *(changed 2026-11-01, D-2026-11-01-01)*. *Original:* **One VPS in an Indian data centre, with every service in Docker Compose.** Everything we can self-host is open source. We pay only for what can't be replaced: app stores, the SMTP email service, Razorpay, and OpenRouter. |
| 5a | Login | **Email + 6-digit OTP** sent over SMTP. No passwords and no SMS. |
| 6 | AI | **OpenRouter**: one API key on the server, with a fallback model list for every task. |
| 7 | Who builds it | **AI agents** write code, tests, and content drafts. The founder approves releases, prices, legal text, and anything touching money or personal data. |
| 8 | Game style | **We take the *logic* of long-running games, not their look or names.** That logic is long progression, timers that bring you back, groups, group battles, seasons, and live events. The look is a **modern, premium, gamified app**. |
| 9 | Daily quiz | **None.** The featured game changes every day. |
| 10 | Lucky games | **Daily Spin and Lucky Slot on alternate days.** Both are free, earned by studying, and **never sold**. |
| 11 | Other games | Clue Poker, Confidence Duel, Squad Battles, District Quest (a Monopoly-style board game), Memory Pits, Tiger Trap, News Hunt, and live events. |
| 12 | Pricing | **Free to download and use, but not everything is free.** Full depth is paid: the full previous-year question vault, unlimited practice, the mock series, deep analytics, AI doubt help, and the full offline library. |
| 13 | Money and games | **Money never touches a game.** There are no paid entries, plays, chips, or stakes, and no game pays out anything bought with money or worth money (Section 30). |
| 14 | Ads | **No third-party ads.** |
| 15 | Profit | **Target: profitable from month 1** (Section 14). |
| 16 | Launch exams | **TNPSC Group 4 (including VAO) and Group 2/2A** get full preparation content. **Exam Alerts and the Eligibility Checker** cover all major Tamil Nadu and central exams from day one. **This is the launch wedge, not the whole market:** other exam families are added in waves after launch (§1a). *(changed 2026-10-22, D-2026-10-22-01)* |
| 17 | Exam families | **Every exam-shaped part of the product is data, not code** (exam family → exam → stage → paper → section, marking scheme, attempt cycles). Adding an exam family is a content and data job, plus only the paper types it needs. *(changed 2026-10-22, D-2026-10-22-01)* |
| 18 | Study Rooms | **Live group study is part of the game layer** (§9.11): focus hours are timed by the server, boards show capped hours, and study hours never touch money. *(changed 2026-10-22, D-2026-10-22-02)* |

## 1a. Exam families and expansion waves *(changed 2026-10-22, D-2026-10-22-01)*

**Why:** the founder's scope is "all exams, even UPSC, CA and CS". Students preparing for professional exams like CA and CS often study alone for years without an academy, so the long-preparation game loop (lamps, Relight, squads, Study Rooms) fits them as well as it fits TNPSC aspirants.

**Rule for launch:** the Tamil Nadu wedge (decision 16) is unchanged, so the launch date is not put at risk. Nothing in a later wave blocks launch. What changes **now** is that Phase 2 onward is built exam-agnostic, so a new family needs data and content, not a rewrite.

**Proposed wave order (the founder confirms; INT-006 Q1):**

| Wave | Exam family | Stages / papers (names only; details **to verify from official source**) | Why this position |
|---|---|---|---|
| 0 (launch) | **TNPSC** Group 4 (incl. VAO), Group 2/2A; Exam Alerts + Eligibility Checker for major TN and central exams | As today (Track B content) | Unchanged launch scope |
| 1 | **SSC, Banking, Railways** (central objective exams; TN-relevant ones first) | Objective MCQ stages; exact tiers, sections and marking **to verify from the official notifications** | Large overlap with TNPSC Aptitude, English and General Studies lamps; uses the objective Exam Hall that launch already has; no new paper type |
| 2 | **CA** (ICAI: Foundation, Intermediate, Final) and **CS** (ICSI: CSEET, Executive, Professional) | Papers, objective/descriptive split, marking, attempt windows and exemptions **to verify from official source (icai.org, icsi.edu)** | The founder's pain point (students alone for years); Study Rooms carry most of the value; needs the **descriptive paper** type (see below) |
| 3 | **UPSC Civil Services** (Prelims, Mains, Interview) | Paper list, optional subjects, qualifying papers and marking **to verify from official source (upsc.gov.in)** | Largest content effort (Mains descriptive, essay, optional subjects); reuses the descriptive paper type from wave 2 |

The blueprint's earlier post-launch list (§27: Group 1, Police, TRB, then Bank, Railway, SSC) stays as the order **inside** the TN and central objective waves.

**What "exam-agnostic" means (the model every phase builds to):**
- **Exam family** (TNPSC, SSC, UPSC, ICAI-CA, ICSI-CS …) → **exam** (Group 4, CA Intermediate …) → **stage** (Prelims, Mains, Interview; Foundation, Intermediate, Final) → **paper** → **section**.
- Each paper carries its own **marking scheme** (marks per question, negative marking or none, qualifying-only or counted, sectional limits), **time**, **answer mode** (objective OMR, objective CBT, descriptive) and **content language** (decision 3). Nothing about marks or time is hard-coded.
- **Attempt cycles:** an aspirant prepares for an **attempt** (a specific sitting of an exam), which has its own dates. Some families have yearly cycles, some have more than one sitting a year, some have multi-year journeys across stages, and some count attempts. All of these are data on the attempt, **to verify per family**. Plans, Final Stretch, Exam Pass validity and Attempt Review hang off the attempt, not off "the exam date".
- **Descriptive papers** (CA/CS and UPSC Mains): written answers cannot be scored the way MCQs are. How they are practised and checked (self-check against a model answer, peer review, mentor review, AI-assisted feedback without personal data) is an **open question for wave 2** (INT-006 Q4). The Exam Hall keeps "looks like the real exam" as its rule.
- **Eligibility** stays a data-driven rule engine. Professional courses have registration and stage-progression rules instead of age and community rules; the rule shape for them is **to verify** and is designed before wave 2.

**Places in this document that still assume Tamil Nadu only (each must be generalised or scoped to the TN family before its wave):**

| § | Assumption | Proposed handling |
|---|---|---|
| Header, §2, §28.7 | "Tamil Nadu government-job aspirants" | Wedge wording kept for launch marketing; product wording is all exams |
| §1 dec. 3, §10.4, §19.3 Q24/Q26/Q27, §19.4 Q35, §26.1 content agents, §26.3 | Tamil is the only non-English content language | Per-paper content language (decision 3) |
| §3 / §5.2 | Career Ladder titles are TN government posts (Typist … Chief Secretary) | Rank titles become per-family data; TN titles stay for TN; other families' titles are an open question (INT-006 Q5) |
| §9.6, §10.6 | District Quest board = Tamil Nadu's 38 districts; seasonal boards are TN history | Stays a TN board; other families get other boards or none (INT-006 Q6) |
| §9.5, §17.1 step 10, §17.5 Captain | Squads searched by district | District becomes optional; "exam + paper + study hours" works for all |
| §9.9 | State Mock Sunday, "statewide rank", Pongal Fest, Literature Week, Education Development Day | Scoped per exam family ("all-takers rank for this exam"); events tagged by family |
| §12 | Map themes are TN places | Cosmetic only, keep; add others later |
| §11, §19.3 Q22 | "State Board textbook map" | Becomes "official study material map" per family (State Board books for TN, NCERT for UPSC, institute study material for CA/CS: **to verify** licence and links) |
| §17.1 step 2, §19.1 Q1 | Community categories and Tamil-medium (PSTM) | Asked only when the chosen family uses them |
| §19.4 Q37, §10.6 Exam Hall | OMR ("pen-and-paper exams like TNPSC") or CBT only | Add the descriptive answer mode as a paper type (wave 2) |
| §9.9 Answer Key Day, §19.5 Q49 cutoffs | Official answer keys and cutoffs exist | True only for some families; per-family flag (**to verify**) |
| §14, §28, §29 | Month-1 targets, launch channels and press story are TN | Unchanged for launch; new targets per wave |
| §16 Mentor, §17.3 "Cleared" | "Proof of selection" | "Proof of selection or qualification" per family |
| §17.1 step 1, §18 under-18 row, §30 DPDP | 18+ only | Under 18 matters more for CA Foundation and CSEET aspirants; **open question** (INT-006 Q3), no change until the founder decides |

## 2. HeyMey in one paragraph

*(changed 2026-10-22, D-2026-10-22-01 and -02: HeyMey now serves Indian competitive and professional exams, starting with Tamil Nadu; this paragraph describes the launch wedge, and the same loop applies to every exam family. Study Rooms (§9.11) let aspirants who study alone study "together" with people preparing for the same exam.)*
HeyMey turns a 1–3 year government-exam preparation into a game you want to come back to. Your syllabus becomes the **Study Map**, a glowing map where every topic is a **lamp**. A lamp **lights** when you learn the topic, burns **steady** when you remember it, and turns **gold** when you can answer it under exam conditions. When you stop revising, the lamp slowly dims, so you can see your real memory. As your lamps grow, you climb the **Career Ladder**, a rank system named after real government posts, from Aspirant to Typist, Village Officer, Tahsildar, Collector, and up to Chief Secretary. You join a **Squad** of other aspirants and win **Squad Battles** with real exam questions. Every day there's a different game: Daily Spin or Lucky Slot, Clue Poker, Confidence Duels, and a weekend board game across Tamil Nadu's 38 districts. Underneath all of it is a serious, honest preparation tool: eligibility, alerts, a plan, previous-year questions, mocks, revision, and a readiness meter. That combination is what makes people stay and pay.

## 3. Names used in the app (all plain English)

| Area | Name in the app |
|---|---|
| Home tab | **Today** |
| Syllabus map | **Study Map** (topics are **lamps**: Lit → Steady → Gold) |
| Rank system | **Career Ladder** |
| Study plan | **My Plan** |
| Today's task card | **Today Card** |
| Revision | **Relight** (relighting a dimming lamp) |
| Readiness | **Readiness Meter** |
| Eligibility | **Eligibility Checker** |
| Notifications | **Exam Alerts** |
| Books & resources | **Library** |
| Previous-year questions | **PYQ Vault** |
| Mock tests | **Exam Hall** |
| Current affairs | **Current Affairs** (+ weekly **News Hunt**) |
| Aptitude course | **Aptitude Path** |
| Audio | **Listen Mode** |
| Wellbeing | **Wellbeing Corner** |
| Store | **Store** |
| Weekly report | **Sunday Report** |
| Group of aspirants | **Squad** |
| Squad roles | **Captain · Vice-Captain · Senior Member · Member** |
| Group battle | **Squad Battle** |
| Monthly group goal | **Squad Goal** |
| Asking the squad for help | **Help Requests** |
| Live group study *(changed 2026-10-22, D-2026-10-22-02)* | **Study Room** (public, per exam or paper) · **Squad Room** (private, per squad) |
| A timed study block *(changed 2026-10-22, D-2026-10-22-02)* | **Focus session** ("Start focus", "Pause", "End") |
| Count of people studying | **Studying now** |
| Study-hours board | **Hours Board** (Today · This week) |
| Days with focused study *(changed 2026-10-22, D-2026-10-22-02)* | **Focus days** (name to confirm, INT-007 Q6) |
| Free in-app currency | **Points** |
| Paid currency | **Sparks** |
| Rank-up XP | **XP** |
| League score | **Trophies** |
| Duel leagues | **Starter → Learner → Scholar → Achiever → Expert → Ranker → Topper** |
| Lucky games | **Daily Spin** · **Lucky Slot** |
| Other games | **Clue Poker** · **Confidence Duel** · **District Quest** · **Memory Pits** · **Tiger Trap** · **Dice Relay** |
| Subscription | **HeyMey Pro** · **Exam Pass** · **Season Pass** |
| Founding badge | **First Lamp** badge |
| Simple mode | **Calm Mode** |
| Low-end phone mode | **Lite Mode** |
| Partner & staff web tool | **HeyMey Desk** |

**Naming rule for everything new:** use short, common English words that a 19-year-old who studied in Tamil medium can read and say easily. Don't use Tamil words, and don't copy names from other games.

## 4. The logic we borrow (not the look, not the names)

| Proven game logic | HeyMey version | Real study value |
|---|---|---|
| Long progression with levels | **Career Ladder** driven by your lamps | Visible proof of syllabus mastery |
| Timers that bring you back | Lamps **dim on a spaced-revision schedule**, and you come back to relight them | You remember for the exam |
| Collect twice a day | **Daily check-in** + morning relight + evening recall | A light, healthy habit |
| Groups + helping each other | **Squad** + **Help Requests** | Peer support over a long preparation |
| Group battles | **Squad Battles** twice a week with real exam questions | Timed practice under pressure |
| Seasons + passes | Monthly **Seasons** + **Season Pass** (cosmetic only) | A fresh goal every month |
| Live events | Exam-calendar events + festival events | Practice that follows the real exam calendar |
| Leagues | **Duel leagues** that reset every season | Fair competition with peers |

---

## PART B — THE GAME LAYER

## 5. Core systems

### 5.1 Study Map and lamps

- Each exam's **official syllabus** is split into **subjects** (shown as areas on the map), and each subject into **topics** (lamps). For example: Polity has 42 lamps, Aptitude has 35.
- Each lamp has **three rings**:

| Ring | Meaning | How you earn it |
|---|---|---|
| **Lit** | You've **learned** it | Finish the lesson or the mapped textbook pages + pass a 3-question check |
| **Steady** | You **remember** it | Pass a recall check after a gap (1 → 3 → 7 → 21 days) |
| **Gold** | You're **exam-ready** | Pass a timed, exam-level set (80% or more) |

- **Dimming:** when a topic is due for revision, its lamp fades. If it stays overdue, the Steady ring is lost (your history stays). **Relighting** takes 2–5 minutes.
- If you prepare for more than one exam, topics they share use one lamp, tagged with each exam's colour.
- *(changed 2026-10-22, D-2026-10-22-01)* The map is built the same way for **every exam family**: family → exam → stage → paper → subject → topic (§1a). A stage or paper can be shared (for example, a prelims paper and a mains paper may share topics) and shared topics still use one lamp. For **descriptive papers** (CA/CS, UPSC Mains), how a lamp turns Steady and Gold is an open question (INT-006 Q4); Lit/Steady/Gold keep their meaning (learned / remembered / exam-ready).
- *(changed 2026-10-22, D-2026-10-22-02)* **Study hours never light a lamp by themselves.** Time in a Focus session (§9.11) is shown next to the topics you worked on, and lamps you light, keep or turn Gold during that session are credited to it, but every ring is still earned only by the checks in the table above.

### 5.2 Career Ladder (your rank)

Your rank comes **only from your lamps**: how many are Lit, Steady, and Gold across your syllabus. It never comes from purchases.

| Level | Rank title (a game title, not an official post) |
|---|---|
| 1 | Aspirant |
| 2 | Typist |
| 3 | Junior Assistant |
| 4 | Village Officer |
| 5 | Section Officer |
| 6 | Deputy Tahsildar |
| 7 | Tahsildar |
| 8 | Deputy Collector |
| 9 | District Collector |
| 10 | Secretary |
| 11 | Chief Secretary (top rank) |

Every rank-up gets a celebration and a shareable **Rank Card**, which carries a small note: *"Game title. Not an official designation."*

*(changed 2026-10-22, D-2026-10-22-01)* The titles above are the **Tamil Nadu family's** ladder. Rank titles are data per exam family; the titles for UPSC, SSC/Banking/Railways, CA and CS are an open question (INT-006 Q5). Study hours (§9.11) **never** change rank: rank still comes only from lamps.

### 5.3 Currencies and the firewall

| Item | How you get it | What it's for | Buyable with money? | Transferable or cashable? |
|---|---|---|---|---|
| **XP** | All study | Rank progress | No | No |
| **Points** | Practice, check-ins, games | Basic cosmetics, Revision Shields, profile items | **No** | **No** |
| **Trophies** | Duels, Clue Poker, Squad Battles | League placement | **No** | **No** |
| **Match chips / board cash** | Given free at the start of each Clue Poker or District Quest match | Only that match. **They disappear when it ends.** | **No** | **No** |
| **Sparks** | **Bought** in-app, or **earned** from fixed study milestones (max 50 a month) | Store items: creator notes, single mock packs, premium cosmetics | Yes | **No.** You can't withdraw them, send them to another user, or swap them for Points. Bought Sparks **never expire**. |

**Firewall rules (written into the code and covered by tests that can never be deleted):**
1. **No conversion** between Sparks and Points, Trophies, or chips, in either direction.
2. Nothing bought with money can be used to enter or play any game.
3. No game rewards Sparks, subscriptions, books, or anything worth money outside the app.
4. **Pro and the Season Pass give no game advantage.** Everyone gets the same plays, limits, odds, and rewards.
5. *(changed 2026-10-22, D-2026-10-22-02)* **Study hours are not money and money does not make study hours.** Focus hours (§9.11) never convert to Sparks, money or anything worth money; no study-hours milestone earns Sparks; nothing bought (Pro, Exam Pass, Season Pass, Sparks, cosmetics) adds, multiplies, protects or restores hours, streaks or board places; Study Rooms are the same for free and paid users.

## 6. Daily loop (15–60 minutes, your choice)

```
Morning alert (only if real: "4 Polity lamps are dimming")
 → Open → check in (1 tap)
 → Today Card: "Polity Unit 4 (40 min) + relight 4 lamps (8 min)"
 → Study → lamps light → rank bar moves
 → Today's lucky game unlocks (only after one real study task)
 → Featured game of the day (battle / Clue Poker / duel / board)
 → Squad: answer a Help Request
 → Evening: recall checks → lamps turn Steady
```

## 7. Daily check-in

- **7-day track** with fixed, listed rewards (Points, a Revision Shield, profile items). Day 7 gives a cosmetic.
- **Missing a day never resets you to day 1.** The track just waits for you. There's no "streak lost" shaming.
- **28-day track:** an exclusive monthly profile frame.
- The rewards are the same for free and paid users.

## 8. Two-week game calendar

| Day | Lucky game (1 free + 1 earned) | Featured game |
|---|---|---|
| Mon | **Daily Spin** | Squad Battle #1: prep day |
| Tue | **Lucky Slot** | Squad Battle #1: battle day |
| Wed | Spin | **Clue Poker Night** (week 1) · **Memory Pits** (week 2) |
| Thu | Slot | Squad Battle #2: prep day |
| Fri | Spin | Squad Battle #2: battle day · **District Quest opens** |
| Sat | Slot | District Quest · **News Hunt** |
| Sun | Spin | District Quest finale · **State Mock Sunday** (1st & 3rd) · **Tiger Trap** (2nd & 4th) |

Confidence Duels are open every day. Live events sit on top of this calendar.

## 9. The games

### 9.1 Daily Spin (odd days)
- **1 free spin.** You **earn a 2nd spin** by relighting all your due lamps that day. **Spins are never sold.**
- Prizes: Points, cosmetic pieces, a **Revision Shield** (stops one lamp from dimming for 48 hours), a **2× XP hour**, and profile items.
- **Odds are shown on the wheel.** No prize is Sparks or anything with real-world value.
- Look: a bright **festival-fair wheel**, not a casino.

### 9.2 Lucky Slot (even days)
- **1 free pull + 1 earned pull** (same rule as the spin). Pulls are never sold.
- The reels show subject icons: scroll, dome, map, coin, flask, lamp.
- **Three matching icons unlock a Bonus Round** of 3 quick questions from that subject. Each correct answer multiplies the prize, so luck opens the door and knowledge decides the win.
- Odds are shown. The machine looks like a festival-fair machine.

### 9.3 Clue Poker
- 2–6 players, with one hidden answer (a person, place, Article, scheme, or year).
- Each player gets **2 private hint cards**. Then **5 shared clue cards** are revealed: 3, then 1, then 1.
- Everyone starts with **1,000 free match chips**. You can fold, call, or raise. At the showdown, each player still in types the answer, and correct answers split the pot in proportion to their bets.
- **Chips disappear at the end of the match.** Rewards are Trophies + Points based on placement.
- It trains elimination and inference, which are the core skills for tricky multiple-choice questions.
- A **practice table vs bots** is always open. Ranked tables run on Clue Poker Night and at weekends.

### 9.4 Confidence Duel
- 1-vs-1, 7 real exam questions. Before answering, you mark **Sure / Think so / Guessing**.
- Score = correctness × confidence. **Wrong + Sure costs the most.**
- After every duel you get a **confidence report**, for example: "You were overconfident twice in Polity."
- Leagues: **Starter → Learner → Scholar → Achiever → Expert → Ranker → Topper.** They reset every season.
- **Ranked duels are capped at 10 a day for everyone, and the cap can't be bought.** Practice duels are unlimited.

### 9.5 Squad and Squad Battles
- **Squad:** 10–40 members. Roles are **Captain, Vice-Captain, Senior Member, and Member**. Search squads by exam, district, and daily study hours. *(changed 2026-10-22, D-2026-10-22-01 and -02: district is optional and used only where the exam family has districts; every squad gets a private **Squad Room** for live study, §9.11.)*
- **Help Requests:** members post doubts, and others answer them. Helpful answers earn Points + reputation. Reported answers go to review.
- **Squad Battle (twice a week):**
  - Two squads of similar strength are matched.
  - The battle board has **10 topic zones** from the shared syllabus.
  - Each member gets **2 attempts**. An attempt is a timed 5-question set at that zone's difficulty: **1 flag** = 3 correct, **2 flags** = 4 correct, **3 flags** = 5 correct within time.
  - The squad with the most flags wins. Rewards: Points, squad XP, Trophies.
- **Squad Goal (monthly):** a shared target (for example, "relight 3,000 lamps together") that unlocks squad banners.

### 9.6 District Quest (Monopoly-style board, weekends)
- The board is **Tamil Nadu's 38 districts**. 2–4 players take turns from Friday to Sunday.
- Each player starts with **₹1,500 of free board cash** (pretend money, not real money), which disappears at the end of the match.
- Roll the dice and land on a district. Answer its question (geography, history, schemes, famous people) to **claim** it. Opponents who land there pay board-cash rent, unless they answer its challenge correctly.
- **Event cards** poke fun at aspirant life: *Notification Released!* (everyone moves to Chennai), *Exam Postponed* (skip a turn), *Answer Key Objection* (retry one wrong answer), *Hall Ticket Day* (bonus).
- **Seasonal boards:** Chola Empire, Constitution, Sangam Literature. Rewards: Trophies + Points + board-only cosmetics.

### 9.7 Quick games
- **Memory Pits:** a seed-sowing board game (based on a traditional South Indian game). Each pit hides a revision card you must recall. Good for 5–10 minute sessions.
- **Tiger Trap:** a goats-vs-tiger strategy puzzle (based on a traditional game). Each move needs a reasoning or aptitude step solved.
- **Dice Relay:** a squad dice relay during festival events.

### 9.8 News Hunt (weekly)
Daily current affairs are **read-only cards** with a date, a source, and an exam-relevance tag. On Saturday, the **News Hunt** turns the week's cards into a treasure-trail game. This keeps current affairs from becoming a cheap daily quiz.

### 9.9 Live events

| Event | When | What happens |
|---|---|---|
| **Notification Night** | Within hours of a real notification (after human checking) | A 72-hour event with an eligibility check, a starter plan, and themed rewards |
| **Answer Key Day** | When an official answer key is published | Expected-marks calculator, objection-window reminders, an anonymous statewide score spread |
| **State Mock Sunday** | 1st & 3rd Sunday | One full mock for the whole state at the same time, with a statewide rank. **Free for everyone.** |
| **Education Development Day** | July 15 | Statewide relight drive |
| **Constitution Week** | Around Nov 26 | Constitution board + Polity cosmetics |
| **Pongal Fest** | January | Festival theme + Dice Relay |
| **New Year Season** | April | New season celebration |
| **Literature Week** | January | Literature-themed event |

*(changed 2026-10-22, D-2026-10-22-01)* "Statewide" events (State Mock Sunday rank, Answer Key Day score spread, First Lamp Fest) belong to the **Tamil Nadu family**. Each event is tagged with the exam family it serves; other families get their own mock days and ranks ("all takers of this exam on HeyMey"), and Answer Key Day runs only where the family publishes official keys (**to verify per family**).

### 9.10 Healthy-play guardrails
- After 1 hour of continuous play, a playtime reminder appears, and then every 30 minutes.
- **Games sleep from 12 AM to 5 AM.** Study stays open.
- During **Exam Hall** mocks there are no game sounds, no animations, and no alerts.
- In the last 7 days before your exam, games become quiet and optional.

### 9.11 Study Rooms *(changed 2026-10-22, D-2026-10-22-02)*

**Why:** many aspirants (especially CA and CS students) study alone for years. Seeing other people preparing for the same exam study at the same time ("this person studied 12 hours today") motivates them. Study Rooms bring that into HeyMey, honestly: hours are timed by the server, boards reward steady effort rather than extreme days, and nothing touches money.

**Rooms**
- **Study Room (public):** one per exam, and optionally per paper (for example, one per exam stage or paper). Large rooms are split into **room groups** of a fixed size so each board stays personal (size: INT-007 Q2).
- **Squad Room (private):** one per squad (§9.5). Only squad members can see it.
- A user can be in one room at a time while a focus session runs. Rooms are free for everyone (§11 "same for everyone").

**Focus session (server-timed)**
- **Start focus → Pause → Resume → End.** Every one of these is a server call with an `Idempotency-Key`; the **server records the times** (§34.1, §37). The phone clock is never used (§18 clock row).
- While a session runs, the app sends a **presence heartbeat** over the realtime connection (interval: INT-007 Q1). The server credits time **only between heartbeats it received**. If heartbeats stop (no connection, app killed), the session is **auto-paused at the last heartbeat**; nothing after that is credited.
- **App in the background / phone idle:** a session pauses when the app has been in the background longer than a short grace period (so a quick look at a calculator or a notes app is fine). The grace period, and whether reading a PDF in another app counts, is INT-007 Q3. Exam Hall mocks and HeyMey lessons/practice in the foreground always count.
- **"Still studying?" check:** after a long stretch without any app interaction, a simple tap check appears; no answer within the window pauses the session. This is a plain check, never a trick or a timed penalty.
- **One active session per account**, across all devices.
- Optional **topic tag**: pick the subject/topic you are studying, or link the Today Card. Lamps you light or relight during the session are shown on the session summary. **Hours never light a lamp by themselves** (§5.1) and **never change rank** (§5.2). Focus hours are written to My Plan's study log so the plan sees real hours (§19.2).
- **Offline:** a focus session needs a connection to count for boards (§34.2, §18 offline row). Study done offline still counts for lamps as today (§39). Whether offline study time shows in your **private** totals is INT-007 Q9.

**Live counts and boards**
- Each room shows **Studying now** (a live count) and member tiles: display name, avatar, the subject tag if the user shares it, and today's hours.
- **Hours Board:** **Today** and **This week**, per room, using **IST days** (Asia/Kolkata, §37) and IST weeks (week start: INT-007 Q5).
- **Boards show capped hours.** Each day's hours count on the board only up to a **daily board cap** (value: INT-007 Q4); anything above shows as "cap reached", never as a bigger number. A board can never be won by studying 18 hours.
- Boards follow the **kind leaderboard** rule (§19.7 Q70): you see the top places and your own place; you can hide yourself anytime.

**Personal record**
- **Focus days:** days with at least a minimum amount of focused study (minimum: INT-007 Q6). Following §7, **missing a day never resets anything to zero and the app never says "streak lost"**. The exact streak shape (longest run, this month's count, a weekly target that waits for you) is INT-007 Q6.
- Personal totals (today, week, month, all time) are always visible to the user, including above the cap.
- Rewards for focus days, if any, are fixed, listed, and limited to cosmetics or Points with the same rules as check-in (§7); **never Sparks**. Whether there are any rewards at all is INT-007 Q7.

**Wellbeing guardrails** (same spirit as §9.10)
- After a long continuous session, a **break nudge** ("You've studied 2 hours. Take a 10-minute break?"; values: INT-007 Q8). The nudge repeats on a fixed interval. The user can keep going; no penalty.
- After a long day, a **rest nudge**, and the board stops adding hours (the cap).
- Late-night study (12 AM–5 AM): study stays open (§9.10), but those hours show a sleep reminder; whether they count on boards is INT-007 Q8.
- **Calm Mode hides boards and live counts** (§10.7). The room shows only your own timer and "Studying now: on".
- Nothing celebrates very long days: no badge, title or message for hours above the cap.
- Wellbeing Corner and Tele-MANAS 14416 are one tap away from every room (§19.10 Q98).

**Privacy**
- Rooms show a **display name** (nickname, §19.9 Q89) and avatar only: never email, real name, district (unless the user adds it), exam result or private scores.
- **Visibility is opt-in:** a user can study in a room with their timer only and not appear on public boards or member tiles. Squad Room visibility to squad members is a separate choice. Defaults are INT-007 Q10 (proposed: hidden on public boards until the user turns it on).
- Supporters (§17.5) see focus hours only if the aspirant allows it.
- **Under 18:** HeyMey is 18+ (§17.1). Accounts reported as under 18 are paused (§18). Wider multi-exam scope raises this question (INT-006 Q3).

**Moderation**
- MVP rooms have **no free-text chat**. Interaction is limited to a fixed set of positive reactions ("Keep going", "Well done"). Squad chat (§9.5) stays where it is.
- Users can **report** a display name or avatar and **block** a user (blocked users disappear from your room view). Reports go to the moderation queue (§17.5 Moderator). Repeat offenders are hidden from public boards.
- Accounts flagged for faking hours (see anti-cheat) are removed from boards pending review.

**Anti-cheat**
- Server-credited time only (heartbeats + server start/pause/end). One session per account. Device integrity check (§18, §20.1). Duplicate devices and impossible patterns (for example, sessions that never pause for many days) are flagged for review (§17.5 System "cheat detection").
- Boards only use **capped, server-credited, online** hours.

**Money/game firewall** (§5.3 rule 5): hours never become Sparks or money; nothing paid boosts, protects or restores hours, focus days or board places; Pro gives no Study Room advantage. Firewall tests are added for this (INT-007).

---

## PART C — EXPERIENCE AND DESIGN

## 10. Premium gamified UI/UX

### 10.1 Design principles
1. **Premium, not childish.** It should feel like a top mobile game (depth, glow, smooth motion) with the clarity of a banking app.
2. **Clean English interface.** There's no mixed-language text. Cultural flavour comes through **visuals only**: lamp glow, festival lights, dot-pattern art, brass and gold tones.
3. **Study screens are calm, play screens are rich.** The Exam Hall and lessons are clean and focused. The map, games, and celebrations are vivid.
4. **One clear next action on every screen.**
5. **Fast on cheap phones.** Every animation has a Lite version.

### 10.2 Copy rules (simple English)
- Short sentences, common words, and active voice.
- Explain every exam term the first time it appears, with a **tap-to-see meaning** glossary.
- No idioms, slang, or sarcasm in instructions.
- Buttons are verbs: "Start", "Relight", "Join squad", "Not now".
- **Aim for wording a student who studied in Tamil medium understands on the first read.**

### 10.3 Colour tokens

| Token | Hex | Use |
|---|---|---|
| Night Indigo (dark background) | `#0F1230` | Default dark theme |
| Deep Ink (surface) | `#1A1E45` | Cards in dark mode |
| Ivory (light background) | `#FFF8EC` | Light theme |
| Temple Gold (primary) | `#F2B33D` | Main buttons, Gold rings, ranks |
| Peacock Teal (secondary) | `#0FA3A3` | Links, progress, Steady rings |
| Flame Orange | `#FF8A3D` | Lit rings, check-in flame |
| Ember Red | `#E2453C` | Errors, dimming warnings |
| Leaf Green | `#2FA866` | Correct answers, success |
| Brass gradient | `#C8963E → #F6D27A` | Premium items, Pro badge |

The app comes with a dark theme (the default), a light theme, and a high-contrast option.

### 10.4 Fonts, icons, motion, sound
- **Fonts** (open-source, bundled so they work offline):
  - **Plus Jakarta Sans** for the interface
  - **Sora** for big numbers
  - **Noto Sans Tamil** used **only** inside Tamil Language paper content
- **Icons:** soft 3D-style icons with depth and light, in one consistent style.
- **Motion:**
  - Screen transitions take 200–300 ms.
  - Celebrations last at most 1.5 s, and you can always skip them.
  - Lamps flicker subtly, and the map has a slight parallax.
  - Animations are made in **Rive**.
- **Sound:** short festive drum-and-horn sounds for rank-ups and wins, and soft taps on answers. Sound can be switched off, and it's always off in the Exam Hall.
- **Haptics:** a light tap for a correct answer, a double pulse for a rank-up, and nothing during mocks.

### 10.5 Navigation (5 tabs)

| Tab | Contains |
|---|---|
| **Today** | Check-in, Today Card, relight queue, today's lucky game, featured game, rank bar |
| **Study Map** | Subjects and lamps, lessons, practice, PYQ Vault, Exam Hall, Current Affairs, Aptitude Path |
| **Play** | Confidence Duel, Clue Poker, District Quest, Memory Pits, Tiger Trap, events |
| **Squad** | Chat, Help Requests, Squad Battles, Squad Goal, leaderboards, **Study Rooms** (Squad Room + public Study Room) *(changed 2026-10-22, D-2026-10-22-02; tab placement and a "Start focus" shortcut on Today: INT-007 Q11)* |
| **Profile** | Readiness Meter, reports, Eligibility Checker, Exam Alerts, Store, Pro, settings, Help, **role switcher** (for creators, partners, and staff) |

### 10.6 Key screens

| Screen | Look and feel |
|---|---|
| **First open** | Gold dots draw a pattern, a lamp lights, and the HeyMey wordmark appears. Under 2 seconds. |
| **Eligibility result** | Cards fan out with "You're eligible for 23 exams". The top 5 glow. One tap shares it as an image. |
| **Today** | At the top: rank badge, XP bar, check-in flame. In the middle: one big Today Card. Below: the dimming lamps ("Relight 4 · 8 min"), then the lucky-game tile, which shows **locked** until one study task is done. |
| **Study Map** | A dark canvas with glowing subject islands. Zoom in to see lamps along a path, each with its three rings. Dimming lamps flicker. |
| **Lesson** | A clean reading view, a Listen button, the textbook page reference, and a "Check yourself" button at the end. |
| **Practice / recall** | One question per screen with big tap targets and instant feedback with an explanation. A gold ring animates when you reach mastery. |
| **Exam Hall** | **No game styling.** It looks like the real exam. **OMR mode** (a bubble sheet, for pen-and-paper exams like TNPSC) or **CBT mode** (for computer-based exams). Timer, question palette, mark for review. |
| **Spin / Slot** | A full-screen festival scene with lights, a weighted spin, a confetti reveal, and an odds button you can always see. |
| **Clue Poker** | A dark teal table with brass chips. Clue cards flip with suspense, and avatars show "thinking" states. |
| **District Quest** | A stylised Tamil Nadu map board. Districts glow in their owner's colour, and event cards flip with comic art. |
| **Squad Battle** | 10 topic zones shown as tiles, with flags filling in live and a squad cheer feed. |
| **Rank-up** | A brass seal stamps your new rank title, then a "Share card" button appears. |
| **Store** | Premium cards with clear prices (GST included), a "what's inside" list, a sample, and ratings. |

### 10.7 Calm Mode (for 35+, or anyone)
A simpler Today screen (Today Card, Study, Relight) with bigger text, voice guidance, fewer animations, and competitive games hidden until you switch them back on. **Same account, same progress.** *(changed 2026-10-22, D-2026-10-22-02)* Calm Mode also **hides Study Room boards and live counts**; the focus timer still works.

### 10.8 Lite Mode (low-end phones)
It switches on automatically on phones with 3 GB of RAM or less. It uses a static map, simple animations, and compressed images. Every core feature still works.

### 10.9 Accessibility
- Works with **TalkBack/VoiceOver** screen readers
- Text can be scaled up to 200%
- High-contrast option
- Rings differ by **shape and colour**, so they're colour-blind safe
- Listen Mode for all text
- Tap targets are at least 48 dp

---

## PART D — BUSINESS

## 11. Free vs Pro

| Area | **Free** | **HeyMey Pro** |
|---|---|---|
| Eligibility Checker, Exam Alerts, exam pages | ✅ Full | ✅ |
| My Plan + auto-rebalance | ✅ | ✅ + life profiles (working / college / family) + pace forecast |
| Lessons | First 2 topics of every subject | **All topics** |
| State Board textbook map | ✅ Full | ✅ |
| Practice questions | 30 a day | **Unlimited** |
| PYQ Vault | Latest 2 years | **All years**, with topic and difficulty filters |
| Relight (revision) | For topics you can open | For everything |
| Full mocks | 1 a month + State Mock Sunday | **Full Exam Hall series** + Retry Wrong Only + Custom Test Builder |
| Readiness Meter | Coverage + Memory bars | **Full evidence report** + 7/30/90-day trends + speed and negative-marking analysis |
| Current Affairs | Last 7 days | **Full archive** + monthly packs |
| AI doubt help | 3 a month | **Fair use** (up to 30 a day) |
| Offline downloads | Free content | **Everything** |
| Listen Mode | Free content | Everything |
| Answer-key calculator | ✅ | ✅ |
| Cutoff history | Last year | **Full history** |
| Sunday Report | Short | **Full**, with next week's plan |
| **Games, squads, check-ins, events** | ✅ **Same for everyone** | ✅ **Same for everyone** |
| **Study Rooms, focus sessions, Hours Boards** *(changed 2026-10-22, D-2026-10-22-02)* | ✅ **Same for everyone** | ✅ **Same for everyone** |

Accessibility is never behind a paywall. Listen Mode and screen-reader support work on everything you can open.

## 12. Prices (GST included)

| Product | Price | Notes |
|---|---|---|
| **Pro Monthly** | ₹149 | Auto-renews. Cancel anytime. |
| **Pro Quarterly** | ₹399 | |
| **Pro Yearly** | ₹999 | |
| **Founding Pro Yearly** | ₹699 | **Only in the first 30 days after launch**, with the real end date shown. The price stays locked for renewals while the subscription stays active. |
| **Exam Pass** (one exam) | ₹399 | All Pro study features for one exam, until 30 days after that exam. Doesn't auto-renew. |
| **Season Pass** | ₹99 a season | Cosmetics only, with fixed rewards listed upfront. No random boxes. |
| **Sparks packs** | ₹19 (one-time starter) · ₹49 → 50 · ₹99 → 110 · ₹199 → 230 · ₹499 → 600 | For premium cosmetics, creator notes, and single mock packs |
| **Premium cosmetics** | 30–300 Sparks | Map themes (Madurai Temple Town, Chettinad, Nilgiris, Marina at Night), avatar outfits, lamp styles, squad banners |
| **Creator content** | 29–299 Sparks or the rupee price | Reviewed notes, mock packs, strategy guides |
| **Physical books** | MRP + delivery | From partner publishers, paid by UPI or card through Razorpay |
| **Institution licence** | ₹15,000–₹50,000 a year per batch | Invoiced |
| **Gift** | Same prices | Buy Pro, an Exam Pass, a Season Pass, or a cosmetic **for someone else**. Sparks are never transferred. |

## 13. What makes people pay (honest) vs what we never do

| Allowed trigger | Example |
|---|---|
| **A real limit at a high-intent moment** | After the 30th free question: "You're on a roll. Pro unlocks unlimited practice. ₹149/month or ₹999/year." |
| **Real exam urgency** | "Group 4 is 58 days away. In our data, aspirants who took 8+ full mocks in the last 60 days scored higher. Exam Pass: ₹399." (Shown only when the data is real.) |
| **Proof before payment** | Your free mock result shows a blurred preview of the full Pro report. |
| **Founding offer with a real deadline** | "Founding price ends 15 Feb." It really does end then. |
| **Pride** | On rank-up: "Celebrate with the Collector Brass lamp style." |
| **Belonging** | After a Squad Battle win: squad banner cosmetics. |
| **Family** | Supporters gift Pro for a birthday or the exam month. |
| **Season end** | "Season ends Sunday. You're on tier 24 of 30." This is a true statement. |

**Never allowed:**
- fake countdowns
- fake "others are buying" numbers
- guilt-trip buttons ("No, I don't care about my career")
- hidden auto-renew or a hard-to-find cancel
- hidden charges (prices always include GST)
- repeated nagging (each offer appears at most once a day)
- disguised ads
- blocking study to push a sale

These are banned by India's **Dark Patterns Guidelines 2023** (Section 30). Every paywall has a **"Not now"** button.

**Spending safeguards:**
- Users can set daily, weekly, and monthly spending limits.
- A monthly spend summary appears in Profile.
- Every purchase is confirmed with the phone's own biometric or password check.

## 14. Profit from month 1

### 14.1 Monthly running costs (estimate)

| Item | ₹ / month |
|---|---|
| Hosting at launch: Oracle Always Free VM + Supabase (Free → Pro $25 before public launch) + Cloudflare R2 + Vercel (marketing; Pro $20/mo if commercial use) + Firebase Hosting (ADR-0014) *(changed 2026-11-01, D-2026-11-01-01; marketing changed 2026-11-04, D-2026-11-04-01)* | ≈ 0 – 2,200 |
| Off-site backup storage (nightly pg_dump in Cloudflare R2, inside free 10 GB) *(changed 2026-11-01, D-2026-11-01-01)* | 0 |
| OpenRouter (in-app AI + content pipeline) | 30,000 |
| AI development agents | 40,000 |
| SMTP email service for OTP + transactional mail | 2,000 |
| Part-time subject reviewers (paid per item) | 60,000 |
| Launch marketing (education creators, library and study-hall posters, Telegram groups) | 1,00,000 |
| Domain, small tools | 5,000 |
| **Total** | **≈ ₹2.39 lakh** (was ≈ ₹2.47 lakh with the VPS) *(changed 2026-11-01, D-2026-11-01-01)* |

### 14.2 What we keep from each sale
App stores take **15%** from developers earning under $1M a year (Google Play, and Apple's Small Business Program). 18% GST is inside the price.

| Product | Price | We keep (approx.) |
|---|---|---|
| Pro Monthly | ₹149 | ≈ ₹107 |
| Founding Yearly | ₹699 | ≈ ₹503 |
| Exam Pass | ₹399 | ≈ ₹287 |
| Institution (direct invoice) | ₹15,000 + GST | ₹15,000 |

### 14.3 Month-1 target

| Source | Assumption | Net ₹ |
|---|---|---|
| Founding Yearly | 1,200 buyers | 6,03,600 |
| Pro Monthly | 1,000 buyers | 1,07,000 |
| Exam Pass | 500 buyers | 1,43,500 |
| Sparks, Season Pass, cosmetics | ₹50,000 gross | ≈ 36,000 |
| Institutions (pre-sold) | 5 × ₹15,000 | 75,000 |
| **Total** | | **≈ ₹9.65 lakh** |

**Profit target:** ≈ **₹7.2 lakh** in month 1.

**Break-even:** about **490 Founding Yearly buyers**, or about **2,310 Pro Monthly buyers**. Reaching **about 30% of the target is still profitable.**

**What the target assumes:** 60,000 installs (25,000+ of them from pre-registration) and 25,000 active users. That's an unusually high conversion rate, which is why the Founding offer and launching near a real notification matter.

**Cash timing:**
- Store money arrives **30–60 days after the month ends**, so month 1 is profitable on paper first.
- Razorpay book sales and institution invoices settle within days.
- **Keep 2 months of costs in the bank at launch.**
- Yearly plans arrive as cash up front, but accounts spread them over 12 months, so confirm the reporting with the CA.

### 14.4 How month-1 numbers become real
1. Store **pre-registration** opens 6 weeks before launch.
2. **Launch 3–6 weeks before an expected TNPSC notification.**
3. **Pre-sell 5+ institution licences** before launch: a free pilot month, then paid.
4. **Founding Yearly** gives people a real reason to buy in the first 30 days.
5. **State Mock Sunday #1 runs in launch week** and is free for everyone. Its report screen is the strongest point where free users decide to pay.

---

## PART E — ACCESS, ROLES, AND FLOWS

## 15. How each role uses HeyMey (app vs Desk)

**The answer:** one codebase, one login, one backend, **two front doors**:

1. **HeyMey app (mobile, Android + iOS):** the product. **Every** user lives here: aspirants, supporters, mentors, and squad captains. Partners and staff also get **quick actions** here.
2. **HeyMey Desk (web, at `desk.heymey.app`):** the **same Flutter codebase built for the web**. It's only for **partners and staff** doing desk work on a laptop: bulk uploads, large tables, reviewing hundreds of questions, analytics, and sensitive admin actions. **Aspirants can't log in to the Desk.** There's nothing for them there.

**Why this is the best setup:**
- An institution admin uploading 300 students, or a reviewer checking 200 questions, needs a big screen and a keyboard. Doing that on a phone is slow and leads to mistakes.
- Admin powers (prices, payouts, data deletion) are safer on a locked-down web Desk than on a phone that can be lost.
- It's still "all in one": one codebase, one account per person, one backend, one design system. The AI agents maintain it as one project.

| Role | Mobile app | HeyMey Desk (web) |
|---|---|---|
| Aspirant (Free / Pro) | ✅ Everything | ❌ No access |
| Squad Captain / Vice-Captain / Senior Member | ✅ Everything | ❌ |
| Supporter (parent, spouse, friend) | ✅ Supporter view | ❌ |
| Mentor | ✅ Everything | ❌ |
| Creator (educator) | ✅ Simple editing, sales, ratings | ✅ **Studio**: bulk upload, long-form editing |
| Reviewer | ✅ Quick review queue | ✅ **Review Desk**: high-volume review |
| Publisher partner | ✅ Order alerts | ✅ **Partner Desk**: catalogue, stock, orders |
| Institution admin | ✅ Batch summary, alerts | ✅ **Institution Desk**: student upload, seats, analytics, mock assignment |
| Support agent | ✅ Reply to tickets | ✅ **Support Desk** |
| Moderator | ✅ Quick actions on reports | ✅ **Moderation Desk** |
| Ops (exam data, events) | ✅ View + urgent alerts | ✅ **Ops Desk**: publish alerts, events, odds |
| Admin | ✅ Read-only dashboard + **emergency switch** (pause games, pause store) | ✅ **Admin Desk**: prices, payouts, roles, refunds, data deletion |

**Desk security:**
- Separate login with an **authenticator-app second factor**
- Desk access restricted by role
- **Admin and Ops pages accessible only through a protected access layer** (an IP allowlist or a private VPN)
- Short sessions, an audit log of every action, and two-person approval for money and data actions

## 16. Roles

| # | Role | How you get it |
|---|---|---|
| 1 | Visitor | Install the app (onboarding + Eligibility Checker only) |
| 2 | Aspirant (Free) | Sign up |
| 3 | Aspirant (Pro / Exam Pass) | Purchase |
| 4 | Squad Captain / Vice-Captain / Senior Member | Create a squad, or be promoted in one |
| 5 | Supporter | Accept an aspirant's Supporter invite |
| 6 | Mentor | Apply + proof of selection, verified by Ops |
| 7 | Creator | Apply + KYC (PAN, bank) + sample review |
| 8 | Reviewer | Invited by Ops |
| 9 | Publisher partner | Agreement + KYC |
| 10 | Institution admin | Agreement + invoice |
| 11 | Support agent | Staff |
| 12 | Moderator | Staff |
| 13 | Ops | Staff |
| 14 | Admin | Founder only (plus one trusted second approver) |
| 15 | System | Automation |

**Every action is checked on the server, every time.** Hiding a button is never the security.

## 17. Flows

### 17.1 Onboarding (about 3 minutes, value before login)

| Step | Screen | Rule |
|---|---|---|
| 1 | **Date of birth** | Under 18: "HeyMey is for 18+. See you on your 18th birthday." No account is created and nothing is stored. |
| 2 | Qualification, community category, Tamil-medium (PSTM) yes/no, special categories (optional) | One-tap choices, no typing |
| 3 | **Eligibility result:** "You're eligible for 23 exams" + top 5 + share card | Every exam links to its official notification, with the line "Always confirm with the official notification." |
| 4 | Pick your **main exam** (+ up to 2 more) | Shows how much the syllabuses overlap |
| 5 | **Your Study Map lights up** (5-second animation) | |
| 6 | **Light your first lamp:** a 2-minute micro-lesson + 3 easy questions | The tutorial *is* the product |
| 7 | **Save your progress:** enter your email → 6-digit code arrives → type or paste it (one tap opens the email app, and the code field accepts paste) | Login comes only after the user has something worth saving. There's a "Didn't get it? Check spam" hint, and resend unlocks after 60 seconds. |
| 8 | Consent screen (DPDP) | Short and clear. Optional choices are separate. Nothing pre-ticked. |
| 9 | "How many hours can you study on weekdays and weekends?" + exam date (auto-filled) | Builds My Plan |
| 10 | Suggested **Squad** (same exam, district, study hours) → Join or Skip | Asked again on day 3 if skipped |
| 11 | Alert permission: "Max 3 a day. Exam alerts always." | |
| 12 | Lands on **Today** with the plan ready and the lucky game already unlocked (a study task was just done) | Day 1 never feels empty |

### 17.2 Weekly and monthly
- **Weekly:** 2 Squad Battles, Clue Poker Night or Memory Pits, the weekend District Quest, News Hunt, and the Sunday Report.
- **Monthly:** a new Season (Season Pass, league reset, new cosmetics), a Squad Goal, the monthly Current Affairs pack (Pro), and 2 State Mock Sundays.

### 17.3 Exam season and after

| Time | What HeyMey does |
|---|---|
| 90 days before | **Final Stretch plan**: light the remaining lamps, more Gold attempts |
| 60 days | More mocks, weekly mistake review |
| 30 days | No new topics unless critical. Relight + mocks. |
| 7 days | Quiet games, sleep reminders, hall-ticket checklist, exam-centre tips |
| Exam day | Good-luck messages from your squad + recorded messages from supporters |
| After the exam | Answer Key Day → expected marks → objection reminders → result tracking |
| **Cleared** | Golden rank seal + alumni badge + invitation to become a Mentor. Your map stays forever. |
| **Not cleared** | **Attempt Review** (coverage, memory, speed, negative marking, nerves) → new season, same map, new plan → "Your preparation also fits these exams" |

### 17.4 Purchase flows

| Case | What happens |
|---|---|
| Buy Pro / Pass / Sparks | Store sheet → the store confirms → **our server verifies the receipt** → unlock. The phone never unlocks anything on its own. |
| Payment pending (UPI delay) | "Payment processing" is shown. It unlocks automatically once verified, and is never charged twice. |
| Payment failed | A clear message. Nothing unlocked, nothing charged. |
| Renewal | The store tells our server → Pro continues |
| Billing problem | The store's grace period keeps Pro on, with a gentle banner. If it isn't fixed, Pro pauses. **Progress is never deleted.** |
| Cancel | A "Manage subscription" button goes straight to store settings. Pro runs until the end of the paid period. |
| Refund / chargeback | The store tells our server → Pro ends, or Sparks are reversed. If they were already spent, the balance can go negative, and new Sparks repay it first. |
| New phone | Sign in → purchases restore automatically, plus a "Restore purchases" button (required on iOS) |
| Gift | The giver pays through the store → the receiver gets a claim notice → the item is attached to their account. Gifts never expire. |
| Physical book | Razorpay in the app → the publisher gets the order → tracking → delivered. The return policy is shown before payment. |
| Institution seats | Invoice paid → Ops activates the seats → the institution admin adds students by phone number (Desk) → each student gets a join invite |

### 17.5 Role flows
- **Squad Captain:**
  - Create the squad (name, banner, exam, district, study hours) → invite link → approve members.
  - Set the battle line-up and the weekly target, and promote Vice-Captains and Senior Members.
  - See squad activity, but **never a member's private scores**.
  - Hand over captaincy before leaving.
- **Supporter:**
  - The aspirant sends an invite → the supporter installs HeyMey → picks "I'm supporting someone".
  - They see **only what the aspirant allows** (days studied, rank, exam date, and scores only if shared).
  - They can gift, send encouragement, or record an exam-morning message.
  - **They can never see chats or private reports.**
- **Mentor:** apply → upload proof of selection → Ops verifies → mentor badge → answer doubts, host weekly Q&A rooms, publish "how I cleared" plans → earn **70% of net** from paid mentor content.
- **Creator:**
  - Apply → KYC + sample → approved.
  - Create in the app or the **Desk Studio** (including bulk spreadsheet upload). Every item goes through **review**, then it's listed in the Store.
  - Earn **70% of net**, paid monthly with TDS deducted. Ratings, error reports, and refunds are visible.
  - Three confirmed major errors trigger a review of the creator's listing rights.
- **Reviewer:** queue → check every answer against an **official source** (textbook page, official answer key, gazette, government site) → approve, fix, or reject with a note → every fix goes into the **public Correction Log** → the users who reported it are notified.
- **Publisher:** list books (edition, syllabus mapping, stock, price) in the Desk → **HeyMey editors alone decide "Recommended" tags (they can never be bought)** → orders → ship → tracking → monthly settlement minus commission.
- **Institution admin (Desk):**
  - Add students → private institution league.
  - **Batch-level** analytics (coverage, common weak topics, mock trends), and assign mocks.
  - Students choose whether their individual results are visible to the institution.
- **Support agent:** a ticket queue from in-app Help → sees the account, purchases, and logs (never card data) → fixes, restores, or refunds within policy → users see the ticket status. Targets: first reply within 24 hours, payment issues within 4 hours.
- **Moderator:**
  - Reports queue (chat, names, avatars, Help Requests answers) → warn, mute, or ban → appeals.
  - **Self-harm alerts come first:** the user is shown helpline details and a trained person follows up.
- **Ops:** the website watcher flags changes on official sites → **a human checks them** → publish the exam page and alert → run Notification Night → schedule seasons and events → watch game balance.
- **Admin (Desk):** prices, feature flags, payouts, refund overrides, roles, legal holds, data deletion. Two-person approval and an audit log for all of these.
- **System:**
  - Website watching every 30–60 minutes
  - The lamp dimming schedule
  - Plan rebalancing
  - Battle and duel matching
  - Sunday Reports
  - Receipt checks
  - Cheat detection
  - Health monitoring

## 18. Loophole check

| Possible loophole | How it's closed |
|---|---|
| Paying to play a game (which would make it a "money game") | No game accepts anything bought with money. Enforced in server code and permanent tests. |
| Game rewards turned into value | Rewards are only Points, Trophies, and cosmetics: they can't be transferred, redeemed, or converted to Sparks. |
| Pro giving game advantages | Pro and the Season Pass never change game limits, odds, or rewards. |
| Selling or trading Sparks | Sparks can't be transferred. Gifts are **specific items** bought by the giver. Account selling is banned and detected. |
| Farming free Sparks with fake accounts | Earned Sparks are capped (50 a month), need a verified email + a device integrity check, and come only from milestones that are hard to fake. Disposable email domains are blocked, and each device can earn milestone Sparks on only 1 account. |
| OTP abuse (spamming codes, guessing) | Max 3 codes per email per 10 minutes and 10 per IP per hour. Codes expire after 10 minutes. 5 wrong tries lock that code. Codes are stored hashed. |
| Referral fraud | No cash rewards. Invites give cosmetics and Points only, after the invited person studies for 3 days. |
| Under-18 users | Date-of-birth gate. Accounts reported as under 18 are paused until verified. |
| Cheating in duels or battles | The server decides every result. Questions are sent one at a time, answer speed is checked, the phone's integrity is checked, and duplicate devices are caught. |
| Offline answers used for ranks | Offline work counts for study progress only, never for ranked games, battles, or leaderboards. |
| Changing the phone clock | All timers use **server time**. |
| Leaving a duel to avoid losing | Counts as a loss after a 60-second reconnect window. |
| Refund after using Pro | A store refund ends access, and Sparks are reversed (the balance can go negative). |
| Repeated refund abuse | Flagged, and future purchases need a manual check. |
| Wrong eligibility or notification data | A human checks it before publishing, the official link is always shown, there's a "confirm with official notification" line, and a Correction Log. |
| Creators selling wrong or copied content | Review before listing, plagiarism check, user reports, and refunds charged to the creator's share. |
| Paid "Recommended" tags | Never sold. Recommendations are editorial only. |
| Taking users off the app for paid coaching through squad chat | Phone numbers and links are filtered in chat, repeat offenders are muted, and Mentors follow a code of conduct. |
| Harassment in squads | Report and block, a moderation queue, Captains can remove members, slow mode. |
| Deleting the account with an active subscription | The user is told to cancel in the store first. Then the account is deleted. Financial records are kept for the legally required period, and everything else is erased. |
| A stolen phone with admin access | Sensitive admin actions exist only on the protected web Desk (second factor + access layer). The phone has only read-only views and the emergency switch, and that needs the second factor. |
| Data leaks | Encryption, least-privilege access, audit logs, a breach plan, and reporting under the DPDP Rules. |
| Fake urgency or guilt text in offers | Every offer and paywall text is checked against the Dark Patterns list before release, and the founder approves it. |
| Changing the spin or slot odds secretly | Odds live on the server, are shown in the app, and every change is versioned and logged. |
| Exam postponed after buying an Exam Pass | The pass automatically follows the new exam date. |
| Faking study hours in Study Rooms (leaving the timer running, phone clock, scripts, two phones) *(changed 2026-10-22, D-2026-10-22-02)* | Server-timed sessions, presence heartbeats, auto-pause on missed heartbeats and background, "Still studying?" check, one session per account, device integrity, cheat flags, boards use only capped online hours (§9.11). |
| Unhealthy competition on hours (18-hour days) *(changed 2026-10-22, D-2026-10-22-02)* | Daily board cap, break and rest nudges, nothing celebrates hours above the cap, Calm Mode hides boards (§9.11). |
| Buying an advantage on Hours Boards *(changed 2026-10-22, D-2026-10-22-02)* | Firewall rule 5 (§5.3): nothing paid adds, protects or restores hours; permanent tests. |
| Abuse in public Study Rooms (names, avatars) *(changed 2026-10-22, D-2026-10-22-02)* | No free-text chat in rooms; report + block; moderation queue; offenders hidden from boards. |
| Exam-specific facts for new families entered wrongly *(changed 2026-10-22, D-2026-10-22-01)* | Same rule as eligibility data: cited official source (upsc.gov.in, icai.org, icsi.edu, …) + human check before publishing. |

---

## PART F — THE 100 ASPIRANT QUESTIONS, ANSWERED

**F** = Free · **P** = Pro or Exam Pass · **F/P** = basic free, full paid · **Later** = not in version 1

### 19.1 Choosing the right exam
| Q | Answer | Tier |
|---|---|---|
| 1 | The **Eligibility Checker** reads date of birth, qualification, degree subject, community, Tamil-medium status, and special categories, then lists every exam you qualify for, ranked by fit. | F |
| 2 | **Exam Compare:** posts, pay level, stages, syllabus, and past competition, side by side. | F |
| 3 | **Overlap view:** % of syllabus shared between exams. Shared lamps show more than one exam colour. | F |
| 4 | **Eligibility check per notification** with reasons (age with relaxation, qualification, category) + a link to the exact official clause. | F |
| 5 | **Jobs by qualification** (10th / 12th / Diploma / ITI / degree / postgraduate). | F |
| 6 | **Exam page:** official notification link, syllabus, pattern, vacancies, dates, eligibility, fees. | F |
| 7 | **Follow an exam** → an alert within hours of the official notification (after a human check). | F |
| 8 | **Vacancy view** by post and reservation category, exactly as published, with a source link. | F |
| 9 | **Selection timeline:** every stage, from prelims to counselling. | F |
| 10 | **"Your preparation also fits…"**: other exams ranked by overlap with your lit lamps. | F |

### 19.2 Starting and planning
| Q | Answer | Tier |
|---|---|---|
| 11 | **7-day starter path**, built automatically for your exam. | F |
| 12 | **My Plan** turns the official syllabus into subjects and lamps with time estimates on a calendar. | F |
| 13 | **Study-hour ranges** by exam, time left, and coverage. | F |
| 14 | **Life profiles** (working / college / family): short blocks, commute audio, weekend-heavy plans. | P |
| 15 | **Flexible weekly target** + 5/10/15-minute pocket sessions. Squads can be filtered by study hours. | F |
| 16 | **Today Card:** one clear "do this now". | F |
| 17 | The timetable is built automatically from your hours and your exam date. | F |
| 18 | **Auto-rebalance** after missed days, with a kind welcome-back. The check-in track waits, it doesn't reset. | F |
| 19 | **Pace forecast**: "At this pace you'll finish 12 days before the exam." | P |
| 20 | **Balance dial:** the mix of new topics, relights, PYQs, and mocks shifts as the exam nears. | F |

### 19.3 Books and resources
| Q | Answer | Tier |
|---|---|---|
| 21 | **Library book list** per subject with the right current editions. Editorial choice only. | F |
| 22 | **State Board textbook map:** each topic → class, chapter, and pages, linked to the official free textbook site. | F |
| 23 | **Free Path:** a real route using free official textbooks, free HeyMey lessons, and the latest PYQs. Pro adds depth and speed. | F/P |
| 24 | Study content is in **simple English**. **Tamil Language paper** content is in Tamil (that paper tests Tamil). Tamil-medium explanations for other subjects aren't in version 1. | F/P · Later |
| 25 | **No language switch.** One clean English interface, plus a **tap-to-see meaning** glossary for every hard word and exam term. | F |
| 26 | Tamil Language paper content is **written by Tamil experts**, not translated, with a "report an unclear question" button. | F/P |
| 27 | **Listen Mode** reads lessons, explanations, and notes aloud, even with the screen off. Tamil Language lessons have recorded human audio. | F (free content) / P (all) |
| 28 | **Offline downloads**. Answers sync later. | F (free content) / P (all) |
| 29 | **Verified badge** with source and last-checked date. **Syllabus Check** tells you whether an outside topic is in your syllabus. | F |
| 30 | **Essentials list** + "you don't need this" notes. | F |

### 19.4 PYQs and mocks
| Q | Answer | Tier |
|---|---|---|
| 31 | **PYQ Vault** filtered by exam, year, subject, topic, and difficulty. | F (2 years) / P (all) |
| 32 | Every question shows its **source (exam, year, number), the official answer, and a step-by-step explanation**. | F |
| 33 | Questions affected by later changes (new facts, deleted questions, revised keys) are **flagged with a note**. | F |
| 34 | **Report** on every question → tracked → you're told when it's fixed → public Correction Log. | F |
| 35 | Practise in the **real paper's format**: English for general subjects, Tamil for the Tamil Language paper. | F |
| 36 | **Exam Hall** mocks match the current official pattern, marking, and time. | F (1/month + State Mock) / P (full series) |
| 37 | **OMR mode** (bubble sheet) and **CBT mode**, with timer, palette, and mark for review. | F |
| 38 | **Mistake review:** why yours was wrong, why the answer is right, and which lamp to relight. | F |
| 39 | **Retry Wrong Only.** | P |
| 40 | **Custom Test Builder** (chapters, weak topics, unanswered questions, bookmarks). | P |

### 19.5 Progress and readiness
| Q | Answer | Tier |
|---|---|---|
| 41 | **Weak-spot finder** after every practice and mock, marked on your map. | F |
| 42 | **Coverage view:** Lit / Steady / Gold % for the whole syllabus. | F |
| 43 | The **three rings** answer it exactly: learned, remembered, exam-ready. | F |
| 44 | **7/30/90-day trends** for score, accuracy, coverage. | P |
| 45 | **Exam habits card:** accuracy, time per question, unanswered rate, marks lost to negative marking (where it applies). | P |
| 46 | **Readiness Meter:** four evidence bars (Coverage, Memory, Exam performance, Speed) + a plain label (*Not yet / Building / Close / Mock-ready*). **No single fake percentage.** | F (2 bars) / P (full) |
| 47 | **"Why did this change?"** shows the evidence. | P |
| 48 | The **"Ready for full mocks"** badge unlocks at clear thresholds. Before that, sectional tests are suggested. | F |
| 49 | **Cutoff history:** your mock range next to past official cutoffs, labelled "past data, not a guarantee". | F (last year) / P (full) |
| 50 | **Sunday Report.** | F (short) / P (full) |

### 19.6 Revision and current affairs
| Q | Answer | Tier |
|---|---|---|
| 51 | **Lamp dimming + Relight** = automatic spaced revision. | F/P (by access) |
| 52 | **Bookmarks, saved questions, "My Lists"**, which you can share with your squad. | F |
| 53 | **Pocket sessions** (5/10/15 min) + Memory Pits. | F |
| 54 | **Fact drills** (dates, Articles, formulas, events, literature) inside relights and Memory Pits. | F |
| 55 | **Daily Current Affairs cards** (date + source) + the weekly News Hunt. | F (7 days) / P (archive) |
| 56 | An **exam-relevance tag** on every card (High / Medium / Skip). | F |
| 57 | **Monthly pack**, downloadable. | P |
| 58 | **Aptitude Path:** step by step from the basics, with a placement check. | F (first levels) / P (all) |
| 59 | **Method-first explanations** with a "show next step" button. | F |
| 60 | **Mistake loop:** repeated mistakes create a concept drill + an explanation from another angle. | P |

### 19.7 Games, Sparks, competition
| Q | Answer | Tier |
|---|---|---|
| 61 | Duels, Clue Poker, Squad Battles, and District Quest all use **real exam questions**. | F |
| 62 | **Earn Sparks** from fixed study milestones (finish a subject unit, 10 Gold lamps, a State Mock, a helpful answer), up to 50 a month. Never from luck. | F |
| 63 | The **Store** shows every price. The **"Earn Sparks" page** lists every free way to earn them, and the cap. | F |
| 64 | Sparks buy creator notes, single mock packs, and premium cosmetics. Pro, Exam Pass, and books are bought directly. | F |
| 65 | **Honest answer:** you can prepare seriously for free (eligibility, alerts, plan, textbook map, latest PYQs, daily practice, a monthly mock, State Mocks, revision, audio). Pro gives the full depth and saves time. | F/P |
| 66 | Every game has a **rules card** (odds, limits, rewards) that you see before your first play. | F |
| 67 | Practice tables and practice duels have **no rank and nothing at stake**. No game ever uses Sparks. | F |
| 68 | **Confidence report** after every duel + a monthly chart. | F |
| 69 | **Friend challenge:** same questions, same time, a fair comparison. | F |
| 70 | **Kind leaderboards:** you see the top ranks and your own position only. You can hide yourself anytime. | F |

### 19.8 Phones, data, accessibility
| Q | Answer | Tier |
|---|---|---|
| 71 | Install size **≤ 40 MB**, content downloaded in packs, **Lite Mode** for 2–3 GB RAM phones, tested on low-cost phones. | F |
| 72 | **Offline-first** study + **Data Saver**. | F |
| 73 | **Wi-Fi-only downloads**, with overnight scheduling. | F |
| 74 | Text up to 200%, spacing, high contrast, dark and light themes. | F |
| 75 | **No third-party ads.** Nothing interrupts questions, lessons, or mocks. | F |
| 76 | Every answer **saves on the phone instantly**. Mocks resume exactly where you left off. | F |
| 77 | **HeyMey is a mobile app** (Android + iOS, phones and tablets). One account works on all your devices with full sync. | F |
| 78 | **Max 3 alerts a day** by default. Exam alerts are separate, offers are opt-in, and you can set quiet hours. | F |
| 79 | **Listen Mode**, screen-reader support, **Calm Mode**. | F |
| 80 | **Simple English everywhere**, plus a tap-to-see meaning glossary for hard words. | F |

### 19.9 Money, trust, privacy
| Q | Answer | Tier |
|---|---|---|
| 81 | **Price list** in the Store (GST included) + a **"spent this month"** view. | F |
| 82 | Every item is marked **Free** or **Pro** before you tap it. No surprise paywall in the middle of a lesson. | F |
| 83 | The **"Manage subscription"** button goes straight to store settings. The refund policy is shown before you buy. | F |
| 84 | Paid items show a **content list, sample, creator, review status, and ratings**. If an item isn't as described, you get a refund. | F |
| 85 | Errors are fixed and logged, and buyers are told. **Refund or credit** for major problems. | F |
| 86 | **Real human support**, with payment issues handled first. | F |
| 87 | **Ticket tracking** for app problems and content errors. | F |
| 88 | Data is stored on servers in India and encrypted. **Card details never reach HeyMey.** Short, clear privacy notice (DPDP Act). | F |
| 89 | **Privacy controls:** nickname, hide from leaderboards, choose what your squad, institution, and supporters see. | F |
| 90 | Study is never blocked by a sales screen. Competition is optional (Calm Mode). Data sharing is opt-in. | F |

### 19.10 The long journey
| Q | Answer | Tier |
|---|---|---|
| 91 | **Attempt Review** + a fresh-start plan that keeps all your lamps + a mentor who cleared after failing. | F (summary) / P (full) |
| 92 | **Problem finder:** coverage gaps, memory gaps, speed, negative marking, nerves (the drop between practice and timed tests). | P |
| 93 | **Final Stretch plans** at 90 / 60 / 30 / 7 days. | F |
| 94 | **Multi-exam mode:** exam colours on shared lamps, separate dates, one calendar. | F (up to 3 exams) |
| 95 | **Answer Key Day:** enter your answers → expected marks → objection dates → result tracking. | F |
| 96 | **Cutoff history** with vacancy changes, always labelled as history. | F/P |
| 97 | **Schedule-change alerts** + the plan stretches or shrinks automatically. The Exam Pass follows the new date. | F |
| 98 | **Wellbeing Corner:** breathing exercises, mentor stories, tips for family talks, squad support, and **Tele-MANAS 14416** (the free national mental-health helpline), always visible. | F |
| 99 | **Your map, history, and notes stay forever.** A new attempt is a new season on the same map. | F |
| 100 | **Measured every month:** more Gold lamps, fewer dimmed lamps, better accuracy and speed, fewer negative marks, shown in the Sunday Report. **We never promise selection.** | F/P |

---

## PART G — TECHNOLOGY (open source first, self-hosted on VPS)

## 20. The stack

### 20.1 App: Flutter (mobile app + Desk web build from one codebase)

| Need | Choice | Licence / cost |
|---|---|---|
| Framework | **Flutter (stable) + Dart** | Open source (BSD) |
| State management | **Riverpod** | Open source (MIT) |
| Navigation + deep links | **go_router** | Open source (BSD) |
| Models | **freezed + json_serializable** | Open source |
| API client | Generated from our **OpenAPI** spec with **openapi-generator** | Open source (Apache 2.0) |
| Game scenes (Spin, Slot, Clue Poker, District Quest, Memory Pits, Tiger Trap) | **Flame** | Open source (MIT) |
| Animations | **Rive** runtime (lamps, rank-ups, celebrations) | Runtime is open source (MIT). The design editor has a free plan. |
| Real-time (chat, duels, battles, live counters) | **socket_io_client** | Open source (MIT) |
| Offline database | **Drift (SQLite)** | Open source (MIT) |
| Secure token storage | **flutter_secure_storage** | Open source |
| Store purchases | Official **in_app_purchase** plugin (no paid middleman) | Open source |
| Book payments | **razorpay_flutter** | Free SDK (Razorpay charges per payment) |
| Push alerts | **Firebase Cloud Messaging** (Android) + APNs (iOS) | Free. There's no open-source way to reach phones reliably. |
| Listen Mode | **flutter_tts** (the phone's built-in voice: free and works offline) + **just_audio** for recorded audio | Open source |
| Crash reports | **sentry_flutter** SDK sending to our self-hosted **GlitchTip** | Open source |
| Phone integrity | Play Integrity (Android) + App Attest (iOS) | Free |
| Mobile builds and releases | **fastlane** + CI | Open source (MIT) |

### 20.2 Backend: TypeScript on Node.js

| Need | Choice | Licence |
|---|---|---|
| Runtime | **Node.js 24 LTS** | Open source |
| API framework | **NestJS** on the **Fastify** adapter | Open source (MIT) |
| Real-time | **Socket.IO** + **Valkey adapter** (scales across servers). Game rooms are **server-authoritative** and kept in Valkey. | Open source (MIT) |
| Database | **PostgreSQL 17** (self-hosted) | Open source |
| ORM + migrations | **Prisma** | Open source (Apache 2.0) |
| Cache, rate limits, leaderboards, game-room state | **Valkey 8** (fully open-source Redis-compatible) | Open source (BSD) |
| Background jobs + schedules | **BullMQ** (on Valkey) | Open source (MIT) |
| Search + duplicate detection | **PostgreSQL full-text search + pg_trgm** (no separate search server needed) | Open source |
| File storage (content packs, audio, images) | **Cloudflare R2** (S3-compatible, zero egress) at launch *(changed 2026-11-01, D-2026-11-01-01)*; SeaweedFS later if self-hosting | Open source (Apache 2.0) |
| Request validation | **Zod** (via nestjs-zod), with the **OpenAPI** spec generated from it | Open source (MIT) |
| Auth | Our own auth module: **email OTP** sent through **Nodemailer** over SMTP, **jose** JWT access tokens + rotating refresh tokens (hashed in the database), **TOTP** second factor (otplib) for Desk users. Only email login, so **Sign in with Apple isn't required** (Apple requires it only when third-party logins like Google are offered). | Open source libraries |
| Email delivery | A transactional **SMTP provider** (for example Zoho ZeptoMail, Amazon SES, or Brevo) on the `mail.heymey.app` subdomain, with **SPF, DKIM, and DMARC** set up. We send through SMTP but don't run our own mail server, because OTP codes must reach the inbox, not spam. | Small cost |
| Official-site watching | Self-hosted **changedetection.io** → sends a webhook to our API → a human checks the change | Open source (Apache 2.0) |
| Odds, feature flags, emergency switch | Our own tables + Desk screens | — |
| Product analytics | Our own event table in PostgreSQL (partitioned) + **Metabase** dashboards | Open source |
| Transactional email (invoices, partner mail) | Same SMTP provider as the OTP emails | Included above |

### 20.3 Infrastructure: VPS

> **Launch tier** *(changed 2026-11-01, D-2026-11-01-01)*: see ADR-0014. Postgres runs on **Supabase** (transaction pooler 6543 for the app, direct URL for migrations; Supabase Auth not used); files and packs on **Cloudflare R2** via `cdn.heymey.app`; marketing on **Vercel** (GitHub integration) *(changed 2026-11-04, D-2026-11-04-01)*; Desk on **Firebase Hosting**; api, realtime, worker, scheduler, Valkey, Caddy and changedetection on **one small VM** (Oracle Cloud Always Free ARM 4 OCPU / 24 GB; fallback Hetzner CX22). Errors/metrics: Sentry free + Grafana Cloud free, or self-hosted on the VM if RAM allows. Backups: nightly `pg_dump` to R2 (plus Supabase backups on Pro). The table below is the **target once revenue justifies a dedicated VPS**.

| Need | Choice | Licence |
|---|---|---|
| Server | **One VPS** in an Indian data centre (Bangalore / Mumbai / Chennai), **Ubuntu 24.04 LTS**. Recommended size at launch: **16 vCPU / 64 GB RAM / 500 GB NVMe**. The minimum workable size is 8 vCPU / 32 GB. | — |
| Containers | **Docker + Docker Compose**: every service is a container with memory and CPU limits, health checks, and `restart: unless-stopped` | Open source |
| Web server, TLS, load balancing | **Caddy** (automatic HTTPS) | Open source (Apache 2.0) |
| DNS, CDN cache, DDoS shield, Desk access protection | **Cloudflare free plan** (not open source, but free) | Free |
| Metrics + dashboards + logs | **Prometheus + Grafana + Loki + Grafana Alloy** | Open source |
| Uptime checks | **Uptime Kuma** on the VPS (internal checks), **plus one external free uptime check** (so we still get an alert if the whole VPS goes down). Alerts go to Telegram. | Open source (MIT) |
| Error tracking | **GlitchTip** | Open source (MIT) |
| Database backups | **pgBackRest**: daily full backup + continuous log shipping to **off-site** S3-compatible storage (Backblaze B2 or Cloudflare R2). **Monthly test restore.** | Open source (MIT) |
| Secrets | **SOPS + age** (encrypted secrets in the repo, decrypted only on the server) | Open source |
| Server security | UFW firewall, SSH keys only, **CrowdSec**, automatic security updates | Open source |
| Code hosting + CI | GitHub + GitHub Actions (backend). iOS builds need macOS: use **Codemagic's free tier** or GitHub's macOS runners. | Free tiers |

### 20.4 AI: OpenRouter

- **One OpenRouter API key, kept only on the server, never in the app.**
- **AI Gateway module** in NestJS. Every AI call goes through it.
- **Per-task model lists, stored in the database** so they can be changed without an app update. Each task has a **primary model plus fallbacks**, using OpenRouter's built-in fallback (the `models` list). If one model fails or is busy, the next one answers.

| Task | When it runs | Model choice |
|---|---|---|
| Write explanations for questions | Offline, in bulk, **once per question** (not per user) | Strong, low-cost model + 2 fallbacks |
| Independent answer check | Offline, for every question | **A different model family** from the writer, + fallbacks |
| Pro doubt help | Live, streamed | Fast mid-size model + fallbacks |
| Chat and answer moderation | Live | Small, fast model + fallbacks |
| Sunday Report and plan notes | Nightly batch | Small model + fallbacks |

- **Cost control:**
  - Pre-generate and **cache** everything that can be shared, so the same question's explanation is created once for all users.
  - Per-user limits (Free 3 a month, Pro 30 a day), a maximum length per answer, and a **monthly budget cap** with alerts at 50%, 80%, and 100%.
  - Ask OpenRouter for providers that **don't keep or train on our data**.
- **Privacy:** no names, phone numbers, or personal details are ever sent to a model, only the question and context.
- **Quality:** AI never publishes on its own. Every item needs a cited source + independent AI verification + the human checks in Section 26.

### 20.5 Licence note
Some tools (Grafana, Loki, Metabase, GlitchTip parts) use AGPL or similar licences. **Using them internally without changing and distributing them is fine.** Never copy their code into the HeyMey app.

## 21. Architecture: one VPS, everything in Docker

> At launch only api, realtime, worker, scheduler, Valkey, Caddy and changedetection run on one small VM; Postgres, file storage, marketing and Desk run on managed free tiers (ADR-0014). *(changed 2026-11-01, D-2026-11-01-01)* The diagram below is the target dedicated-VPS layout.

```
            Cloudflare (DNS · CDN cache · DDoS · Desk access protection)
                                     │ HTTPS only
                                     ▼
┌──────────────────── ONE VPS  (16 vCPU / 64 GB / NVMe, Ubuntu 24.04) ────────────────────┐
│  UFW: only 80/443 open (+ SSH on a non-default port, key-only, CrowdSec)                 │
│                                                                                          │
│  caddy ── api.heymey.app ─────────► api        (NestJS, 3 replicas)        ─┐            │
│        ├─ rt.heymey.app  ─────────► realtime   (Socket.IO, 2 replicas)     ─┤            │
│        ├─ desk.heymey.app ────────► desk       (Flutter web, static files) │            │
│        ├─ cdn.heymey.app ─────────► seaweedfs  (content packs, audio)      │            │
│        ├─ heymey.app ─────────────► site       (static legal pages + store links)       │
│        └─ ops.heymey.app (VPN/IP only) ─► grafana · glitchtip · metabase · uptime-kuma  │
│                                                                             │            │
│  worker      (BullMQ jobs, 2 replicas)  ◄──────────────────────────────────┤            │
│  scheduler   (cron-style repeatable jobs, 1 replica)                        │            │
│  postgres    (PostgreSQL 17, data on NVMe volume) ◄─────────────────────────┤            │
│  pgbouncer   (connection pooling)                                           │            │
│  valkey      (cache · queues · leaderboards · room state · socket adapter) ◄┘            │
│  seaweedfs   (S3-compatible file store)                                                  │
│  pgbackrest  (continuous WAL + nightly full → off-site storage)                          │
│  changedetection (official-site watcher → webhook to api)                                │
│  prometheus · node-exporter · cadvisor · postgres-exporter · loki · alloy                │
│  grafana · glitchtip · metabase · uptime-kuma                                            │
│                                                                                          │
│  Staging: separate Compose project ("heymey-staging") with low resource limits           │
│           and its own database, on staging-*.heymey.app                                  │
└──────────────────────────────────────────────────────────────────────────────────────────┘
        │ encrypted backups                         ▲ external uptime check
        ▼                                           │
  Backblaze B2 / Cloudflare R2                Free external monitor → Telegram

 Paid external services (only these): Google Play + App Store billing · FCM/APNs push (free)
 · SMTP email service · Razorpay · OpenRouter
```

**Resource limits (starting values, tuned after load tests):**

| Container | CPU | Memory |
|---|---|---|
| postgres | 6 | 24 GB (shared_buffers 8 GB) |
| api ×3 | 1 each | 1.5 GB each |
| realtime ×2 | 1 each | 1.5 GB each |
| worker ×2 | 1 each | 2 GB each |
| valkey | 1 | 4 GB (maxmemory 3 GB) |
| seaweedfs | 1 | 2 GB |
| monitoring stack | 2 total | 6 GB total |
| staging (all) | 2 total | 6 GB total |

Everything left over is headroom for State Mock Sunday spikes.

## 22. Core data model

```
User, Device, Session, Consent, RoleAssignment, TwoFactor
ExamFamily, Exam, ExamStage, Paper, PaperSection, MarkingScheme, ExamAttemptCycle   (changed 2026-10-22, D-2026-10-22-01; names for the architect ADR)
Notification, EligibilityRule, Syllabus, Subject, Topic(Lamp), TopicExamTag (tags a topic to exam/stage/paper)
StudyRoom, RoomMembership, FocusSession, FocusSegment, FocusDayTotal   (changed 2026-10-22, D-2026-10-22-02; names for the architect ADR)
Lesson, Question, QuestionVersion, Source, Explanation, Correction, Report, Glossary
UserTopicState (lit_at, steady_level, gold_at, next_due_at, dim_state)
PracticeAttempt, Answer, Mock, MockAttempt, MockAnswer
Plan, PlanItem, StudyLog
Product, Entitlement (pro, exam_pass, season_pass), Purchase, Refund, Gift
SparksLedger  (append-only, idempotency_key, source: purchase|milestone|spend|reversal)
PointsLedger  (append-only, separate table, no link to SparksLedger)
Squad, SquadMember, SquadBattle, BattleAttempt, HelpRequest, ChatMessage
GameRoom, GameResult, League, Trophy
Cosmetic, UserCosmetic, Season, SeasonPassProgress
Creator, CreatorItem, Payout, Publisher, Book, BookOrder
Institution, Seat, Ticket, ModerationCase, AuditLog, FeatureFlag, OddsConfig(versioned)
AiTask, AiModelRoute, AiUsage, AnalyticsEvent (partitioned)
```

## 23. Security and privacy

- **OWASP MASVS** (mobile) and **OWASP ASVS** (API) as checklists. An external penetration test before launch.
- HTTPS everywhere. Database disk encryption. Secrets via SOPS. **Nothing secret inside the app.**
- Every request is authorised on the server. Rate limits on OTP, login, purchases, AI, and chat.
- **Server-authoritative games:** questions are sent one by one, scoring happens on the server, and timing is checked.
- **DPDP:** consent records, clear purpose, access/correct/delete in Settings, a grievance officer, a breach plan. We **don't collect** contacts or location (the user picks their district).
- **Desk:** a second factor, admin pages behind protected access, short sessions, audit logs, and two-person approval for money and data actions.
- **Backups:** continuous, off-site, encrypted, and **restore-tested every month**.
- The database is never exposed to the internet. Servers talk over a private network only. At launch (Supabase, ADR-0014) the database is reached only over TLS with strong credentials, Supabase network restrictions limited to the VM IP and CI, and no public Data API (PostgREST disabled) *(changed 2026-11-01, D-2026-11-01-01)*.

## 24. Performance budgets

| Item | Budget |
|---|---|
| Install size | ≤ 40 MB |
| Cold start on a low-end Android phone | ≤ 2.5 s |
| Frame rate in Lite Mode (3 GB RAM phone) | 60 fps for screens, ≥ 30 fps for game scenes |
| API response time (95% of requests) | ≤ 300 ms |
| Saving an answer | Instant (saved on the phone first) |

## 25. Scaling on VPS

| Monthly users | Setup |
|---|---|
| Launch → ~10k | **Free/starter tiers (ADR-0014)** *(changed 2026-11-01, D-2026-11-01-01)*: one small VM + Supabase + Cloudflare R2 + Vercel (marketing) *(changed 2026-11-04, D-2026-11-04-01)* + Firebase Hosting. |
| Up to ~1.5 lakh | **The single VPS above** (or a bigger VM + Supabase Pro compute add-on). Scale by adding replicas inside Compose. |
| 1.5–5 lakh | Move **PostgreSQL to its own VPS** (the same Compose files, just a different host), and add a **streaming replica** on a third VPS for reads and failover. |
| 5 lakh+ | Separate VPS machines for API, real-time, and workers behind Caddy/Cloudflare load balancing. **Patroni** for automatic database failover. Table partitioning. Optionally move to **k3s**. |

Because every service is already a container with its configuration in environment variables, moving a service to another server is a configuration change, not a rewrite.

**Single-VPS failure plan:**
- Continuous off-site WAL backups, so at most a few minutes of data can be lost.
- A written runbook ("new VPS → install Docker → pull images → restore pgBackRest → switch DNS") practised every month.
- Target: **back online within 1 hour**.

**State Mock Sunday is the peak.** Load-test it at **5× the expected users** with **k6** (open source) before every one, and add a temporary extra app server for that weekend.

## 26. How the AI agents build HeyMey

### 26.1 Agents

| Agent | Responsible for |
|---|---|
| **Spec agent** | Turns this document into feature specs with acceptance tests |
| **Architect agent** | OpenAPI contract, data model, migrations, module boundaries |
| **Flutter UI agents** (2–3) | Screens, design-system widgets, accessibility, Desk web layouts |
| **Game agent** | Flame scenes, Rive animations, game feel and sound |
| **Backend agent** | NestJS modules, workers, receipt checks |
| **Realtime agent** | Socket.IO gateway, game rooms, battles, chat |
| **AI-gateway agent** | OpenRouter routing, fallbacks, caching, budgets |
| **QA agent** | Unit, widget, golden (screenshot), integration, and k6 load tests |
| **Security agent** | Reviews every change against MASVS/ASVS and the money/game firewall |
| **DevOps agent** | Docker Compose, Caddy, backups, monitoring, CI/CD |
| **Content agents** | Draft questions from official sources, write explanations, write Tamil Language paper content, plus a **separate verifier agent on a different model** |
| **Compliance agent** | Checks every offer, paywall, and text against the Dark Patterns list and the firewall |

### 26.2 Rules for the agents
1. This document is the spec. If something conflicts, **stop and ask the founder**.
2. **Every change must pass CI:** `dart analyze`, ESLint, tests, golden tests, a security scan (**Semgrep** + dependency audit, both open source), and the performance budget.
3. **Firewall tests can never be deleted** (for example: "no game endpoint accepts Sparks", "no game reward is Sparks").
4. **The founder approves:** merges to main, prices, legal text, store submissions, odds changes, and any code touching money or personal data.
5. **Content goes live only after:** a cited source + independent AI verification + human checks:
   - **100%** of eligibility and notification data
   - **100% of practice questions in the first 2 weeks** after launch, then a risk-based sample
   - **every** item a user reports

### 26.3 Humans still needed
- **Founder:** product owner, approver, grievance officer
- **Part-time subject reviewers** (paid per item), including Tamil Language paper experts
- **Chartered accountant** (GST, TDS, accounts) and a **lawyer** (gaming classification, terms)
- **Support and moderation:** AI drafts and sorts. A human handles payment disputes, bans, appeals, and self-harm cases.

## 27. Build plan: 4 weeks of engineering + parallel tracks

The AI agents build the **complete application in about 4 weeks** (the detailed week-by-week plan is in Section 43). Three tracks run **at the same time**, and **launch happens when all three are green**, not just the code:

| Track | Weeks 1–4 | Weeks 5–8 |
|---|---|---|
| **A. Engineering** (AI agents) | The full app + Desk + backend + games (Section 43) | Closed beta fixes, performance, store submission |
| **B. Content** (content agents + human reviewers) | Group 4 + Group 2/2A syllabus mapping, PYQs, lessons, explanations, Tamil Language paper. Eligibility data for all major exams. | 100% human review of the launch content |
| **C. Company & legal** (founder + CA + lawyer) | Incorporation, GST, D-U-N-S, store accounts, Razorpay, SMTP domain set-up, trademark, legal opinion, policies | Store pre-registration, institution pre-sales |

**Honest timing:** the code can be ready in ~4 weeks. **Public launch is realistically weeks 7–9**, because these steps have outside waiting times that agents can't speed up:
- D-U-N-S and store organisation accounts (1–3 weeks)
- Legal opinion
- Human content review
- Beta feedback
- Apple and Google review (allow 1–2 weeks with fixes)

**After launch (always running, never "done"):**
- **Month 2:** District Quest + the first Season Pass
- **Month 3:** Mentors, Supporters, Creator Studio, publisher books
- **Month 4 onward:**
  - Memory Pits, Tiger Trap, Dice Relay
  - New exams: Group 1, Police, TRB, then Bank, Railway, and SSC
  - *(changed 2026-10-22, D-2026-10-22-01)* Then the national and professional waves in §1a: CA and CS, then UPSC CSE (order to be confirmed by the founder). Track B content for a wave starts only after its official patterns are verified.
  - A new season every month and an event every week

*(If the agents finish features early, District Quest, Memory Pits, and Tiger Trap can ship at launch. They're kept for later only so the launch has fewer risks and each new game becomes a reason to come back.)*

---

## PART H — LAUNCH

## 28. Launch plan

1. **Pre-registration (from week 10)** on Google Play and the App Store. Everyone who pre-registers gets the **First Lamp badge** + a founding map theme.
2. **Squads form before launch:** study groups, library circles, and college friends reserve a squad name together during the beta. Early squads get a **founding squad banner**, so on day one people arrive together.
3. **Go where aspirants already are:** district central libraries, government free-coaching centres, private study halls (QR posters), Telegram and WhatsApp preparation groups, and education YouTubers and Instagram creators.
4. **Timing:** launch **3–6 weeks before an expected Group 4 / Group 2 notification**.
5. **Launch week: "First Lamp Fest":**
   - a statewide live lamp counter
   - a district-vs-district race
   - **State Mock Sunday #1** (free)
   - the Founding Pro offer for 30 days
6. **Shareable cards:** eligibility result, Rank Card, and State Mock rank. Every share carries a store link.
7. **Press story:** "A Tamil Nadu startup turned government-exam preparation into a game, and keeps it honest."
8. **Institutions:** at least 5 pilots signed before launch.

## 29. Metrics

| Metric | Month 1 | Month 6 |
|---|---|---|
| Installs | 60,000 | 4,00,000 total |
| Day-1 / Day-7 / Day-30 retention | 45% / 25% / 15% | 50% / 30% / 18% |
| Active days per week | ≥ 3.5 | ≥ 4 |
| Joined a squad within 7 days | ≥ 35% | ≥ 45% |
| Paying users / monthly active users | ≥ 8% (founding month) | 5–7% |
| Net revenue | ≥ ₹2.64L (break-even), target ₹9.65L | Growing every month |
| Content errors fixed within 72 hours | ≥ 90% | ≥ 95% |
| Refund rate | < 2% | < 2% |
| Store rating | ≥ 4.4 | ≥ 4.5 |
| "HeyMey helped me prepare better" (in-app survey) | ≥ 75% | ≥ 80% |

---

## PART I — LAW AND RISK

## 30. Compliance checklist

> This is a design and launch checklist, not legal advice. A lawyer and a chartered accountant must sign it off before launch.

| Law / rule | What it means for us | Action |
|---|---|---|
| **Promotion and Regulation of Online Gaming Act, 2025 + Rules 2026** (in force from 1 May 2026) | Bans "online money games": paying fees or stakes (**including coins bought with money**) expecting to win money or other enrichment, **skill or chance**. The regulator looks at the revenue model and whether rewards can be cashed or used outside the game. **Online social games are allowed.** | The firewall (Sections 5.3, 18). Get a written legal opinion. Check whether we must **register with the Online Gaming Authority of India**, and register if needed. |
| **Tamil Nadu Online Gaming Authority regulations (2025)** | Cover real-money games (not us). Upheld by the Madras High Court. | We follow them voluntarily: playtime reminders, games sleep at night, spending limits. |
| **Consumer Protection Act + Dark Patterns Guidelines 2023** | 13 banned design tricks (fake urgency, guilt-trip buttons, subscription traps, nagging, hidden charges…). | The compliance agent + the founder check every offer (Section 13). |
| **Consumer Protection (E-Commerce) Rules 2020** | Show seller details, full prices, refund policy, and a **grievance officer**. | Creator and publisher details on items. Grievance officer named in the app. |
| **IT Act + Intermediary Rules 2021** | Squad chat and user posts bring duties: user rules, a grievance officer, takedown timelines. | Community guidelines, report tools, a moderation time limit. |
| **DPDP Act 2023 + DPDP Rules 2025** (phased) | Consent, notice, purpose limits, user rights, breach reporting, parental consent for children. | 18+ only, consent screen, delete and download in Settings, breach plan. |
| **GST** | GST on subscriptions and digital items, and as a marketplace for creator sales. | Register before launch. Prices include GST. |
| **Income tax: TDS on payouts** | TDS on creator, mentor, and publisher payouts. | Collect PAN at KYC. The CA confirms the rules. |
| **RBI prepaid wallet rules** | Sparks are closed-loop (used only for HeyMey items, never withdrawn), so no RBI licence is needed. | Never add cash-out, user-to-user transfers, or spending at other businesses. |
| **TRAI DLT** | Applies only to commercial **SMS**. We use **email OTP**, so it doesn't apply. | Register only if we ever add SMS. |
| **Email rules (anti-spam best practice)** | OTP and service emails are transactional. Marketing email needs consent and an unsubscribe link. | SPF/DKIM/DMARC, no marketing email without opt-in. |
| **Apple App Store rules** | In-app purchase for digital items. Bought currency must not expire. "Restore purchases" button. Sign in with Apple is needed only if third-party logins are offered (we offer email only). **In-app account deletion is required.** Gambling-style art affects the age rating. | Follow all of them. Honest age rating (likely 18+). Festival-style Spin and Slot. |
| **Google Play policies** | Play Billing for digital items. Odds disclosure for paid random items. Rules for gambling-style content. Accurate data-safety form. | No paid random items. Odds shown anyway. Accurate forms. |
| **Copyright** | PYQs, textbooks, third-party material. | Link to official free textbooks. Cite sources on every PYQ. Write our own explanations. Get legal advice on reusing PYQs. |
| **Trademark** | Protect "HeyMey" + the logo. | File in classes 9, 41, 42 (the lawyer confirms). |
| **Companies Act** | Incorporation and records. | Incorporate before store accounts and payments. |

## 31. Pre-launch setup (in this order, each one blocks launch)

1. Incorporate **HeyMey Technologies Pvt Ltd** → PAN/TAN → bank account
2. **GST registration**
3. **D-U-N-S number** → **Google Play organisation account** ($25 one-time) + **Apple Developer organisation account** (about ₹8,700 a year)
4. **Razorpay** merchant account
5. **SMTP email service** on `mail.heymey.app` with SPF, DKIM, and DMARC. Test that OTP emails land in the inbox for Gmail, Outlook, and Yahoo.
6. **Trademark** filing
7. **Legal opinion** on gaming classification + the Online Gaming Authority registration question
8. Policies: Privacy, Terms, Refunds, Community Guidelines, Creator/Publisher agreements, Game Rules & Odds. Host them at **heymey.app**, because the stores require public policy links.
9. Grievance officer named in the app and the policies
10. (Optional) **Startup India (DPIIT)** recognition

## 32. Risks

| Risk | Response |
|---|---|
| Gaming law read more strictly | The firewall is already strict, the legal opinion is on file, and a switch turns all games into "practice only" within minutes. |
| Month-1 install target missed | Break-even needs only ~30% of the target. Institutions are pre-sold. Keep 2 months of cash in the bank. |
| The single VPS fails | Off-site continuous backups (a few minutes of data loss at most), monthly restore drills, a written rebuild runbook, and an external uptime alert. Target: back online within 1 hour. A database replica on a second VPS is added in the growth stage. |
| OTP emails go to spam or arrive late | A reputable SMTP provider, SPF/DKIM/DMARC, a plain-text OTP email with no images or links, a "check spam" hint, and a resend option after 60 seconds. Delivery time is monitored and alerts fire if 95% of emails take more than 30 seconds. |
| Content errors at launch | Human checks on 100% of eligibility data and 100% of questions for the first 2 weeks, a public Correction Log, fast refunds. |
| Flaws in AI-written code | CI gates, a security agent, an external penetration test, and founder approval on money and data code. |
| Slow on low-end phones | Lite Mode, performance budgets enforced in CI, regular testing on cheap phones. |
| Store rejection | Festival-style art, no paid randomness, correct in-app purchase use, honest ratings, and submitting 2 weeks early. |
| Toxic squads | Moderation, filters, Captain tools, quick bans. |
| "It's just a game" feeling | Every game uses real questions, the Exam Hall stays serious, and the Sunday Report shows study proof. |
| OpenRouter outage or a price change | Fallback model lists, cached explanations (most AI content is pre-generated), and in-app AI that degrades gracefully ("AI help is busy, here is the written explanation"). |

## 33. One-time setup budget (estimate)

| Item | ₹ |
|---|---|
| Incorporation + CA setup | 15,000–25,000 |
| Trademark (3 classes, startup fee) incl. attorney | 15,000–30,000 |
| Legal opinion + policy drafting | 50,000–1,00,000 |
| Apple + Google developer accounts | ≈ 11,000 |
| Penetration test | 40,000–80,000 |
| Beta content + reviewer onboarding | 60,000 |
| **Total** | **≈ ₹1.9–3.1 lakh** |

---

## PART J — ENGINEERING SPECIFICATION (for the AI agents)

## 34. Engineering principles (non-negotiable)

1. **The server is the source of truth.** The app shows what the server says. Scores, rewards, unlocks, timers, ranks, and purchases are all decided on the server.
2. **Offline-first for study, online-only for competition.** Study works offline and syncs later. Ranked games, battles, purchases, and leaderboards need a connection.
3. **Every write is idempotent.** Every write request carries an `Idempotency-Key`, so retries never double-count.
4. **One contract.** The OpenAPI spec is generated from the backend, and the Dart client is generated from that spec. Nobody hand-writes API models twice.
5. **Money paths are boring and strict.** There are 2 append-only ledgers (Sparks, Points), the money/game firewall has permanent tests, and every financial change happens inside a database transaction.
6. **Configuration over code for LiveOps.** Events, odds, seasons, prices, model routes, and feature flags live in database tables managed from the Desk, not in app releases.
7. **Everything observable.** Structured logs, metrics, and traces for every request. Every error reaches GlitchTip.
8. **Small, testable modules.** Each backend module owns its tables and exposes services, and no module reads another module's tables directly.

## 35. Repository layout (one monorepo)

```
heymey/                               (single Git repository)
├─ apps/
│  ├─ mobile_app/                     Flutter app (Android + iOS)
│  ├─ desk_web/                       Flutter web build target for HeyMey Desk
│  └─ site/                           Static legal pages for heymey.app (HTML)
├─ packages/                          Shared Flutter packages (used by mobile_app + desk_web)
│  ├─ hm_design/                      Design tokens, theme, components, Rive assets loader
│  ├─ hm_api/                         GENERATED Dart API client (from OpenAPI) — never hand-edited
│  ├─ hm_core/                        Auth/session, networking, error handling, feature flags
│  ├─ hm_data/                        Drift database, sync engine (outbox), repositories
│  ├─ hm_games/                       Flame game scenes (spin, slot, poker, quest, pits, tiger)
│  └─ hm_features/                    Feature modules (today, map, exam_hall, squad, store, desk_*)
├─ server/                            TypeScript backend (pnpm workspace)
│  ├─ apps/
│  │  ├─ api/                         NestJS HTTP API
│  │  ├─ realtime/                    NestJS Socket.IO gateway + game rooms
│  │  └─ worker/                      BullMQ workers + scheduler
│  ├─ libs/
│  │  ├─ db/                          Prisma schema, migrations, seed
│  │  ├─ domain/                      Business modules (see Section 36), shared by api/realtime/worker
│  │  ├─ contracts/                   Zod schemas → OpenAPI + socket event types
│  │  ├─ ai-gateway/                  OpenRouter client, routing, caching, budgets
│  │  └─ testing/                     Test factories, fixtures, fake clock
│  └─ package.json
├─ content/                           Content pipeline scripts + syllabus mapping files (YAML)
├─ infra/
│  ├─ compose/                        docker-compose.yml, compose.staging.yml, compose.monitoring.yml
│  ├─ caddy/                          Caddyfile
│  ├─ backup/                         pgBackRest config + restore runbook
│  └─ scripts/                        provision.sh, deploy.sh, restore.sh
├─ docs/
│  ├─ HEYMEY_PRODUCT_BLUEPRINT.md     (this document)
│  ├─ adr/                            Architecture decision records
│  └─ runbooks/                       Incident, restore, release, event-day runbooks
└─ .github/workflows/                 CI/CD pipelines
```

**Flutter structure inside each feature:** `presentation/` (widgets, screens) → `application/` (Riverpod controllers) → `domain/` (models) → `data/` (repositories using `hm_api` + `hm_data`).

**Desk:** `desk_web` reuses the same `hm_*` packages and adds only the desk screens. **Desk-only code is never included in the mobile app build**, and the mobile app ships only the quick-action desk screens.

## 36. Backend modules

| Module | Owns | Key responsibilities |
|---|---|---|
| `auth` | User credentials, OTP codes, sessions, refresh tokens, TOTP | Email OTP, JWT, refresh rotation, device binding, Desk 2FA |
| `users` | Profile, settings, privacy, consent | Profile, nickname, privacy controls, DPDP consent records, deletion and export |
| `roles` | Role assignments | Role checks (guards), Desk access |
| `exams` | Exams, notifications, eligibility rules, vacancies, cutoffs. *(changed 2026-10-22, D-2026-10-22-01)* Also exam families, stages, papers, sections, marking schemes, attempt cycles | Eligibility engine, Exam Alerts, exam pages, the exam-family catalogue |
| `syllabus` | Subjects, topics (lamps), mappings | Syllabus → Study Map, textbook mapping, glossary |
| `content` | Lessons, questions, versions, sources, explanations, corrections, reports | Content serving, versioning, Correction Log |
| `mastery` | UserTopicState | Lit/Steady/Gold rings, dimming schedule, relight, rank calculation |
| `practice` | Practice attempts, answers | Practice sessions, free daily limit, mistake loop |
| `exam-hall` | Mocks, attempts, answers | OMR/CBT mocks, State Mock Sunday, scoring, reports |
| `plan` | Plans, plan items, study logs | My Plan, Today Card, rebalance, final stretch |
| `readiness` | Derived metrics | Readiness Meter, trends, Sunday Report |
| `games` | Game rooms, results, odds config, leagues, trophies | Spin, Slot, Duel, Clue Poker, District Quest, Memory Pits, Tiger Trap |
| `squads` | Squads, members, battles, help requests, chat | Squads, Squad Battles, Squad Goal, chat, Help Requests |
| `focus` *(proposed, changed 2026-10-22, D-2026-10-22-02; needs an architect ADR)* | Study rooms, room membership, focus sessions and segments, IST day/week totals | Start/pause/end, heartbeat crediting, auto-pause, caps, Hours Boards (Valkey sorted sets), focus days, cheat flags. Squad Rooms check membership through `squads`' public API; hours go to `plan` study log through its public API; presence runs in `apps/realtime` |
| `economy` | SparksLedger, PointsLedger, cosmetics, seasons, pass progress | Currencies (with the firewall), cosmetics, Season Pass, check-in |
| `billing` | Products, purchases, entitlements, refunds, gifts | Store receipt verification, server notifications, entitlements, Razorpay |
| `marketplace` | Creators, creator items, payouts, publishers, books, orders | Creator Studio, publishers, book orders, payouts with TDS |
| `institutions` | Institutions, seats | Seat management, batch analytics |
| `support` | Tickets | Help tickets, status tracking |
| `moderation` | Reports, cases, sanctions | Chat filter, moderation queue, self-harm protocol |
| `notifications` | Push tokens, alert preferences, send log | FCM/APNs sending, the daily alert budget, quiet hours |
| `liveops` | Events, feature flags, emergency switch | Event calendar, flags, "pause games / pause store" |
| `ai` | AI tasks, model routes, usage | Doubt help, explanation generation, verification, moderation (via `ai-gateway`) |
| `analytics` | Events (partitioned) | Event ingestion for Metabase |
| `audit` | AuditLog | Every staff action logged |

## 37. API conventions

- **Base URL:** `https://api.heymey.app/v1`. Breaking changes go into `/v2`, and the old version is supported for 6 months.
- **REST + JSON.** Every request and response is described by **Zod** schemas, from which the **OpenAPI 3.1** spec is generated in CI.
- **Auth:** `Authorization: Bearer <access JWT>` (15-minute life). Refresh tokens last 60 days and **rotate on every use**. Reuse of an old refresh token **revokes the whole session family** (stolen-token protection).
- **Idempotency:** every `POST/PUT/PATCH` that changes state requires an `Idempotency-Key` header. The server stores the key + response for 24 hours.
- **Errors:** one format, `{ "error": { "code": "PRACTICE_DAILY_LIMIT", "message": "You've used today's 30 free questions.", "details": {...} } }`. Codes are stable, and messages are simple English the app can show directly.
- **Pagination:** cursor-based (`?cursor=...&limit=20`).
- **Time:** all timestamps are UTC ISO-8601. "Day" logic (check-in, daily limits, night sleep) uses **Asia/Kolkata**, calculated on the server.
- **Rate limits:** per user and per IP, kept in Valkey. Over the limit returns `429` with a `Retry-After` header.
- **App version gate:** every response carries `X-Min-App-Version`. Older apps show an "Update needed" screen (needed for urgent fixes).

## 38. Authentication flow (email OTP)

```
1. App → POST /v1/auth/otp/request { email }
   Server: normalise email, block disposable domains, rate-limit
           (3 per email / 10 min, 10 per IP / hour), create a 6-digit code,
           store a HASH of it (argon2id) with a 10-minute expiry,
           queue the email (BullMQ → Nodemailer → SMTP). Always respond 200
           (never reveal whether the email exists).
2. User receives a plain-text email: "Your HeyMey code is 482913. It expires in 10 minutes."
3. App → POST /v1/auth/otp/verify { email, code, deviceId }
   Server: max 5 tries per code, constant-time compare, then
           create the user if new, issue an access JWT (15 min) + refresh token (60 days),
           bind the session to the device, return the onboarding state.
4. App stores tokens in flutter_secure_storage. It refreshes silently before expiry.
5. Desk login = the same email OTP + a TOTP code from an authenticator app (required for
   every staff and partner role). Admin/Ops pages are also reachable only through the protected access layer.
6. Logout = revoke the refresh-token family. "Log out of all devices" is in Settings.
7. Delete account (in-app, required by Apple): confirm by OTP → a 7-day grace period
   (cancel by logging in) → personal data erased. Financial records are kept as the law requires.
```

## 39. Offline sync rules

- The **local Drift database** holds: downloaded content packs, the user's topic states, plan, bookmarks, and an **outbox** of pending actions.
- Every study action (answer, lesson complete, relight) is **written locally first**, then added to the outbox with a client UUID + timestamp.
- The sync engine sends the outbox in batches when online. The server **accepts each action once** (the UUID is the idempotency key) and returns the authoritative topic state.
- **Conflicts:** the server wins for rings, rank, and rewards. The client wins only for personal notes and bookmarks (last write wins).
- **Offline actions never earn** ranked rewards, trophies, battle flags, or Sparks. They earn only study progress (Lit/Steady), checked by the server on sync with time limits (an action older than 7 days when synced counts as a study log only).
- **Content packs:** versioned zip files (JSON + images + audio) on `cdn.heymey.app`, downloaded only on Wi-Fi by default and checked with a SHA-256 checksum.

## 40. Real-time and game rooms

- **Transport:** Socket.IO over WebSocket at `rt.heymey.app`, authenticated with the access JWT. The **Valkey adapter** lets the 2+ realtime containers share rooms.
- **Rooms:** `squad:{id}` (chat, battle updates), `match:{id}` (duel, poker, quest), `event:{id}` (live counters).
- **The server is authoritative.** The server holds the game state in Valkey (with a time limit), sends **one question at a time**, receives answers with timestamps, and scores everything itself. The client only displays.
- **Events** are typed in `contracts/`, for example `match.question`, `match.answer`, `match.result`, `poker.clue_revealed`, `poker.bet`, `battle.flag_captured`, `chat.message`.
- **Reconnect:** a 60-second window to rejoin with the full state restored. After that, the match is forfeited.
- *(changed 2026-10-22, D-2026-10-22-02)* **Study Rooms:** rooms `study:{roomId}` (public room group) and `squadstudy:{squadId}` (Squad Room). Start, pause, resume and end are **REST writes** with `Idempotency-Key` (`POST /v1/focus/sessions`, `…/{id}/pause`, `…/{id}/resume`, `…/{id}/end`; names for the architect). Socket events (to define in `contracts/`): client → server `study.join`, `study.leave`, `study.heartbeat` (session id + app state: foreground/background), `study.react`; server → client `study.presence` (studying-now count + member tiles), `study.session_state` (running / auto-paused with reason / ended, credited seconds), `study.board` (today/week top places + your place, capped), `study.check` ("Still studying?"), `study.nudge` (break / rest / sleep). Presence lives in Valkey with a time limit; credited time is written to PostgreSQL by `focus` on pause/end and at least every few minutes, so a server restart loses no credited time. A dropped connection is not a forfeit: the session auto-pauses at the last heartbeat and the user can resume.
- **Turn-based games** (District Quest) also save each turn in PostgreSQL, so a match survives server restarts and players can take turns hours apart.
- **Matchmaking:** Valkey sorted sets by trophy range. The range widens every 10 seconds. If no human is found within 30 seconds, the player is offered a **practice bot** (bot matches never give ranked trophies).
- **Spin/Slot outcomes** come from a server-side cryptographically secure random generator, using the **current versioned odds table**. The result + odds version are stored for audit.

## 41. Billing integration (Google Play, App Store, Razorpay)

| Flow | Implementation |
|---|---|
| **Android purchase** | `in_app_purchase` → purchase token → `POST /v1/billing/google/verify` → server checks it with the **Google Play Developer API** → grants the entitlement or ledger credit → **acknowledges** the purchase (within 3 days, or Google refunds it) |
| **Android lifecycle** | **Real-time developer notifications** (Pub/Sub push to `/v1/billing/google/rtdn`) for renewals, grace period, account hold, cancellations, refunds, and voided purchases |
| **iOS purchase** | StoreKit 2 → signed transaction → `POST /v1/billing/apple/verify` → server checks the signature with the **App Store Server API** → grant |
| **iOS lifecycle** | **App Store Server Notifications V2** to `/v1/billing/apple/notifications` |
| **Restore** | On login, the server returns the entitlements it already knows. The "Restore purchases" button re-sends store receipts. |
| **Physical books** | Razorpay order created on the server → Razorpay checkout in the app → **webhook with signature check** (`/v1/billing/razorpay/webhook`) → order confirmed. The app's success screen is never trusted. |
| **Institution invoices** | Razorpay Payment Links / invoices + webhook → Ops activates seats |
| **Ledger** | Every credit and debit is written to `SparksLedger` with a unique `idempotency_key` = the store transaction ID, so duplicate notifications never double-credit |
| **Entitlements** | One `Entitlement` table (pro, exam_pass, season_pass) with start/end dates and source. The app reads entitlements from the server only. |

## 42. Deployment, environments, and CI/CD

**Environments:**

| Environment | Where | Data |
|---|---|---|
| `local` | The developer's or agent's machine (Docker Compose) | Seed data |
| `staging` | The same VM, a separate Compose project with low limits; its own Supabase project *(changed 2026-11-01, D-2026-11-01-01)* | Anonymised copy or seed data. Never real personal data. |
| `production` | VM (api/realtime/worker) + Supabase + Cloudflare R2 + Vercel (marketing) + Firebase Hosting *(changed 2026-11-01, D-2026-11-01-01; marketing changed 2026-11-04, D-2026-11-04-01)* | Real |

**Pipeline (GitHub Actions):**

```
On every pull request:
  server:  pnpm install → lint (ESLint) → typecheck → unit tests → integration tests
           (Testcontainers: real Postgres + Valkey) → OpenAPI generate → diff check
  flutter: dart format check → dart analyze → unit + widget tests → golden tests
           → regenerate hm_api from OpenAPI and fail if it is out of date
  security: Semgrep, dependency audit (pnpm audit, osv-scanner), secret scan (gitleaks)
  firewall: permanent money/game firewall test suite

On merge to main (after founder approval):
  build server images → push to GitHub Container Registry (tagged by commit)
  → deploy to STAGING (ssh: docker compose pull && up -d, run migrations)
  → smoke tests + k6 quick load test against staging
  → manual "Promote" button → deploy to PRODUCTION:
       1. pg_dump to R2 (was: pgBackRest snapshot) (changed 2026-11-01, D-2026-11-01-01)
       2. prisma migrate deploy over the Supabase direct URL (only backward-compatible migrations: expand → migrate → contract)
       3. rolling restart of api/realtime/worker containers one by one (zero downtime behind Caddy)
       4. health checks; automatic rollback to the previous image tag if they fail

Mobile releases:
  fastlane builds Android (AAB) + iOS (IPA, on a macOS runner / Codemagic)
  → internal testing tracks (Play internal testing, TestFlight)
  → staged rollout in production: 10% → 50% → 100%, watching crash-free rate ≥ 99.5%
Desk web: built in CI → static files deployed to Firebase Hosting (was: the desk container) (changed 2026-11-01, D-2026-11-01-01)
Marketing: built and deployed by Vercel's GitHub integration (Preview per PR, Production on main) (changed 2026-11-04, D-2026-11-04-01)
```

**Rules:**
- Database migrations must never break the currently live app version.
- Feature flags hide unfinished features.
- Each release has release notes in simple English.

## 43. Four-week engineering plan (AI agents)

| Week | Server | App + Desk | Done when |
|---|---|---|---|
| **1: Foundation** | Monorepo, Compose stack (local + staging + prod), Caddy, CI/CD, backups, monitoring. Prisma schema v1. `auth` (email OTP), `users`, `roles`, `exams` + eligibility engine, `syllabus`, `content` serving | `hm_design` (tokens, theme, all core components, dark/light/high-contrast), app shell + 5 tabs, onboarding, eligibility result + share card, email OTP login, Study Map rendering, lessons, Listen Mode | A new user can install, check eligibility, sign in by email, and see their Study Map on staging |
| **2: Core study** | `mastery` (rings, dimming, relight scheduler), `practice`, `exam-hall` (OMR + CBT + scoring), `plan` (Today Card, rebalance), `readiness`, `notifications`, changedetection webhook → Exam Alerts | Today screen, practice/recall, PYQ Vault, Exam Hall, Readiness Meter, My Plan, Exam Alerts, offline packs + outbox sync, Calm Mode, Lite Mode | A user can study for a week offline/online, and lamps light, dim, and relight correctly |
| **3: Games, squads, money** | `economy` (ledgers, check-in, cosmetics, Season Pass), `games` (Spin, Slot, Duel, Clue Poker rooms, odds), `squads` (chat, Help Requests, Squad Battles), `billing` (Google, Apple, Razorpay, entitlements), `ai` gateway | Check-in, Daily Spin, Lucky Slot, Confidence Duel, Clue Poker, Squad screens + battles, Store, Pro/Exam Pass/Sparks purchase flows, paywalls (with the Dark Patterns checklist), AI doubt help | Purchases work end to end in the store sandboxes, and games run server-authoritatively with the firewall tests passing |
| **3b: Study Rooms MVP** *(changed 2026-10-22, D-2026-10-22-02)* | `focus` module (sessions, heartbeat crediting, auto-pause, caps, IST boards, focus days), `study.*` socket events in `realtime`, Squad Room via `squads`, firewall tests for rule 5 | Study Room + Squad Room screens, focus timer, Studying now, Hours Board, nudges, privacy toggles, Calm Mode hiding | A user can run a server-timed focus session in a room, faked time is not credited, boards show capped IST-day hours, and the firewall tests pass |
| **4: Desk, safety, polish** | `support`, `moderation`, `institutions`, `marketplace`, `liveops` (events, flags, emergency switch), `audit`, `analytics`, Desk APIs. Security hardening, k6 load test (State Mock Sunday scenario) | **HeyMey Desk** (Support, Moderation, Review, Ops, Admin, Institution, Creator Studio, Partner), staff quick actions in the app, accessibility pass, low-end phone performance pass, store listing assets | All "Definition of done" items (Section 45) pass on staging, and the build goes to closed beta |

**Where the 2026-10-22 decisions land** *(changed 2026-10-22, D-2026-10-22-01 and -02)*:
- **Exam-agnostic model (D-…-01): Phase 2.** It costs little now and a lot later. The `exams`/`syllabus` schema gets families, stages, papers, marking schemes and attempt cycles in Phase 2's schema bolt, and `exam-hall`, `plan`, `mastery` and `readiness` read them as data (INT-002 "Exam-agnostic build rules"). Only TN data is loaded. The descriptive paper type is **designed for but not built** in Phase 2.
- **Exam waves 1–3 (D-…-01): after launch** (§1a, §27), each as its own intent with Track B content. None blocks launch.
- **Study Rooms MVP (D-…-02): Phase 3, as row 3b**, after the `squads` and realtime bolts of week 3. Why Phase 3: it needs the realtime gateway and presence (built for games in week 3), the Squad Room needs `squads` (week 3), and it is a squad-style social loop, so it is tested with the same socket harness. Nothing in the blueprint argues for earlier: Phase 2 has no realtime gateway. Risks to watch, which could push it to Phase 4: (1) week 3 is already the heaviest, T2 week (money, games, billing), so Study Rooms goes **after** the week-3 money and game bolts and behind a feature flag, and it must never delay them; (2) the moderation queue and Desk arrive in week 4, which is why the MVP has no free-text chat and only reports + block (a report can be stored in Phase 3 and worked in the Desk in Phase 4); (3) the "studying now" fan-out adds realtime load, so the week-4 k6 run includes a Study Rooms scenario.

## 44. Testing strategy

| Layer | Tool | What |
|---|---|---|
| Backend unit | Vitest | Business rules: rings, dimming, scoring, eligibility, ledgers, firewall |
| Backend integration | Vitest + **Testcontainers** (real Postgres + Valkey) | API endpoints, transactions, idempotency, billing webhooks (with recorded store payloads) |
| Real-time | Socket.IO test clients | Matches, reconnects, cheating attempts (fast answers, replays) |
| Flutter unit/widget | `flutter_test` | Controllers, widgets, offline sync engine |
| Visual | Golden tests | Every key screen in dark, light, high-contrast, Calm, and large-text modes |
| End to end | **Patrol** (open source) on emulators | Onboarding → study → game → purchase (sandbox) |
| Load | **k6** | State Mock Sunday: 5× expected users starting at the same minute |
| Security | Semgrep, osv-scanner, gitleaks, an OWASP ZAP baseline scan on staging, plus an external penetration test before launch | |
| Content | Automatic: source present, answer verified by a second model, no duplicates (pg_trgm). Human: review queue | |

**Coverage targets:** 90% or more on `economy`, `billing`, `mastery`, `exam-hall`, `games`, and `auth`. 70% or more elsewhere.

## 45. Definition of done (for every feature)

- [ ] Matches this document (or the founder approved a change)
- [ ] API in the OpenAPI spec, with the Dart client regenerated
- [ ] Server-side permission checks + rate limits
- [ ] Idempotent writes
- [ ] Tests at the coverage targets, plus golden tests for the UI
- [ ] Works offline where Section 39 says it should
- [ ] Dark/light/high-contrast, Calm Mode, Lite Mode, and 200% text all checked
- [ ] Screen-reader labels on every control
- [ ] Simple English copy (Section 10.2) + Dark Patterns checklist (Section 13) for any offer text
- [ ] Logs, metrics, and errors visible in Grafana/GlitchTip
- [ ] Feature flag in place if it's risky
- [ ] Performance budget met on a 3 GB RAM Android phone

## 46. Moving from the old Next.js app

The old HeyMey (Next.js on the same VPS) is **replaced, not upgraded**. It was built for a different product shape, and the new stack is built cleanly for this one.

1. **Freeze** the old app: no new features. Export any real user emails (with consent to contact them) and any reusable, **verified** content (questions with sources) into the new `content/` pipeline for re-review.
2. **Build** the new stack under new subdomains (`api.`, `rt.`, `desk.`, `cdn.`) on the same VPS, with resource limits so both run side by side during the transition.
3. **Launch** the new apps on the stores. `heymey.app` switches to the new static site with store links.
4. **Shut down** the old app and its database after 30 days, and keep an encrypted archive backup for 1 year, then delete it.
5. Old users get an email: "HeyMey is now an app. Your First Lamp founding badge is waiting." (Only for users who agreed to be contacted.)

---

## Sources (legal research, October 2026)

- **Online Gaming Act 2025 & Rules 2026:**
  - [Mondaq](https://webiis10.mondaq.com/india/social-media/1785870/the-promotion-and-regulation-of-online-gaming-act-2025-and-the-promotion-and-regulation-of-online-gaming-rules-2026)
  - [SCC Online](https://www.scconline.com/blog/post/2025/08/24/promotion-regulation-online-gaming-act-2025-legal-reform/)
  - [PIB document](https://static.pib.gov.in/WriteReadData/specificdocs/documents/2026/apr/doc2026430859401.pdf)
  - [LawBhoomi](https://lawbhoomi.com/indias-online-gaming-law-2026/)
- **Tamil Nadu gaming regulations:**
  - [MediaNama](https://www.medianama.com/2025/02/223-tamil-nadu-tightens-online-real-money-gaming-rules/)
  - [Bar & Bench](https://www.barandbench.com/law-firms/view-point/madras-hc-upholds-tn-online-gaming-act-validates-regulatory-restrictions-on-real-money-games)
  - [Khaitan & Co](https://compass.khaitanco.com/tamil-nadu-gaming-regulations-implications-on-gaming-companies)
- **Dark Patterns Guidelines 2023:**
  - [SCC Online](https://www.scconline.com/blog/post/2023/12/04/ccpa-notifies-guidelines-for-prevention-and-regulation-of-dark-patterns-2023-legal-news/)
  - [JSA](https://www.jsalaw.com/newsletters-and-updates/ccpa-issues-guidelines-for-prevention-and-regulation-of-dark-patterns-2023/)
- **TNPSC Group 4 2025 (3,935 posts):**
  - [Careers360](https://news.careers360.com/tnpsc-group-4-result-2025-out-how-to-download-rank-position-login-details-required-3935-posts)
