
class Profile {
  String ID;
  String name;
  String userID;
  String? tag;
  bool isKirani;

  Profile({
    required this.ID,
    required this.name,
    required this.userID,
    required this.tag,
    this.isKirani = false,
  });

  factory Profile.fromJson(Map<String, dynamic> json, { ID: "" }) {
    return Profile(
        ID: ID,
        name: json['name'],
        userID: json['userID'],
        tag: json['tag']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'resources': userID,
      'tag': tag
    };
  }
}
