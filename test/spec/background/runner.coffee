jasmineEnv = jasmine.getEnv()
jasmineEnv.updateInterval = 250

htmlReporter = new jasmine.HtmlReporter()

jasmineEnv.addReporter(htmlReporter)

jasmineEnv.specFilter = (spec) ->
  htmlReporter.specFilter(spec)

currentWindowOnload = window.onload

window.onload = ->
  if currentWindowOnload
    currentWindowOnload()
  execJasmine()

execJasmine = ->
  jasmineEnv.execute()
