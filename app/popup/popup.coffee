google?.load 'visualization', '1.0',
  packages: [
    'corechart'
    'table'
  ]

app = window.app = angular.module 'popup', []

app.run ['$rootScope', ($rootScope) ->
  $rootScope.mode = 'day'
]
