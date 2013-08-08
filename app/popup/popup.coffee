google?.load 'visualization', '1.0',
  packages: [
    'corechart'
    'table'
  ]

app = window.app = angular.module 'popup', []

app.controller 'MainCtrl', ['$scope', ($scope) ->
  $scope.mode = 'day'
]
