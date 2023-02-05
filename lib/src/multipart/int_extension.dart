extension IntExtension on int {

  int chunk(int chunkSize) {
    return (this / chunkSize).ceil();
  }
}