import 'note.dart';
import 'part.dart';

enum ServiceStatus {
  pending,
  inProgress,
  finished,
  washing,
}

class Service {
  final int? id;
  final int clientId;
  final int vehicleId;
  final int mechanicId;
  final String mechanicName;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<Note> notes;
  final List<Part> parts;
  final List<String> beforeImages;
  final List<String> afterImages;
  final String? audioRecord;
  final double totalCost;
  final double laborCost;
  final double laborHours;
  final ServiceStatus status;

  Service({
    this.id,
    required this.clientId,
    required this.vehicleId,
    required this.mechanicId,
    required this.mechanicName,
    this.startDate,
    this.endDate,
    this.notes = const [],
    this.parts = const [],
    this.beforeImages = const [],
    this.afterImages = const [],
    this.audioRecord,
    this.totalCost = 0.0,
    this.laborCost = 0.0,
    this.laborHours = 0.0,
    this.status = ServiceStatus.pending,
  });


  @override
  String toString() {
    return 'Service{id: $id, clientId: $clientId, vehicleId: $vehicleId, mechanicId: $mechanicId, mechanicName: $mechanicName, startDate: $startDate, endDate: $endDate, notes: $notes, parts: $parts, beforeImages: $beforeImages, afterImages: $afterImages, audioRecord: $audioRecord, totalCost: $totalCost, laborCost: $laborCost, laborHours: $laborHours, status: $status}';
  }

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int?,
      clientId: json['clientId'] as int,
      vehicleId: json['vehicleId'] as int,
      mechanicId: json['mechanic_id'] as int? ?? 0,
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
      laborCost: (json['laborCost'] as num?)?.toDouble() ?? 0.0,
      laborHours: (json['laborHours'] as num?)?.toDouble() ?? 0.0,
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
      'mechanicId': mechanicId,
      'mechanicName': mechanicName,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'notes': notes.map((n) => n.toJson()).toList(),
      'parts': parts.map((p) => p.toJson()).toList(),
      'beforeImages': beforeImages,
      'afterImages': afterImages,
      'audioRecord': audioRecord,
      'totalCost': totalCost,
      'laborCost': laborCost,
      'laborHours': laborHours,
      'status': status.name,
    };
  }

  Service copyWith({
    int? id,
    int? clientId,
    int? vehicleId,
    int? mechanicId,
    String? mechanicName,
    DateTime? startDate,
    DateTime? endDate,
    List<Note>? notes,
    List<Part>? parts,
    List<String>? beforeImages,
    List<String>? afterImages,
    String? audioRecord,
    double? totalCost,
    double? laborCost,
    double? laborHours,
    ServiceStatus? status,
  }) {
    return Service(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      vehicleId: vehicleId ?? this.vehicleId,
      mechanicId: mechanicId ?? this.mechanicId,
      mechanicName: mechanicName ?? this.mechanicName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      parts: parts ?? this.parts,
      beforeImages: beforeImages ?? this.beforeImages,
      afterImages: afterImages ?? this.afterImages,
      audioRecord: audioRecord ?? this.audioRecord,
      totalCost: totalCost ?? this.totalCost,
      laborCost: laborCost ?? this.laborCost,
      laborHours: laborHours ?? this.laborHours,
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
      case ServiceStatus.washing:
        return 'Lavagem/Polimento';
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

  double get serviceTotal {
    return partsTotal + laborCost;
  }

  double calculateTotal() {
    return partsTotal + laborCost;
  }
}
