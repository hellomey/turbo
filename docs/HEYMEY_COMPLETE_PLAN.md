# HeyMey — The Complete Plan
### Everything we've decided, how it works, and where it's going

*Written in plain English on purpose. Anything marked **(assumption)** still needs real user data to confirm it. Anything marked **(verified)** came from a checked source.*

---

## 1. What HeyMey Is, in One Paragraph

HeyMey is a daily companion app for Tamil Nadu students preparing for government exams like TNPSC Group 4, Group 2 and similar competitive exams. Most students today have no honest way to know if they're actually improving — they just collect more PDFs and hope. HeyMey fixes that with one honest number (a readiness score you can open up and understand), a five-minute daily habit that's genuinely fun to keep, and a game-like world around it that makes studying feel like something you *want* to open, not something you force yourself to do. It's free to start, makes money from people who want more, and is built by one person to run on a single server without needing a big team.

---

## 2. The Decision That's Now Final: One Product, Not Two

You asked for zero confusion here, so here it is stated once, clearly: **HeyMey is one product with one codebase, that runs as a website, an installable app on your phone's home screen, and a real Android app in the Play Store — all from the same code.**

- It is built as a modern web app (Next.js).
- On a phone, it installs like a real app (a "Progressive Web App") — icon on the home screen, works with a weak signal, sends notifications.
- It is also wrapped (using a tool called Capacitor) into a real Android app for the Play Store, and later an iOS app for the App Store, from that same code.
- On a laptop, the exact same app just works in the browser, full screen, no separate "web version" to maintain.

**Why this and not building two separate apps (one native app, one website):** you are one person. Building and maintaining two completely separate codebases means every new feature gets built twice, forever. This approach gives you a real app-store presence, a working website, and a phone-installable app, all from one place. The only real cost is slightly less buttery animation than a fully native app — which does not matter for a study app the way it would for a high-end game.

---

## 3. Brand, Name, and Domain

- **Legal company name (recommended):** HeyMey Technologies Private Limited.
- **Brand name shown to users:** **HeyMey.**
- **Domain:** you've now settled on **heymey.app**. Buy `heymey.in` and `hellomey.com` as well if you haven't, purely as defensive redirects so nobody else can build confusion around your name later.
- **Why "HeyMey" and not just "Mey":** your own trademark search found 20+ existing marks on the bare word "Mey." A two-word name like "HeyMey" is much easier to actually own and defend.
- **The meaning behind it, kept real, not decorative:** *Mey* (மெய்) means "truth" in Tamil, and in classical Tamil grammar it's also the word for the "body" that gives raw sound its shape. Thirukkural 423 says it directly: no matter who tells you something, wisdom is seeing the true substance underneath it. That's the whole brand promise in one old sentence: HeyMey shows you the real picture, not comforting noise.
- **In-app currency:** **Sudar** (சுடர், meaning "spark" or "flame") — the little flash of understanding when something finally clicks.
- **Mascot:** **Sudi**, a small, simple flame character with four moods (resting, bright, sleepy, thinking). Not a cartoon kid, not an animal — a living symbol of the Sudar currency itself.

---

## 4. The Legal Reality You Need to Know Before Building Any Game Mechanics

You shared screenshots of a gamified platform (OVAL) with a poker room and a slot machine, and asked about bringing that kind of addictive, game-like energy into HeyMey. Before designing anything in that direction, here is something you must know, because it changes what's actually legal to build in India right now.

**India passed the Promotion and Regulation of Online Gaming Act, 2025 (verified).** It completely bans "online money games" — any game where a person pays or deposits something, in the hope of winning money or anything of monetary value back, whether the game involves skill, chance, or both. This removes the old "it's legal because it's skill-based" argument that poker and rummy apps used to rely on. The ban applies to real-money poker rooms, real-money slot machines, and anything that works like them — deposit, play, win-or-lose real value. Running such a game can mean up to 3 years in prison and a ₹1 crore fine for the operator. Banks and payment gateways are also banned from processing money for these games.

