import path from "node:path";
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Monorepo: standalone server for the Docker image (infra/docker/marketing.Dockerfile), traced from the repo root.
  output: "standalone",
  outputFileTracingRoot: path.join(process.cwd(), "../.."),
  images: {
    formats: ["image/avif", "image/webp"],
  },
  // Routes from the previous (Vite) marketing site keep working.
  async redirects() {
    return [
      { source: "/studio", destination: "/creators", permanent: true },
      { source: "/journal", destination: "/about", permanent: true },
      { source: "/journal/:slug*", destination: "/about", permanent: true },
      { source: "/result-day", destination: "/exams", permanent: true },
      { source: "/trust", destination: "/about", permanent: true },
      { source: "/faq", destination: "/product", permanent: true },
      { source: "/begin", destination: "/contact", permanent: true },
      { source: "/institutions", destination: "/contact", permanent: true },
      { source: "/exams/tnpsc-group-4", destination: "/exams", permanent: true },
      { source: "/blog", destination: "/about", permanent: true },
      { source: "/pro", destination: "/pricing", permanent: true },
      { source: "/legal/grievance", destination: "/legal/terms#grievance", permanent: true },
    ];
  },
};

export default nextConfig;
