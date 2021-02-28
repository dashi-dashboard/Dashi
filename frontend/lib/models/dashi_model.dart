import 'dart:ui';

class Apps {
  String name;
  final String url;
  final String tag;
  final bool enableAPI;
  final String icon;
  final Color color;
  final List<dynamic> accessRoles;

  Apps(
      {this.url,
      this.tag,
      this.enableAPI,
      this.name,
      this.icon,
      this.color,
      this.accessRoles});

  factory Apps.fromMap(Map<String, dynamic> map) {
    return Apps(
      name: map['Name'],
      enableAPI: map["EnableAPI"],
      tag: map["Tag"],
      url: map["URL"],
      icon: map["Icon"],
      color: Color(int.parse("0xFF" + map["Color"].replaceAll("#", ""))),
      accessRoles: map["AccessRoles"],
    );
  }
}

class Users {
  final String name;
  final String role;
  String password;
  String token;

  Users({this.role, this.name, this.password, this.token});

  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      name: map['Username'],
      role: map['Role'],
      password: map['Password'],
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

class AuthenticateResponse {
  final bool success;
  final String message;
  final String token;

  AuthenticateResponse({
    this.success,
    this.message,
    this.token,
  });

  factory AuthenticateResponse.fromMap(Map<String, dynamic> map) {
    return AuthenticateResponse(
      message: map["Message"],
      success: map["Success"],
      token: map["Token"],
    );
  }
}

class GeneratePasswordResponse {
  final bool success;
  final String message;
  final String hash;

  GeneratePasswordResponse({this.success, this.message, this.hash});

  factory GeneratePasswordResponse.fromMap(Map<String, dynamic> map) {
    return GeneratePasswordResponse(
      message: map["Message"],
      success: map["Success"],
      hash: map["Hash"],
    );
  }
}
