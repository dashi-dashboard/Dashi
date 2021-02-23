class Apps {
  String name;
  final String url;
  final String tag;
  final bool enableAPI;
  final String icon;

  Apps({this.url, this.tag, this.enableAPI, this.name, this.icon});

  factory Apps.fromMap(Map<String, dynamic> map) {
    return Apps(
      name: map['Name'],
      enableAPI: map["EnableAPI"],
      tag: map["Tag"],
      url: map["URL"],
      icon: map["Icon"],
    );
  }
}
