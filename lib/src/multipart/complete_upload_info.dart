class CompleteMultipartUpload {
  final List<PartTag> parts;

  const CompleteMultipartUpload(this.parts);

  String toXml() {
    final String partString = parts.map((part) => part.toXml()).join("");
    return """<CompleteMultipartUpload>$partString</CompleteMultipartUpload>""";
  }
}

class PartTag {
  final int index;
  final String eTag;

  const PartTag({required this.index, required this.eTag});

  String toXml() {
    return """<Part><PartNumber>$index</PartNumber><ETag>"$eTag"</ETag></Part>""";
  }
}
