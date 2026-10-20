import { PORTS, loadLocalEnv } from "@heymey/config";
import { createApiApp } from "./bootstrap.js";

async function main(): Promise<void> {
  loadLocalEnv(); // local development only: repo-root .env from `pnpm env:dev`
  const app = await createApiApp();
  const port = Number(process.env.PORT ?? PORTS.API);
  await app.listen(port, "0.0.0.0");
  console.log(`api listening on :${port} (${process.env.HEYMEY_ENV ?? "local"})`);
}

void main();
