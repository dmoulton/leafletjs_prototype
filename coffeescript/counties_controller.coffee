@app.controller "CountiesCtrl", [
  "$scope"
  "$http"
  "$state"
  "$stateParams"
  ($scope, $http, $state, $stateParams) ->
    shapeClick = (area, event) ->
      alert "Nothing to see here"
      return

    # Get a country paint color from the continents array of colors

    style = (feature) ->
      fillColor: getColor(feature)
      weight: 2
      opacity: 0.5
      color: "white"
      dashArray: "3"
      fillOpacity: 0.9

    getColor = (f) ->
      try
        pop = $scope.popData[f.properties.GEO_ID].pop2013
        pct = (parseInt(pop)/$scope.largestPop) * 100
        (if pct > 90 then "#800026"
        else (if pct > 80 then "#BD0026"
        else (if pct > 60 then "#E31A1C"
        else (if pct > 40 then "#FC4E2A"
        else (if pct > 20 then "#FD8D3C"
        else (if pct > 20 then "#FEB24C"
        else (if pct > 10 then "#FED976"
        else "#FFEDA0")))))))
      catch e
        console.log("error getting colors")
        "grey"

    # Mouse over function, called from the Leaflet Map Events
    shapeMouseover = (leafletEvent) ->
      layer = leafletEvent.target
      layer.setStyle
        weight: 2
        color: "#666"
        fillColor: "white"

      layer.bringToFront()

      return
    $scope.$on "leafletDirectiveMap.geojsonMouseover", (ev, leafletEvent) ->
      shapeMouseover leafletEvent
      return

    $scope.$on "leafletDirectiveMap.geojsonClick", (ev, featureSelected, leafletEvent) ->
      shapeClick featureSelected, leafletEvent
      return

    angular.extend $scope,
      center:
        zoom: 2

    $http.get("/data/states/"+$stateParams.stateId.replace(/\s/g, "_")+".counties.geo.json").success (data, status) ->
      $scope.map_data = data
      $scope.bounds.northEast.lat = -90
      $scope.bounds.northEast.lng = -181
      $scope.bounds.southWest.lat = 90
      $scope.bounds.southWest.lng = 180
      $scope.largestPop = 0
      for f in data.features
        for c in f.geometry.coordinates
          for x in c
            if x[0] > $scope.bounds.northEast.lng
              $scope.bounds.northEast.lng= x[0]
            if x[1] > $scope.bounds.northEast.lat
              $scope.bounds.northEast.lat = x[1]
            if x[0] < $scope.bounds.southWest.lng
              $scope.bounds.southWest.lng = x[0]
            if x[1] < $scope.bounds.southWest.lat
              $scope.bounds.southWest.lat = x[1]

      $scope.popData = {}
      $http.get("/census/"+$stateParams.stateId+"_census.json").success (data, status) ->
        for county in data
          $scope.popData[county['GEO.id']]={}
          $scope.popData[county['GEO.id']]["pop2010"] = county.respop72010
          $scope.popData[county['GEO.id']]["pop2011"] = county.respop72011
          $scope.popData[county['GEO.id']]["pop2012"] = county.respop72012
          $scope.popData[county['GEO.id']]["pop2013"] = county.respop72013
          if parseInt(county.respop72013) > $scope.largestPop
            $scope.largestPop = county.respop72013

        angular.extend $scope,
          geojson:
            data: $scope.map_data
            style: style
            resetStyleOnMouseout: true
      .error (data,status) ->
        console.log("error loading census")
        angular.extend $scope,
          geojson:
            data: $scope.map_data
            style: style
            resetStyleOnMouseout: true

    return

]
