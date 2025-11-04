class Note {
  final DateTime dateTime;
  final String observation;

  Note({
    required this.dateTime,
    required this.observation,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      dateTime: DateTime.parse(json['dateTime'] as String),
      observation: json['observation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'observation': observation,
    };
  }

  Note copyWith({
    DateTime? dateTime,
    String? observation,
  }) {
    return Note(
      dateTime: dateTime ?? this.dateTime,
      observation: observation ?? this.observation,
    );
  }
}
