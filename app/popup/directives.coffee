app.directive 'wtGraph', ->
  templateUrl: 'graph.html'

app.directive 'wtTable', ['DomainData', (DomainData) ->
  (scope, element, attrs) ->
    DomainData.getDataTable scope.mode, (dataTable) ->
      options =
        allowHtml: true
        sort: 'disable'

      table = new google.visualization.Table element[0]
      table.draw dataTable, options
]

app.directive 'wtChart', ['DomainData', (DomainData) ->
  (scope, element, attrs) ->
    DomainData.getDataTable scope.mode, (dataTable) ->
      options =
        tooltip:
          text: 'percentage'
        chartArea:
          width: 400
          height: 180

      chart = new google.visualization.PieChart element[0]
      chart.draw dataTable, options
]
