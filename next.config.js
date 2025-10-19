/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  experimental: {
    optimizeCss: true,
  },
  compiler: {
    removeConsole: process.env.NODE_ENV === 'production',
  },
  webpack: (config, { dev, isServer }) => {
    // Optimize for animations and performance
    if (!dev && !isServer) {
      config.optimization.splitChunks.chunks = 'all';
      config.optimization.splitChunks.cacheGroups = {
        ...config.optimization.splitChunks.cacheGroups,
        animations: {
          name: 'animations',
          test: /[\\/]node_modules[\\/](framer-motion|lottie-react)[\\/]/,
          chunks: 'all',
          priority: 10,
        },
        three: {
          name: 'three',
          test: /[\\/]node_modules[\\/](@react-three|three|maath)[\\/]/,
          chunks: 'all',
          priority: 10,
        },
      };
    }

    // Handle shader files for Three.js
    config.module.rules.push({
      test: /\.(glsl|vs|fs|vert|frag)$/,
      use: ['raw-loader'],
    });

    return config;
  },
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin',
          },
        ],
      },
    ];
  },
}

module.exports = nextConfig