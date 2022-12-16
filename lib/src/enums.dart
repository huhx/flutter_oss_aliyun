enum AciMode {
  publicWrite("public-read-write"),
  publicRead("public-read"),
  private("private");

  final String content;

  const AciMode(this.content);
}
