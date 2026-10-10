# HeyMey Marketing Site: Build Spec for the AI Agent

**Purpose:** pure marketing. No login, no dashboards, no payments, no product features on this site. Every "use the product" action links out to the app.
**Reference:** the existing root hero (the Tamil Nadu golden-hour coast scene, the "Where you truly stand. What to do today." headline, the glass nav pill, the black "Begin Journey" button). It is the visual standard for everything below.

---

## 0. Prime Directives (read first, never violate)

1. **The root hero at `/` is frozen.** Do not change its background, layout, typography, spacing, nav pill, or buttons. You may change only its **text**, through `content/home.ts`.
   - Before touching anything, take Playwright screenshots of `/` at 1920×1080, 1440×900, 1280×720 and 390×844. Save them as baselines.
   - Every later change must keep the pixel diff at or under 0.1%, or the change is rejected.
   - Exceptions that need the founder's approval are listed in §5.4.
2. **No vertical scrolling by design, on any route.** Every page is either (a) a single fixed-viewport scene or (b) a horizontal track of full-viewport panels (§3). One accessibility safety net is allowed (§3.5).
3. **Marketing only.** Auth, payments, dashboards and anything stateful live in the app on `app.heymey.in`.
4. **Honesty over hype.** Obey the Claims Register (§7). If a claim is not in the register as allowed, do not write it. Never invent numbers, testimonials, logos, awards or counters.
5. **Low-end phones first.** The audience uses mid-range Android on patchy 4G. Video must degrade gracefully (§4.5). Performance budgets in §9 are acceptance criteria.
6. **Accessible:** WCAG 2.2 AA. Motion must be pausable and must respect `prefers-reduced-motion`.
7. **Private by default:** no third-party trackers, no ad pixels. Forms record explicit consent (§8).
8. **No dark patterns:** no fake urgency, no countdowns except real exam dates, no shaming copy, no pre-ticked boxes.

---

## 1. Stack and Hosting Assumptions

Your dev URL (`localhost:5173/#studio`) suggests React + Vite with hash navigation. This spec assumes that. Adapt names if the stack differs.

| Item | Decision |
|---|---|
| Framework | React + TypeScript + Vite |
| Routing | **Path-based routes** (React Router). Replace hash navigation. Add a redirect so legacy `/#studio`-style links land on `/studio` |
| Prerendering | **Prerender every route to static HTML at build time** (for example `vite-react-ssg`, or a Vite prerender plugin). A client-only SPA gives search engines and link previews an empty page |
| Content | Typed content files (`content/*.ts`) with `en` and `ta` keys from day one. Journal articles in MDX |
| Styling | Reuse the hero's existing CSS and tokens. Do not add a competing design system |
| Motion | CSS and a small motion library. Lottie only for small illustrations (≤ 60 KB each) |
| Hosting | Static files behind Caddy and Cloudflare on the existing VPS, or Cloudflare Pages |
| Domains | **Marketing: `heymey.in`. Product app: `app.heymey.in`.** If the earlier plan put the app at the root domain, move it to the `app.` subdomain and update the app's auth URL and cookie domain accordingly |
| Forms backend | One small endpoint on the app's backend (§8). Do not build a second backend |

---

## 2. Sitemap and Navigation

### 2.1 Route table

Types: **F** = fixed single scene. **H** = horizontal panels. **R** = horizontal reader (multi-column text).

| Route | Page | Type | Panels | Phase |
|---|---|---|---|---|
| `/` | Home (frozen hero) | F | 1 | 1 |
| `/studio` | Product tour | H | 7 | 1 |
| `/exams` | Choose your exam | F + cards row | 1 (+ horizontal card row) | 1 |
| `/exams/tnpsc-group-4` | Exam detail | H | 5 | 1 |
| `/result-day` | Result Day toolkit | H | 4 | 1 |
| `/pricing` | Plans | H | 4 | 1 |
| `/about` | Story and principles | H | 6 | 1 |
| `/trust` | Our promise | H | 6 | 1 |
| `/faq` | Questions | H | 4 | 1 |
| `/journal` | Article index | F + card row | 1 (+ horizontal card row) | 1 |
| `/journal/:slug` | Article | R | n/a | 1 (3 articles) |
| `/contact` | Reach Us | F | 1 | 1 |
| `/institutions` | For coaching centres and colleges | H | 5 | 1 |
| `/begin` | Waitlist ("Begin Journey" entry) | F | 1 | 1 |
| `/legal/privacy` | Privacy policy | R | n/a | 1 |
| `/legal/terms` | Terms of use | R | n/a | 1 |
| `/legal/refunds` | Refund and cancellation | R | n/a | 1 |
| `/legal/grievance` | Grievance officer | F | 1 | 1 |
| `/404` | Not found | F | 1 | 1 |
| `/creators` | For educators (invite-only waitlist) | H | 5 | 2 |
| `/download` | Get the app | F | 1 | 2 (when Android is ready) |
| `/exams/tnpsc-group-2` | Exam detail | H | 5 | 2 |
| `/press` | Brand assets | F | 1 | 2 |
| `/legal/cookies` | Only if any non-essential cookie is ever added | R | n/a | 2 |

