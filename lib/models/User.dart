class AuthData {
  late String accessToken;
  late String refreshToken;
  late User user;

  AuthData(this.accessToken, this.refreshToken, this.user);

  AuthData.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    user = new User.fromJson(json['user']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['accessToken'] = this.accessToken;
    data['refreshToken'] = this.refreshToken;
    data['user'] = this.user.toJson();
    return data;
  }
}

class User {
  late String email;
  late String id;
  late String name;

  User(this.email, this.id, this.name);

  User.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    name = json['name'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    data['id'] = this.id;
    data['name'] = this.name;
    // data['id'] = this.id;

    return data;
  }
}
