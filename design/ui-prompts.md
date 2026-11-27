# HeyMey: AI prompts for UI screens (26 screens)

How to use this file: paste the **Master style block** first, then the **Mascot block**, then one screen prompt.
The two blocks are what keep every screen uniform, so paste them every time, even when the tool remembers context.
Frame size: **mobile 390 × 844 (iPhone 14 size)**, portrait, one screen per image.

Honesty rule for every generated screen: use placeholder names such as "Priya" or "You", and keep numbers small and
plausible. Never generate fake reviews, star ratings, "10,000+ users" counters or testimonials.
The app is in beta, so a small "Beta" chip may appear in headers.

---

## 1. Master style block (paste first, every time)

```
Design a premium, gamified mobile app screen for "HeyMey", a TNPSC (Tamil Nadu government exam) preparation app.
Light theme only. Modern, warm, friendly, clean. Feels like a polished game, not a school website.

PALETTE
- Background: warm white #FAF8F4
- Cards: pure white #FFFFFF, corner radius 20px, soft shadow (0 6px 20px rgba(20,20,20,0.06)), no borders
- Primary (lamp amber): #F5A524, used for main buttons, lit lamps, progress, highlights
- Primary deep: #D9820B for pressed states and text on amber-tinted surfaces
- Success mint: #2BB673; Error coral: #F2645A; Info sky: #3A8DDE
- Soft tints for tile backgrounds: amber #FFF3DC, mint #E3F6EC, coral #FDE6E4, sky #E4F0FB
- Text: ink #1C1C1E for headings, grey #6B6B6B for secondary text
- Absolutely no violet, purple or neon colours. No dark mode. No gradients on text.

TYPOGRAPHY
- Font: Nunito. Headings ExtraBold 24-28px, card titles Bold 17px, body Regular 15px, captions 13px.
- Big numbers (scores, XP, timers): Nunito Black 40-56px.

LAYOUT
- 20px side padding, 12px gap between cards.
- Bento grid: exactly one large hero tile at the top of the content, smaller tiles below in a 2-column grid.
- Top bar: screen title on the left, small round icon buttons on the right.
- Floating pill-shaped bottom navigation bar (white, shadowed, 16px from the bottom) with 4 tabs:
  Today (sun icon), Map (lamp icon), Play (dice icon), Me (person icon). The active tab has an amber pill behind its icon and label.
- Primary button: full width, 56px tall, fully rounded, amber #F5A524 with ink text, Bold 17px.
- Secondary button: white with a 1.5px #E8E2D6 outline.
- Chips: fully rounded, 36px tall, tinted backgrounds.

ILLUSTRATION STYLE
- Flat vector illustrations with soft rounded shapes, 2-3 tone shading, no outlines or thin 2px ink outlines only.
- The same palette as the UI. Subtle Tamil Nadu cultural touches where natural (kolam patterns, temple gopuram silhouettes,
  palm trees, agal vilakku oil lamps), never stereotyped.
- Icons: rounded, 2px stroke, consistent set (similar to Phosphor or Lucide rounded).
- Gamified details: XP badges, small sparkles, glowing lamps, coin-like Points tokens (gold circle with a star, never a rupee sign).

QUALITY
- Pixel-perfect, generous white space, clear hierarchy, accessible contrast (WCAG AA).
- Realistic but short English text, no lorem ipsum.
- Show the status bar (9:41, signal, battery).
```

## 2. Mascot block (paste second, every time)

```
MASCOT: "Mey", a small friendly lamp spirit, the app's guide.
- Body: a rounded clay agal vilakku (traditional Tamil oil lamp) in warm terracotta #E07A4F with a cream rim.
- Head: a soft teardrop flame in amber #F5A524 with a lighter yellow core #FFD66B; the flame IS the head.
- Face: two big glossy ink-dot eyes on the flame, small rosy cheeks, a tiny smile. No nose, no mouth teeth.
- Two tiny stubby arms coming from the lamp body. No legs; it hovers slightly with a soft shadow below.
- Size: chibi proportions, cute but not babyish. Flat vector, same style as the rest of the screen.
- Emotions used across screens: happy wave, cheering with arms up, thinking (flame tilted, hand on chin),
  sleepy (dim flame, half-closed eyes), proud (glowing brighter, sparkles around), encouraging thumbs up.
- Mey must look identical on every screen: same shape, colours and face. Only the pose and expression change.
```

---

## 3. Screen prompts

### Getting started

#### 1. Loading / splash
```
Splash screen. Centre: Mey with a gentle glow halo, flame flickering upward. Below Mey, the wordmark "HeyMey" in
Nunito Black 36px ink, and under it "Light up your TNPSC prep" in grey 15px. Background warm white with a very faint
kolam dot pattern in #F1EBDD. Bottom: a thin amber loading bar, 40% filled, and a small "Beta" chip. No bottom nav.
```

