class Spacecraft {
  final String passid, driverid;
  final String taq, comment, report;

  Spacecraft({
    this.passid,
    this.driverid,
    this.taq,
    this.comment,
    this.report,
  });

  factory Spacecraft.fromJson(Map<String, dynamic> jsonData) {
    return Spacecraft(
      passid: jsonData['passid'],
      driverid: jsonData['driverid'],
      taq: jsonData['taq'],
      comment: jsonData['comment'],
      report: jsonData['report'],
    );
  }
}
       