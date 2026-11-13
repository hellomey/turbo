# SKILLS.lock.md

Every third-party skill in this folder is vendored as files (no plugin hooks, no CLIs, no background services) and
pinned to the commit below. Installed 2026-11-13 by Kural after reading each SKILL.md and scanning every script and
hook for outbound network calls and telemetry. Folder prefix shows the source repo. To update a skill: re-clone at a new
commit, repeat the review, replace the folder, update this file in the same PR.

## Installed

| Prefix | Repo | Commit | What it does | Removed during review |
| --- | --- | --- | --- | --- |
| `secaudit-` | cloudflare/security-audit-skill | c1c8a8c1471069fb0e188eeaff69b8e8db6564a8 | Security audit of a diff or repo (Kaaval, Paalam, Kanakku) | nothing |
| `mp-` | mattpocock/skills | 5863806dd4e15c63174bee4e7515a4256792ecfa | TDD, domain modelling, code review, PR writing, bug diagnosis | nothing |
| `karpathy-` | multica-ai/andrej-karpathy-skills | 2c606141936f1eeef17fa3043a72095b4765b9c2 | Coding guidelines: surgical changes, explicit assumptions | nothing |
| `ponytail-` | dietrichgebert/ponytail | 96608e078b2d5ea607c5c3b8b5a54d1c1fba6846 | Smallest-change coding mode, repo audit, diff review, debt ledger | plugin hooks and UI band |
| `ua-` | Egonex-AI/Understand-Anything | 5cc4aad9b8b43596dfedaee00755a7223825fe9b | Codebase and document understanding, onboarding, diff explain | PostToolUse auto-update and SessionStart hooks |
| `uiux-` | nextlevelbuilder/ui-ux-pro-max-skill | 6ae86f61f520d6ca229d2f40e070410638c908c5 | UI/UX rules, styles, palettes, local search over bundled data | nothing |
| `taste-` | leonxlnx/taste-skill | f6b76575f949707b4e3c37cd86cb44b0b98643e8 | Anti-generic frontend design taste | nothing |
| `archify-` | tt-a1i/archify | 7e45f36c66de1254d5ad6ba1d878f6499ea269fd | Architecture and flow diagrams as local HTML | nothing |
| `impeccable-` | pbakaus/impeccable | c4cd1924c389f68d37c687d9c2bbf13f12547c41 | Design critique, polish, accessibility, motion | Cursor/Codex hooks |
| `pptmaster-` | hugohe3/ppt-master | 01fe549371b98f44be22cd337bbc911013452f09 | Decks and print layouts (posters, flex) | `scripts/image_backends`, `scripts/image_sources`, `scripts/latex_render.py` (send prompts to outside image/LaTeX APIs) |
| `diagram-` | cathrynlavery/diagram-design | f6db0decea96de66b901331a0f79a8d4b147ebae | Diagrams as HTML/SVG | nothing |
| `adhd-` | uditakhourii/adhd | 47beee24e4842fb748bd30c55e66ae77d6bb22f9 | Parallel divergent ideation | nothing |
| `mkt-` | coreyhaines31/marketingskills | 1f837447b20bb6f0e72d87b80ece1c221c362c7d | Copy, launch, events, ASO, analytics planning (Murasu) | nothing |
| `humanizer-` | blader/humanizer | b48c832f0f809c1b5658edbb838c2521b72f2413 | Removes AI tells from user-facing copy | nothing |
| `caveman-` | juliusbrussee/caveman | ad473752bdc86ca96d7289443228d4c53ec119a8 | Terse voice for agent-to-agent notes only | CLI, proxy, hooks, and every Caveman Cloud skill (telemetry on by default to the author's Supabase; compress sends files to a model) |

## Rejected

| Repo | Commit reviewed | Reason |
| --- | --- | --- |
| affaan-m/ecc | d2ef2680594f9a17526a6e1a2e18b3d242c5d17b | Plugin installs hooks on every tool call (`.*`) plus memory-persistence hooks; 1,000+ skills and 1,200+ scripts cannot be audited in time. mattpocock, karpathy and ponytail cover the same ground. |
| Panniantong/agent-reach | c70ae6da5d39bc90e09ad2ae0575ccc89f31e284 | Reads social platforms (X, Reddit, YouTube, Bilibili, Xiaohongshu) with stored logins. Those are not allowed content sources (CLAUDE.md section 6). |
| mvanhorn/last30days-skill | b4eb381ad2f93de86fedb3f40118de6a43d0e6e1 | Pulls from Reddit, X, YouTube, TikTok through third-party APIs; sources not allowed for content. |
| garrytan/gstack | 4414f4cc9377a9df06c7847433fe567ba6398aa8 | "Outside reviews" are on by default and send code to Codex/Claude under the user's login; update checks phone home; installs into the home directory. |
| headroomlabs-ai/headroom | 9f2cc017863f540c61f8747b3c744a97776ebaf2 | Reroutes model traffic through a local proxy via hooks; large telemetry surface. |
| thedotmack/claude-mem | 0c488b54e761d7f6f4091b3a6e1958712f13b19d | Hooks capture every Read/Bash/Grep output into a background worker that summarises it with a model, so file contents and secrets can be stored and sent. Use Claude Code's built-in memory instead. |
| OpenMontageInc/OpenMontage | fecb9a1e3cc23ef84de30b272059457a427f16f8 | Video pipeline built on outside generation/TTS APIs. Revisit for the demo video with founder approval. |
| heygen-com/hyperframes | ff687fed9900ed6a531057f2ebbed7ad43e801c6 | CLI with sharing/upload telemetry and cloud rendering. Same revisit as OpenMontage. |
