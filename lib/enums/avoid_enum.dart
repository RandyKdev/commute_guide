enum AvoidEnum {
  tolls,
  ferries,
  highways,
  unpavedRoads;

  String getMapBoxString() {
    switch (this) {
      case tolls:
        return 'toll';
      case ferries:
        return 'ferry';
      case highways:
        return 'motorway';
      case unpavedRoads:
        return 'unpaved';
    }
  }

  String getGoogleJson() {
    switch (this) {
      case tolls:
        return 'tolls';
      case ferries:
        return 'ferries';
      case highways:
        return 'highways';
      case unpavedRoads:
        return 'indoor';
    }
  }
}
