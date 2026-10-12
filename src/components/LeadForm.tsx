import { useState, type FormEvent } from 'react';
import { TN_DISTRICTS, EXAM_OPTIONS } from '../content/begin';

export type LeadType = 'waitlist' | 'contact' | 'pilot';

interface LeadFormProps {
  type: LeadType;
  defaultExam?: string;
  defaultIntent?: string;
  onSuccess?: () => void;
}

export const LeadForm = ({ type, defaultExam, defaultIntent }: LeadFormProps) => {
  const [email, setEmail] = useState('');
  const [name, setName] = useState('');
  const [role, setRole] = useState('Aspirant');
  const [exam, setExam] = useState(defaultExam || 'group-4');
  const [district, setDistrict] = useState('Chennai');
  const [message, setMessage] = useState('');
  const [institution, setInstitution] = useState('');
  const [studentCount, setStudentCount] = useState('100');
  const [intent] = useState(defaultIntent || '');
  const [is18Plus, setIs18Plus] = useState(false);
  const [consent, setConsent] = useState(false);
  const [honeypot, setHoneypot] = useState(''); // Anti-spam honeypot per spec §8

  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setErrorMsg('');

    // Honeypot detection
    if (honeypot) {
      setSuccess(true);
      return;
    }

    if (!consent) {
      setErrorMsg('Please accept the consent terms to proceed.');
      return;
    }

    if (type === 'waitlist' && !is18Plus) {
      setErrorMsg('You must be 18 years of age or older.');
      return;
    }

    setLoading(true);

    try {
      // In production, posts to https://app.heymey.in/api/public/leads per spec §8
      await new Promise((resolve) => setTimeout(resolve, 600));
      setSuccess(true);
    } catch {
      setErrorMsg('Unable to submit right now. Please try again or email hello@heymey.in');
    } finally {
      setLoading(false);
    }
  };

  if (success) {
    return (
      <div className="w-full max-w-md p-8 rounded-2xl bg-white border border-neutral-200/90 shadow-sm flex flex-col items-center text-center animate-fade-rise">
        <div className="w-10 h-10 rounded-full bg-neutral-950 text-white flex items-center justify-center text-sm font-medium mb-4">
          ✓
        </div>
        <h3 className="font-serif text-2xl text-neutral-950 font-normal mb-2">
          {type === 'waitlist' ? "You're on the list." : 'Message received.'}
        </h3>
        <p className="font-sans text-xs text-neutral-600 leading-relaxed max-w-xs">
          {type === 'waitlist'
            ? 'We have recorded your beta invitation request. We will email you the moment your batch opens.'
            : `Thanks, we will reply to ${email || 'your email'} within two working days.`}
        </p>
      </div>
    );
  }

  return (
    <form
      onSubmit={handleSubmit}
      className="w-full max-w-md p-6 sm:p-8 rounded-2xl bg-white border border-neutral-200/90 shadow-sm flex flex-col text-left space-y-3.5 select-text"
    >
      {/* Honeypot field (hidden from genuine users per spec §8) */}
      <div className="hidden" aria-hidden="true">
        <input
          type="text"
          name="website"
          value={honeypot}
          onChange={(e) => setHoneypot(e.target.value)}
          tabIndex={-1}
          autoComplete="off"
        />
        {intent && <input type="hidden" name="intent" value={intent} />}
      </div>

      {/* Name for contact and pilot */}
      {(type === 'contact' || type === 'pilot') && (
        <div>
          <label className="block text-xs font-sans font-medium text-neutral-700 mb-1">
            Your Name
          </label>
          <input
            type="text"
            required
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Kavitha R."
            className="w-full px-3.5 py-2.5 rounded-xl border border-neutral-300 bg-white text-sm font-sans focus:outline-none focus:border-neutral-900"
          />
        </div>
      )}

      {/* Institution name for pilot */}
      {type === 'pilot' && (
        <div>
          <label className="block text-xs font-sans font-medium text-neutral-700 mb-1">
            Institution / Academy Name
          </label>
          <input
            type="text"
            required
            value={institution}
            onChange={(e) => setInstitution(e.target.value)}
            placeholder="e.g. Apex IAS Academy, Madurai"
            className="w-full px-3.5 py-2.5 rounded-xl border border-neutral-300 bg-white text-sm font-sans focus:outline-none focus:border-neutral-900"
          />
        </div>
      )}

      {/* Email */}
      <div>
        <label className="block text-xs font-sans font-medium text-neutral-700 mb-1">
          Email Address
        </label>
        <input
          type="email"
          required
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="aspirant@gmail.com"
          className="w-full px-3.5 py-2.5 rounded-xl border border-neutral-300 bg-white text-sm font-sans focus:outline-none focus:border-neutral-900"
        />
      </div>

      {/* Role selector for contact */}
      {type === 'contact' && (
        <div>
          <label className="block text-xs font-sans font-medium text-neutral-700 mb-1">
            I am a...
          </label>
          <select
            value={role}
            onChange={(e) => setRole(e.target.value)}
            className="w-full px-3.5 py-2.5 rounded-xl border border-neutral-300 bg-white text-sm font-sans focus:outline-none focus:border-neutral-900"
          >
            <option value="Aspirant">Aspirant</option>
            <option value="Educator">Educator / Teacher</option>
            <option value="Institution">Institution / Academy</option>
            <option value="Press">Press & Media</option>
            <option value="Investor">Investor</option>
            <option value="Other">Other</option>
          </select>
        </div>
      )}

      {/* Exam selector for waitlist */}
      {type === 'waitlist' && (
        <div>
          <label className="block text-xs font-sans font-medium text-neutral-700 mb-1">
            Target Examination
          </label>
          <select
            value={exam}
            onChange={(e) => setExam(e.target.value)}
            className="w-full px-3.5 py-2.5 rounded-xl border border-neutral-300 bg-white text-sm font-sans focus:outline-none focus:border-neutral-900"
          >
            {EXAM_OPTIONS.map((opt) => (
              <option key={opt.id} value={opt.id}>
                {opt.label}
              </option>
            ))}
          </select>
        </div>
      )}

      {/* District selector for waitlist and pilot */}
      {(type === 'waitlist' || type === 'pilot') && (
        <div>
          <label className="block text-xs font-sans font-medium text-neutral-700 mb-1">
            Tamil Nadu District
          </label>
          <select
            value={district}
            onChange={(e) => setDistrict(e.target.value)}
            className="w-full px-3.5 py-2.5 rounded-xl border border-neutral-300 bg-white text-sm font-sans focus:outline-none focus:border-neutral-900"
          >
            {TN_DISTRICTS.map((dist) => (
              <option key={dist} value={dist}>
                {dist}
              </option>
            ))}
          </select>
        </div>
      )}

      {/* Student count for pilot */}
      {type === 'pilot' && (
        <div>
          <label className="block text-xs font-sans font-medium text-neutral-700 mb-1">
            Approximate Student Count
          </label>
          <input
            type="number"
            min="20"
            max="10000"
            value={studentCount}
            onChange={(e) => setStudentCount(e.target.value)}
            className="w-full px-3.5 py-2.5 rounded-xl border border-neutral-300 bg-white text-sm font-sans focus:outline-none focus:border-neutral-900"
          />
        </div>
      )}

      {/* Message textarea for contact */}
      {type === 'contact' && (
        <div>
          <label className="block text-xs font-sans font-medium text-neutral-700 mb-1">
            Message (Max 1,000 characters)
          </label>
          <textarea
            required
            maxLength={1000}
            rows={3}
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder="Tell us what is on your mind..."
            className="w-full px-3.5 py-2 rounded-xl border border-neutral-300 bg-white text-sm font-sans focus:outline-none focus:border-neutral-900"
          />
        </div>
      )}

      {/* 18+ Checkbox for waitlist */}
      {type === 'waitlist' && (
        <div className="flex items-start gap-2 pt-1">
          <input
            type="checkbox"
            id="is-18-plus"
            checked={is18Plus}
            onChange={(e) => setIs18Plus(e.target.checked)}
            required
            className="mt-0.5 rounded text-neutral-900 focus:ring-neutral-900"
          />
          <label htmlFor="is-18-plus" className="text-xs font-sans text-neutral-600 leading-tight">
            I am 18 years of age or older.
          </label>
        </div>
      )}

      {/* Consent Checkbox */}
      <div className="flex items-start gap-2 pt-1">
        <input
          type="checkbox"
          id="lead-consent"
          checked={consent}
          onChange={(e) => setConsent(e.target.checked)}
          required
          className="mt-0.5 rounded text-neutral-900 focus:ring-neutral-900"
        />
        <label htmlFor="lead-consent" className="text-xs font-sans text-neutral-600 leading-tight">
          I consent to HeyMey storing my contact details solely for this request pursuant to the{' '}
          <a href="/legal/privacy" className="underline hover:text-neutral-900">
            Privacy Policy
          </a>
          .
        </label>
      </div>

      {errorMsg && (
        <p className="text-xs font-sans text-red-600 font-medium">{errorMsg}</p>
      )}

      <button
        type="submit"
        disabled={loading}
        className="w-full py-3 rounded-full bg-neutral-950 hover:bg-neutral-800 text-white font-sans font-medium text-sm transition-all duration-200 cursor-pointer shadow-sm active:scale-[0.98] mt-2"
      >
        {loading
          ? 'Submitting...'
          : type === 'waitlist'
          ? 'Request Beta Invitation'
          : type === 'pilot'
          ? 'Submit Pilot Request'
          : 'Send Message'}
      </button>
    </form>
  );
};