Utility files: `/sitemap.xml`, `/robots.txt`, `/journal/rss.xml`, per-route Open Graph images.
Redirects: `/signup`, `/login`, `/app` → `https://app.heymey.in`. `/pro` → `/pricing`. `/blog` → `/journal`.

### 2.2 Top navigation (keep exactly what exists)

**Home · Studio · About · Journal · Reach Us** and the black **Begin Journey** button. Do not add items, chevrons, dropdowns or restyle the pill. Secondary routes are reached as below.

| Primary item | Route | Secondary routes reached from it (via the "Also explore" row on the last panel of the page) |
|---|---|---|
| Home | `/` | none (the hero stays pure) |
| Studio | `/studio` | `/exams`, `/result-day`, `/pricing` |
| About | `/about` | `/trust`, `/faq` |
| Journal | `/journal` | none |
| Reach Us | `/contact` | `/institutions`, `/creators`, `/download` |

"Studio" means the product tour ("what we build and how it works"). Keep the label and route even if you rename it later.

The hero's secondary button **Explore Syllabus** goes to `/exams`.

### 2.3 CTA state machine (one flag controls every "Begin Journey")

Set `APP_STATE` in config:

| State | "Begin Journey" goes to | Helper text under the form or button |
|---|---|---|
| `waitlist` (now) | `/begin` | "Closed beta opening soon. Join the list." |
| `beta` | `https://app.heymey.in/signup` | "Invite-only beta." |
| `live` | `https://app.heymey.in/signup` | none |

The visible label stays "Begin Journey" in all states.

### 2.4 Edge UI (replaces the footer, since there is no vertical scroll)

- **Bottom bar on every page except Home:** left: `© HeyMey · Privacy · Terms · Refunds · Grievance`. Centre: panel dots (on H pages). Right: ‹ › buttons, a **Pause background** toggle, and an **All pages** button that opens a full-site overlay listing every route in groups.
- **Disclaimer text in the overlay and on `/exams*`:** "HeyMey is an independent product. It is not affiliated with TNPSC or the Government of Tamil Nadu."
- **Home (`/`):** adding anything here changes the frozen hero. See §5.4 (needs approval). Until approved, the same links live only in the mobile menu overlay and in the `/sitemap.xml`.
- **Mobile menu:** full-screen overlay, 48px tap targets, focus trap, Escape to close. Groups: Product, Learn, Company, Legal.

---

## 3. Layout System: Scenes and Panels

### 3.1 Model

- A **Scene** is one route. A **Panel** is one `100vw × 100dvh` screen inside a horizontal **Track**.
- Components to build once and reuse: `Scene`, `PanelTrack`, `Panel`, `VideoBackground`, `EdgeBar`, `PanelDots`, `MenuOverlay`, `CtaButton`, `AlsoExplore`, `Reader`, `LeadForm`.
- Use `100dvh`, never `100vh`. Respect safe-area insets (`env(safe-area-inset-*)`).

### 3.2 Panel content budget (so nothing ever needs vertical scroll)

| Element | Limit |
|---|---|
| Headline | ≤ 9 words |
| Body | ≤ 35 words on desktop, ≤ 28 on mobile |
| Bullets | ≤ 3, each ≤ 10 words |
| Buttons | 1 primary + 1 secondary |
| Visual | 1 hero visual per panel |
| Type | `clamp()` fluid scale; body never below 16px |

Layout: desktop = text left, visual right; mobile = visual above (about 38% of height) and text below. Landscape phones (height ≤ 450px): hide secondary text and shrink the visual.

### 3.3 Navigation behaviour

- **Touch:** native horizontal scrolling with `scroll-snap-type: x mandatory`.
- **Wheel:** when a vertical wheel event occurs over a Track, convert it to panel steps (accumulate `deltaY`, trigger at a threshold, debounce about 600 ms). Never hijack when the pointer is over a form field, a textarea, or an element marked `data-no-wheel`, and never when `ctrlKey` is set (browser zoom). Pass native horizontal `deltaX` through.
- **Keyboard:** ← → PageUp PageDown Home End. Space/Enter only on focused buttons.
- **Mouse drag** with pointer events, and the dots and ‹ › buttons.
- **Deep links:** panels have ids (for example `/studio#practise`). Update the hash with `history.replaceState` (no history spam).
- **Focus:** when focus enters an off-screen panel (Tab), scroll that panel into view.
- **Transitions:** 500–650 ms ease; instant when `prefers-reduced-motion`.

### 3.4 Accessibility specifics

- Track: `role="region"`, `aria-roledescription="carousel"`, `aria-label`. Each panel: `role="group"`, `aria-roledescription="slide"`, `aria-label="3 of 7"`.
- Announce the panel change politely (`aria-live="polite"`).
- **Do not use `aria-hidden` on off-screen panels.** Their text must stay available to screen readers and crawlers.
- Every motion must be pausable (WCAG 2.2.2): the **Pause background** toggle stops video and decorative animation, and the choice persists.
- Text over video sits on a scrim gradient that guarantees a 4.5:1 contrast ratio. Test the contrast against the poster image.

### 3.5 The one allowed fallback

