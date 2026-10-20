"use client";
// Posts to the product app's real endpoint: POST {APP_URL}/api/public/leads.
// Success is shown only when the server says so; failures show its message.
import { useState, type FormEvent } from "react";
import { AnimatePresence } from "motion/react";
import * as m from "motion/react-m";
import { APP_URL } from "@/lib/site";

type LeadType = "waitlist" | "contact" | "pilot";

const TABS: { id: LeadType; label: string }[] = [
  { id: "waitlist", label: "Join the beta" },
  { id: "contact", label: "Ask a question" },
  { id: "pilot", label: "For institutions" },
];

const EXAMS = [
  { id: "group-4", label: "TNPSC Group IV & VAO" },
  { id: "group-2", label: "TNPSC Group II / IIA" },
  { id: "tet", label: "Tamil Nadu TET (Paper I & II)" },
  { id: "set", label: "Tamil Nadu SET (TNSET)" },
  { id: "police", label: "TN Police (SI / Constable)" },
  { id: "other", label: "Other TN Govt Exams" },
];

const field =
  "mt-2 block min-h-12 w-full rounded-xl border border-white/15 bg-white/[0.04] px-4 text-[1rem] text-white placeholder:text-white/35 focus:border-mint-400/70 focus:outline-none";

export function LeadForm() {
  const [type, setType] = useState<LeadType>("waitlist");
  const [status, setStatus] = useState<"idle" | "sending" | "done" | "error">("idle");
  const [error, setError] = useState("");

  async function onSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const fd = new FormData(e.currentTarget);
    const get = (k: string) => (fd.get(k) as string | null)?.trim() || undefined;
    setStatus("sending");
    setError("");
    try {
      const res = await fetch(`${APP_URL}/api/public/leads`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          type,
          email: get("email"),
          name: get("name"),
          exam: type === "waitlist" ? get("exam") : undefined,
          district: type === "waitlist" ? get("district") : undefined,
          institution: type === "pilot" ? get("institution") : undefined,
          studentCount: type === "pilot" && get("studentCount") ? Number(get("studentCount")) : undefined,
          message: get("message"),
          is18Plus: type === "waitlist" ? fd.get("is18Plus") === "on" : undefined,
          consent: fd.get("consent") === "on",
          website: (fd.get("website") as string) ?? "",
        }),
      });
      if (!res.ok) {
        let reason = "";
        try {
          reason = (await res.json()).error ?? "";
        } catch {
          /* non-JSON error */
        }
        setError(reason || "We couldn't send that right now. Please try again.");
        setStatus("error");
        return;
      }
      setStatus("done");
    } catch {
      setError("We couldn't reach HeyMey right now. Please check your connection and try again.");
      setStatus("error");
    }
  }

  if (status === "done") {
    return (
      <div role="status" className="grad-border rounded-[1.75rem] p-8 [--grad-fill:#0a0714]">
        <p className="font-[family-name:var(--font-display)] text-4xl">
          {type === "waitlist" ? "You're on the list." : "Message received."}
        </p>
        <p className="mt-3 text-ink-2">We will write to you at the address you gave. No spam, ever.</p>
      </div>
    );
  }

  return (
    <div className="rounded-[1.75rem] border border-line p-[clamp(1.25rem,3vw,2.5rem)]">
      <div role="tablist" aria-label="What would you like to do?" className="flex flex-wrap gap-2">
        {TABS.map((t) => (
          <button
            key={t.id}
            role="tab"
            type="button"
            aria-selected={type === t.id}
            onClick={() => setType(t.id)}
            className={`relative min-h-11 rounded-full px-4 text-[0.95rem] font-medium ${type === t.id ? "text-black" : "text-ink-2 hover:text-white"}`}
          >
            {type === t.id && (
              <m.span layoutId="lead-tab" className="absolute inset-0 -z-0 rounded-full bg-white" transition={{ type: "spring", stiffness: 420, damping: 34 }} />
            )}
            <span className="relative">{t.label}</span>
          </button>
        ))}
      </div>

      <form onSubmit={onSubmit} className="mt-6 grid gap-5" noValidate={false}>
        {/* Honeypot: hidden from people and assistive tech. */}
        <div aria-hidden className="absolute -left-[9999px]">
          <label>
            Website <input name="website" tabIndex={-1} autoComplete="off" />
          </label>
        </div>

        <label className="text-sm font-medium">
          Email address
          <input name="email" type="email" required autoComplete="email" placeholder="you@example.com" className={field} />
        </label>
        <label className="text-sm font-medium">
          Name <span className="text-ink-3">(optional)</span>
          <input name="name" autoComplete="name" className={field} />
        </label>

        <AnimatePresence mode="popLayout" initial={false}>
          {type === "waitlist" && (
            <m.div key="w" initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }} className="grid gap-5 sm:grid-cols-2">
              <label className="text-sm font-medium">
                Exam
                <select name="exam" className={field} defaultValue="group-4">
                  {EXAMS.map((x) => (
                    <option key={x.id} value={x.id} className="bg-black">
                      {x.label}
                    </option>
                  ))}
                </select>
              </label>
              <label className="text-sm font-medium">
                District
                <input name="district" autoComplete="address-level2" placeholder="e.g. Madurai" className={field} />
              </label>
            </m.div>
          )}
          {type === "pilot" && (
            <m.div key="p" initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }} className="grid gap-5 sm:grid-cols-2">
              <label className="text-sm font-medium">
                Institution
                <input name="institution" required className={field} />
              </label>
              <label className="text-sm font-medium">
                Number of students
                <input name="studentCount" type="number" min={1} inputMode="numeric" className={field} />
              </label>
            </m.div>
          )}
        </AnimatePresence>

        <label className="text-sm font-medium">
          Message <span className="text-ink-3">(optional)</span>
          <textarea name="message" rows={4} maxLength={2000} className={`${field} py-3`} />
        </label>

        {type === "waitlist" && (
          <label className="flex min-h-11 items-start gap-3 text-sm text-ink-2">
            <input name="is18Plus" type="checkbox" required className="mt-1 size-5 accent-[#5df3be]" />I am 18 years of age or older.
          </label>
        )}
        <label className="flex min-h-11 items-start gap-3 text-sm text-ink-2">
          <input name="consent" type="checkbox" required className="mt-1 size-5 accent-[#5df3be]" />
          <span>
            I consent to HeyMey storing my contact details for this request, as described in the{" "}
            <a href="/legal/privacy" className="underline underline-offset-4">
              privacy policy
            </a>
            .
          </span>
        </label>

        {status === "error" && (
          <p role="alert" className="rounded-xl border border-red-400/40 bg-red-500/10 px-4 py-3 text-sm text-red-200">
            {error}
          </p>
        )}

        <m.button
          type="submit"
          disabled={status === "sending"}
          whileTap={{ scale: 0.98 }}
          className="grad-border flex min-h-14 items-center justify-center rounded-full text-lg font-semibold text-black disabled:opacity-60 [--grad-fill:#fff]"
        >
          {status === "sending" ? "Sending…" : type === "waitlist" ? "Request an invitation" : "Send"}
        </m.button>
      </form>
    </div>
  );
}
