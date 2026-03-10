import 'package:flutter/material.dart';

class MrPatientApiModel {
  final int id;
  final String mrNumber;
  final String firstName;
  final String lastName;
  final String? guardianName;
  final String guardianRelation;
  final String? cnic;
  final String? dob;
  final int? age;
  final String gender;
  final String phone;
  final String? email;
  final String? profession;
  final String? address;
  final String? city;
  final String? bloodGroup;
  final int status;
  final String createdAt;
  final String updatedAt;
  final String? appointmentDate;
  final String patientName;
  final String phoneNumber;
  final String? fatherHusbandName;

  MrPatientApiModel({
    required this.id,
    required this.mrNumber,
    required this.firstName,
    required this.lastName,
    this.guardianName,
    required this.guardianRelation,
    this.cnic,
    this.dob,
    this.age,
    required this.gender,
    required this.phone,
    this.email,
    this.profession,
    this.address,
    this.city,
    this.bloodGroup,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.appointmentDate,
    required this.patientName,
    required this.phoneNumber,
    this.fatherHusbandName,
  });

  factory MrPatientApiModel.fromJson(Map<String, dynamic> json) {
    return MrPatientApiModel(
      id: json['id'] as int,
      mrNumber: (json['mr_number'] as String?) ?? '',
      firstName: (json['first_name'] as String?) ?? '',
      lastName: (json['last_name'] as String?) ?? '',
      guardianName: json['guardian_name'] as String?,
      guardianRelation: (json['guardian_relation'] as String?) ?? 'Parent',
      cnic: json['cnic'] as String?,
      dob: json['dob'] as String?,
      age: json['age'] as int?,
      gender: (json['gender'] as String?) ?? 'Male',
      phone: (json['phone'] as String?) ?? '',
      email: json['email'] as String?,
      profession: json['profession'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      bloodGroup: json['blood_group'] as String?,
      status: (json['status'] as int?) ?? 1,
      createdAt: (json['created_at'] as String?) ?? '',
      updatedAt: (json['updated_at'] as String?) ?? '',
      appointmentDate: json['appointment_date'] as String?,
      patientName: (json['patient_name'] as String?) ?? '',
      phoneNumber: (json['phone_number'] as String?) ?? '',
      fatherHusbandName: json['father_husband_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mr_number': mrNumber,
      'first_name': firstName,
      'last_name': lastName,
      'guardian_name': guardianName,
      'guardian_relation': guardianRelation,
      'cnic': cnic,
      'dob': dob,
      'age': age,
      'gender': gender,
      'phone': phone,
      'email': email,
      'profession': profession,
      'address': address,
      'city': city,
      'blood_group': bloodGroup,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'appointment_date': appointmentDate,
      'patient_name': patientName,
      'phone_number': phoneNumber,
      'father_husband_name': fatherHusbandName,
    };
  }

  // Convert to PatientModel for UI compatibility
  PatientModel toPatientModel() {
    // Parse date of birth if available
    DateTime? parsedDob;
    if (dob != null && dob!.isNotEmpty) {
      try {
        parsedDob = DateTime.parse(dob!);
      } catch (_) {
        // If parsing fails, leave as null
      }
    }

    // Parse registration date
    DateTime registeredAt;
    try {
      registeredAt = DateTime.parse(createdAt);
    } catch (_) {
      registeredAt = DateTime.now();
    }

    return PatientModel(
      mrNumber: mrNumber,
      firstName: firstName,
      lastName: lastName,
      guardianName: guardianName ?? fatherHusbandName ?? '',
      relation: guardianRelation,
      gender: gender,
      dateOfBirth: dob ?? '',
      age: age,
      bloodGroup: bloodGroup ?? '',
      profession: profession ?? '',
      phoneNumber: phone,
      email: email ?? '',
      cnic: cnic ?? '',
      address: address ?? '',
      city: city ?? '',
      registeredAt: registeredAt,
      totalVisits: 0, // Not provided by API
      visitsToday: 0, // Not provided by API
    );
  }
}

// PatientModel class for UI (existing structure)
class PatientModel {
  final String mrNumber;
  final String firstName;
  final String lastName;
  final String guardianName;
  final String relation;
  final String gender;
  final String dateOfBirth;
  final int? age;
  final String bloodGroup;
  final String profession;
  final String phoneNumber;
  final String email;
  final String cnic;
  final String address;
  final String city;
  final DateTime registeredAt;
  int totalVisits;
  int visitsToday;

  PatientModel({
    required this.mrNumber,
    required this.firstName,
    required this.lastName,
    this.guardianName = '',
    this.relation = 'Parent',
    required this.gender,
    this.dateOfBirth = '',
    this.age,
    this.bloodGroup = '',
    this.profession = '',
    this.phoneNumber = '',
    this.email = '',
    this.cnic = '',
    this.address = '',
    this.city = '',
    required this.registeredAt,
    this.totalVisits = 0,
    this.visitsToday = 0,
  });

  String get fullName => '$firstName $lastName'.trim();

  get visitHistory => null;

  // Convert to API request format for create/update
  Map<String, dynamic> toApiRequest() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'guardian_name': guardianName.isEmpty ? null : guardianName,
      'guardian_relation': relation,
      'cnic': cnic.isEmpty ? null : cnic,
      'dob': dateOfBirth.isEmpty ? null : _convertDateToApiFormat(dateOfBirth),
      'age': age,
      'gender': gender,
      'phone': phoneNumber,
      'email': email.isEmpty ? null : email,
      'profession': profession.isEmpty ? null : profession,
      'address': address.isEmpty ? null : address,
      'city': city.isEmpty ? null : city,
      'blood_group': bloodGroup.isEmpty ? null : bloodGroup,
      'status': 1,
    };
  }

  // Helper: convert date from DD/MM/YYYY to YYYY-MM-DD
  String? _convertDateToApiFormat(String date) {
    if (date.isEmpty) return null;
    try {
      final parts = date.split('/');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        return '$year-$month-$day';
      }
    } catch (_) {}
    return null;
  }
}
