import type { GlossaryList, z } from "@heymey/contracts";

export type GlossaryListDto = z.infer<typeof GlossaryList>;

export const GLOSSARY_SEARCH_LIMIT = 20;
export const GLOSSARY_BROWSE_LIMIT = 50;

export interface GlossaryQuerySpec {
  /** Case-insensitive "contains" text, or null to browse alphabetically. */
  contains: string | null;
  take: number;
}

/** Tap-to-see meaning glossary (§10.2): search up to 20 by term; without a query, the first 50 A-Z. */
export function glossaryQuery(q?: string | null): GlossaryQuerySpec {
  const text = q?.trim() ?? "";
  return text ? { contains: text, take: GLOSSARY_SEARCH_LIMIT } : { contains: null, take: GLOSSARY_BROWSE_LIMIT };
}