At 200% text zoom or with large system fonts, content can exceed the viewport. **Never clip it.** The panel's inner container gets `overflow-y: auto` only as a fallback.

**QA rule:** at default zoom, at every viewport in the test matrix, no route may show a vertical scrollbar. The fallback must never be visible in normal use.

### 3.6 Viewport test matrix

360×640, 375×667, 390×844, 412×915, 768×1024, 1024×768, 1280×720, 1366×768, 1440×900, 1920×1080, and landscape phone 844×390.

---

## 4. Animated Video Backgrounds

### 4.1 Art direction (one world for every page)

Painterly-cinematic **golden hour in Tamil Nadu**: amber and marigold light, soft haze, slow gentle motion, inclusive of every community's landmarks (the hero already mixes a temple gopuram, a church spire and mosque domes beside the Valluvar statue). Rules for every clip:
- No readable text, no logos, no recognisable faces or people, no sacred figures as the focus.
- Slow, subtle motion only: no fast cuts, no camera shake.
- **Seamless 8–12 second loop.**
- All overlay text is real HTML, never baked into the video.

### 4.2 Scene brief per route

| Route | Scene | Core prompt idea |
|---|---|---|
| `/studio` | Pre-dawn study window | A small-town window, warm lamp on a wooden desk, notebooks and a tea glass, curtains moving, terracotta roofs and palms brightening to gold; tiny marigold embers drifting from the lamp |
| `/exams` | Fields to town | Slow aerial glide over green paddy fields and a rural road at golden hour toward a distant town with a gopuram silhouette; birds crossing the sky |
| `/exams/*` | Reuse `/exams` scene | One video, fewer downloads |
| `/result-day` | New day over the sea | Calm waves at sunrise, light shifting from deep blue to gold, one distant fishing boat, soft cloud drift |
| `/pricing` | Lamp-lit lane | Blue-hour lane, strings of warm bulbs swaying, soft bokeh |
| `/about` | Palm-leaf manuscript | A palm-leaf manuscript on wood, a stylus tracing glowing abstract strokes (unreadable), dawn light sliding across |
| `/trust` | Still pond at morning | Ripples settling into stillness, mist lifting, clear reflection |
| `/faq` | Banyan canopy | Dappled light through a banyan canopy, leaves swaying, fireflies at dusk |
| `/journal` | Rainy window | Soft rain on a window, notebooks and a steaming tea glass, book pages turning in the breeze |
| `/contact` | Evening veranda | Hanging lamp, jasmine garlands swaying, palms beyond, warm bokeh |
| `/institutions` | Empty classroom | Sunbeams sweeping across wooden benches and a blank blackboard, dust motes, open windows to palms |
| `/creators` | Teacher's desk | Chalk, handwritten notes under a lamp, pages lifting, an ink pen drawing abstract lines |
| `/download` | Phone glow at dusk | A phone resting on a wooden table, a soft screen glow, window light fading to dusk (no readable UI) |
| `/begin` | The kolam draws itself | A kolam (floor pattern) drawing itself on a doorstep at dawn in glowing white lines, marigold petals drifting |
| `/404` | Quiet crossroads | A signpost at a paddy crossroads at dusk, drifting dust, fireflies |
| `/legal/*`, `/journal/:slug` | **No video** | Calm static gradient with fine grain. Reading pages stay light and quiet |

Roughly 12 unique clips. Each downloads only on its own route.

### 4.3 Technical specs

| Item | Desktop | Mobile (≤ 768px) |
|---|---|---|
| Aspect | 16:9, 1920×1080 | 9:16, 720×1280 (generate a separate portrait version; cropping 16:9 loses the composition) |
| Length | 8–12 s seamless loop | same |
| Formats | MP4 (H.264) + WebM (VP9). AV1 optional | same |
| Size cap | ≤ 3 MB | ≤ 1.5 MB |
| Poster | AVIF + WebP + JPG, ≤ 120 KB | ≤ 70 KB |

```bash
# Desktop MP4 (adjust CRF until under the size cap)
ffmpeg -i in.mp4 -vf "scale=1920:-2,fps=24" -c:v libx264 -crf 29 -preset slow -pix_fmt yuv420p -an -movflags +faststart out-1080.mp4
# WebM
ffmpeg -i in.mp4 -vf "scale=1920:-2,fps=24" -c:v libvpx-vp9 -crf 38 -b:v 0 -an out-1080.webm
# Mobile portrait
ffmpeg -i in-portrait.mp4 -vf "scale=720:-2,fps=24" -c:v libx264 -crf 30 -preset slow -pix_fmt yuv420p -an -movflags +faststart out-720.mp4
# Poster from a clean frame
ffmpeg -i out-1080.mp4 -frames:v 1 poster.jpg
```

### 4.4 `VideoBackground` component behaviour

- Markup: `<video muted loop playsinline preload="none" poster="…">` with WebM and MP4 sources (WebM first).
- Show the **poster first**. Start the video only after first paint and idle time (`requestIdleCallback`), and fade it in over the poster.
- Pause when the tab is hidden or the scene is off-screen. Only one video plays at a time.
- Preload the next route's poster only, never its video.
- Cross-fade between route posters on navigation.

