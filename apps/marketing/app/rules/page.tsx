import type { Metadata } from "next";
import { StallShell, DraftNotice } from "../../components/stall/Shell";
import "./rules.css";

export const metadata: Metadata = {
  title: "Game rules and odds | HeyMey",
  description: "HeyMey games are free. Prizes are Points only. The exact Daily Spin odds and Confidence Duel scoring.",
};

// Game facts mirror the server tables in packages/domain/src/modules/games (DAILY_SPIN_ODDS v1, DUEL_RULES), which the
// API also serves at GET /v1/games/rules. A domain test fails if this page and those tables disagree.
const SPIN = [
  { label: "5 Points", percent: 40 },
  { label: "10 Points", percent: 30 },
  { label: "20 Points", percent: 15 },
  { label: "50 Points", percent: 5 },
  { label: "Better luck tomorrow", percent: 10 },
];

const DUEL = [
  { label: "Not sure", right: 2, wrong: 1 },
  { label: "Fairly sure", right: 3, wrong: 0 },
  { label: "Certain", right: 5, wrong: 0 },
];

export default function Page() {
  return (
    <StallShell>
      <h1>Game rules and odds</h1>
      <p>
        HeyMey games are free. You never pay, bet or stake anything to play, and nothing can be cashed out. Prizes are
        Points only. Points can&apos;t be bought, and they never turn into Sparks or money.
      </p>

      <h2>Daily Spin</h2>
      <p>
        One free spin a day, India time. Our server picks the prize; the app only shows it. These are the exact
        chances (odds table version 1):
      </p>
      <table className="st-table">
        <thead>
          <tr>
            <th scope="col">Prize</th>
            <th scope="col">Chance</th>
          </tr>
        </thead>
        <tbody>
          {SPIN.map((p) => (
            <tr key={p.label}>
              <td>{p.label}</td>
              <td>{p.percent}%</td>
            </tr>
          ))}
        </tbody>
      </table>
      <p>Spin again on the same day and you see the same prize. Nothing is paid twice.</p>

      <h2>Confidence Duel</h2>
      <p>
        Five practice questions and a 150-second clock. With each answer you say how sure you are. Sure and right
        earns the most. Sure and wrong earns nothing. An honest &quot;Not sure&quot; still earns a point when you miss.
        You can never lose Points.
      </p>
      <table className="st-table">
        <thead>
          <tr>
            <th scope="col">How sure</th>
            <th scope="col">Right</th>
            <th scope="col">Wrong</th>
          </tr>
        </thead>
        <tbody>
          {DUEL.map((r) => (
            <tr key={r.label}>
              <td>{r.label}</td>
              <td>{r.right} Points</td>
              <td>{r.wrong} Points</td>
            </tr>
          ))}
        </tbody>
      </table>
      <ul className="st-list">
        <li>Duels earn up to 50 Points a day. After that you can keep playing for practice.</li>
        <li>Answers sent within 10 seconds of the start earn no Points.</li>
        <li>If your connection drops, you get 60 extra seconds. After that the duel is still marked, with no Points.</li>
      </ul>

      <h2>When games are open</h2>
      <p>Games sleep from 12 AM to 5 AM India time. Study stays open all day.</p>

      <DraftNotice />
    </StallShell>
  );
}