**What this means for HeyMey, clearly: we can absolutely borrow the fun, colorful, game-like energy of something like OVAL — the avatars, the rooms, the spin animations, the leaderboards, the sense of a living, playful world — but nothing in HeyMey can ever let a student put in money (or Sudars bought with money) for a *chance* at winning something back.** The good news is this was already how Sudar was designed from the start: Sudars are earned through study, can be bought with real money at a flat, fixed rate, and are spent on real, guaranteed features (unlocking a mock test, extra AI help) — never on a game of chance. That design was always legal. We just now have an extra, very good reason to never change it.

---

## 5. The Addiction Engine — Built Like a Game, Built Legally

This is the actual new plan: take everything exciting about a platform like OVAL, and rebuild it around real study effort instead of gambling.

### 5.1 The world, not just the app

Instead of a plain dashboard, HeyMey opens into a living space: a top ticker scrolling real, recent activity ("Priya in Salem just hit a 7-day streak," "Team Vetrivel Pod reached Silver rank," "Arun just solved his 50th doubt"), your own avatar and rank badge always visible, and a sidebar that feels like a game lobby — Daily Flash, Study Pods, Mock Test Arena, Leaderboard, Store — instead of a plain settings-style menu.

### 5.2 The Daily Spark Spin (the "slot machine," made legal and honest)

Once a day, after finishing the Flash Challenge, a student gets **one free spin** on a wheel — not a slot machine with cash symbols, a bright, satisfying spinning wheel. It never costs anything, and it never requires paying to spin again. It can land on: a Sudar bonus, a Sudi mascot outfit, a rare profile badge, a "double Sudars today" boost, or (most of the time) a small guaranteed Sudar amount so it never feels like a loss. This gives you the dopamine hit of a spin mechanic — which is genuinely one of the most addictive and well-loved interactions in gaming — with zero gambling, because nothing was ever risked to get it.

### 5.3 Study Rooms (the "poker room," rebuilt around a real exam)

Instead of a poker table, a **live Study Room**: 4 to 6 students join a round table (visually, just like the OVAL image, cartoon avatars and all), and everyone answers the same live question at the same time. Points for speed and accuracy, visible on a timer in the middle of the table, with reactions and a simple chat. This is just a lively, multiplayer version of the Battle Mode already planned — same backend, far more exciting presentation.

### 5.4 Ranks, tiers, and a real sense of progress

Bronze, Silver, Gold, Platinum, Diamond — exactly like OVAL's rank system — but earned entirely through real study behavior: consistency, accuracy, Study Room wins, and helping others in the doubt forum. A visible progress bar always shows how close you are to the next rank.

### 5.5 Events (the "Events" tab)

Weekly and monthly tournaments tied to real exam prep: a Sunday "Exam Wars" where everyone takes the same mock test and the leaderboard is shown live, seasonal pushes timed to real TNPSC notification windows, and small cosmetic or Sudar prizes for top performers in each district.

### 5.6 The Store (cosmetic only, never pay-to-win)

Spend earned or purchased Sudars on: Sudi outfits and accessories, profile frames and banners, custom Study Room themes, and streak-shield top-ups. **Never** on anything that changes your actual readiness score or gives you an unfair test advantage — that would break the one promise the whole brand is built on: honesty.

### 5.7 The live social feed (the "Eagles approved a deal" ticker)

A constantly updating, real feed of genuine events happening across HeyMey right now — streaks hit, ranks earned, doubts answered, Study Rooms won. This is one of the single most effective things in the OVAL screenshots: it makes the app feel alive and populated, the moment you open it, even if you personally haven't done anything yet today.

### 5.8 Why this is not "too simple and minimalist"

Every part of Section 5 is deliberately colorful, animated, and game-forward — cartoon avatars, spinning wheels, live tickers, rank badges — because you were right that a plain, minimal, "obviously AI-made" dashboard will not hook an 18-to-35-year-old audience the way a game does. The honesty and trust principles from earlier stay exactly the same underneath; they just now live inside a much more exciting shell.

---

## 6. Who Uses HeyMey

