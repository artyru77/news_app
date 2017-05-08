# setup datepicker

import 'flatpickr/dist/plugins/confirmDate/confirmDate.css'
import 'flatpickr/dist/themes/material_blue.css'
import 'flatpickr/dist/flatpickr.min.css'

import Flatpickr from 'flatpickr/dist/flatpickr.min.js'
import confirmDatePlugin from 'flatpickr/dist/plugins/confirmDate/confirmDate.js'

document.addEventListener 'DOMContentLoaded', ->
  if (window.navigator.userLanguage or window.navigator.language).toLowerCase().indexOf('ru') > 0
    Russian = require('flatpickr/dist/l10n/ru.js').ru
    Flatpickr.localize Russian
    Flatpickr.l10ns.default.firstDayOfWeek = 1
  new Flatpickr(document.querySelector('.txt-expiration-date'),
    enableTime: true
    time_24hr: true
    minDate: 'today'
    defaultHour: 0
    'plugins': [ new confirmDatePlugin(confirmText: '') ])
