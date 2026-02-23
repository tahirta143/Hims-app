import 'package:flutter/material.dart';

// ─────────────────────────────────────
//  MODELS
// ─────────────────────────────────────
class EmergencyPatient {
  final String mrNo;
  final String name;
  final String age;
  final String gender;
  final String phone;
  final String address;
  final DateTime admittedSince;
  final bool inQueue;
  const EmergencyPatient({
    required this.mrNo, required this.name, required this.age,
    required this.gender, required this.phone, required this.address,
    required this.admittedSince, this.inQueue = false,
  });
}

class EmService {
  final String id, name;
  final double price;
  final IconData icon;
  final Color color;
  const EmService({required this.id, required this.name, required this.price, required this.icon, required this.color});
}

class AddedInv {
  final String type, name;
  AddedInv({required this.type, required this.name});
}

class EmMedicine {
  final String name, dose, route;
  const EmMedicine({required this.name, required this.dose, required this.route});
}

// ─────────────────────────────────────
//  PROVIDER
// ─────────────────────────────────────
class EmergencyProvider extends ChangeNotifier {

  // ── 10 mock patients ──
  static final List<EmergencyPatient> _allPatients = [
    EmergencyPatient(mrNo:'000001',name:'Ahmed Hassan',     age:'35',gender:'Male',  phone:'0300-1234567',address:'12-B Model Town, Lahore',             admittedSince:DateTime(2026,2,23,9,15)),
    EmergencyPatient(mrNo:'000002',name:'Fatima Malik',     age:'28',gender:'Female',phone:'0321-9876543',address:'House 5, Block C, Gulberg, Lahore',   admittedSince:DateTime(2026,2,23,10,0)),
    EmergencyPatient(mrNo:'000003',name:'Muhammad Ali Khan',age:'52',gender:'Male',  phone:'0333-5554444',address:'Sector G-10, Street 4, Islamabad',     admittedSince:DateTime(2026,2,23,8,30)),
    EmergencyPatient(mrNo:'000004',name:'Ayesha Siddiqui', age:'41',gender:'Female',phone:'0345-7778888',address:'Flat 3, Pearl Heights, Clifton',       admittedSince:DateTime(2026,2,23,7,45)),
    EmergencyPatient(mrNo:'000005',name:'Usman Tariq',     age:'19',gender:'Male',  phone:'0312-3334455',address:'Village Kot Addu, Muzaffargarh',       admittedSince:DateTime(2026,2,23,11,0)),
    EmergencyPatient(mrNo:'000006',name:'Sara Anwar',      age:'33',gender:'Female',phone:'0311-9998877',address:'G-9/1, Islamabad',                     admittedSince:DateTime(2026,2,23,10,30),inQueue:true),
    EmergencyPatient(mrNo:'000007',name:'Bilal Rauf',      age:'34',gender:'Male',  phone:'0311-2223344',address:'DHA Phase 5, Lahore',                  admittedSince:DateTime(2026,2,23,10,38),inQueue:true),
    EmergencyPatient(mrNo:'000008',name:'Zara Khan',       age:'22',gender:'Female',phone:'0322-1112233',address:'F-7/2, Islamabad',                     admittedSince:DateTime(2026,2,23,10,51),inQueue:true),
    EmergencyPatient(mrNo:'000009',name:'Saima Noor',      age:'27',gender:'Female',phone:'0322-5556677',address:'Gulberg III, Lahore',                  admittedSince:DateTime(2026,2,23,10,55),inQueue:true),
    EmergencyPatient(mrNo:'000010',name:'Hamza Malik',     age:'45',gender:'Male',  phone:'0300-4445566',address:'Bahria Town, Rawalpindi',               admittedSince:DateTime(2026,2,23,11,2)),
  ];

  /// Type "1" → "000001", "7" → "000007", "12" → "000012"
  static String formatMr(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    return int.parse(digits).toString().padLeft(6, '0');
  }

  EmergencyPatient? lookupPatient(String raw) {
    final formatted = formatMr(raw);
    if (formatted.isEmpty) return null;
    try { return _allPatients.firstWhere((p) => p.mrNo == formatted); } catch (_) { return null; }
  }

  // ── Queue ──
  List<EmergencyPatient> get queue => _allPatients.where((p) => p.inQueue).toList();
  int get queueCount => queue.length;
  void refresh() => notifyListeners();

  // ── Emergency Services ──
  final List<EmService> emergencyServices = const [
    EmService(id:'drip',     name:'Drip',      price:2000, icon:Icons.water_drop_rounded,           color:Color(0xFF1E88E5)),
    EmService(id:'foodpipe', name:'Food Pipe', price:3500, icon:Icons.settings_input_svideo_rounded, color:Color(0xFF8E24AA)),
    EmService(id:'injection',name:'Injection', price:1000, icon:Icons.vaccines_rounded,              color:Color(0xFF00B5AD)),
    EmService(id:'oxygen',   name:'Oxygen',    price:1500, icon:Icons.air_rounded,                   color:Color(0xFF43A047)),
    EmService(id:'ecg',      name:'ECG',       price:600,  icon:Icons.monitor_heart_rounded,         color:Color(0xFFE67E22)),
    EmService(id:'nebulizer',name:'Nebulizer', price:800,  icon:Icons.masks_rounded,                 color:Color(0xFFF4511E)),
    EmService(id:'dressing', name:'Dressing',  price:500,  icon:Icons.medical_services_rounded,      color:Color(0xFFE53935)),
    EmService(id:'catheter', name:'Catheter',  price:1200, icon:Icons.device_hub_rounded,            color:Color(0xFF039BE5)),
  ];

