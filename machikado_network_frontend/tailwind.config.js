/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        momo: "#f088a8",
        primary: {
          50: "#efe7ea",
          500: "#f088a8",
          600: "#e56c8d",
          900: "#ee4379",
        }
      }
    },
  },
  plugins: [],
}
