import 'package:equatable/equatable.dart';

class PartInfo extends Equatable {
  final int index;
  final int start;
  final int end;

  const PartInfo({
    required this.index,
    required this.start,
    required this.end,
  });

  @override
  List<Object?> get props => [index, start, end];
}