#### 2. Story onboarding (4 cards; generate each card separately)
```
Story onboarding card, full-screen, no bottom nav. Top right: "Skip" text button. Top 60% of the screen: a large flat
illustration on a soft amber-tinted rounded panel. Below: a headline in 26px ExtraBold and one line of body text.
Bottom: page dots (active dot is an amber pill) and a full-width amber "Next" button.
Card 1 illustration: Mey waving next to a dark map of small unlit lamps. Headline "Every topic is a lamp". Body
"Learn a topic and its lamp lights up."
Card 2: Mey thinking as one lamp slowly dims. Headline "Lamps dim when you forget". Body "A quick recall check brings the light back."
Card 3: Mey cheering beside a readiness ring at 62%. Headline "See how ready you are". Body "A simple score, and we show you how it's calculated."
Card 4: Mey with arms open in front of a glowing path of lit lamps leading to a gopuram. Headline "Let's light your first lamp".
Button text "Start".
```

#### 3. Start (eligibility: age band, exam, date of birth)
```
Onboarding form, one question per card, no bottom nav. Top: back arrow, a segmented progress bar (step 2 of 3, amber).
Small Mey in the top right corner, peeking and encouraging. Hero card: question "Which exam are you preparing for?"
with 3 large selectable option cards stacked: "Group 4 (VAO, Junior Assistant)", "Group 2 / 2A", "Group 1". Each option
card has a small icon tile on the left; the selected one has an amber 2px border, amber-tint background and a check
circle. Below: a calm grey note "You can change this later." Bottom: full-width amber "Continue" button.
```

#### 4. Plan setup
```
Plan setup screen, no bottom nav. Title "Build your plan". Hero card: "When is your exam?" with a horizontal date
chip row and a selected date "Jun 2027" in amber. Second card: "How much time per day?" with chips 15 min, 30 min,
45 min, 60 min (30 min selected). Third card: a live preview "Your week" showing 7 small day columns with stacked
coloured blocks (amber = new topics, mint = recall, sky = practice) and the line "About 24 topics before your exam".
Mey in a thinking pose next to the preview. Bottom: amber "Create my plan" button.
```

### Daily use

#### 5. Today (home)
```
Home dashboard, bottom nav with Today active. Top: "Good morning, Priya" in 24px ExtraBold, a date line in grey, and
on the right a round avatar plus an XP pill "Lv 3 · 240 XP".
Hero tile (full width, amber-tint background): "Your next lamp" label, topic "Indian Polity: Fundamental Rights",
"8 min lesson", a large amber "Start" button, and Mey on the right holding up a small unlit lamp, cheerful.
Bento grid below (2 columns):
- Check-in tile (mint tint): a calendar icon, "Day check-in", a small "Claim +10 XP" button.
- Readiness tile: a ring at 38% with the label "Readiness".
- Recall tile (coral tint): "3 lamps dimming", "Relight now" link.
- Exam alert tile (sky tint, full width): bell icon, "Group 4 notification expected", "Official source" chip.
Small "Beta" chip next to the greeting.
```

#### 6. Study Map
```
Study Map screen, bottom nav with Map active. Top: title "Study Map", a subject filter chip row (All, Polity,
History, Geography, Aptitude, Tamil). The main area is a winding soft path (like a game level map) on a warm white
background with faint palm trees, kolam dots and a gopuram silhouette at the top. Along the path: circular lamp nodes.
Lit lamps glow amber with a soft halo, gold-mastered lamps have a gold ring and sparkles, dim lamps are pale grey with
a tiny flicker, and locked lamps are grey with a lock. Mey hovers next to the current node with a happy wave.
A bottom summary strip card: "12 lit · 3 dimming · 2 gold" with three small coloured dots.
```

#### 7. Lesson (with Listen)
```
Lesson reading screen, no bottom nav. Top: close X, a thin amber reading progress bar, a "Listen" pill button with a
speaker icon. Title "Fundamental Rights (Articles 12-35)" in 26px ExtraBold, meta "8 min read · Polity". A small
header illustration of the Indian Constitution book with Mey reading it. Body text in comfortable 17px with
a highlighted "Key idea" callout card (amber-tint, lamp icon) and a short bullet list. Source line in grey at the
bottom: "Source: Samacheer Kalvi Class 8, rewritten". Sticky bottom: amber "Check yourself" button.
```

