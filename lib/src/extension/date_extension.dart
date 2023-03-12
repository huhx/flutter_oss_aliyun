extension DateExtension on DateTime {
  /// get GMT format String
  String toGMTString() {
    const List weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const List month = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];

    final DateTime d = toUtc();
    final StringBuffer sb = StringBuffer()
      ..write(weekdays[d.weekday - 1])
      ..write(", ")
      ..write(d.day <= 9 ? "0" : "")
      ..write(d.day.toString())
      ..write(" ")
      ..write(month[d.month - 1])
      ..write(" ")
      ..write(d.year.toString())
      ..write(d.hour <= 9 ? " 0" : " ")
      ..write(d.hour.toString())
      ..write(d.minute <= 9 ? ":0" : ":")
      ..write(d.minute.toString())
      ..write(d.second <= 9 ? ":0" : ":")
      ..write(d.second.toString())
      ..write(" GMT");
    return sb.toString();
  }

  int secondsSinceEpoch() {
    return (millisecondsSinceEpoch / 1000).floor();
  }
}