### 4.5 When NOT to play video (show the poster instead)

Show a still poster with a very slow CSS drift (scale 1 → 1.05 over 30 seconds, disabled under reduced motion) when any of these is true:
- `prefers-reduced-motion: reduce`
- `navigator.connection.saveData === true`
- `navigator.connection.effectiveType` is `slow-2g`, `2g` or `3g` (where the API exists)
- The user has chosen **Pause background**
- The device reports very low memory (`navigator.deviceMemory` ≤ 2)

### 4.6 Animated visuals inside panels

CSS, SVG or small Lottie only. Needed: the readiness ring filling with its four sub-bars; a question card with answer selection and a checkmark; a chat typing animation; Sudi in four states (resting, bright, sleepy, thinking); the exam-calendar timeline advancing; a kolam line-draw for `/begin`. Keep each ≤ 60 KB.

---

## 5. Design Tokens and Components

### 5.1 Inherit, don't invent

- Extract colours, fonts, radii and spacing from the existing hero into `tokens.css`. The extraction must render the hero identically (§0.1).
- Reuse the hero's font stack. Do not add new display fonts. Tamil text uses Noto Sans Tamil.
- Buttons: black pill primary (as in the hero), soft cream pill secondary. Marigold is an accent for chips, rings and highlights only.
- Sudi (the flame mascot): resting, bright, sleepy and thinking SVG states. Use him sparingly: success states, empty states, loading, the 404.

### 5.2 Content in files, not JSX

Every page's copy lives in `content/<page>.ts` as `{ en: {...}, ta?: {...} }`. Components never hard-code strings.

### 5.3 Per-page meta

Each route has a unique `<title>` (≤ 60 chars), meta description (≤ 155), canonical URL, Open Graph and Twitter images, and `lang`.

### 5.4 Changes that touch the frozen hero (require the founder's explicit approval)

1. **Replace `®` with `™` next to "HeyMey".** The ® symbol states that a mark is registered. Using it for an unregistered mark is prohibited under Section 107 of India's Trade Marks Act, 1999 (the penalty provisions were amended in 2023, so ask counsel for the current penalty). Use ™ until the registration actually exists. This is the only change I strongly recommend.
2. A one-line low-contrast row on `/`: `Privacy · Terms · Refunds · All pages`. Many payment and compliance reviews expect to see policy links on the homepage.
3. Optional: `text-wrap: balance` on the hero headline, to avoid the "What to / do today." line break.

If any of these are declined, leave the hero untouched.

---

## 6. Page-by-Page Specs and Copy

Copy is final-draft quality. `[ ]` marks values the founder must supply (§12). Never replace a placeholder with an invented value.

### 6.1 `/` Home (frozen)

- Meta title: `HeyMey: an honest daily companion for TNPSC aspirants`
- Meta description: `Know where you truly stand and what to do today. A calm daily companion for Tamil Nadu government-exam aspirants.`
- **Allowed text changes only.** Current headline stays: *"Where you truly stand. What to do today."*
- Subhead, second person (replaces the third-person line):
  *"An honest daily companion for Tamil Nadu's government-exam aspirants. It shows you where you truly stand, and what to do today."*
- Buttons: **Begin Journey** (state machine, §2.3) and **Explore Syllabus** → `/exams`.
- Add Organization and WebSite JSON-LD. No layout change.

### 6.2 `/studio` (7 panels, deep-link ids in brackets)

Scene: pre-dawn study window. Never advertise features that are not live in the beta (§7).

| # | Id | Headline | Body | Visual |
|---|---|---|---|---|
| 1 | `intro` | Inside HeyMey. | Four quiet ideas, built for a phone and five spare minutes. | Looping phone mockup |
| 2 | `know` | A readiness score you can open up. | See where you stand today, how sure we are, and what moved it. No black box. | Ring fills; four bars labelled *how well · how often · how much of the syllabus · which way you're heading* |
| 3 | `practise` | Five minutes a day, aimed at you. | A daily challenge and a revision list built from what you got wrong, not random drills. | Question card with selection and checkmark |
| 4 | `understand` | Ask in Tamil or English. | Stuck on a concept? Get a clear explanation in seconds, in the language you think in. Footnote: AI explanations can be wrong. Report errors and we fix them. | Chat typing animation |
| 5 | `return` | A habit that forgives. | Miss a day and your streak gets a shield, not a scolding. Sudi, our little flame, is on your side. | Sudi cycling through four states |
| 6 | `calendar` | It moves with your exam. | Notification out: a sprint plan. Exam week: calm mode. Results: your next-attempt plan. | Timeline advancing |
| 7 | `begin` | Ready when you are. | Your first diagnostic is free. | **Begin Journey** + "See what's free" → `/pricing`; `AlsoExplore`: Exams · Result Day · Pricing |

Do not show formulas, weights or thresholds anywhere on the site.

### 6.3 `/exams` and `/exams/tnpsc-group-4`

`/exams`: headline *"Choose your exam."* Subhead *"We're starting with the ones most Tamil Nadu aspirants sit."* A horizontal card row:

