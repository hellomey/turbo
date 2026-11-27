# Stall print kit

Products of PSG Products expo, CODISSIA, Coimbatore. Hall A, stall A130 (3 m x 2 m), Dec 9 to 13.
Print files go to the printer by Dec 3.

Regenerate every SVG from the repo root with `node design/stall/build.mjs`. The poster topic names come from
`content/syllabus/tnpsc-group-4.yaml`.

## Files and sizes

| File | Piece | Trim | Bleed | Document |
| --- | --- | --- | --- | --- |
| `flex-banner-3000x2000.svg` | Flex banner | 3000 x 2000 mm | 10 mm | 3020 x 2020 mm |
| `poster-a3-group4-checklist.svg` | Take-away poster, A3 | 297 x 420 mm | 3 mm | 303 x 426 mm |
| `table-tent-a5.svg` | Table tent face, A5 | 148 x 210 mm | 3 mm | 154 x 216 mm |
| `sticker-first-lamp.svg` | Sticker, red circle | 50 mm round | 2 mm | 54 x 54 mm |
| `sticker-group4-lamplighter.svg` | Sticker, yellow triangle | 50 mm round | 2 mm | 54 x 54 mm |
| `sticker-exam-hall-survivor.svg` | Sticker, blue square | 50 mm round | 2 mm | 54 x 54 mm |

One SVG unit is 1 mm. Each file has a hidden `trim-guide` layer; stickers also have a hidden `die-cut` layer (50 mm
circle). Keep text at least 5 mm inside the trim (30 mm on the flex).

Export notes for the printer: convert text to outlines after installing Nunito (Black 900, ExtraBold 800, Bold 700),
then export PDF/X-4 in CMYK. Flex: 100 dpi at full size is enough for viewing from 2 m or more.

## Colours

| Name | Hex | CMYK (approximate, confirm with a printed proof) |
| --- | --- | --- |
| Red | `#D7261E` | 0 / 90 / 90 / 10 |
| Yellow | `#F5C518` | 0 / 20 / 95 / 0 |
| Blue | `#1F4FA3` | 90 / 65 / 0 / 5 |
| Ink | `#111111` | 0 / 0 / 0 / 100 (rich black on the flex: 60 / 40 / 40 / 100) |
| Paper | `#FAF6EE` | 0 / 2 / 5 / 0 |

The same values are used on `heymey.app/try` (`apps/marketing/components/stall/stall.css`).

## QR codes

The repo has no QR library, so every file holds a box marked `QR-PLACEHOLDER` with the URL printed inside it. Before
print, replace each box with a real QR code (error correction M or higher, at least a 4-module quiet zone) at the
same size, then scan it with an Android phone and an iPhone.

| Piece | URL | QR size |
| --- | --- | --- |
| Flex banner | `https://heymey.app/try?src=flex` | 420 mm |
| A3 poster | `https://heymey.app/try?src=poster` | 62 mm |
| A5 table tent | `https://heymey.app/try?src=table` | 70 mm |

## Open items before print

- The poster lists the 25 topics in the current syllabus seed file, which is marked as seed data. Thirutham should
  confirm the names against the official Group 4 syllabus. The poster says it is a starting set and points to
  tnpsc.gov.in.
- Kaaval reviews every claim ("free", "no install", "beta"). Kalai reviews the brand.
- "Free" holds only while the guest web app costs nothing to try.

## Stall-day checklist

- [ ] All three QR codes scan to the right URL, with the right `src`, on Android and iPhone, over mobile data.
- [ ] `heymey.app/try` asks the age question first; "No" goes to `/waitlist`.
- [ ] `app.heymey.app` loads as a guest and a first lamp can be lit in about a minute.
- [ ] The APK link downloads and installs on a test Android phone using the 3-step guide.
- [ ] The Desk sticker-code page works on the staff phone; staff are signed in with TOTP.
- [ ] Stickers counted per design; give one only after a code checks out on Desk.
- [ ] A3 posters stacked for take-away; table tent on the table near the demo phone.
- [ ] A charged demo phone and a power bank.
- [ ] No deploys during stall hours. Critical fixes only, after hours.
