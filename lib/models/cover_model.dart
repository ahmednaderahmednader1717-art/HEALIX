class CoverModel {
  final String coverImage;
  final String coverName;

  CoverModel({required this.coverImage, required this.coverName});
  static List<CoverModel> covers = [
    CoverModel(
      coverImage:"assets/covers/IMG_1049.JPG", 
      coverName: "NO PAIN NO GAIN"
      ),
    CoverModel(
      coverImage:"assets/covers/IMG_1050.PNG", 
      coverName: "RISE AND GRIND"
      ),
    CoverModel(
      coverImage:"assets/covers/IMG_1050.PNG", 
      coverName: "GO HARD OR GO HOME"
      ),
  ];
}
