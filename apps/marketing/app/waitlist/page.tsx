import type { Metadata } from "next";
import { StallShell, DraftNotice } from "../../components/stall/Shell";

export const metadata: Metadata = {
  title: "HeyMey waitlist",
  description: "HeyMey accounts are for adults. Under 18? Here is what happens next.",
};

export default function WaitlistPage() {
  return (
    <StallShell>
      <h1>Thanks for being honest.</h1>
      <p>
        HeyMey accounts are for people aged 18 and over, so we can&apos;t make one for
        you yet.
      </p>
      <p>
        We are building a waitlist that needs no account. It isn&apos;t open yet. Ask
        at the stall and we will tell you when it is.
      </p>
      <DraftNotice />
    </StallShell>
  );
}