#### 8. Check / Relight question
```
Question screen for a recall check, no bottom nav. Top: close X, "Question 2 of 5" and a segmented progress bar.
Question card: "Which Article abolishes untouchability?" Four option cards stacked, each with a letter circle A-D.
Show the answered state: option "Article 17" is mint with a check icon, a wrong tapped option "Article 15" is coral
with an X. An explanation card slides up from the bottom (white, rounded top): "Correct answer: Article 17" in mint,
two lines of explanation, a "Report a mistake" grey text link, and a full-width amber "Next" button.
Small Mey in the corner giving a thumbs up.
```

#### 9. Relight list
```
Relight screen. Title "Relight", subtitle "Lamps fade as memory fades. Two minutes brings them back."
Hero tile (coral tint): "3 lamps need you today" with Mey looking slightly sleepy holding a dim lamp, amber button
"Relight all (6 min)". Below: grouped list sections "Today", "This week", "Later", each with rows: a small dim lamp
icon, topic name, a fading-glow bar, and a "Relight" chip on the right.
```

#### 10. Practice
```
Practice picker screen. Title "Practice". Hero tile: "Mixed practice" with "10 questions from your lit topics" and an
amber "Start" button, Mey holding a pencil. Bento grid of subject tiles (2 columns), each with a flat subject icon
illustration, subject name, and "24 / 60 done" with a thin progress bar: Polity, History, Geography, Economy,
Aptitude, General Tamil. One tile is labelled "Practice set, not official" with a small grey chip.
```

#### 11. Mistakes
```
Mistakes screen. Title "Mistakes", subtitle "Every wrong answer is a free lesson." A stack of swipeable cards
(the top card full, two cards peeking behind). The top card shows the question, "Your answer" in coral and
"Correct" in mint, and a short explanation. Under the stack: two round buttons, "Got it" (mint check) and
"Retry later" (amber clock). A counter "8 left". Mey in a thinking pose near the counter. Empty-state variant:
Mey proudly glowing, "No mistakes waiting. Nice work."
```

#### 12. PYQ Vault
```
Past papers screen. Title "PYQ Vault", "Beta" chip. Hero tile: an illustration of a treasure-chest-style vault with a
glowing scroll, "Group 4 · 2024 paper", "200 questions", amber "Practice" button. Below: a vertical list of year cards
(2024, 2022, 2019, 2016), each with exam name, question count, an "Official answer key" mint chip, or a grey
"Practice set, not official" chip, and a chevron.
```

#### 13. Exam Hall (mock test)
```
Mock exam screen, focused mode, no bottom nav. Top bar: exam title "Group 4 Mock #1", a calm timer pill "1:42:10"
in ink on white (not red), and a "Submit" text button. Question area: "Q 37" with the question and four options.
Bottom sheet peeking: an OMR-style answer grid of small numbered circles (answered = amber filled, marked for review
= sky outline, unanswered = grey outline) with a legend. Buttons "Previous", "Mark for review", "Next".
Clean, serious, exam-like, but the same warm style.
```

#### 14. Plan
```
Plan screen. Title "My plan". A horizontal week strip of 7 day pills (today highlighted amber with a dot).
Hero tile: "Today · 30 min" with a circular progress at 1/3 done. A checklist of task cards: "Learn: Fundamental
Rights (8 min)" checked mint, "Relight: Mughal Empire (2 min)", "Practice: Percentages (10 min)". Each card has a
coloured left icon tile and a round checkbox. Bottom tile: "Exam in 186 days" with a small calendar illustration
and Mey encouraging.
```

### Progress

#### 15. Readiness
```
Readiness screen. Hero tile: a large ring gauge at 38% (amber arc on a pale track), the label "Readiness" and the line
"Up 4 this week". Mey standing beside the ring, proud. Below, a white card titled "How we calculate this" with three
simple rows and mini bars: "Lamps lit 40%", "Recall strength 30%", "Mock score 30%", and the line "No hidden factors."
A bento row: "Strongest: Polity" (mint tint) and "Needs work: Aptitude" (coral tint).
```

#### 16. Sunday reports list
```
Reports screen. Title "Sunday Reports". A vertical list of week cards: "Week of Nov 23", a mini sparkline, "+4
readiness", "5 lamps lit", chevron. The newest card is larger with an amber-tint background and a "New" chip, and a
small envelope illustration with Mey peeking out.
```

#### 17. Report detail
```
Weekly report detail. Title "Week of Nov 23". Hero tile: a summary with three big numbers in a row, "5 lit", "12
relit", "62% accuracy". A simple bar chart card "Minutes per day" with 7 amber bars and day labels. A card "Topics
you lit" with lamp-icon rows. A card "Next week" with 2 suggested topics and an amber "Add to plan" button.
Mey cheering at the top.
```

#### 18. Leaderboard
```
Leaderboard screen. Title "Leaderboard", tabs "This week" / "All time", a note "Opt-in players only. XP from learning."
Top 3 podium with round avatars (display names only), crowns or laurels, amber, silver and bronze tiers, and XP
numbers. Below: a clean list of ranks 4-10 with avatar, display name, XP. Your own row pinned at the bottom in an
amber-tint card: "#24 You · 240 XP".
```

