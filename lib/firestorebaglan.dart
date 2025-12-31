class UserModel {//null safety hatası almamak icin nullable
  String? uid;
  String? fullname;
  String? email;

  UserModel({this.uid, this.fullname, this.email});

  UserModel.fromJson(Map<String, dynamic> json) {//usermodel nesnesine cevirmek icin
    uid = json['uid'];
    fullname = json['fullname'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {//yazma
    final Map<String, dynamic> data = {};
    data['uid'] = uid;
    data['fullname'] = fullname;
    data['email'] = email;
    return data;
  }
  //mapi her yerde tekrar tekrar kullanmak yerine modele ceviriyoruz (fonksiyon gibi)
}