| Card | Status chip | Action |
|---|---|---|
| TNPSC Group 4 & VAO | In beta | → `/exams/tnpsc-group-4` |
| TNPSC Group 2 / 2A | Coming soon | Notify me → `/begin?exam=group-2` |
| Police recruitment (TNUSRB) | Planned | Notify me |
| Teacher eligibility (TET / TRB) | Planned | Notify me |
| Banking, SSC, Railways | Later | Notify me |

Disclaimer line: *"HeyMey is independent and is not affiliated with TNPSC or the Government of Tamil Nadu."*

`/exams/tnpsc-group-4` (5 panels):
1. **By the numbers.** Headline *"One exam. A very large room."* Cards: **about 20 lakh** applied, **13,89,738** appeared, **3,935** posts notified (July 2025). Line: *"Roughly one selection for every 300–350 candidates. That's why knowing where you stand matters."* Source note: *TNPSC Group 4, 12 July 2025, as reported by Dinamalar (Oct 2025) and News Today (Jul 2025). Later reports mention about 4,662 posts.*
2. **What the exam tests.** `[Fill from the official current notification: papers, marks, negative marking.]` Link to the official TNPSC notification. Do not state structure from memory.
3. **One exam cycle.** Timeline of the 2025 cycle (verified): notification **25 Apr 2025**, applications until **24 May**, exam **12 Jul**, answer key **21 Jul**, results **22 Oct**. Caption: *"Preparation looks different at each stage. So does HeyMey."*
4. **How HeyMey prepares you.** Three short lines linking to `/studio#know`, `#practise`, `#understand`.
5. **Begin.** CTA, plus "Explore the official syllabus" (official TNPSC link).

### 6.4 `/result-day` (4 panels)

Scene: new day over the sea. Control with `RESULT_TOOL_STATE` = `coming` | `live` (when `live`, the CTA links into the app tool).

| # | Headline | Body |
|---|---|---|
| 1 | Answer key out? Know your score in a minute. | Enter your answers. See your expected marks, with negative marking worked out. |
| 2 | Honest cutoff context. | See how your expected score compares with past published cutoffs for your category. It's context, not a promise. |
| 3 | A plan for what's next. | Selected or not, start the next step the very next day, with your whole history intact. |
| 4 | Be first to know. | **Notify me when it opens** → `/begin?intent=result-day` |

Footnote: *"Expected marks are an estimate until official results are published."* Never promise ranks or selection.

### 6.5 `/pricing` (4 panels)

All prices come from `pricing.config.ts`. While a value is `null`, render "Beta pricing announced soon". Never display a number the founder has not set.

1. **Free where it matters.** Your first diagnostic, the daily challenge, a basic diagnosis, and a few doubts a day.
2. **The Cycle Pass.** One price per exam cycle, the way you already buy test series. `[price from config]`. Extra depth: unlimited mock tests, deeper topic insight. *No countdown timers, no "last chance" banners, ever.*
3. **For institutions.** Bulk access and cohort insight → `/institutions`.
4. **Our pricing promises.** Prices shown include taxes. Cancel in a few taps. Plain refund policy → `/legal/refunds`. Nothing important sits behind a surprise wall.

### 6.6 `/about` (6 panels)

