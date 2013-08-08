app.factory 'DomainData', ->
  storageArea = chrome.storage.local
  timeString = $filter 'timeString'
  getData = (mode) ->
    data = []
    storageArea.get mode, (items) ->
      store = items[mode]
      for domain, duration of store
        data.push [domain,
          v: duration
          f: timeString duration
          p:
            style: "text-align: left; white-space; normal;"
        ]

  getTableData: (mode) ->

  getChartData: (mode) ->

