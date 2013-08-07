# Load the Visualization API and the piechart package.
google.load 'visualization', '1.0',
  packages: ['corechart']

app = window.app = angular.module 'popup', []

app.controller 'MainCtrl', ['$scope', ($scope) ->
  $scope.name = 'asdf'
]

app.directive 'pieChart', ->
  (scope, element, attrs) ->
    console.log 'directive'
    data = new google.visualization.DataTable()
    data.addColumn "string", "Topping"
    data.addColumn "number", "Slices"
    data.addRows [["Mushrooms", 3], ["Onions", 1], ["Olives", 1], ["Zucchini", 1], ["Pepperoni", 2]]

    # Set chart options
    options =
      title: "How Much Pizza I Ate Last Night"
      width: 400
      height: 300

    # Instantiate and draw our chart, passing in some options.
    chart = new google.visualization.PieChart(element[0])
    chart.draw data, options
