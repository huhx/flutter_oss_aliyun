enum AclMode {
  publicWrite("public-read-write"),
  publicRead("public-read"),
  private("private"),
  inherited("default");

  final String content;

  const AclMode(this.content);
}
