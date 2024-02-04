class Users {
  final String nickname;
  final String birthday;
  final String gender;
  final String email;
  final String password;
  final String photo_url;
  final String idKey;

  Users({
    required this.nickname,
    required this.birthday,
    required this.gender,
    required this.email,
    required this.password,
    required this.photo_url,
    required this.idKey,
  });

  Users.fromJson(Map<String, Object?> json, String idKey)
      : this(
          nickname: json['Nickname']! as String,
          birthday: json['Birthday']! as String,
          gender: json['Gender']! as String,
          email: json['Email']! as String,
          password: json['Password']! as String,
          photo_url: json['Photo_url'] as String? ?? '',
          idKey: idKey,
        );

  Users copywith({
    String? nickname,
    String? birthday,
    String? gender,
    String? email,
    String? password,
    String? photo_url,
    String? idKey,
  }) {
    return Users(
      nickname: nickname ?? this.nickname,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      password: password ?? this.password,
      photo_url: photo_url ?? this.photo_url,
      idKey: idKey ?? this.idKey,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'Nickname': nickname,
      'Birthday': birthday,
      'Gender': gender,
      'Email': email,
      'Password': password,
      'Photo_url': photo_url,
    };
  }
}
