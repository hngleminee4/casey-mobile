class UserModel {
  String? uid;
  String? fullname;
  String? email;

  UserModel({this.uid, this.fullname, this.email});

  UserModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    fullname = json['fullname'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['uid'] = uid;
    data['fullname'] = fullname;
    data['email'] = email;
    return data;
  }
}
