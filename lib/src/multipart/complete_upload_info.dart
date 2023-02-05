import 'part_info.dart';

class CompleteMultipartUpload {
  final List<PartTag> parts;

  const CompleteMultipartUpload(this.parts);

  factory CompleteMultipartUpload.from(List<Part> parts) {
    final List<PartTag> partList = parts
        .where((item) => item.tag != null)
        .map((e) => PartTag.from(e))
        .toList();
    return CompleteMultipartUpload(partList);
  }

  String toXml() {
    final String partString = parts.map((part) => part.toXml()).join("");
    return """<CompleteMultipartUpload>$partString</CompleteMultipartUpload>""";
  }
}

class PartTag {
  final int index;
  final String eTag;

  const PartTag({required this.index, required this.eTag});

  factory PartTag.from(Part part) {
    return PartTag(index: part.index, eTag: part.tag!);
  }

  String toXml() {
    return """<Part><PartNumber>$index</PartNumber><ETag>$eTag</ETag></Part>""";
  }
}
