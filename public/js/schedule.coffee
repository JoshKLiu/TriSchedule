populateCalendar = ->
  getString = 'getCalendarData'
  $.get getString, callback

callback = (jsonObj) ->
  console.log jsonObj


$(document).ready ->

  populateCalendar()

  $("#calendar").fullCalendar
    weekends: false
    firstDay: 1
    defaultView: "agendaWeek"
    height: 800
    allDaySlot: false
    firstHour: 7
    minTime: 7
    maxTime: 21
    header:
      left: "" #temporary - to be removed
      center: ""
      right: ""

    columnFormat:
      week: "ddd"

  # hack - always goes to this date bc of limited fullcalendar functionality
  # Mon - 5/26/14
  # Tues - 5/27/14
  # Wed - 5/28/14
  # Thurs - 5/29/14
  # Fri - 5/30/14
  $("#calendar").fullCalendar "gotoDate", 2014, 4, 28
  return

