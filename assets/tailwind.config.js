module.exports = {
  
  theme: {
    extend: {
      colors: {
        'duck-blue': {
          100: '#EDF2FA',
          200: '#D1DEF3',
          300: '#B5CAEC',
          400: '#7EA3DD',
          500: '#467BCF',
          600: '#3F6FBA',
          700: '#2A4A7C',
          800: '#20375D',
          900: '#15253E',
        },
      }
    },
  },
  variants: {},
  plugins: [
    require('@tailwindcss/ui')
  ],
}
