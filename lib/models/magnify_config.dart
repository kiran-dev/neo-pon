class MagnifyConfig {
  double fx;
  double fy;
  double fh;
  double fw;
  int ox;
  int oy;
  double scale;

  MagnifyConfig({
    required this.fx, required this.fy,
    required this.fh, required this.fw,
    required this.ox, required this.oy,
    required this.scale
  });

  MagnifyConfig.original()
      : fx = 0.4, fy = 0.4, fh = 0.2, fw = 0.2, ox = 0, oy = 0, scale = 1.43;

  MagnifyConfig copyWith({ double? newFX, double? newFY, double? newFH, double? newFW, int? newOX, int? newOY, double? newScale }) {
    return MagnifyConfig(
      fx: newFX ?? fx,
      fy: newFY ?? fy,
      fw: newFW ?? fw,
      fh: newFH ?? fh,
      ox: newOX ?? ox,
      oy: newOY ?? oy,
      scale: newScale ?? scale
    );
  }

  factory MagnifyConfig.fromJson(Map<String, dynamic> json,) {

    return MagnifyConfig(
      fx: json['fx'],
      fy: json['fy'],
      fw: json['fw'],
      fh: json['fh'],
      ox: json['ox'],
      oy: json['oy'],
      scale: json['scale'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fx': fx,
      'fy': fy,
      'fw': fw,
      'fh': fh,
      'ox': ox,
      'oy': oy,
      'scale': scale
    };
  }
}