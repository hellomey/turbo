export interface JournalArticle {
  slug: string;
  title: string;
  subtitle: string;
  date: string;
  category: 'Exam updates' | 'Study craft' | 'Product' | 'Stories';
  readMinutes: number;
  summary: string;
  sources?: string[];
  paragraphs: string[];
}

export const journalArticles: JournalArticle[] = [
  {
    slug: 'group-4-numbers',
    title: 'TNPSC Group 4, 2025 by the numbers',
    subtitle: 'Understanding the true arithmetic of Tamil Nadu’s largest public examination.',
    date: '15 Oct 2025',
    category: 'Exam updates',
    readMinutes: 4,
    summary:
      'A factual breakdown of the 13.89 lakh attendees, the 3,935 notified posts, and why realistic odds require honest daily diagnostics rather than generic mock exams.',
    sources: [
      'TNPSC Group 4 notification dated 25 April 2025',
      'Attendance statistics reported by Dinamalar & News Today (July & October 2025)',
      'Subsequent vacancy announcements indicating ~4,662 positions',
    ],
    paragraphs: [
      'Every year, over a million aspirants across Tamil Nadu sit in exam halls from Tirunelveli to Chennai. In the 12 July 2025 examination, approximately 20 lakh candidates filed applications. On the morning of the exam, exactly 13,89,738 candidates sat at their desks.',
      'Against this immense ocean of hopefuls, the government initially notified 3,935 vacancies across Village Administrative Officer, Junior Assistant, Typist, and Steno-Typist posts.',
      'The mathematics is straightforward: roughly one selection for every 350 candidates who wrote the paper. That is less than 0.3%. Yet most coaching advertisements still promise guaranteed rank and effortless success.',
      'When the odds are one in three hundred and fifty, generic mock tests that flatter your ego do more harm than good. You need to know exactly which sub-topic in General Tamil or Aptitude is pulling your cutoff probability down.',
      'Knowing where you truly stand is not an exercise in pessimism—it is the only ground upon which genuine, disciplined progress can be built.',
    ],
  },
  {
    slug: 'what-readiness-means',
    title: 'What "readiness" should mean, and what it shouldn\'t',
    subtitle: 'Why a percentage score is not an indicator of exam day mastery.',
    date: '28 Oct 2025',
    category: 'Study craft',
    readMinutes: 5,
    summary:
      'Why scoring 80% on random drills masks blind spots, and how measuring coverage, retention stability, and revision velocity creates true readiness.',
    paragraphs: [
      'Most test series give you a simple percentage and a mock rank. If you score 165 out of 200, you feel confident. But what happens if those 35 missed questions belong entirely to Indian Polity and Tamil Literature?',
      'Real readiness is multi-dimensional. At HeyMey, we evaluate readiness across four transparent pillars: syllabus breadth, retention stability under time pressure, frequency of practice, and your directional velocity over the last thirty days.',
      'When your readiness score moves, you should be able to click on it and see the exact mechanics: did your score increase because you reviewed 50 previous mistakes, or because you took an unusually easy set of questions?',
      'Transparency removes the anxiety of the unknown. When you see your weaknesses clearly, your daily study checklist writes itself.',
    ],
  },
  {
    slug: 'why-we-named-it-mey',
    title: 'Why we named it மெய் (Mey)',
    subtitle: 'The grammar of truth and the foundation of conscious learning.',
    date: '04 Nov 2025',
    category: 'Stories',
    readMinutes: 3,
    summary:
      'In Tamil, Mey means truth and the physical body that gives breath its form. How ancient Tamil poetics inspired our design philosophy.',
    paragraphs: [
      'In classical Tamil grammar, letters are divided into உயிரெழுத்து (vowels, the breath of life) and மெய்யெழுத்து (consonants, the body). Without the மெய் (the body), the breath cannot take physical form.',
      'Beyond grammar, மெய் is the pure word for truth—the essence that remains when all superficial distractions and false illusions are stripped away.',
      'Thiruvalluvar captured this eternal truth in couplet 423 of the Thirukkural: "எப்பொருள் யார்யார்வாய்க் கேட்பினும் அப்பொருள் மெய்ப்பொருள் காண்ப தறிவு." (Whoever may speak whatever words, to discern the truth therein is wisdom.)',
      'For decades, competitive exam preparation in our state has been clouded by sensationalism, fake countdowns, and commercial anxiety. HeyMey was created to bring back the calm discipline of the truth.',
    ],
  },
];
