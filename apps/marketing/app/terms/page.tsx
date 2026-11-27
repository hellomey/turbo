import type { Metadata } from "next";
import { StallShell, DraftNotice } from "../../components/stall/Shell";

export const metadata: Metadata = { title: "Terms of use | HeyMey" };

// Shell only. The text is owned by Kaaval and needs founder and legal approval.
export default function Page() {
  return (
    <StallShell>
      <h1>Terms of use</h1>
      <DraftNotice />
    </StallShell>
  );
}
