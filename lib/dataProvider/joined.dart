class Joint {
  String id;
  String passengers;
  String passname;
  String passphone;

  Joint(
      {this.id,
      this.passengers,
      this.passname,
      this.passphone,
     });

  factory Joint.fromJson(Map<String, dynamic> json) {
    return Joint(
      id: json['id'],
      passengers: json['passengers'],
      passname: json['passname'],
      passphone: json['passphone'],
      
    );
  }
}
 