/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./**/*.templ"],
  darkMode: "media", //  or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {
      backgroundColor: ["active"],
    },
  },
  plugins: [require("daisyui")],
  daisyui: {
    themes: ["nord"],
  },
};
