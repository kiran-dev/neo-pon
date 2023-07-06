import 'arc.dart';

class Titil {
  String ID;
  String name;
  List<String> resources;
  String thumbnailRef;
  List<ArcLayoutConfig>? arcsLayout;

  Titil({
    required this.ID,
    required this.name,
    required this.resources,
    required this.thumbnailRef,
    this.arcsLayout,
  }) : super();

  factory Titil.fromJson(Map<String, dynamic> json, { ID: "" }) {
    List<ArcLayoutConfig> arcsLayout = [];
    if (json['arcLayoutConfig'] != null) {
       List<Map<String, dynamic>> layoutJsons = List<Map<String, dynamic>>.from(json['arcLayoutConfig']);
       print(layoutJsons);
       for (Map<String, dynamic> map in layoutJsons) {
         arcsLayout.add(ArcLayoutConfig.fromJson(map));
       }
    }
    print("-----------");
    print(arcsLayout);
    return Titil(
      ID: ID,
      name: json['name'],
      resources: List<String>.from(json['resources']),
      thumbnailRef: json['thumbnailRef'],
      arcsLayout: arcsLayout
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'resources': resources,
      'thumbnailRef': thumbnailRef,
    };
  }
}
