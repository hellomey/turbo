export interface ExamCard {
  id: string;
  title: string;
  subtitle: string;
  status: 'In beta' | 'Coming soon' | 'Planned' | 'Later';
  badgeColor: string;
  href: string;
  isExternal?: boolean;
}

export const examsContent = {
  en: {
    metaTitle: 'Choose Your Exam — HeyMey',
    metaDescription:
      "We're starting with the exams most Tamil Nadu aspirants sit. Explore TNPSC Group 4 & VAO, Group 2, and upcoming coverage.",
    headline: 'Choose your exam.',
    subhead: "We're starting with the ones most Tamil Nadu aspirants sit.",
    disclaimer:
      'HeyMey is independent and is not affiliated with TNPSC or the Government of Tamil Nadu.',
    cards: [
      {
        id: 'group-4',
        title: 'TNPSC Group 4 & VAO',
        subtitle: 'Village Administrative Officer & Ministerial Services',
        status: 'In beta',
        badgeColor: 'bg-emerald-100 text-emerald-800 border-emerald-300',
        href: '/exams/tnpsc-group-4',
      },
      {
        id: 'group-2',
        title: 'TNPSC Group 2 & 2A',
        subtitle: 'Combined Civil Services Examination II (Executive & Non-Executive)',
        status: 'Coming soon',
        badgeColor: 'bg-amber-100 text-amber-800 border-amber-300',
        href: '/begin?exam=group-2',
      },
      {
        id: 'tnusrb',
        title: 'Police Recruitment (TNUSRB)',
        subtitle: 'Sub-Inspector and Police Constable examinations',
        status: 'Planned',
        badgeColor: 'bg-neutral-100 text-neutral-700 border-neutral-300',
        href: '/begin?exam=tnusrb',
      },
      {
        id: 'tet',
        title: 'Teacher Eligibility (TET / TRB)',
        subtitle: 'Tamil Nadu Teacher Recruitment Board eligibility',
        status: 'Planned',
        badgeColor: 'bg-neutral-100 text-neutral-700 border-neutral-300',
        href: '/begin?exam=tet',
      },
      {
        id: 'central',
        title: 'Banking, SSC & Railways',
        subtitle: 'Central examinations with bilingual preparation',
        status: 'Later',
        badgeColor: 'bg-neutral-100 text-neutral-700 border-neutral-300',
        href: '/begin?exam=central',
      },
    ] as ExamCard[],
  },
};

export const group4DetailContent = {
  en: {
    metaTitle: 'TNPSC Group 4 & VAO Preparation — HeyMey',
    metaDescription:
      'Honest numbers, cycle timeline, and verified facts for TNPSC Group 4. Understand where you truly stand.',
    panels: [
      {
        id: 'numbers',
        badge: '01 / The Reality',
        headline: 'One exam. A very large room.',
        body: 'Roughly one selection for every 300–350 candidates. That is why knowing where you truly stand matters.',
        stats: [
          { value: '~20 Lakh', label: 'Candidates Applied' },
          { value: '13,89,738', label: 'Appeared on Exam Day' },
          { value: '3,935', label: 'Posts Notified (Jul 2025)' },
        ],
        sourceNote:
          'Source: TNPSC Group 4, 12 July 2025, as reported by Dinamalar (Oct 2025) and News Today (Jul 2025). Later reports cite ~4,662 posts.',
      },
      {
        id: 'structure',
        badge: '02 / Exam Pattern',
        headline: 'What the exam tests.',
        body: 'A single objective paper of 200 questions carrying 300 marks over 3 hours.',
        papers: [
          { name: 'Part A: General Tamil', qs: '100 Qs', marks: '150 Marks' },
          { name: 'Part B: General Studies', qs: '75 Qs', marks: '112.5 Marks' },
          { name: 'Part B: Aptitude & Mental Ability', qs: '25 Qs', marks: '37.5 Marks' },
        ],
        officialLink: 'https://www.tnpsc.gov.in',
      },
      {
        id: 'cycle',
        badge: '03 / Timeline',
        headline: 'One complete cycle.',
        body: 'Preparation looks different at each stage. So does your daily guidance in HeyMey.',
        timeline: [
          { date: '25 Apr 2025', stage: 'Official Notification Published' },
          { date: '24 May 2025', stage: 'Online Applications Close' },
          { date: '12 Jul 2025', stage: 'Statewide Written Exam' },
          { date: '21 Jul 2025', stage: 'Tentative Answer Keys Released' },
          { date: '22 Oct 2025', stage: 'Rank & Selection Results' },
        ],
      },
      {
        id: 'how-we-prepare',
        badge: '04 / The Approach',
        headline: 'How HeyMey prepares you.',
        body: 'No mindless mock dumps. Targeted clarity every single day.',
        points: [
          { title: 'Readiness Score', desc: 'See your true score percentile across 4 honest dimensions.', link: '/studio#know' },
          { title: 'Targeted Daily Five', desc: 'Five daily questions calibrated to fix past mistakes.', link: '/studio#practise' },
          { title: 'Bilingual Clarification', desc: 'Instant concept explanations in clear Tamil and English.', link: '/studio#understand' },
        ],
      },
      {
        id: 'begin',
        badge: '05 / Begin Today',
        headline: 'Start with honest clarity.',
        body: 'Take your first diagnostic for TNPSC Group 4 today.',
        ctaText: 'Begin Journey',
        secondaryText: 'Official TNPSC Portal',
        secondaryHref: 'https://www.tnpsc.gov.in',
      },
    ],
  },
};
