import type { Metadata } from "next";
import { StallShell, DraftNotice } from "../../components/stall/Shell";

export const metadata: Metadata = { title: "Privacy policy | HeyMey" };

// Shell only. The text is owned by Kaaval and needs founder and legal approval.
export default function Page() {
  return (
    <StallShell>
      <h1>Privacy policy</h1>
      <DraftNotice />
    </StallShell>
  );
}