| Role | Who they are | What they get |
|---|---|---|
| **Aspirant (the main user)** | A student preparing for a Tamil Nadu government exam, 18–35, mostly on a mid-range phone | The whole gamified world in Sections 5 and 7 |
| **Creator** | A teacher, retired officer, or someone who already cleared the exam | Uploads study material, earns 75% of every sale |
| **Institution** | A small coaching centre or college | Bulk access for their students, a progress dashboard for the whole batch |
| **Admin** | You | A simple control panel: approve content, watch for problems, see the numbers |
| **Parent** (planned for later) | A parent who wants to see their child's weekly progress | A gentle weekly summary, nothing invasive |

---

## 7. The Complete User Journey (From Install to "No End")

You asked for a flow with "no end" — meaning this isn't a funnel that finishes at a sale, it's a loop that keeps going for years, through multiple exam attempts.

**Day 0 — Discover and install.** A student sees HeyMey through a friend, a study group, or a college stall. They install it in under 20 seconds — no app store wait needed if they use the installable web version, or a normal Play Store install if they prefer. First screen shown is something alive (a live counter, a real success story), never a blank login box.

**Day 0 — Onboarding, with zero friction.** One question per screen, never a long form: which exam, when it is, which district, what language. No payment, no permissions dump, no 10-field sign-up form. Account creation happens through a simple phone or email code — not a password to remember. By the end of onboarding (under 3 minutes), the student already has a personal scorecard waiting for them: here's roughly where you stand, here's what's typical for your exam.

**Day 1–7 — The hook.** Every day, a short, fun Flash Challenge, a spin on the wheel, and one weak topic to fix. The first streak milestone (day 3 or day 7) triggers a genuinely exciting celebration, not just a tiny badge.

**Week 2–8 — The habit sets in.** Study Pods form, Study Room battles start, the readiness score becomes something they check the way they'd check a game's XP bar. Sudars accumulate fast enough from daily play that a consistent student can unlock real value without ever paying.

**Exam notification arrives.** The whole app shifts mode: a sprint plan, more frequent mock tests, a live countdown that matters.

**Exam day and after.** Calm mode during the exam window, then a free answer-key scorer the moment results are expected — a moment almost every competitor ignores, and one of the highest-traffic, highest-trust moments available.

**Result day — cleared or not, the story doesn't end.** If cleared: a public "cleared the exam" badge, a share card for social media, an invite to become a Creator and help the next batch. If not cleared (the more common outcome, given how competitive these exams are): the very next day, a next-attempt plan is already built from their full history — nothing starts from zero. This is the "no end" you asked for: the same account, the same streak history, the same Sudar balance and rank, carries a student through attempt after attempt, for years if needed.

---

## 8. Why People Come Back Every Single Day

Five real, separate reasons, each addressing a different kind of motivation:

1. **Progress you can see** — the readiness ring, the rank badge, the streak counter.
2. **Social pull** — the live ticker, Study Pods, Study Room battles against real people.
3. **A small reward every day** — the free spin, Sudar drops, rank-up moments.
4. **Real usefulness** — it actually tells you what to study today, which saves real time.
5. **No guilt if you miss a day** — a streak shield forgives one missed day automatically, so a single bad week doesn't make someone give up on the whole app.

---

## 9. Design Direction: Dark, Vivid, and Alive — Not a Plain AI Template

Your latest landing page direction (dark background, glowing purple and mint colours, a cosmic hero scene, the HeyMey logo with a glowing மெய் badge) is the right instinct, and it should carry through the whole app, not just the marketing site:

- **Dark theme throughout**, rich blacks and deep purples, with mint-green and gold used as bright accent colours for important numbers, buttons, and live/active states.
- **Big, bold typography** for key numbers (readiness score, rank, streak) — never a tiny, cramped dashboard font.
- **Real motion everywhere**: the spin wheel actually spins with weight, rank-ups have a real celebration animation, the live ticker genuinely scrolls.
- **Cartoon-style, warm character art** (Sudi, and optionally stylised student avatars for Study Rooms) instead of plain stock icons.
- **Avoid at all costs:** a flat white or grey dashboard, a cold "enterprise SaaS" look, tiny thin fonts, or anything a student would mistake for a boring school portal.

---

## 10. Technical Architecture (Short Version)

