{
  "name": "ui",
  "description": "ui for {{.ProjectName}}",
  "main": "postcss.config.js",
  "scripts": {
    "build": "postcss ./input.css -o ./public/static/output.css"
  },
  "devDependencies": {
    "autoprefixer": "^10.4.19",
    "cssnano": "^7.0.1",
    "daisyui": "^4.10.3",
    "postcss-cli": "^11.0.0",
    "tailwindcss": "^3.4.3"
  }
}
