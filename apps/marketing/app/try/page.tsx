import type { Metadata } from "next";
import { StallShell } from "../../components/stall/Shell";
import TryFlow from "../../components/stall/TryFlow";

export const metadata: Metadata = {
  title: "Try HeyMey: light up your TNPSC syllabus",
  description:
    "Try HeyMey in your browser, no install needed. A study app for TNPSC Group 4 and Group 2/2A, in beta.",
};

export default function TryPage() {
  return (
    <StallShell>
      <TryFlow />
    </StallShell>
  );
}
