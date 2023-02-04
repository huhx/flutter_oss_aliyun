class CompleteMultipartUpload {
  final List<Part> parts;

  const CompleteMultipartUpload(this.parts);

  String toXml() {
    final String partString = parts.map((part) => part.toXml()).join("");
    return """<CompleteMultipartUpload>$partString</CompleteMultipartUpload>""";
  }
}

class Part {
  final int index;
  final String eTag;

  const Part({required this.index, required this.eTag});

  String toXml() {
    return """<Part><PartNumber>$index</PartNumber><ETag>"$eTag"</ETag></Part>""";
  }
}
