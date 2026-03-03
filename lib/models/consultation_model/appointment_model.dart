import 'package:flutter/material.dart';

class AppointmentModel {
  final int id;
  final String appointmentId;
  final String mrNumber;
  final String patientName;
  final String patientContact;
  final String? patientAddress;
  final int doctorSrlNo;
  final String appointmentDate;
  final String slotTime;
  final int isFirstVisit;
  final String fee;
  final String followUpCharges;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String doctorName;
  final String doctorSpecialization;
  final String consultationTimeFrom;
  final String consultationTimeTo;

  AppointmentModel({
    required this.id,
    required this.appointmentId,
    required this.mrNumber,
    required this.patientName,
    required this.patientContact,
    this.patientAddress,
    required this.doctorSrlNo,
    required this.appointmentDate,
    required this.slotTime,
    required this.isFirstVisit,
    required this.fee,
    required this.followUpCharges,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.consultationTimeFrom,
    required this.consultationTimeTo,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id'] ?? 0}') ?? 0,
      appointmentId: json['appointment_id'] as String? ?? '',
      mrNumber: json['mr_number'] as String? ?? '',
      patientName: json['patient_name'] as String? ?? '',
      patientContact: json['patient_contact'] as String? ?? '',
      patientAddress: json['patient_address'] as String?,
      doctorSrlNo: json['doctor_srl_no'] is int
          ? json['doctor_srl_no'] as int
          : int.tryParse('${json['doctor_srl_no'] ?? 0}') ?? 0,
      appointmentDate: json['appointment_date'] as String? ?? '',
      slotTime: json['slot_time'] as String? ?? '',
      isFirstVisit: json['is_first_visit'] is int
          ? json['is_first_visit'] as int
          : int.tryParse('${json['is_first_visit'] ?? 0}') ?? 0,
      fee: json['fee']?.toString() ?? '0',
      followUpCharges: json['follow_up_charges']?.toString() ?? '0',
      status: json['status'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      doctorName: json['doctor_name'] as String? ?? '',
      doctorSpecialization: json['doctor_specialization'] as String? ?? '',
      consultationTimeFrom: json['consultation_time_from'] as String? ?? '',
      consultationTimeTo: json['consultation_time_to'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appointment_id': appointmentId,
      'mr_number': mrNumber,
      'patient_name': patientName,
      'patient_contact': patientContact,
      'patient_address': patientAddress,
      'doctor_srl_no': doctorSrlNo,
      'appointment_date': appointmentDate,
      'slot_time': slotTime,
      'is_first_visit': isFirstVisit,
      'fee': fee,
      'follow_up_charges': followUpCharges,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'doctor_name': doctorName,
      'doctor_specialization': doctorSpecialization,
      'consultation_time_from': consultationTimeFrom,
      'consultation_time_to': consultationTimeTo,
    };
  }

  // Convert to ConsultationAppointment for UI compatibility
  ConsultationAppointment toConsultationAppointment(String hospitalName) {
    // Parse date
    final date = DateTime.parse(appointmentDate);

    // Parse time slot (HH:MM:SS to HH:MM AM/PM)
    final timeSlot = _formatTimeSlot(slotTime);

    // Generate timings from consultation times
    final timings = _formatTimings(consultationTimeFrom, consultationTimeTo);

    // Determine status
    final uiStatus = _mapStatus(status);

    return ConsultationAppointment(
      id: id.toString(),
      consultantName: 'Dr. $doctorName',
      specialty: doctorSpecialization,
      consultationFee: fee,
      followUpCharges: followUpCharges,
      availableDays: [], // Not provided in appointment response
      timings: timings,
      hospital: hospitalName,
      mrNo: mrNumber,
      patientName: patientName,
      contactNo: patientContact,
      address: patientAddress ?? '',
      isFirstVisit: isFirstVisit == 1,
      appointmentDate: date,
      timeSlot: timeSlot,
      type: 'In-Person', // Default, can be extended
      status: uiStatus,
    );
  }

  // Helper: format time slot from 24h to 12h format
  String _formatTimeSlot(String time24) {
    try {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      final period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;

      return '$hour:${minute.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return time24;
    }
  }

  // Helper: format timings range
  String _formatTimings(String from, String to) {
    return '${_formatTimeSlot(from)} - ${_formatTimeSlot(to)}';
  }

  // Helper: map API status to UI status
  String _mapStatus(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'booked':
        return 'Upcoming';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Upcoming';
    }
  }
}

// ConsultationAppointment class for UI (existing structure)
class ConsultationAppointment {
  final String id;
  final String consultantName;
  final String specialty;
  final String consultationFee;
  final String followUpCharges;
  final List<String> availableDays;
  final String timings;
  final String hospital;
  final String mrNo;
  final String patientName;
  final String contactNo;
  final String address;
  final bool isFirstVisit;
  final DateTime appointmentDate;
  final String timeSlot;
  final String type;
  final String status;

  ConsultationAppointment({
    required this.id,
    required this.consultantName,
    required this.specialty,
    required this.consultationFee,
    required this.followUpCharges,
    required this.availableDays,
    required this.timings,
    required this.hospital,
    required this.mrNo,
    required this.patientName,
    required this.contactNo,
    required this.address,
    required this.isFirstVisit,
    required this.appointmentDate,
    required this.timeSlot,
    required this.type,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'doctor': consultantName,
        'specialty': specialty,
        'date': _formatDate(appointmentDate),
        'time': timeSlot,
        'type': type,
        'status': status,
        'mrNo': mrNo,
        'patientName': patientName,
        'icon': type == 'Video Call'
            ? Icons.videocam_rounded
            : Icons.local_hospital_rounded,
      };

  static String _formatDate(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  // Convert to API request format
  Map<String, dynamic> toApiRequest(int doctorSrlNo) {
    // Format date as YYYY-MM-DD
    final dateStr =
        '${appointmentDate.year}-${appointmentDate.month.toString().padLeft(2, '0')}-${appointmentDate.day.toString().padLeft(2, '0')}';

    // Convert time slot to 24h format (HH:MM:SS)
    final timeStr = _convertTo24Hour(timeSlot);

    return {
      'mr_number': mrNo,
      'patient_name': patientName,
      'patient_contact': contactNo,
      'patient_address': address.isEmpty ? null : address,
      'doctor_srl_no': doctorSrlNo,
      'appointment_date': dateStr,
      'slot_time': timeStr,
      'is_first_visit': isFirstVisit ? 1 : 0,
      'fee': consultationFee,
      'follow_up_charges': followUpCharges,
      'status': 'booked',
    };
  }

  // Helper: convert 12h time to 24h format
  String _convertTo24Hour(String time12) {
    try {
      final isPM = time12.contains('PM');
      final isAM = time12.contains('AM');
      final cleaned = time12.replaceAll('AM', '').replaceAll('PM', '').trim();
      final parts = cleaned.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      if (isPM && hour != 12) hour += 12;
      if (isAM && hour == 12) hour = 0;

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
    } catch (_) {
      return '00:00:00';
    }
  }
}
