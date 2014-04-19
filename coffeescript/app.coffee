@app = angular.module("geojson", ["leaflet-directive","ui.router"]).config ($stateProvider, $urlRouterProvider) ->
  $stateProvider.state("us_states",
    url: "/"

    templateUrl: "templates/states.html"
    controller: "StatesCtrl"
  ).state("counties",
    url: "/counties/:stateId"

    templateUrl: "templates/counties.html"
    controller: "CountiesCtrl"
  )
  # if none of the above states are matched, use this as the fallback
  $urlRouterProvider.otherwise "/"
  return
