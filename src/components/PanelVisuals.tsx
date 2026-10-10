import { useState, useEffect } from 'react';
import { Sudi, type SudiState } from './Sudi';

/* 1. Readiness Ring with 4 Sub-Bars */
export const ReadinessRing = () => {
  return (
    <div className="w-full max-w-sm p-6 rounded-3xl bg-white/80 backdrop-blur-md border border-neutral-200/80 shadow-xl flex flex-col items-center">
      <div className="relative w-36 h-36 flex items-center justify-center">
        <svg className="w-full h-full -rotate-90" viewBox="0 0 100 100">
          <circle cx="50" cy="50" r="40" stroke="#E5E7EB" strokeWidth="8" fill="none" />
          <circle
            cx="50"
            cy="50"
            r="40"
            stroke="#D97706"
            strokeWidth="8"
            strokeDasharray="251.2"
            strokeDashoffset="65"
            strokeLinecap="round"
            fill="none"
            className="transition-all duration-1000 ease-out"
          />
        </svg>
        <div className="absolute flex flex-col items-center text-center">
          <span className="font-serif text-3xl font-bold text-neutral-900 leading-none">74%</span>
          <span className="text-[11px] font-sans font-medium text-amber-700 uppercase tracking-wider mt-1">
            Readiness
          </span>
        </div>
      </div>

      {/* Four Sub-Bars */}
      <div className="w-full mt-6 space-y-2.5 text-xs font-sans">
        <div>
          <div className="flex justify-between text-neutral-600 mb-1">
            <span>Accuracy & Retention</span>
            <span className="font-medium text-neutral-900">78%</span>
          </div>
          <div className="w-full h-1.5 bg-neutral-100 rounded-full overflow-hidden">
            <div className="w-[78%] h-full bg-amber-500 rounded-full" />
          </div>
        </div>
        <div>
          <div className="flex justify-between text-neutral-600 mb-1">
            <span>Practice Consistency</span>
            <span className="font-medium text-neutral-900">85%</span>
          </div>
          <div className="w-full h-1.5 bg-neutral-100 rounded-full overflow-hidden">
            <div className="w-[85%] h-full bg-amber-500 rounded-full" />
          </div>
        </div>
        <div>
          <div className="flex justify-between text-neutral-600 mb-1">
            <span>Syllabus Covered</span>
            <span className="font-medium text-neutral-900">62%</span>
          </div>
          <div className="w-full h-1.5 bg-neutral-100 rounded-full overflow-hidden">
            <div className="w-[62%] h-full bg-amber-500 rounded-full" />
          </div>
        </div>
        <div>
          <div className="flex justify-between text-neutral-600 mb-1">
            <span>Directional Velocity</span>
            <span className="font-medium text-emerald-700">↗ Improving</span>
          </div>
          <div className="w-full h-1.5 bg-neutral-100 rounded-full overflow-hidden">
            <div className="w-[70%] h-full bg-emerald-500 rounded-full" />
          </div>
        </div>
      </div>
    </div>
  );
};

/* 2. Question Card with Interactive Selection */
export const QuestionCard = () => {
  const [selected, setSelected] = useState<number | null>(1);
  const options = [
    { id: 0, text: 'Rajendra Chola I', isCorrect: false },
    { id: 1, text: 'Rajaraja Chola I (கி.பி. 1010)', isCorrect: true },
    { id: 2, text: 'Kulothunga Chola', isCorrect: false },
    { id: 3, text: 'Parantaka I', isCorrect: false },
  ];

  return (
    <div className="w-full max-w-sm p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-xl flex flex-col text-left">
      <div className="flex items-center justify-between mb-3 text-xs font-sans">
        <span className="px-2.5 py-1 rounded-full bg-amber-100 text-amber-900 font-medium">
          Daily Challenge #42
        </span>
        <span className="text-neutral-500 font-tamil">தமிழ் & English</span>
      </div>

      <p className="font-sans text-sm font-medium text-neutral-900 mb-4 leading-snug">
        Who constructed the Brihadisvara Temple (Peruvudaiyar Kovil) at Thanjavur?
      </p>

      <div className="space-y-2">
        {options.map((opt) => {
          const isChosen = selected === opt.id;
          return (
            <button
              key={opt.id}
              type="button"
              onClick={() => setSelected(opt.id)}
              className={`w-full p-2.5 rounded-xl text-xs font-sans text-left flex items-center justify-between transition-all cursor-pointer ${
                isChosen
                  ? 'bg-neutral-900 text-white font-medium shadow-md'
                  : 'bg-neutral-50 hover:bg-neutral-100 text-neutral-800 border border-neutral-200/60'
              }`}
            >
              <span>{opt.text}</span>
              {isChosen && opt.isCorrect && (
                <svg className="w-4 h-4 text-emerald-400 ml-2" fill="currentColor" viewBox="0 0 20 20">
                  <path
                    fillRule="evenodd"
                    d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                    clipRule="evenodd"
                  />
                </svg>
              )}
            </button>
          );
        })}
      </div>

      <p className="mt-4 text-[11px] text-neutral-500 text-center font-sans">
        Instant calibration • Builds your personal revision queue
      </p>
    </div>
  );
};

