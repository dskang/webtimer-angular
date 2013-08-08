app.directive 'wtTable', ['DomainData', (DomainData) ->
  (scope, element, attrs) ->
    scope.$watch 'mode', (mode) ->
      DomainData.getDataTable mode, true, (dataTable) ->
        options =
          allowHtml: true
          sort: 'disable'

        table = new google.visualization.Table element[0]
        table.draw dataTable, options
]

app.directive 'wtChart', ['DomainData', (DomainData) ->
  (scope, element, attrs) ->
    scope.$watch 'mode', (mode) ->
      DomainData.getDataTable mode, false, (dataTable) ->
        options =
          tooltip:
            text: 'percentage'
          chartArea:
            width: 400
            height: 180

        chart = new google.visualization.PieChart element[0]
        chart.draw dataTable, options
]