Scene: palm-leaf manuscript.
1. **Why HeyMey.** `[Founder's 40-word story. Placeholder, do not invent.]`
2. **The problem, plainly.** Same verified Group 4 numbers as §6.3.
3. **Why "மெய்".** *"Mey is Tamil for truth, the real thing. In Tamil grammar it is also the body that gives breath its shape."* Show Thirukkural 423 in Tamil: *எப்பொருள் யார்யார்வாய்க் கேட்பினும் அப்பொருள் மெய்ப்பொருள் காண்ப தறிவு.* English line (G. U. Pope's classic rendering): *"Though things diverse from divers sages' lips we learn, 'tis wisdom's part in each the true thing to discern."* Caption: *Thirukkural, couplet 423, "The Possession of Wisdom".*
4. **What we won't do.** No fake urgency. No shaming. No guarantees of selection. No selling your data `[confirm before publishing]`.
5. **Where we are.** Beta first, then the Result Day toolkit, then more exams. No dates unless the founder sets them.
6. **Meet the maker.** `[Name, photo, one line.]` + Contact link; `AlsoExplore`: Trust · FAQ.

### 6.7 `/trust` (6 panels)

Scene: still pond. Every line must be true on the day it ships.
1. **Honest scores.** Every score can be opened up and explained. We show how sure we are.
2. **Your data.** What we collect (account, exam choices, practice history). You can see, correct and delete it. HeyMey is for adults (18+) at launch. → Privacy.
3. **Fair play.** No fake deadlines, no guilt, no pre-ticked boxes.
4. **Content you can check.** Questions are checked before release. Found a wrong answer? Report it and see the fix.
5. **How AI is used.** AI helps explain and summarise. It can be wrong, so we label it, cap it and let you report errors. Scores are never made up by AI.
6. **Money.** Payments go through a licensed payment gateway. We never see your card details. Refunds follow the published policy. Grievances → `/legal/grievance`.

### 6.8 `/faq` (4 panels × 4 questions)

Add FAQPage JSON-LD. Answers must stay consistent with §7.

**Basics**
- *Is HeyMey free?* Starting is free: first diagnostic, daily challenge, basic diagnosis, a few doubts a day. Deeper tools need a plan.
- *Which exams?* TNPSC Group 4 and VAO first. Others are on the exams page.
- *Is it in Tamil?* The interface is in English. Questions and explanations are available in Tamil and English.
- *Who is it for?* Adults (18+) preparing for Tamil Nadu government exams.

**Trust and accuracy**
- *How accurate is the readiness score?* It's an estimate. We show how sure we are and how it's made up. It does not predict selection.
- *Does the AI make mistakes?* Sometimes. We label AI answers and you can report errors.
- *How are questions checked?* Automated checks, then review. Reported errors are fixed.
- *Do you guarantee selection?* No. Nobody honestly can.

**Using it**
- *Does it work on my phone?* Yes. It's built for phones first and also works on a laptop.
- *Is there an app?* `[State per APP_STATE; do not claim an app store listing until live.]`
- *What if I miss a day?* Your streak has a monthly shield. No scolding.
- *Can I delete my account and data?* Yes, from the app or by writing to us.

**Money and company**
- *How do you make money?* Paid plans, and licences for coaching institutes.
- *Can I get a refund?* See the refund policy `[window from config]`.
- *Are you affiliated with TNPSC?* No. HeyMey is independent.
- *Who is behind it?* `[founder line]`

### 6.9 `/journal` and `/journal/:slug`

Index: a horizontal card row (cover art, category chip, read time) with filter chips *All · Exam updates · Study craft · Product · Stories*. Articles are MDX files in `content/journal/` with front matter (`title, slug, date, updated, category, readMinutes, summary, sources[]`) and an RSS feed.

**Reader (`R`):** the article flows into horizontal CSS columns (`column-width` about 46ch, container height `calc(100dvh - header)`), paged by column, with progress, keyboard (← →) and swipe. No vertical scrolling. No video on this view.

**Launch with three articles:**
1. *TNPSC Group 4, 2025 by the numbers* (use only verified figures and cite sources).
2. *What "readiness" should mean, and what it shouldn't.*
3. *Why we named it மெய்.*

**Next queue:** answer-key day checklist · how negative marking works · reading a cutoff table without panic · Group 2 or Group 4? · your last 30 days · a calm exam week · after you don't clear: a plan · the five-minute rule for daily study · spaced repetition for aspirants · how to spot a wrong answer key.

**Editorial rules:** cite every number, date-stamp and show "updated", no guarantees, no unverified exam-structure claims, a human byline.

### 6.10 `/contact` ("Reach Us")

Scene: evening veranda. Fixed layout: form card on the right, direct channels on the left.
- Headline: *"Say hello."* Body: *"Questions, ideas, a wrong answer you spotted, or a partnership. We read everything."*
- Fields: name, email, "I am a…" (Aspirant · Educator · Institution · Press · Investor · Other), message (≤ 1,000 characters), consent checkbox (unchecked).
- Channels: `[email]`, `[WhatsApp: only if someone will actually staff it]`. Response promise `[e.g., within 2 working days]`.
- States: empty, loading, error (specific message), success (Sudi in bright state + "Thanks, we'll reply to <email>").
- `AlsoExplore`: Institutions · Educators · Download.

### 6.11 `/institutions` (5 panels)

Scene: empty classroom. Do not state prices.
1. **Better practice for every batch.** Fair-priced tests and clear cohort insight for coaching centres and colleges.
2. **See the batch, not just the average.** Which topics the cohort struggles with, how readiness is moving, who's falling behind quietly.
3. **A pilot in four weeks.** One batch, four weeks, one report. *(Describe only if the founder commits to this process.)*
4. **Privacy first.** Cohort-level insight. Individual student detail is shown only with that student's consent.
5. **Request a pilot.** Form: institution, district, approximate student count, your role, email or phone, consent.

### 6.12 `/begin` (the waitlist)

Scene: the kolam draws itself. Fixed layout, one card.
- Headline: *"Begin your journey."* Subhead: *"Closed beta opening soon. Join the list and we'll write when your turn comes."*
- Fields: email (required), exam (select), district (38 Tamil Nadu districts), checkbox "I'm 18 or older" (required, unchecked), consent checkbox (required, unchecked, links to the privacy policy).
- Query params: `?exam=` pre-selects the exam; `?intent=` is stored as a tag.
- Success: Sudi bright + *"You're on the list."* Send a confirmation email (double opt-in, §8).
- Capture first-party UTM values only if the consent text discloses it.

### 6.13 `/creators` (Phase 2, invite-only waitlist)

Scene: teacher's desk. Do not advertise payouts or the marketplace as live.
1. *Turn what you know into income.* 2. *Invite-only for now.* 3. *What we check:* originality and accuracy. 4. *How you'll be paid* `[split and terms TBD; do not publish a number until final]`. 5. *Tell us about yourself* (form).

### 6.14 `/download` (Phase 2)

Scene: phone glow at dusk. Android `[coming | live]`, iOS "Later", Web "Use it now" → app. A QR code to the app URL. "Notify me" form.

### 6.15 Legal pages

- `/legal/privacy`, `/legal/terms`, `/legal/refunds` use the horizontal **Reader**. `/legal/grievance` is a fixed page: officer name and contact `[ ]`, how complaints are handled, expected response times `[per current IT rules; counsel to confirm]`.
- The agent builds the shells with real headings. **Counsel supplies the text.** Each page shows effective date and version number.
- Privacy outline: who we are · what we collect and why · consent · how long we keep it · your rights (access, correction, erasure, grievance) · children (18+ only) · processors we use · security · international transfers · changes · contact.
- Terms outline: using HeyMey · accounts · acceptable use · content and IP · AI-generated content disclaimer · payments · termination · liability · governing law.
- Refunds outline: what's refundable, window `[ ]`, how to request, timelines.

### 6.16 `/404`

Scene: quiet crossroads. Sleepy Sudi. *"This page took a different route."* Buttons: Home · Studio · Exams.

---

## 7. Claims Register

| Claim | Status | Allowed wording |
|---|---|---|
| About 20 lakh applied, 13,89,738 appeared, 3,935 posts (Group 4, July 2025) | Verified | As in §6.3, with sources |
| Roughly 1 in 300–350 selected | Derived | "Roughly one selection for every 300–350 candidates, based on posts notified" |
| Dates of the 2025 Group 4 cycle | Verified | As in §6.3 |
| Thirukkural 423; mey as truth; uyir/mey in grammar | Verified | As in §6.6 |
| Readiness score | Product feature | "An estimate, shown with how sure we are" |
| "Predicts / guarantees you will clear" | **Banned** | Say "shows where you stand against past cutoffs" |
| "N students" or "trusted by …" | **Banned until real** | Only a live counter drawn from the real database, never typed in |
| Testimonials, press logos, awards | **Banned until real** | Real, dated, with written permission |
| "100% accurate", "sure-shot", "rank guaranteed" | **Banned** | n/a |
| Official or partner of TNPSC/Government | **Banned** | Use the independence disclaimer |
| Cutoff data | Only after real data is loaded | Hide any cutoff figure otherwise |
| Battle mode, study pods, marketplace, creator payouts | Not live in the beta | Do not advertise as available |
| Free items | Only what is really free at launch | The list in §6.5 |
| Android/iOS app | Only when published | Follow `APP_STATE` and the download state |
| ® symbol | **Banned** | Use ™ |
| Prices and refund window | Config only | Never typed into JSX |
| "Full Tamil app" | **Banned** | Say Tamil and English questions and explanations |

---

## 8. Forms and Backend

One endpoint on the app backend: `POST https://app.heymey.in/api/public/leads` with a `type` field. CORS is locked to `https://heymey.in`.

| Type | Fields |
|---|---|
| `waitlist` | email, exam, district, is18Plus, consent |
| `contact` | name, email, role, message, consent |
| `pilot` | institution, district, studentCount, role, email/phone, consent |
| `creator` | name, email, subject area, link to work, consent |
| `notify` | email, intent (`result-day`, `download`, `exam:<slug>`), consent |

Requirements:
- **Validation** with Zod on the server; never trust the client.
- **Spam defence:** a honeypot field, Cloudflare Turnstile, and rate limit of about 3 submissions per hour per IP.
- **Consent record:** store consent text version, timestamp and `consentGiven=true`. Do not store IP addresses in plain text (a salted hash is fine).
- **Double opt-in** for `waitlist` and `notify` (confirmation email, link expires in 48 hours). Every email has an unsubscribe and deletion link.
- **Storage:** a `Lead` table (`id, type, email, name, role, exam, district, org, studentCount, message, intent, utm*, consentVersion, confirmedAt, createdAt`).
- **Notifications:** an email to the founder on `contact` and `pilot`.
- **Retention:** delete unconfirmed leads after 30 days; state the retention period in the privacy policy.
- **Adults only:** `waitlist` requires the 18+ checkbox.

---

## 9. SEO, Performance, Analytics, Security, Language

**SEO**
- Prerendered HTML for every route. All panel text is in the DOM at load, never lazy-mounted.
- Unique title and description, canonical, Open Graph and Twitter images, `sitemap.xml`, `robots.txt`.
- JSON-LD: Organization and WebSite (home), FAQPage (`/faq`), Article (journal), BreadcrumbList (exam pages).

**Performance budgets (acceptance criteria)**
- First route JS ≤ 150 KB gzipped. Route transfer ≤ 400 KB excluding video and fonts.
- LCP ≤ 2.5 s on the Lighthouse mobile slow-4G profile (the poster is the LCP element).
- CLS ≤ 0.05. Lighthouse mobile performance ≥ 85 and accessibility ≥ 95 on every route.
- Self-host and subset fonts, `font-display: swap`, preload the hero font. AVIF/WebP with `srcset`.

**Analytics:** self-hosted, cookieless (Plausible or Umami). Events only: `cta_click`, `form_submit`, `panel_view`, `video_started`, `bg_paused`. No third-party pixels.

**Security headers (via Caddy):** HSTS, a strict CSP (self + the analytics host + Turnstile), `X-Content-Type-Options`, `Referrer-Policy: strict-origin-when-cross-origin`, frame-ancestors none.

**Monitoring:** Sentry free tier for the front end.

**Language:** English by default. All strings go through `content/*.ts` with `en` and `ta` keys so a Tamil toggle can be added later without refactoring. Starter Tamil strings (**have a native speaker review before use**): *Begin Journey* — பயணத்தைத் தொடங்குங்கள்; *Reach Us* — தொடர்பு கொள்ளுங்கள்; *Explore Syllabus* — பாடத்திட்டத்தைப் பாருங்கள்.

---

## 10. QA and Acceptance

**Automated (Playwright + axe-core), run on every PR:**
1. **Hero freeze:** the `/` pixel diff against the baseline is ≤ 0.1% at four viewports.
2. **No vertical scroll:** for every route, every panel, every viewport in §3.6, assert `document.documentElement.scrollHeight <= window.innerHeight` and that no element's bounding box leaves its panel.

```ts
for (const route of ROUTES) for (const vp of VIEWPORTS) test(`${route} fits ${vp.name}`, async ({ page }) => {
  await page.setViewportSize(vp); await page.goto(route);
  for (let i = 0; i < await panelCount(page); i++) {
    await goToPanel(page, i);
    expect(await page.evaluate(() => document.documentElement.scrollHeight <= innerHeight)).toBe(true);
  }
});
```

3. **Keyboard:** arrows, Home/End and Tab work; focus entering an off-screen panel brings it into view.
4. **Reduced motion, Save-Data and slow-connection emulation:** no video requests are made; posters render.
5. **Pause background** stops video and animation, and the choice persists.
6. **axe-core:** zero serious or critical issues. **Contrast** over posters meets 4.5:1.
7. **Forms:** validation, honeypot, rate limit, double opt-in, consent stored.
8. **Links:** every CTA resolves per `APP_STATE`; no broken internal links; redirects work.

**Manual:** read every page once as an aspirant on a mid-range Android phone over throttled 4G. Read the Claims Register against every page.

---

## 11. Build Order

1. Baseline screenshots of `/`. Extract tokens with a zero-diff check. Switch to path routing and prerendering.
2. Build `Scene`, `PanelTrack`, `Panel`, `EdgeBar`, `PanelDots`, `MenuOverlay`, `VideoBackground` and the no-vertical-scroll test harness.
3. Pages: `/studio`, `/exams` and `/exams/tnpsc-group-4`, `/about`, `/trust`, `/faq`.
4. `/begin`, `/contact` and the leads endpoint (with double opt-in).
5. `/pricing`, `/institutions`, `/result-day`.
6. `/journal` index and the Reader, with three articles. Legal shells with counsel's text.
7. SEO, analytics, headers, performance pass, the full QA suite.
8. Phase 2: `/creators`, `/download`, `/exams/tnpsc-group-2`, `/press`.

---

## 12. Inputs Needed From the Founder (placeholders the agent must not invent)

1. Approval on the three hero-adjacent changes (§5.4): ™, the legal row on `/`, `text-wrap`.
2. Founder story (40 words), name, photo, and one line of background.
3. Contact email; WhatsApp only if it will be staffed; response-time promise.
4. Pricing numbers (or confirmation to show "announced soon"); refund window.
5. Whether "we never sell your data" is true and may be published.
6. Grievance officer name and email; counsel's drafts of privacy, terms and refunds.
7. Official TNPSC Group 4 exam-structure facts from the current notification.
8. The app's final domain (`app.heymey.in`?) and the beta invite mechanics.
9. Whether a live counter (real data only) should appear anywhere.
10. Who will answer contact messages and pilot requests, and how fast.
11. Which of the roughly 12 video scenes to produce first (suggested: Home is already done; then `/studio`, `/begin`, `/about`, `/exams`).

---

### Appendix A: global video prompt wrapper

*Style:* "Painterly cinematic, golden hour, warm amber and marigold light, soft haze, shallow depth of field, slow gentle camera drift, Tamil Nadu, culturally inclusive."
*Negative:* "text, letters, logos, watermarks, recognisable faces or people, fast motion, camera shake, hard cuts, sacred idols as focus, modern brands."
*Loop:* "Seamless 10-second loop, first and last frames matching." Generate the 9:16 version separately from the same prompt.

### Appendix B: suggested structure

```
src/
  pages/            Home (frozen), Studio, Exams, ExamDetail, ResultDay, Pricing, About, Trust, Faq,
                    Journal, Article, Contact, Institutions, Begin, Legal*, NotFound
  components/       Scene, PanelTrack, Panel, VideoBackground, EdgeBar, PanelDots, MenuOverlay,
                    CtaButton, AlsoExplore, Reader, LeadForm, Sudi
  content/          home.ts studio.ts exams.ts about.ts trust.ts faq.ts pricing.ts ... journal/*.mdx
  config/           app.config.ts (APP_STATE, RESULT_TOOL_STATE)  pricing.config.ts
  styles/           tokens.css
public/media/       <route>-1080.{mp4,webm}  <route>-720.mp4  <route>-poster.{avif,webp,jpg}
tests/              hero-freeze.spec.ts  no-vscroll.spec.ts  a11y.spec.ts  forms.spec.ts
```
