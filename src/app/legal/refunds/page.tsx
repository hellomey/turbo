import type { Metadata } from "next";
import { LegalPage } from "@/components/LegalPage";

export const metadata: Metadata = { title: "Refund & Cancellation Policy" };

export default function Page() {
  return <LegalPage doc="refunds" />;
}
