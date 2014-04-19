@app.controller "CountiesCtrl", [
  "$scope"
  "$http"
  "$state"
  "$stateParams"
  ($scope, $http, $state, $stateParams) ->
    shapeClick = (area, event) ->
      alert "#{area.properties.NAME} #{area.properties.LSAD} contains #{((parseInt(area.properties.populations.respop72013)/$scope.totalPop)*100).toFixed(2)}% of the population of #{area.properties.STATE_NAME}"
      return

    style = (feature) ->
      fillColor: getColor(feature)
      weight: 2
      opacity: 0.5
      color: "white"
      dashArray: "3"
      fillOpacity: 0.9

    getColor = (f) ->
      try
        pop = f.properties.populations.respop72013
        pct = (parseInt(pop)/$scope.largestPop) * 100
        (if pct > 90 then "#800026"
        else (if pct > 80 then "#8D193C"
        else (if pct > 70 then "#993351"
        else (if pct > 60 then "#A64D67"
        else (if pct > 50 then "#B3667D"
        else (if pct > 40 then "#C08092"
        else (if pct > 30 then "#CC99A8"
        else (if pct > 20 then "#D9B2BE"
        else (if pct > 10 then "#E6CCD4"
        else "#F2E6E9")))))))))
      catch e
        #console.log("error getting colors")
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
      $scope.totalPop = 0
      for f in data.features
        if parseInt(f.properties.populations.respop72013) > $scope.largestPop
          $scope.largestPop = f.properties.populations.respop72013
        $scope.totalPop += parseInt(f.properties.populations.respop72013)

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

      console.log("error loading census")
      angular.extend $scope,
        geojson:
          data: $scope.map_data
          style: style
          resetStyleOnMouseout: true

    return

]
