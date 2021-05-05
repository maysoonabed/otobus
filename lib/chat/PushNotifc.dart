class PushNotific {
  PushNotific({
    this.title,
    this.body,
    this.dataTitle,
    this.dataBody,
  });

  String title;
  String body;
  String dataTitle;
  String dataBody;
  factory PushNotific.fromJson(Map<String, dynamic> json) {
    return PushNotific(
      title: json["notification"]["title"],
      body: json["notification"]["body"],
      dataTitle: json["data"]["title"],
      dataBody: json["data"]["body"],
    );
  }
}
