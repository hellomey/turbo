import { routes, type HmRoute } from "@heymey/contracts";

/** "/v1/exams/{code}" (OpenAPI) -> "/v1/exams/:code" (Fastify). */
export const toFastifyPath = (path: string) => path.replace(/\{(\w+)\}/g, ":$1");

const byKey = new Map<string, HmRoute>(routes.map((r) => [`${r.method.toUpperCase()} ${toFastifyPath(r.path)}`, r]));

/** The contract entry for a matched Fastify route, or undefined if the route is not in the contract. */
export function policyFor(method: string, fastifyUrl: string | undefined): HmRoute | undefined {
  return fastifyUrl ? byKey.get(`${method.toUpperCase()} ${fastifyUrl}`) : undefined;
}

/** The 2xx status the contract declares for a route (used for replayed idempotent responses). */
export function successStatus(route: HmRoute): number {
  const code = Object.keys(route.responses).map(Number).find((c) => c >= 200 && c < 300);
  return code ?? 200;
}
