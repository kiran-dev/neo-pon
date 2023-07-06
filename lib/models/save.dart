
import 'moment.dart';
import 'snap.dart';

class Save {
  String titleID;
  String userID;
  String ref;
  int createdAt;

  Save(this.titleID, this.userID, this.ref, this.createdAt,);

  factory Save.fromJson(Map<String, dynamic> json) {
    try {
      return Moment.fromJson(json);
    } catch (e) {
      return Snap.fromJson(json);
    }
  }

  Map<String, dynamic> toJson() {
    if (this is Moment) {
      return (this as Moment).toJson();
    } else if (this is Snap) {
      return (this as Snap).toJson();
    } else {
      return {};
    }
  }

}
