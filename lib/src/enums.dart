enum AclMode {
  publicWrite("public-read-write"),
  publicRead("public-read"),
  private("private"),
  inherited("default");

  final String content;

  const AclMode(this.content);
}

enum StorageType {
  standard("Standard", "标准存储"),
  ia("IA", "低频访问"),
  archive("Archive", "归档存储"),
  coldArchive("ColdArchive", "冷归档存储");

  final String content;
  final String description;

  const StorageType(this.content, this.description);
}