  final List<EmService> _selectedServices = [];
  List<EmService> get selectedServices => List.unmodifiable(_selectedServices);
  double get servicesTotalPrice => _selectedServices.fold(0.0, (s, e) => s + e.price);
  void toggleService(EmService svc) {
    final i = _selectedServices.indexWhere((s) => s.id == svc.id);
    if (i >= 0) _selectedServices.removeAt(i); else _selectedServices.add(svc);
    notifyListeners();
  }
  bool isServiceSelected(String id) => _selectedServices.any((s) => s.id == id);

  // ── Investigations ──
  final Map<String, List<String>> investigations = const {
    'Lab': ['CBC (Complete Blood Count)','LFTs','RFTs','Blood Sugar (Fasting)','HbA1c','Urine D/R','Blood Culture','ESR','CRP','Troponin','PT/APTT','Serum Electrolytes','Serum Creatinine','Thyroid Profile'],
    'Ultra Sound': ['Abdominal Ultrasound','Pelvic Ultrasound','Thyroid Ultrasound','Doppler Study','ECHO','Renal Ultrasound','Scrotal Ultrasound'],
    'X-Rays': ['Ankle Joint Lat+','Ankle Joint AP +','Barium Followthrough Study','Barium Meal Study','Barium Swallow Study','Cervicle Spine Ap','Cervicle Spine Lat','Chest PA','Chest AP','KUB','Skull AP/Lat','Pelvis AP','Wrist Joint AP/Lat','Knee Joint AP/Lat'],
  };

  final List<AddedInv> _addedInvestigations = [];
  List<AddedInv> get addedInvestigations => List.unmodifiable(_addedInvestigations);
  void addInvestigation(String type, String name) {
    if (!_addedInvestigations.any((i) => i.name == name)) { _addedInvestigations.add(AddedInv(type:type,name:name)); notifyListeners(); }
  }
  void removeInvestigation(String name) { _addedInvestigations.removeWhere((i) => i.name == name); notifyListeners(); }

  // ── Medicines ──
  final List<EmMedicine> medicinesList = const [
    EmMedicine(name:'Paracetamol 500mg',   dose:'1 tab TDS',route:'Oral'),
    EmMedicine(name:'Amoxicillin 500mg',   dose:'1 tab BD', route:'Oral'),
    EmMedicine(name:'Metronidazole 400mg', dose:'1 tab TDS',route:'Oral'),
    EmMedicine(name:'Omeprazole 20mg',     dose:'1 cap BD', route:'Oral'),
    EmMedicine(name:'Diclofenac 75mg/3ml', dose:'1 amp',    route:'IM'),
    EmMedicine(name:'Ranitidine 50mg',     dose:'1 amp BD', route:'IV'),
    EmMedicine(name:'Dextrose 5% 500ml',   dose:'1 bag',    route:'IV Drip'),
    EmMedicine(name:'Normal Saline 0.9%',  dose:'1 bag',    route:'IV Drip'),
    EmMedicine(name:'Buscopan 20mg',       dose:'1 amp',    route:'IM'),
    EmMedicine(name:'Ondansetron 4mg',     dose:'1 amp TDS',route:'IV'),
    EmMedicine(name:'Hydrocortisone 100mg',dose:'1 vial',   route:'IV'),
    EmMedicine(name:'Ceftriaxone 1g',      dose:'1 vial BD',route:'IV'),
  ];
  final List<EmMedicine> _prescribedMedicines = [];
  List<EmMedicine> get prescribedMedicines => List.unmodifiable(_prescribedMedicines);
  void toggleMedicine(EmMedicine med) {
    final i = _prescribedMedicines.indexWhere((m) => m.name == med.name);
    if (i >= 0) _prescribedMedicines.removeAt(i); else _prescribedMedicines.add(med);
    notifyListeners();
  }
  bool isMedicinePrescribed(String name) => _prescribedMedicines.any((m) => m.name == name);

  // ── Save ──
  final List<Map<String, dynamic>> savedRecords = [];
  void saveRecord({required String mrNo,required String name,required String age,required String gender,required String phone,required String address,required String mo,required String bed,required String complaint,required String moNotes,required String dischargeOpt,required List<EmService> services,required List<AddedInv> investigations,required List<EmMedicine> medicines}) {
    savedRecords.add({'mrNo':mrNo,'name':name,'age':age,'gender':gender,'phone':phone,'address':address,'mo':mo,'bed':bed,'complaint':complaint,'moNotes':moNotes,'dischargeOption':dischargeOpt,'services':services,'investigations':investigations,'medicines':medicines,'date':DateTime.now()});
    notifyListeners();
  }

  void clearAll() {
    _selectedServices.clear();
    _addedInvestigations.clear();
    _prescribedMedicines.clear();
    notifyListeners();
  }
}