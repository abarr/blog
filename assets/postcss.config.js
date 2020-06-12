const { purge } = require('tailwindcss/stubs/defaultConfig.stub');
const purgecss = require('@fullhuman/postcss-purgecss')(
  {
    content: [
      "../**/*.html.eex",
      "../**/*.html.leex",
      "../**/views/**/*.ex",
      "../**/live/**/*.ex",
      "./js/**/*.js"
    ],
    defaultExtractor: content => content.match(/[\w-/:]+(?<!:)/g) || []
  }
)

module.exports = {
  plugins: [
    require('postcss-import'),
    require('tailwindcss'),
    require('autoprefixer'),
    ...(process.env.NODE_ENV === "production" ? [purgecss] : [])    
  ]
}
