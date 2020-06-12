const { purge } = require('tailwindcss/stubs/defaultConfig.stub');

module.exports = {
  plugins: [
    require('postcss-import'),
    require('tailwindcss'),
    require('autoprefixer'),
    require('@fullhuman/postcss-purgecss')(
      {
        content: [
          "../**/*.html.eex",
          "../**/*.html.leex",
          "../**/*.ex",
          "../**/views/**/*.ex",
          "./js/**/*.js"
        ],
        defaultExtractor: content => content.match(/[\w-/:]+(?<!:)/g) || []
      }
    )
  ]
}
