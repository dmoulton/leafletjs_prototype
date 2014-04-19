@app.controller "StatesCtrl", [
  "$scope"
  "$http"
  "$state"
  ($scope, $http, $state,$stateParams) ->
    shapeClick = (area, event) ->
      $state.go('counties',{"stateId": area.properties.name.toLowerCase()})
      return

    # Get a country paint color from the continents array of colors
    getColor = (country) ->
      return "#FFF"  if not country or not country["region-code"]
      colors = continentProperties[country["region-code"]].colors
      index = country["alpha-3"].charCodeAt(0) % colors.length
      colors[index]
    style = (feature) ->
      fillColor: getColor(feature.properties.density)
      weight: 2
      opacity: 0.5
      color: "white"
      dashArray: "3"
      fillOpacity: 0.9

    getColor = (d) ->
      (if d > 1000 then "#800026"
      else (if d > 500 then "#BD0026"
      else (if d > 200 then "#E31A1C"
      else (if d > 100 then "#FC4E2A"
      else (if d > 50 then "#FD8D3C"
      else (if d > 20 then "#FEB24C"
      else (if d > 10 then "#FED976"
      else "#FFEDA0")))))))

    # Mouse over function, called from the Leaflet Map Events
    shapeMouseover = (leafletEvent) ->
      layer = leafletEvent.target
      layer.setStyle
        weight: 2
        color: "#666"
        fillColor: "white"

      layer.bringToFront()
      #console.log(layer.feature.properties.NAME + " county was rolled over")
      return
    $scope.$on "leafletDirectiveMap.geojsonMouseover", (ev, leafletEvent) ->
      shapeMouseover leafletEvent
      return

    $scope.$on "leafletDirectiveMap.geojsonClick", (ev, featureSelected, leafletEvent) ->
      shapeClick featureSelected, leafletEvent
      return

    angular.extend $scope,
      tiles:
        url: "http://{s}.tile.cloudmade.com/{key}/{styleId}/256/{z}/{x}/{y}.png"
        key: 'BC9A493B41014CAABB98F0471D759707'
        options:
          styleId: 22677
          attribution: 'Map data &copy; 2011 OpenStreetMap contributors, Imagery &copy; 2011 CloudMade'


      center:
        lat: 41.7549
        lng: -96.0205
        zoom: 5

      # Get the countries geojson data from a JSON
    $http.get("/us_states.geo.json").success (data, status) ->

      angular.extend $scope,
        geojson:
          data: data
          style: style
          resetStyleOnMouseout: true

    return

]