/* 3. Bilingual AI Chat Explanation */
export const ChatTyping = () => {
  return (
    <div className="w-full max-w-sm p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-xl flex flex-col space-y-3.5 text-left text-xs font-sans">
      <div className="flex items-start gap-2.5">
        <div className="w-7 h-7 rounded-full bg-neutral-900 text-white flex items-center justify-center font-serif text-sm">
          A
        </div>
        <div className="p-3 rounded-2xl rounded-tl-sm bg-neutral-100 text-neutral-800 max-w-[85%]">
          What is Article 324 in Indian Constitution? தமிழ்ல சொல்லுங்க.
        </div>
      </div>

      <div className="flex items-start gap-2.5">
        <Sudi state="bright" size={28} />
        <div className="p-3.5 rounded-2xl rounded-tl-sm bg-amber-50/90 border border-amber-200/70 text-neutral-900 max-w-[85%] leading-relaxed space-y-1.5 font-tamil">
          <p className="font-semibold text-amber-950 font-sans">
            சரத்து 324 (Article 324)
          </p>
          <p className="text-neutral-700">
            இந்திய தேர்தல் ஆணையத்தின் அதிகாரம் மற்றும் தேர்தல் மேற்பார்வை பற்றி கூறுகிறது.
          </p>
          <span className="inline-block text-[10px] text-neutral-500 font-sans pt-1">
            ✦ AI Explanation • Verified against SCERT Book
          </span>
        </div>
      </div>
    </div>
  );
};

const SUDI_STATES: SudiState[] = ['resting', 'bright', 'thinking', 'sleepy'];

/* 4. Sudi State Cycler */
export const SudiCycler = () => {
  const [currentState, setCurrentState] = useState<SudiState>('resting');

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentState((prev) => {
        const nextIndex = (SUDI_STATES.indexOf(prev) + 1) % SUDI_STATES.length;
        return SUDI_STATES[nextIndex];
      });
    }, 2800);
    return () => clearInterval(timer);
  }, []);

  return (
    <div className="w-full max-w-sm p-8 rounded-3xl bg-white/80 backdrop-blur-md border border-neutral-200/80 shadow-xl flex flex-col items-center text-center">
      <Sudi state={currentState} size={84} />
      <span className="mt-4 px-3 py-1 rounded-full bg-amber-100 text-amber-900 text-xs font-sans font-medium capitalize tracking-wide">
        Sudi: {currentState}
      </span>
      <p className="mt-3 text-xs text-neutral-600 font-sans max-w-[220px]">
        {currentState === 'resting' && 'Ready for your daily 5-minute practice.'}
        {currentState === 'bright' && 'Celebrating honest revision streaks!'}
        {currentState === 'thinking' && 'Simplifying complex syllabus concepts.'}
        {currentState === 'sleepy' && 'Streak shield active. Zero guilt.'}
      </p>
    </div>
  );
};

/* 5. Exam Cycle Timeline */
export const ExamTimeline = () => {
  const stages = [
    { stage: 'Notification', date: 'Apr 2025', active: true },
    { stage: 'Applications', date: 'May 2025', active: true },
    { stage: 'Exam Day', date: 'Jul 2025', active: true },
    { stage: 'Answer Key', date: 'Jul 2025', active: true },
    { stage: 'Final Ranks', date: 'Oct 2025', active: true },
  ];

  return (
    <div className="w-full max-w-sm p-6 rounded-3xl bg-white/85 backdrop-blur-md border border-neutral-200/80 shadow-xl flex flex-col text-left">
      <span className="text-xs font-sans font-semibold text-neutral-900 mb-4 uppercase tracking-wider">
        2025 TNPSC Group 4 Cycle
      </span>
      <div className="relative pl-6 space-y-4 before:absolute before:left-2 before:top-2 before:bottom-2 before:w-0.5 before:bg-amber-300">
        {stages.map((st) => (
          <div key={st.stage} className="relative">
            <span className="absolute -left-6 top-1 w-2.5 h-2.5 rounded-full bg-amber-600 ring-4 ring-white" />
            <div className="text-xs font-sans">
              <span className="font-medium text-neutral-900">{st.stage}</span>
              <span className="text-neutral-500 ml-2 font-mono text-[11px]">{st.date}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

/* 6. Kolam Line-Draw Visual for /begin */
export const KolamDraw = () => {
  return (
    <div className="relative w-40 h-40 flex items-center justify-center">
      <svg className="w-full h-full text-amber-500/80 animate-spin" style={{ animationDuration: '40s' }} viewBox="0 0 100 100">
        <circle cx="50" cy="50" r="42" stroke="currentColor" strokeWidth="1.2" strokeDasharray="4 4" fill="none" />
        <circle cx="50" cy="50" r="30" stroke="currentColor" strokeWidth="1.5" fill="none" />
        <path d="M50 10 L50 90 M10 50 L90 50" stroke="currentColor" strokeWidth="1" strokeDasharray="2 3" />
        <rect x="29" y="29" width="42" height="42" stroke="currentColor" strokeWidth="1.5" fill="none" transform="rotate(45 50 50)" />
      </svg>
      <div className="absolute">
        <Sudi state="bright" size={44} />
      </div>
    </div>
  );
};
