import { glossaryQuery, type GlossaryListDto } from "../domain/glossary.js";
import type { SyllabusRepository } from "./ports.js";

/** GET /v1/glossary?q= (§10.2). */
export async function searchGlossary(repo: SyllabusRepository, q?: string | null): Promise<GlossaryListDto> {
  return { items: await repo.searchGlossary(glossaryQuery(q)) };
}
