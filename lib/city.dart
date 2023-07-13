class City {
  late String name;
  late double lat;
  late double long;
  City({required this.name, required this.lat, required this.long});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(name: json['city'], lat: json['lat'], long: json['lng']);
  }
}
