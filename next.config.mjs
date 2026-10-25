/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: false,
  poweredByHeader: false,
  compress: true,
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "d8j0ntlcm91z4.cloudfront.net",
      },
    ],
  },
  eslint: {
    // ESLint is not configured for this project.
    ignoreDuringBuilds: true,
  },
  async headers() {
    const immutable = [
      { key: "Cache-Control", value: "public, max-age=31536000, immutable" },
    ];
    return [
      { source: "/rive/:path*", headers: immutable },
      { source: "/fonts/:path*", headers: immutable },
      { source: "/images/:path*", headers: immutable },
      { source: "/icons/:path*", headers: immutable },
    ];
  },
  webpack: (config) => {
    config.experiments = { ...config.experiments, asyncWebAssembly: true };
    return config;
  },
};

export default nextConfig;
