class Enroll_person {
  final String name;
  final String gender;
  final String age;
  final String id;

  Enroll_person({
    required this.name,
    required this.gender,
    required this.age,
    required this.id,
  });

  Enroll_person.fromJson(Map<String, Object?> json, String idKey)
      : this(
          name: json['Name']! as String,
          gender: json['Gender']! as String,
          age: json['Age']! as String,
          id: idKey,
        );

  Enroll_person copywith({
    String? name,
    String? gender,
    String? age,
    String? id,
  }) {
    return Enroll_person(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      id: id ?? this.id,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'Name': name,
      'Gender': gender,
      'Age': age,
    };
  }
}
