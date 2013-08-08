app.factory 'DomainData', ['$filter', ($filter) ->
  storageArea = chrome.storage.local

  timeString = $filter 'timeString'

  style = "text-align: left;"

  createRows = (store) ->
    rows = []
    for domain, duration of store
      unless domain == 'other'
        rows.push [domain,
          v: duration
          f: timeString duration
          p:
            style: style
        ]
    # Sort rows by descending duration
    rows.sort (a, b) ->
      b[1].v - a[1].v
    rows

  limitRows = (rows, other) ->
    other ?= 0
    limitedRows = []
    for row, i in rows
      if i < 7
        limitedRows.push row
      else
        other += row[1].v
    limitedRows.push ['Other',
      v: other
      f: timeString other
      p:
        style: style
    ]
    limitedRows

  getTotalTime = (store) ->
    total = 0
    for domain, duration of store
      total += duration
    total

  getDataTable: (mode, includeTotal, callback) ->
    key = if mode == 'day' then 'today' else mode
    storageArea.get key, (items) ->
      store = items[key]
      rows = createRows store
      rows = limitRows rows, store.other
      if includeTotal
        totalTime = getTotalTime store
        rows.push [
          v: 'Total'
          p:
            style: 'font-weight: bold;'
        ,
          v: totalTime
          f: timeString totalTime
          p:
            style: "#{style} font-weight: bold;"
        ]

      dataTable = new google.visualization.DataTable()
      dataTable.addColumn 'string', 'Domain'
      dataTable.addColumn 'number', 'Time Spent'
      dataTable.addRows rows

      callback dataTable
]
