/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        serif: ['"Instrument Serif"', 'Georgia', 'serif'],
        sans: ['Inter', 'system-ui', '-apple-system', 'BlinkMacSystemFont', 'sans-serif'],
        tamil: ['"Noto Sans Tamil"', 'Inter', 'system-ui', 'sans-serif'],
      },
      colors: {
        background: '#FAF7F2',
        foreground: '#000000',
        muted: '#6F6F6F',
        marigold: '#F59E0B',
        amberGold: '#D97706',
      },
      screens: {
        xs: '420px',
      },
    },
  },
  plugins: [],
}
