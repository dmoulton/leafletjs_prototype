// Generated by CoffeeScript 1.6.2
(function() {
  this.app.controller("StatesCtrl", [
    "$scope", "$http", "$state", function($scope, $http, $state, $stateParams) {
      var getColor, shapeClick, shapeMouseover, style;

      shapeClick = function(area, event) {
        $state.go('counties', {
          "stateId": area.properties.name.toLowerCase()
        });
      };
      getColor = function(country) {
        var colors, index;

        if (!country || !country["region-code"]) {
          return "#FFF";
        }
        colors = continentProperties[country["region-code"]].colors;
        index = country["alpha-3"].charCodeAt(0) % colors.length;
        return colors[index];
      };
      style = function(feature) {
        return {
          fillColor: getColor(feature.properties.density),
          weight: 2,
          opacity: 0.5,
          color: "white",
          dashArray: "3",
          fillOpacity: 0.9
        };
      };
      getColor = function(d) {
        if (d > 1000) {
          return "#800026";
        } else {
          if (d > 500) {
            return "#BD0026";
          } else {
            if (d > 200) {
              return "#E31A1C";
            } else {
              if (d > 100) {
                return "#FC4E2A";
              } else {
                if (d > 50) {
                  return "#FD8D3C";
                } else {
                  if (d > 20) {
                    return "#FEB24C";
                  } else {
                    if (d > 10) {
                      return "#FED976";
                    } else {
                      return "#FFEDA0";
                    }
                  }
                }
              }
            }
          }
        }
      };
      shapeMouseover = function(leafletEvent) {
        var layer;

        layer = leafletEvent.target;
        layer.setStyle({
          weight: 2,
          color: "#666",
          fillColor: "white"
        });
        layer.bringToFront();
      };
      $scope.$on("leafletDirectiveMap.geojsonMouseover", function(ev, leafletEvent) {
        shapeMouseover(leafletEvent);
      });
      $scope.$on("leafletDirectiveMap.geojsonClick", function(ev, featureSelected, leafletEvent) {
        shapeClick(featureSelected, leafletEvent);
      });
      angular.extend($scope, {
        tiles: {
          url: "http://{s}.tile.cloudmade.com/{key}/{styleId}/256/{z}/{x}/{y}.png",
          key: 'BC9A493B41014CAABB98F0471D759707',
          options: {
            styleId: 22677,
            attribution: 'Map data &copy; 2011 OpenStreetMap contributors, Imagery &copy; 2011 CloudMade'
          }
        },
        center: {
          lat: 41.7549,
          lng: -96.0205,
          zoom: 5
        }
      });
      $http.get("/us_states.geo.json").success(function(data, status) {
        return angular.extend($scope, {
          geojson: {
            data: data,
            style: style,
            resetStyleOnMouseout: true
          }
        });
      });
    }
  ]);

}).call(this);