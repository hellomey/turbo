"use client";

import { useEffect, useState } from "react";
import Link from "next/link";

export const WEB_APP_URL = "https://app.heymey.app/";
// Interim APK location until dl.heymey.app is live.
export const APK_URL =
  "https://github.com/hellomey/turbo/releases/download/latest/heymey-latest.apk";

type Device = "android" | "other";
type Step = "age" | "go";

/** Keep only a short, safe source tag such as "flex", "poster" or "table". */
export function cleanSrc(raw: string | null): string | null {
  if (!raw) return null;
  const v = raw.toLowerCase();
  return /^[a-z0-9-]{1,24}$/.test(v) ? v : null;
}

export function withSrc(url: string, src: string | null): string {
  if (!src) return url;
  const u = new URL(url);
  u.searchParams.set("src", src);
  return u.toString();
}

export function detectDevice(ua: string): Device {
  return /android/i.test(ua) ? "android" : "other";
}

function StepIcon({ n }: { n: 1 | 2 | 3 }) {
  const fill = n === 1 ? "#d7261e" : n === 2 ? "#f5c518" : "#1f4fa3";
  return (
    <svg viewBox="0 0 64 64" aria-hidden="true">
      {n === 1 && <circle cx="32" cy="32" r="28" fill={fill} stroke="#111" strokeWidth="4" />}
      {n === 2 && <polygon points="32,4 60,58 4,58" fill={fill} stroke="#111" strokeWidth="4" />}
      {n === 3 && <rect x="5" y="5" width="54" height="54" fill={fill} stroke="#111" strokeWidth="4" />}
      <text x="32" y={n === 2 ? 50 : 42} textAnchor="middle" fontSize="28" fontWeight="900" fill={n === 2 ? "#111" : "#fff"} fontFamily="Nunito, sans-serif">
        {n}
      </text>
    </svg>
  );
}

export default function TryFlow() {
  const [step, setStep] = useState<Step>("age");
  const [device, setDevice] = useState<Device>("other");
  const [src, setSrc] = useState<string | null>(null);

  useEffect(() => {
    setDevice(detectDevice(navigator.userAgent));
    setSrc(cleanSrc(new URLSearchParams(window.location.search).get("src")));
  }, []);

  const waitlistHref = src ? `/waitlist?src=${src}` : "/waitlist";

  if (step === "age") {
    return (
      <>
        <h1>Light up your TNPSC syllabus.</h1>
        <p>Try HeyMey free in your browser. No install needed.</p>
        <h2 id="age-q">Are you 18 or older?</h2>
        <div className="st-row" role="group" aria-labelledby="age-q">
          <button type="button" className="st-btn blue" onClick={() => setStep("go")}>
            Yes
          </button>
          <Link className="st-btn" href={waitlistHref}>
            No
          </Link>
        </div>
        <p className="st-small">
          We ask because accounts are for adults only. If you are under 18, you can
          join the waitlist instead.
        </p>
      </>
    );
  }

  return (
    <>
      <h1>Play for 60 seconds. Light your first lamp.</h1>
      <div className="st-beta" role="note">
        Beta: HeyMey is still being built. Some features are on the way.
      </div>
      <a className="st-btn red" href={withSrc(WEB_APP_URL, src)}>
        Open HeyMey
      </a>
      <p className="st-small">
        It opens in your browser. Play as a guest first, then sign in with your
        email to save your progress.
      </p>

      {device === "android" && (
        <>
          <h2>Want the Android app?</h2>
          <a className="st-btn" href={withSrc(APK_URL, src)}>
            Download the Android app
          </a>
          <ol className="st-steps">
            <li>
              <StepIcon n={1} />
              <span>
                <b>Download</b>
                <small>Tap the button above. The file is called heymey-latest.apk.</small>
              </span>
            </li>
            <li>
              <StepIcon n={2} />
              <span>
                <b>Allow the install</b>
                <small>
                  Open the file. If Android asks, turn on &quot;Allow from this
                  source&quot; for your browser.
                </small>
              </span>
            </li>
            <li>
              <StepIcon n={3} />
              <span>
                <b>Install and open</b>
                <small>Tap Install, then Open. The app tells you when an update is ready.</small>
              </span>
            </li>
          </ol>
          <p className="st-small">
            The app is not on the Play Store yet, so Android asks before installing it.
          </p>
        </>
      )}
    </>
  );
}
