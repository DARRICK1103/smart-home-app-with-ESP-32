class UnbordingContent {
  String image;
  String title;
  String discription;

  UnbordingContent(
      {required this.image, required this.title, required this.discription});
}

List<UnbordingContent> contents = [
  UnbordingContent(
      title: 'Efficient Lighting',
      image: 'images/1.jpg',
      discription:
          "Experience efficient lighting with our smart home technology."),
  UnbordingContent(
      title: 'Secure Access',
      image: 'images/2.jpg',
      discription: "Ensure secure access to your home with our smart door."),
  UnbordingContent(
      title: 'Connected Appliances',
      image: 'images/3.jpg',
      discription: "Enjoy a connected home with smart appliances. "),
];
