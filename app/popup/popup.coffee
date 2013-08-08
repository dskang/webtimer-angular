google?.load 'visualization', '1.0',
  packages: [
    'corechart'
    'table'
  ]

app = window.app = angular.module 'popup', []

app.controller 'MainCtrl', ['$scope', ($scope) ->
  $scope.mode = 'day'
]

app.directive 'wtGraph', ->
  templateUrl: 'graph.html'

app.directive 'wtTable', ['DomainData', (DomainData) ->
  (scope, element, attrs) ->
    dataTable = new google.visualization.DataTable()
    dataTable.addColumn 'string', 'Domain'
    dataTable.addColumn 'number', 'Time Spent'
    dataTable.addRows DomainData.getTableData scope.mode

    options =
      allowHtml: true
      sort: 'disable'

    table = new google.visualization.Table element[0]
    table.draw dataTable, options
]

app.directive 'wtChart', ['DomainData', (DomainData) ->
  (scope, element, attrs) ->
    dataTable = new google.visualization.DataTable()
    dataTable.addColumn 'string', 'Domain'
    dataTable.addColumn 'number', 'Time'
    dataTable.addRows DomainData.getChartData scope.mode

    options =
      tooltip:
        text: 'percentage'
      chartArea:
        width: 400
        height: 180

    chart = new google.visualization.PieChart element[0]
    chart.draw dataTable, options
]
