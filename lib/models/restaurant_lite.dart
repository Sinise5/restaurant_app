class Restaurant {
  final String id;
  final String jsonData;
  final String timeAdded;

  Restaurant(
      {required this.id, required this.jsonData, required this.timeAdded});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'json_data': jsonData,
      'time_added': timeAdded,
    };
  }

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'],
      jsonData: map['json_data'],
      timeAdded: map['time_added'],
    );
  }
}
