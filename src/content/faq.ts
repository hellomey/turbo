export interface FaqItem {
  q: string;
  a: string;
}

export interface FaqCategory {
  id: string;
  title: string;
  badge: string;
  items: FaqItem[];
}

export const faqContent = {
  en: {
    metaTitle: 'Frequently Asked Questions — HeyMey',
    metaDescription:
      'Clear, honest answers about our free tier, bilingual features, AI accuracy, privacy, and independence from TNPSC.',
    categories: [
      {
        id: 'basics',
        title: 'Basics & Access',
        badge: '01 / Fundamentals',
        items: [
          {
            q: 'Is HeyMey free?',
            a: 'Getting started is completely free. Your first comprehensive diagnostic, daily 5-minute challenges, core diagnosis, and several concept doubts daily require no payment.',
          },
          {
            q: 'Which exams does HeyMey cover?',
            a: 'We are starting with TNPSC Group 4 and VAO. TNPSC Group 2/2A, Police (TNUSRB), and TET are in active preparation.',
          },
          {
            q: 'Is HeyMey in Tamil?',
            a: 'Yes. The interface is available in clean English and Tamil. All questions, options, and explanations are natively bilingual.',
          },
          {
            q: 'Who is HeyMey designed for?',
            a: 'Adults (18+) actively preparing for Tamil Nadu state competitive examinations who want focused, daily discipline without noise.',
          },
        ],
      },
      {
        id: 'accuracy',
        title: 'Trust & Accuracy',
        badge: '02 / Reliability',
        items: [
          {
            q: 'How accurate is the readiness score?',
            a: 'It is a calculated statistical estimate based on syllabus coverage, consistency, and mastery. It displays our confidence interval, but never predicts guaranteed selection.',
          },
          {
            q: 'Does the AI ever make mistakes?',
            a: 'Occasionally yes. All AI explanations are clearly tagged with an error-reporting flag. When mistakes are reported, our team reviews and corrects the underlying material.',
          },
          {
            q: 'How are practice questions checked?',
            a: 'Every question is cross-referenced against Tamil Nadu SCERT Samacheer Kalvi textbooks and verified official TNPSC answer keys before release.',
          },
          {
            q: 'Do you guarantee rank or selection?',
            a: 'No. No honest institution or platform can promise a government job. We promise clarity on where you truly stand today.',
          },
        ],
      },
      {
        id: 'usage',
        title: 'Daily Usage',
        badge: '03 / Experience',
        items: [
          {
            q: 'Does it work smoothly on basic mobile phones?',
            a: 'Yes. HeyMey is built mobile-first, engineered to run smoothly on mid-range Android phones even over modest 4G connections.',
          },
          {
            q: 'Is there an installable mobile app?',
            a: 'A dedicated lightweight Android app is coming soon for beta participants. The web platform works seamlessly across all phone browsers today.',
          },
          {
            q: 'What happens if I miss a daily study streak?',
            a: 'Your streak receives a built-in forgiveness shield every month. Sudi, our companion flame, never shames or penalizes you.',
          },
          {
            q: 'Can I export or delete my personal data?',
            a: 'Yes. You have full ownership of your data and can request a full export or permanent erasure anytime directly from account settings.',
          },
        ],
      },
      {
        id: 'company',
        title: 'Money & Independence',
        badge: '04 / Integrity',
        items: [
          {
            q: 'How does HeyMey generate revenue?',
            a: 'Through transparent, fixed-price Exam Cycle Passes for individual aspirants and institutional licenses for coaching academies.',
          },
          {
            q: 'Can I request a refund if not satisfied?',
            a: 'Yes. We maintain a straightforward, plain-language refund policy outlined clearly under our legal terms.',
          },
          {
            q: 'Are you affiliated with the Government of Tamil Nadu or TNPSC?',
            a: 'No. HeyMey is an independent preparation companion and is not affiliated, endorsed, or connected with TNPSC or any government body.',
          },
          {
            q: 'Who is building HeyMey?',
            a: 'A dedicated team of educators, engineers, and former Tamil Nadu aspirants committed to honest, calm educational technology.',
          },
        ],
      },
    ] as FaqCategory[],
  },
};
