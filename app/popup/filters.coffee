app.filter 'timeString', ->
  (seconds) ->
    timeString = ""
    timeUnits =
      hour: 3600
      minute: 60

    hours = Math.floor(seconds / timeUnits.hour)
    seconds %= timeUnits.hour
    minutes = Math.floor(seconds / timeUnits.minute)
    seconds %= timeUnits.minute

    hourText = if hours > 1 then 'hours' else 'hour'
    minuteText = if minutes > 1 then 'minutes' else 'minute'
    secondText = if seconds > 1 then 'seconds' else 'second'

    if hours > 0
      if minutes > 0
        "#{hours} #{hourText} and #{minutes} #{minuteText}"
      else
        "#{hours} #{hourText}"
    else
      if minutes > 0
        if seconds > 0
          "#{minutes} #{minuteText} and #{seconds} #{secondText}"
        else
          "#{minutes} #{minuteText}"
      else
        "#{seconds} #{secondText}"
