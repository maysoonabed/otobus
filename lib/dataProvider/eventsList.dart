class EventsList {
  int eventID;
  String dest;
  String driverPhoneNumber;
  String pick;
  String st;
  String passengers;
  String eDate;
  String eTime;

  EventsList(
      {this.eventID,
      this.dest,
      this.driverPhoneNumber,
      this.pick,
      this.st,
      this.passengers,
      this.eDate,
      this.eTime});

  factory EventsList.fromJson(Map<String, dynamic> json) {
    return EventsList(
      eventID: json['id'],
      dest: json['dest'],
      driverPhoneNumber: json['driverphone'],
      pick: json['pick'],
      st: json['status'],
      passengers: json['passengers'],
      eDate: json['eDate'],
      eTime: json['eTime'],
    );
  }
}
