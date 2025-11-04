import 'note.dart';
import 'part.dart';

enum ServiceStatus {
  pending,
  inProgress,
  finished,
}

class Service {
  final int? id;
  final int clientId;
  final int vehicleId;
  final String mechanicName;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<Note> notes;
  final List<Part> parts;
  final List<String> beforeImages;
  final List<String> afterImages;
  final String? audioRecord;
  final double totalCost;
  final ServiceStatus status;

  Service({
    this.id,
    required this.clientId,
    required this.vehicleId,
    required this.mechanicName,
    this.startDate,
    this.endDate,
    this.notes = const [],
    this.parts = const [],
    this.beforeImages = const [],
    this.afterImages = const [],
    this.audioRecord,
    this.totalCost = 0.0,
    this.status = ServiceStatus.pending,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int?,
      clientId: json['clientId'] as int,
      vehicleId: json['vehicleId'] as int,
      mechanicName: json['mechanicName'] as String,
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate'] as String)
          : null,
      notes: json['notes'] != null 
          ? (json['notes'] as List).map((n) => Note.fromJson(n)).toList()
          : [],
      parts: json['parts'] != null 
          ? (json['parts'] as List).map((p) => Part.fromJson(p)).toList()
          : [],
      beforeImages: json['beforeImages'] != null 
          ? List<String>.from(json['beforeImages'])
          : [],
      afterImages: json['afterImages'] != null 
          ? List<String>.from(json['afterImages'])
          : [],
      audioRecord: json['audioRecord'] as String?,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      status: ServiceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ServiceStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'vehicleId': vehicleId,
      'mechanicName': mechanicName,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'notes': notes.map((n) => n.toJson()).toList(),
      'parts': parts.map((p) => p.toJson()).toList(),
      'beforeImages': beforeImages,
      'afterImages': afterImages,
      'audioRecord': audioRecord,
      'totalCost': totalCost,
      'status': status.name,
    };
  }

  Service copyWith({
    int? id,
    int? clientId,
    int? vehicleId,
    String? mechanicName,
    DateTime? startDate,
    DateTime? endDate,
    List<Note>? notes,
    List<Part>? parts,
    List<String>? beforeImages,
    List<String>? afterImages,
    String? audioRecord,
    double? totalCost,
    ServiceStatus? status,
  }) {
    return Service(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      vehicleId: vehicleId ?? this.vehicleId,
      mechanicName: mechanicName ?? this.mechanicName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      parts: parts ?? this.parts,
      beforeImages: beforeImages ?? this.beforeImages,
      afterImages: afterImages ?? this.afterImages,
      audioRecord: audioRecord ?? this.audioRecord,
      totalCost: totalCost ?? this.totalCost,
      status: status ?? this.status,
    );
  }

  String get statusDisplay {
    switch (status) {
      case ServiceStatus.pending:
        return 'Pendente';
      case ServiceStatus.inProgress:
        return 'Em Andamento';
      case ServiceStatus.finished:
        return 'Finalizado';
    }
  }

  String get duration {
    if (startDate == null) return 'Não iniciado';
    final end = endDate ?? DateTime.now();
    final duration = end.difference(startDate!);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    
    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  double get partsTotal {
    return parts.fold(0.0, (sum, part) => sum + part.total);
  }
}
