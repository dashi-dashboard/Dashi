import 'dart:ui';

class Apps {
  String name;
  final String url;
  final String tag;
  final bool enableAPI;
  final String icon;
  final Color color;

  Apps({this.url, this.tag, this.enableAPI, this.name, this.icon, this.color});

  factory Apps.fromMap(Map<String, dynamic> map) {
    return Apps(
      name: map['Name'],
      enableAPI: map["EnableAPI"],
      tag: map["Tag"],
      url: map["URL"],
      icon: map["Icon"],
      color: Color(int.parse("0xFF" + map["Color"].replaceAll("#", ""))),
    );
  }
}

class Dashboard {
  final Color color;
  final String backgroundImage;

  Dashboard({this.color, this.backgroundImage});

  factory Dashboard.fromMap(Map<String, dynamic> map) {
    return Dashboard(
      color: Color(int.parse("0xFF" + map["Background"].replaceAll("#", ""))),
      backgroundImage: map["BackgroundImage"],
    );
  }
}