### Fun and stall

#### 19. Play hub
```
Play hub, bottom nav with Play active. Title "Play", subtitle "Prizes are Points only. Odds always shown."
Hero tile: "Daily Spin" with a colourful pastel wheel illustration, "1 free spin today", amber "Spin" button, Mey
cheering beside the wheel. Bento grid: "Confidence Duel" tile (sky tint, two crossed pencils illustration, "5
questions · 150 s"), "Rules & odds" tile (shield icon), and a full-width "Your Points" tile with a gold star token and
"340 Points".
```

#### 20. Daily Spin
```
Daily Spin screen. Centre: a large prize wheel with 5 pastel segments (amber, mint, sky, coral, cream) labelled
"5", "10", "20", "50" Points and "Tomorrow", a pointer at the top with Mey sitting on it. Below the wheel: a compact
odds table card listing "5 Points 40%, 10 Points 30%, 20 Points 15%, 50 Points 5%, Better luck tomorrow 10%".
Bottom: amber "Spin" button. Variant: a result overlay with confetti, a gold star token and "+20 Points".
```

#### 21. Confidence Duel
```
Confidence Duel screen. Top: a thin timer bar (amber), "Q 3 of 5", score pill "9 pts". Question card with four
options, one selected (amber border). Below: "How sure are you?" with three large pills: "Not sure (2/1)",
"Fairly sure (3/0)", "Certain (5/0)", each showing points for right/wrong in small grey text. Mey in a focused,
determined pose in the corner.
```

#### 22. Expo Challenge
```
Expo Challenge quiz for stall visitors. Header card with a small banner illustration of a stall with bunting and the
title "Expo Challenge", "Question 4 of 10". Question card with options. Show the instant feedback state: the correct
option mint with a check, a small "+1" pop, and a one-line explanation. A row of 10 small dots at the top showing
right (mint) and wrong (coral) so far. Mey cheering.
```

#### 23. Sticker reward
```
Reward screen. Confetti and soft sparkles. Mey proudly glowing, holding a sticker. A ticket-style card with a
perforated edge, the label "Your sticker code", a large code "MEY-4K7Q" in Nunito Black monospace style, and the
text "Show this at stall A130 to collect your sticker." Below: "One code per person. Staff will check it."
A secondary button "Back to Today".
```

### Other

#### 24. Exam Alerts
```
Exam Alerts screen. Title "Exam Alerts", a settings gear on the right. A vertical timeline with dots and cards:
"Group 4 notification published" (sky tint, "Official · tnpsc.gov.in" chip, date), "Last date to apply" (coral tint,
"12 days left"), "Hall ticket release" (grey, "Expected"). Each card has a small "Open source" link. Mey holding a
tiny bell at the top.
```

#### 25. Alert settings
```
Alert settings screen. Title "Alert settings". White grouped cards with toggle rows: "New notifications",
"Application deadlines", "Hall tickets and results", "Daily study reminder" with a time chip "7:00 PM".
Toggles are amber when on. A note at the bottom: "We only send alerts from official TNPSC sources." Small sleeping
Mey with a "Quiet hours 10 PM to 7 AM" row.
```

#### 26. Profile (Me)
```
Profile screen, bottom nav with Me active. Hero tile: a large round avatar with an amber ring, display name "Priya",
"Group 4 · Level 3", an XP progress bar "240 / 400 XP to Level 4". Bento grid: "Trophies" tile showing 3 badge
illustrations (First Lamp, 7-day check-in, Gold topic) and "+5 more"; "Lamps lit 12" tile; "Points 340" tile.
Below: a settings list card with rows "Plan", "Exam Alerts", "Privacy", "Help", "Sign out" (coral text).
Small "Beta" chip and app version at the bottom.
```

### Extra: Squad (coming soon)
```
Squad placeholder screen. Centre: an illustration of three Mey-style lamps standing together, a "Coming soon" amber
chip, the title "Study with friends", and the line "Squads are being built. We'll tell you when they're ready."
A secondary button "Back to Today".
```

---

## 4. Consistency checklist (check every generated screen)

- Background #FAF8F4, white cards, 20px corners, soft shadow. No violet, no dark mode.
- Nunito everywhere; one hero tile; 20px side padding.
- Mey has the same terracotta lamp body, amber flame head, ink-dot eyes on every screen.
- Bottom nav only on Today, Map, Play and Me (and the screens reached from them as tabs); none on onboarding,
  lessons, questions and exams.
- Prizes are Points (gold star token), never money or rupee signs. Odds are visible on any game screen.
- No invented reviews, user counts or testimonials.
