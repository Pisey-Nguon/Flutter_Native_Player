class QualityModel {
  final int width;
  final int height;
  final int bitrate;
  final String urlQuality;
  final String urlMovie;
  final String titleMovie;
  final int trackIndex;
  bool isSelected;

  QualityModel(
      {required this.width,
      required this.height,
      required this.bitrate,
      required this.urlQuality,
      required this.urlMovie,
      required this.titleMovie,
      required this.trackIndex,
      required this.isSelected});
}