- **One Next.js codebase** for the website, the installable phone app, and the Android app (via Capacitor).
- **PostgreSQL** database, **Redis** for speed and real-time features (the live ticker, Study Room battles run on this), background workers for the daily content generation and spin-wheel logic.
- **Sudar ledger:** every Sudar movement goes through one single, carefully guarded function, so nothing can ever be double-spent, duplicated, or lost — this matters even more now that Sudar is the backbone of the whole game layer.
- **AI** is used only where it's genuinely needed: explaining a doubt, writing today's current-affairs questions, checking new content for quality. It is never used to calculate your readiness score or your rank — those stay simple, fixed, honest formulas you could explain to someone in one sentence.
- **Hosting:** one well-configured server is enough for your first many thousands of users. No need for a complicated multi-server setup this early.

---

## 11. How It Makes Money

- **Free to start, always.** The daily game loop, the first diagnostic test, and basic features are free for everyone — this is what builds the habit and the trust.
- **HeyMey Pro:** a simple paid plan unlocking unlimited mock tests, deeper readiness detail, and more AI help.
- **The Cycle Pass:** one payment that covers a student through a full exam cycle, since that's how aspirants already like to pay for test series.
- **Sudars for sale:** students who don't want to wait can buy Sudars directly, at a fixed, simple price — never a lucky-draw purchase, always a guaranteed amount.
- **Institutions:** coaching centres and colleges pay for batch licences — this is actually your fastest, most reliable route to covering your monthly costs.
- **Creator marketplace:** a healthy share (75%) goes to the teacher or creator every time their material sells, which keeps good people uploading good content.

---

## 12. Why HeyMey Is Genuinely Different

Every existing TNPSC app is basically a big pile of quiz questions with a streak counter bolted on. None of them:
- Tell you an honest, explainable readiness score tied to your actual district and category cutoff.
- Let you battle real people live, in a fun, visual Study Room.
- Give outside teachers and past achievers a real, fair way to earn money by contributing content.
- Build a genuine game world around studying — most feel like a plain quiz app with no personality.
- Carry your whole multi-year journey (across several exam attempts) in one place, with the story framed around your progress, not just your scores.

---

## 13. Launch Strategy for a Big First Impression in Tamil Nadu

- **Seed with real study groups and educators first**, not cold ads — a trusted teacher sharing it with their students is worth more than any ad spend.
- **Launch the live ticker and Study Rooms from day one**, even with a small user base — a quiet, empty-feeling app on day one kills momentum; a lively one, even with 50 real users, feels alive.
- **Time the big push to an actual TNPSC notification window**, when interest is naturally at its highest — never launch into a quiet period.
- **Use the free answer-key scorer around the next exam's result day** as a zero-cost way to reach a huge number of aspirants at the exact moment they're searching for exactly this kind of help.
- **Run a stall at a college fest or a startup event** (as already planned) to collect the first few hundred real sign-ups and immediately seed the live ticker and the first Study Pods with real activity.

---

## 14. Security and Keeping This Scalable

- Every Sudar transaction is locked down against double-spending from day one, not added later.
- Clear rules for who can do what (students, creators, admins) are enforced at every single screen and every single backend route, not just the ones that seemed obviously sensitive.
- Student data (especially anything about exam category, which can be sensitive) is collected only with clear consent, and can always be deleted on request.
- The whole system is built to comfortably handle tens of thousands of daily users on one well-configured server before anything more complicated is needed — so growth doesn't force a rebuild.

---

## 15. What's Already Built vs. What's New in This Plan

**Already built and working:** accounts and onboarding, the daily Flash Challenge, mock tests with real scoring, the AI doubt solver, a transaction-safe Sudar ledger, spaced revision, basic Study Pods, and an admin panel.

**New in this plan, not yet built:** the live activity ticker, the Daily Spark Spin wheel, visual multiplayer Study Rooms (upgrading plain Battle Mode into the OVAL-style live room), rank tiers and rank-up celebrations, the cosmetic-only Store, and the full dark, game-like visual redesign described in Section 9.

---

## 16. What This Plan Depends On (Be Honest With Yourself Here)

This whole addictive-game layer only works if the honesty underneath it is real. The moment a readiness score feels fake, or a Study Room feels rigged, the fun wrapper stops mattering and the trust is gone for good. Build the game layer with real excitement — but never let it touch the one thing that has to stay completely straight: the truth about where a student actually stands.
