class IbGif {
  String url;
  String id;
  String description;
  int width;
  int height;
  String next;
  double timeStampInSec;

  IbGif(
      {required this.url,
      required this.width,
      required this.height,
      required this.id,
      required this.next,
      required this.timeStampInSec,
      required this.description});

  @override
  String toString() {
    return 'IbGif{url: $url, description: $description}';
  }
}
