// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../custum widgets/drawer/base_scaffold.dart';
// import '../../models/mr_model/mr_patient_model.dart';
// import '../../providers/mr_provider/mr_provider.dart';
//
// // ─────────────────────────────────────────────────────────────────────────────
// // THEME CONSTANTS
// // ─────────────────────────────────────────────────────────────────────────────
// const _teal = Color(0xFF00B5AD);
// const _tealLight = Color(0xFFE6F7F6);
// const _tealDark = Color(0xFF007A75);
// const _bg = Color(0xFFF4F7FA);
// const _card = Colors.white;
// const _textDark = Color(0xFF1A202C);
// const _textMid = Color(0xFF4A5568);
// const _textLight = Color(0xFF718096);
// const _border = Color(0xFFE2E8F0);
// const _red = Color(0xFFE53E3E);
// const _green = Color(0xFF38A169);
//
// // ─────────────────────────────────────────────────────────────────────────────
// // SCREEN
// // ─────────────────────────────────────────────────────────────────────────────
// class MrDetailsScreen extends StatelessWidget {
//   const MrDetailsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BaseScaffold(
//       title: 'MR Details',
//       drawerIndex: 8,
//       actions: [
//         Builder(
//           builder: (ctx) => GestureDetector(
//             onTap: () =>
//                 ctx.findAncestorStateOfType<_MrDetailsBodyState>()
//                     ?._clearForm(),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.white.withOpacity(0.4)),
//               ),
//               child: const Row(mainAxisSize: MainAxisSize.min, children: [
//                 Icon(Icons.add, color: Colors.white, size: 15),
//                 SizedBox(width: 4),
//                 Text('New Patient',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 12)),
//               ]),
//             ),
//           ),
//         ),
//       ],
//       body: const _MrDetailsBody(),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // BODY STATE
// // ─────────────────────────────────────────────────────────────────────────────
// class _MrDetailsBody extends StatefulWidget {
//   const _MrDetailsBody();
//   @override
//   State<_MrDetailsBody> createState() => _MrDetailsBodyState();
// }
//
// class _MrDetailsBodyState extends State<_MrDetailsBody>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _mrFocusNode = FocusNode();
//   late TabController _tabController;
//
//   // Controllers
//   final _mrCtrl = TextEditingController();
//   final _firstCtrl = TextEditingController();
//   final _lastCtrl = TextEditingController();
//   final _guardianCtrl = TextEditingController();
//   final _ageCtrl = TextEditingController();
//   final _profCtrl = TextEditingController();
//   final _phoneCtrl = TextEditingController();
//   final _emailCtrl = TextEditingController();
//   final _cnicCtrl = TextEditingController();
//   final _addrCtrl = TextEditingController();
//   final _cityCtrl = TextEditingController();
//   final _searchCtrl = TextEditingController();
//
//   // Form state
//   String _relation = 'Parent';
//   String _gender = 'Male';
//   String _bloodGroup = '';
//   DateTime? _dob;
//   bool _isExisting = false;
//   int _step = 0;
//
//   // Search state
//   List<PatientModel> _searchResults = [];
//   bool _isSearching = false;
//   Timer? _debounce;
//
//   static const _relations = ['Parent', 'Spouse', 'Sibling', 'Child', 'Other'];
//   static const _genders = ['Male', 'Female', 'Other'];
//   static const _bloodGroups = [
//     'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
//   ];
//
//   // ── lifecycle ──────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _mrFocusNode.addListener(() {
//       if (!_mrFocusNode.hasFocus) _lookupMr(_mrCtrl.text);
//     });
//     WidgetsBinding.instance.addPostFrameCallback((_) => _loadNextMr());
//   }
//
//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _tabController.dispose();
//     _mrFocusNode.dispose();
//     for (final c in [
//       _mrCtrl, _firstCtrl, _lastCtrl, _guardianCtrl, _ageCtrl,
//       _profCtrl, _phoneCtrl, _emailCtrl, _cnicCtrl, _addrCtrl,
//       _cityCtrl, _searchCtrl,
//     ]) {
//       c.dispose();
//     }
//     super.dispose();
//   }
//
//   // ── MR ─────────────────────────────────────────────────────────────────────
//   Future<void> _loadNextMr() async {
//     final p = context.read<MrProvider>();
//     await p.fetchNextMR();
//     if (mounted && p.nextMrNumber != null && !_isExisting) {
//       setState(() => _mrCtrl.text = p.nextMrNumber!);
//     }
//   }
//
//   // ✅ Fixed: always fetches from API so history is populated
//   Future<void> _lookupMr(String value) async {
//     final input = value.trim().replaceAll(RegExp(r'[^0-9]'), '');
//     if (input.isEmpty) {
//       if (_isExisting) {
//         _clearFields();
//         context.read<MrProvider>().selectPatient(null);
//         setState(() => _isExisting = false);
//         _loadNextMr();
//       }
//       return;
//     }
//
//     final formattedInput =
//     input.length < 5 ? input.padLeft(5, '0') : input;
//
//     if (formattedInput != _mrCtrl.text) {
//       _mrCtrl.text = formattedInput;
//     }
//
//     final prov = context.read<MrProvider>();
//
//     // findByMrNumber now always calls API — returns patient with visitHistory
//     final patient = await prov.findByMrNumber(formattedInput);
//
//     if (patient != null) {
//       _mrCtrl.text = patient.mrNumber;
//       _fillForm(patient);
//       // ✅ selectPatient triggers _HistoryContent rebuild with visit data
//       prov.selectPatient(patient);
//       setState(() => _isExisting = true);
//       if (MediaQuery.of(context).size.width > 820) {
//         _tabController.animateTo(1); // auto-switch to History tab
//       }
//     } else {
//       if (_isExisting) {
//         _clearFields();
//         prov.selectPatient(null);
//         setState(() => _isExisting = false);
//       }
//       _snack('New MR — ready to register', info: true);
//     }
//   }
//
//   void _fillForm(PatientModel p) {
//     _firstCtrl.text = p.firstName;
//     _lastCtrl.text = p.lastName;
//     _guardianCtrl.text = p.guardianName;
//     _ageCtrl.text = p.age?.toString() ?? '';
//     _profCtrl.text = p.profession;
//     _phoneCtrl.text = p.phoneNumber;
//     _emailCtrl.text = p.email;
//     _cnicCtrl.text = p.cnic;
//     _addrCtrl.text = p.address;
//     _cityCtrl.text = p.city;
//     setState(() {
//       _relation = _relations.contains(p.relation) ? p.relation : 'Parent';
//       _gender = _genders.contains(p.gender) ? p.gender : 'Male';
//       _bloodGroup =
//       _bloodGroups.contains(p.bloodGroup) ? p.bloodGroup : '';
//     });
//   }
//
//   void _clearFields() {
//     for (final c in [
//       _firstCtrl, _lastCtrl, _guardianCtrl, _ageCtrl, _profCtrl,
//       _phoneCtrl, _emailCtrl, _cnicCtrl, _addrCtrl, _cityCtrl,
//     ]) {
//       c.clear();
//     }
//     setState(() {
//       _relation = 'Parent';
//       _gender = 'Male';
//       _bloodGroup = '';
//       _dob = null;
//     });
//   }
//
//   void _clearForm() {
//     _formKey.currentState?.reset();
//     _mrCtrl.clear();
//     _clearFields();
//     _searchCtrl.clear();
//     context.read<MrProvider>().selectPatient(null);
//     setState(() {
//       _isExisting = false;
//       _searchResults = [];
//       _step = 0;
//     });
//     WidgetsBinding.instance.addPostFrameCallback((_) => _loadNextMr());
//     _snack('Form cleared — new patient ready', info: true);
//   }
//
//   Future<void> _onSave() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_isExisting) {
//       _snack('Patient already registered.', info: true);
//       return;
//     }
//     final prov = context.read<MrProvider>();
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) =>
//       const Center(child: CircularProgressIndicator(color: _teal)),
//     );
//     final patient = await prov.registerPatient(
//       mrNumber: _mrCtrl.text,
//       firstName: _firstCtrl.text,
//       lastName: _lastCtrl.text,
//       guardianName: _guardianCtrl.text,
//       relation: _relation,
//       gender: _gender,
//       dateOfBirth: _dob != null
//           ? '${_dob!.day.toString().padLeft(2, '0')}/${_dob!.month.toString().padLeft(2, '0')}/${_dob!.year}'
//           : '',
//       age: int.tryParse(_ageCtrl.text),
//       bloodGroup: _bloodGroup,
//       profession: _profCtrl.text,
//       phoneNumber: _phoneCtrl.text,
//       email: _emailCtrl.text,
//       cnic: _cnicCtrl.text,
//       address: _addrCtrl.text,
//       city: _cityCtrl.text,
//     );
//     if (mounted) Navigator.pop(context);
//     if (patient != null) {
//       _mrCtrl.text = patient.mrNumber;
//       setState(() => _isExisting = true);
//       _snack('Registered! MR: ${patient.mrNumber}');
//     } else {
//       _snack(prov.errorMessage ?? 'Failed to register', info: true);
//     }
//   }
//
//   // ── Search ─────────────────────────────────────────────────────────────────
//   void _onSearchChanged(String q) {
//     _debounce?.cancel();
//     if (q.trim().length < 2) {
//       setState(() {
//         _searchResults = [];
//         _isSearching = false;
//       });
//       return;
//     }
//     setState(() => _isSearching = true);
//     _debounce = Timer(const Duration(milliseconds: 500), () async {
//       final results = await context.read<MrProvider>().searchPatients(q);
//       if (mounted) {
//         setState(() {
//           _searchResults = results;
//           _isSearching = false;
//         });
//       }
//     });
//   }
//
//   void _selectFromSearch(PatientModel p) {
//     _mrCtrl.text = p.mrNumber;
//     _fillForm(p);
//     context.read<MrProvider>().selectPatient(p);
//     setState(() {
//       _isExisting = true;
//       _searchResults = [];
//     });
//     _searchCtrl.clear();
//     Navigator.pop(context);
//     // ✅ Fetch full patient data (with history) after selecting from search
//     _lookupMr(p.mrNumber);
//   }
//
//   void _snack(String msg, {bool info = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Row(children: [
//         Icon(info ? Icons.info_outline : Icons.check_circle,
//             color: Colors.white, size: 16),
//         const SizedBox(width: 8),
//         Flexible(child: Text(msg, style: const TextStyle(fontSize: 12))),
//       ]),
//       backgroundColor: info ? _textLight : _teal,
//       behavior: SnackBarBehavior.floating,
//       shape:
//       RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       margin: const EdgeInsets.all(12),
//       duration: const Duration(seconds: 2),
//     ));
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // BUILD
//   // ─────────────────────────────────────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     final isWide = MediaQuery.of(context).size.width > 820;
//     return Scaffold(
//       backgroundColor: _bg,
//       body: isWide ? _buildWide() : _buildMobile(),
//     );
//   }
//
//   // ══════════════════════════════════════════ WIDE LAYOUT ════════════════════
//   Widget _buildWide() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(20),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('MR Details',
//                       style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: _textDark)),
//                   Text('Patient Master Index & Medical Record',
//                       style:
//                       TextStyle(fontSize: 12, color: Colors.grey[600])),
//                 ]),
//           ),
//           if (_isExisting)
//             OutlinedButton.icon(
//               onPressed: _clearForm,
//               icon: const Icon(Icons.add, size: 14),
//               label: const Text('New Patient',
//                   style:
//                   TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: _teal,
//                 side: const BorderSide(color: _teal),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10)),
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//               ),
//             ),
//         ]),
//         const SizedBox(height: 16),
//         Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Expanded(flex: 3, child: _wideForm()),
//           const SizedBox(width: 16),
//           SizedBox(width: 300, child: _wideSidebar()),
//         ]),
//         const SizedBox(height: 24),
//       ]),
//     );
//   }
//
//   Widget _wideForm() {
//     return Container(
//       decoration: BoxDecoration(
//         color: _card,
//         borderRadius: BorderRadius.circular(14),
//         border: const Border(left: BorderSide(color: _teal, width: 4)),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 2))
//         ],
//       ),
//       child: Form(
//         key: _formKey,
//         child:
//         Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
//             child: Row(children: [
//               Container(
//                 width: 36,
//                 height: 36,
//                 decoration: BoxDecoration(
//                     color: _tealLight,
//                     borderRadius: BorderRadius.circular(10)),
//                 child: const Icon(Icons.person_add_outlined,
//                     color: _teal, size: 18),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                           _isExisting
//                               ? 'Edit Patient Details'
//                               : 'New Patient Registration',
//                           style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: _textDark)),
//                       Text(
//                           _isExisting
//                               ? 'Update existing patient information.'
//                               : 'MR Number auto-generated. Search or register new.',
//                           style: const TextStyle(
//                               fontSize: 10, color: _textLight)),
//                     ]),
//               ),
//               if (_isExisting)
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                       color: _tealLight,
//                       borderRadius: BorderRadius.circular(6),
//                       border:
//                       Border.all(color: _teal.withOpacity(0.3))),
//                   child: const Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.check_circle_outline,
//                             color: _teal, size: 12),
//                         SizedBox(width: 4),
//                         Text('Existing patient',
//                             style: TextStyle(
//                                 fontSize: 10,
//                                 color: _teal,
//                                 fontWeight: FontWeight.w600)),
//                       ]),
//                 ),
//             ]),
//           ),
//           const Divider(height: 1, color: Color(0xFFF0F0F0)),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(children: [
//               _mrWidget(),
//               const SizedBox(height: 12),
//               Row(children: [
//                 Expanded(
//                     child: _f(
//                         ctrl: _firstCtrl,
//                         label: 'First Name',
//                         required: true,
//                         icon: Icons.person_outline,
//                         readOnly: _isExisting,
//                         validator: (v) =>
//                         v == null || v.trim().isEmpty
//                             ? 'Required'
//                             : null)),
//                 const SizedBox(width: 10),
//                 Expanded(
//                     child: _f(
//                         ctrl: _lastCtrl,
//                         label: 'Last Name',
//                         icon: Icons.person_outline,
//                         readOnly: _isExisting)),
//               ]),
//               const SizedBox(height: 10),
//               Row(children: [
//                 Expanded(
//                     flex: 2,
//                     child: _f(
//                         ctrl: _guardianCtrl,
//                         label: 'Guardian Name',
//                         icon: Icons.people_outline,
//                         readOnly: _isExisting)),
//                 const SizedBox(width: 10),
//                 Expanded(
//                     child: _dd(
//                         label: 'Relation',
//                         value: _relation,
//                         items: _relations,
//                         enabled: !_isExisting,
//                         onChanged: (v) =>
//                             setState(() => _relation = v!))),
//               ]),
//               const SizedBox(height: 10),
//               Row(children: [
//                 Expanded(
//                     child: _dd(
//                         label: 'Gender',
//                         value: _gender,
//                         items: _genders,
//                         required: true,
//                         enabled: !_isExisting,
//                         onChanged: (v) =>
//                             setState(() => _gender = v!))),
//                 const SizedBox(width: 10),
//                 Expanded(child: _dateWidget()),
//                 const SizedBox(width: 10),
//                 Expanded(
//                     child: _f(
//                         ctrl: _ageCtrl,
//                         label: 'Age',
//                         icon: Icons.numbers,
//                         type: TextInputType.number,
//                         readOnly: _isExisting)),
//                 const SizedBox(width: 10),
//                 Expanded(
//                     child: _dd(
//                         label: 'Blood Group',
//                         value: _bloodGroup.isEmpty ? null : _bloodGroup,
//                         items: _bloodGroups,
//                         hint: 'Select...',
//                         enabled: !_isExisting,
//                         onChanged: (v) =>
//                             setState(() => _bloodGroup = v ?? ''))),
//               ]),
//               const SizedBox(height: 10),
//               _f(
//                   ctrl: _profCtrl,
//                   label: 'Profession',
//                   icon: Icons.work_outline,
//                   readOnly: _isExisting),
//               const SizedBox(height: 10),
//               Row(children: [
//                 Expanded(
//                     child: _f(
//                         ctrl: _phoneCtrl,
//                         label: 'Phone',
//                         icon: Icons.phone_outlined,
//                         type: TextInputType.phone,
//                         readOnly: _isExisting)),
//                 const SizedBox(width: 10),
//                 Expanded(
//                     child: _f(
//                         ctrl: _emailCtrl,
//                         label: 'Email',
//                         icon: Icons.email_outlined,
//                         type: TextInputType.emailAddress,
//                         readOnly: _isExisting)),
//                 const SizedBox(width: 10),
//                 Expanded(
//                     child: _f(
//                         ctrl: _cnicCtrl,
//                         label: 'CNIC',
//                         icon: Icons.credit_card_outlined,
//                         type: TextInputType.number,
//                         readOnly: _isExisting)),
//               ]),
//               const SizedBox(height: 10),
//               Row(children: [
//                 Expanded(
//                     flex: 2,
//                     child: _f(
//                         ctrl: _addrCtrl,
//                         label: 'Address',
//                         icon: Icons.location_on_outlined,
//                         readOnly: _isExisting)),
//                 const SizedBox(width: 10),
//                 Expanded(
//                     child: _f(
//                         ctrl: _cityCtrl,
//                         label: 'City',
//                         icon: Icons.location_city_outlined,
//                         readOnly: _isExisting)),
//               ]),
//               const SizedBox(height: 10),
//               Row(mainAxisAlignment: MainAxisAlignment.end, children: [
//                 OutlinedButton.icon(
//                   onPressed: _clearForm,
//                   icon: const Icon(Icons.refresh_rounded, size: 14),
//                   label:
//                   const Text('Clear', style: TextStyle(fontSize: 12)),
//                   style: OutlinedButton.styleFrom(
//                     foregroundColor: _textLight,
//                     side: const BorderSide(color: _border),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(9)),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16, vertical: 11),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Consumer<MrProvider>(builder: (_, prov, __) {
//                   return ElevatedButton.icon(
//                     onPressed: prov.isCreating ? null : _onSave,
//                     icon: prov.isCreating
//                         ? const SizedBox(
//                         width: 13,
//                         height: 13,
//                         child: CircularProgressIndicator(
//                             strokeWidth: 2, color: Colors.white))
//                         : Icon(
//                         _isExisting
//                             ? Icons.save_outlined
//                             : Icons.person_add_outlined,
//                         size: 14),
//                     label: Text(
//                         prov.isCreating
//                             ? 'Saving...'
//                             : _isExisting
//                             ? 'Update Record'
//                             : 'Register Patient',
//                         style: const TextStyle(
//                             fontSize: 12, fontWeight: FontWeight.bold)),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _teal,
//                       foregroundColor: Colors.white,
//                       disabledBackgroundColor: _teal.withOpacity(0.5),
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(9)),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 18, vertical: 11),
//                     ),
//                   );
//                 }),
//               ]),
//             ]),
//           ),
//         ]),
//       ),
//     );
//   }
//
//   Widget _wideSidebar() {
//     final patient = context.watch<MrProvider>().selectedPatient;
//     return Container(
//       decoration: BoxDecoration(
//         color: _card,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 2))
//         ],
//       ),
//       child: Column(children: [
//         Container(
//           decoration: const BoxDecoration(
//             color: Color(0xFFF7FAFC),
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(14),
//                 topRight: Radius.circular(14)),
//             border: Border(bottom: BorderSide(color: _border)),
//           ),
//           child: TabBar(
//             controller: _tabController,
//             labelColor: _teal,
//             unselectedLabelColor: _textLight,
//             indicatorColor: _teal,
//             indicatorWeight: 2,
//             labelStyle: const TextStyle(
//                 fontSize: 11, fontWeight: FontWeight.w600),
//             tabs: [
//               const Tab(
//                   child: Row(mainAxisSize: MainAxisSize.min, children: [
//                     Icon(Icons.search, size: 13),
//                     SizedBox(width: 4),
//                     Text('Search'),
//                   ])),
//               Tab(
//                   child: Row(mainAxisSize: MainAxisSize.min, children: [
//                     const Icon(Icons.history_rounded, size: 13),
//                     const SizedBox(width: 4),
//                     const Text('History'),
//                     if (patient != null && patient.totalVisits > 0) ...[
//                       const SizedBox(width: 4),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 5, vertical: 1),
//                         decoration: BoxDecoration(
//                             color: const Color(0xFFE9D8FD),
//                             borderRadius: BorderRadius.circular(10)),
//                         child: Text('${patient.totalVisits}',
//                             style: const TextStyle(
//                                 fontSize: 9,
//                                 color: Color(0xFF805AD5),
//                                 fontWeight: FontWeight.bold)),
//                       ),
//                     ]
//                   ])),
//             ],
//           ),
//         ),
//         SizedBox(
//           height: 500,
//           child: TabBarView(controller: _tabController, children: [
//             _wideSearchTab(),
//             _HistoryContent(patient: patient),
//           ]),
//         ),
//       ]),
//     );
//   }
//
//   Widget _wideSearchTab() {
//     return Column(children: [
//       Padding(
//         padding: const EdgeInsets.all(12),
//         child:
//         Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           TextField(
//             controller: _searchCtrl,
//             onChanged: (q) {
//               setState(() {});
//               _onSearchChanged(q);
//             },
//             style: const TextStyle(fontSize: 12),
//             decoration: InputDecoration(
//               hintText: 'Search by name or phone...',
//               hintStyle: const TextStyle(
//                   fontSize: 11, color: Color(0xFFBDBDBD)),
//               prefixIcon: const Icon(Icons.search,
//                   size: 15, color: Color(0xFFBDBDBD)),
//               suffixIcon: _searchCtrl.text.isNotEmpty
//                   ? GestureDetector(
//                 onTap: () {
//                   _searchCtrl.clear();
//                   setState(() {
//                     _searchResults = [];
//                     _isSearching = false;
//                   });
//                 },
//                 child: const Icon(Icons.close,
//                     size: 15, color: Color(0xFFBDBDBD)),
//               )
//                   : null,
//               contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 10, vertical: 9),
//               isDense: true,
//               border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(9),
//                   borderSide: const BorderSide(color: _border)),
//               enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(9),
//                   borderSide: const BorderSide(color: _border)),
//               focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(9),
//                   borderSide:
//                   const BorderSide(color: _teal, width: 1.5)),
//               filled: true,
//               fillColor: const Color(0xFFF7FAFC),
//             ),
//           ),
//           const SizedBox(height: 3),
//           const Text('Min 2 characters',
//               style: TextStyle(
//                   fontSize: 9, color: Color(0xFFBDBDBD))),
//         ]),
//       ),
//       Expanded(
//         child: _SearchResultsList(
//           isSearching: _isSearching,
//           results: _searchResults,
//           query: _searchCtrl.text,
//           onSelect: (p) {
//             _searchCtrl.clear();
//             setState(() {
//               _searchResults = [];
//             });
//             // ✅ Use _selectFromSearch which also fetches full history
//             _selectFromSearch(p);
//           },
//         ),
//       ),
//     ]);
//   }
//
//   // ══════════════════════════════════════════ MOBILE LAYOUT ══════════════════
//   Widget _buildMobile() {
//     return Column(children: [
//       _mobileHeader(),
//       Expanded(
//         child: Form(
//           key: _formKey,
//           child: Column(children: [
//             _stepBar(),
//             Expanded(child: _stepContent()),
//             _bottomBar(),
//           ]),
//         ),
//       ),
//     ]);
//   }
//
//   Widget _mobileHeader() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
//       decoration: BoxDecoration(
//         color: _card,
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withOpacity(0.06),
//               blurRadius: 6,
//               offset: const Offset(0, 2))
//         ],
//       ),
//       child:
//       Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('MR Details',
//                       style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: _textDark)),
//                   Text('Patient Master Index',
//                       style: TextStyle(
//                           fontSize: 10, color: Colors.grey[500])),
//                 ]),
//           ),
//           _iconBtn(
//               icon: Icons.search_rounded, onTap: _openSearchSheet),
//           const SizedBox(width: 6),
//           Consumer<MrProvider>(builder: (_, prov, __) {
//             final visits = prov.selectedPatient?.totalVisits ?? 0;
//             return _iconBtn(
//                 icon: Icons.history_rounded,
//                 badge: visits > 0 ? '$visits' : null,
//                 onTap: _openHistorySheet);
//           }),
//           const SizedBox(width: 6),
//           GestureDetector(
//             onTap: _clearForm,
//             child: Container(
//               padding:
//               const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
//               decoration: BoxDecoration(
//                   color: _teal,
//                   borderRadius: BorderRadius.circular(8)),
//               child: const Row(mainAxisSize: MainAxisSize.min, children: [
//                 Icon(Icons.add, color: Colors.white, size: 14),
//                 SizedBox(width: 3),
//                 Text('New',
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 11,
//                         fontWeight: FontWeight.w700)),
//               ]),
//             ),
//           ),
//         ]),
//         const SizedBox(height: 10),
//
//         Consumer<MrProvider>(builder: (_, prov, __) {
//           return Container(
//             height: 44,
//             decoration: BoxDecoration(
//               color:
//               _isExisting ? _tealLight : const Color(0xFFF8FAFC),
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(
//                   color: _isExisting
//                       ? _teal
//                       : _teal.withOpacity(0.35),
//                   width: _isExisting ? 1.5 : 1),
//             ),
//             child: Row(children: [
//               const SizedBox(width: 10),
//               Icon(Icons.badge_outlined,
//                   color: _isExisting
//                       ? _teal
//                       : const Color(0xFFCBD5E0),
//                   size: 16),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: TextFormField(
//                   controller: _mrCtrl,
//                   focusNode: _mrFocusNode,
//                   style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w700,
//                       color: _isExisting ? _tealDark : _textDark,
//                       letterSpacing: 0.5),
//                   onFieldSubmitted: _lookupMr,
//                   onChanged: (v) {
//                     if (_isExisting) {
//                       _clearFields();
//                       context
//                           .read<MrProvider>()
//                           .selectPatient(null);
//                       setState(() => _isExisting = false);
//                     }
//                   },
//                   decoration: InputDecoration(
//                     hintText: prov.isLoading
//                         ? 'Loading...'
//                         : 'MR Number — auto or enter to search',
//                     hintStyle: const TextStyle(
//                         color: Color(0xFFBDBDBD), fontSize: 11),
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.zero,
//                     isDense: true,
//                   ),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: _isExisting
//                     ? _clearForm
//                     : () => _lookupMr(_mrCtrl.text),
//                 child: Container(
//                   width: 38,
//                   height: 44,
//                   decoration: BoxDecoration(
//                     color: _isExisting
//                         ? _teal.withOpacity(0.12)
//                         : Colors.transparent,
//                     borderRadius: const BorderRadius.only(
//                         topRight: Radius.circular(9),
//                         bottomRight: Radius.circular(9)),
//                   ),
//                   child: Icon(
//                       _isExisting
//                           ? Icons.check_circle_rounded
//                           : Icons.search_rounded,
//                       color: _isExisting ? _teal : _textLight,
//                       size: 18),
//                 ),
//               ),
//             ]),
//           );
//         }),
//
//         if (_isExisting) ...[
//           const SizedBox(height: 6),
//           Container(
//             padding:
//             const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//             decoration: BoxDecoration(
//                 color: _tealLight,
//                 borderRadius: BorderRadius.circular(20),
//                 border:
//                 Border.all(color: _teal.withOpacity(0.3))),
//             child: const Row(mainAxisSize: MainAxisSize.min, children: [
//               Icon(Icons.edit_outlined, size: 10, color: _teal),
//               SizedBox(width: 4),
//               Text('Editing existing record · tap ✓ to clear',
//                   style: TextStyle(
//                       fontSize: 10,
//                       color: _teal,
//                       fontWeight: FontWeight.w600)),
//             ]),
//           ),
//         ],
//       ]),
//     );
//   }
//
//   Widget _iconBtn(
//       {required IconData icon,
//         String? badge,
//         required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 36,
//         height: 36,
//         decoration: BoxDecoration(
//             color: const Color(0xFFF4F7FA),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: _border)),
//         child: Stack(alignment: Alignment.center, children: [
//           Icon(icon, size: 17, color: _textMid),
//           if (badge != null)
//             Positioned(
//               top: 4,
//               right: 4,
//               child: Container(
//                 padding: const EdgeInsets.all(2),
//                 decoration: const BoxDecoration(
//                     color: _teal, shape: BoxShape.circle),
//                 child: Text(badge,
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 7,
//                         fontWeight: FontWeight.bold)),
//               ),
//             ),
//         ]),
//       ),
//     );
//   }
//
//   // ── Step bar ───────────────────────────────────────────────────────────────
//   Widget _stepBar() {
//     const labels = ['Identity', 'Personal', 'Contact'];
//     return Container(
//       color: _card,
//       padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
//       child: Row(
//         children: List.generate(labels.length, (i) {
//           final active = i == _step;
//           final done = i < _step;
//           final isLast = i == labels.length - 1;
//           return Expanded(
//             child: Row(children: [
//               if (i > 0)
//                 Expanded(
//                     child: Container(
//                         height: 2,
//                         color: done ? _teal : _border)),
//               GestureDetector(
//                 onTap: () => setState(() => _step = i),
//                 child: Column(children: [
//                   Container(
//                     width: 26,
//                     height: 26,
//                     decoration: BoxDecoration(
//                         color: active
//                             ? _teal
//                             : done
//                             ? _tealLight
//                             : const Color(0xFFF0F4F8),
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                             color: active || done ? _teal : _border,
//                             width: 1.5)),
//                     child: Center(
//                       child: done
//                           ? const Icon(Icons.check_rounded,
//                           size: 13, color: _teal)
//                           : Text('${i + 1}',
//                           style: TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                               color: active
//                                   ? Colors.white
//                                   : _textLight)),
//                     ),
//                   ),
//                   const SizedBox(height: 3),
//                   Text(labels[i],
//                       style: TextStyle(
//                           fontSize: 9,
//                           fontWeight: active
//                               ? FontWeight.w700
//                               : FontWeight.normal,
//                           color: active ? _teal : _textLight)),
//                 ]),
//               ),
//               if (!isLast)
//                 Expanded(
//                     child: Container(
//                         height: 2,
//                         color: i < _step ? _teal : _border)),
//             ]),
//           );
//         }),
//       ),
//     );
//   }
//
//   // ── Step content ────────────────────────────────────────────────────────────
//   Widget _stepContent() {
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 220),
//       transitionBuilder: (child, anim) =>
//           FadeTransition(opacity: anim, child: child),
//       child: SingleChildScrollView(
//         key: ValueKey(_step),
//         padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
//         child: Column(children: [
//           if (_step == 0) _step0(),
//           if (_step == 1) _step1(),
//           if (_step == 2) _step2(),
//           const SizedBox(height: 16),
//         ]),
//       ),
//     );
//   }
//
//   Widget _step0() => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       _stepTitle('Identity', Icons.person_outline),
//       const SizedBox(height: 12),
//       Row(children: [
//         Expanded(
//             child: _f(
//                 ctrl: _firstCtrl,
//                 label: 'First Name',
//                 required: true,
//                 icon: Icons.person_outline,
//                 readOnly: _isExisting,
//                 validator: (v) =>
//                 v == null || v.trim().isEmpty ? 'Required' : null)),
//         const SizedBox(width: 10),
//         Expanded(
//             child: _f(
//                 ctrl: _lastCtrl,
//                 label: 'Last Name',
//                 icon: Icons.person_outline,
//                 readOnly: _isExisting)),
//       ]),
//       const SizedBox(height: 10),
//       _f(
//           ctrl: _guardianCtrl,
//           label: 'Guardian Name',
//           icon: Icons.people_outline,
//           readOnly: _isExisting),
//       const SizedBox(height: 10),
//       _dd(
//           label: 'Relation',
//           value: _relation,
//           items: _relations,
//           enabled: !_isExisting,
//           onChanged: (v) => setState(() => _relation = v!)),
//     ],
//   );
//
//   Widget _step1() => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       _stepTitle('Personal Info', Icons.health_and_safety_outlined),
//       const SizedBox(height: 12),
//       Row(children: [
//         Expanded(
//             child: _dd(
//                 label: 'Gender',
//                 value: _gender,
//                 items: _genders,
//                 required: true,
//                 enabled: !_isExisting,
//                 onChanged: (v) => setState(() => _gender = v!))),
//         const SizedBox(width: 10),
//         Expanded(
//             child: _dd(
//                 label: 'Blood Group',
//                 value: _bloodGroup.isEmpty ? null : _bloodGroup,
//                 items: _bloodGroups,
//                 hint: 'Select',
//                 enabled: !_isExisting,
//                 onChanged: (v) =>
//                     setState(() => _bloodGroup = v ?? ''))),
//       ]),
//       const SizedBox(height: 10),
//       Row(children: [
//         Expanded(child: _dateWidget()),
//         const SizedBox(width: 10),
//         Expanded(
//             child: _f(
//                 ctrl: _ageCtrl,
//                 label: 'Age',
//                 icon: Icons.numbers,
//                 type: TextInputType.number,
//                 readOnly: _isExisting)),
//       ]),
//       const SizedBox(height: 10),
//       _f(
//           ctrl: _profCtrl,
//           label: 'Profession',
//           icon: Icons.work_outline,
//           readOnly: _isExisting),
//     ],
//   );
//
//   Widget _step2() => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       _stepTitle('Contact & Address', Icons.contact_phone_outlined),
//       const SizedBox(height: 12),
//       _f(
//           ctrl: _phoneCtrl,
//           label: 'Phone Number',
//           icon: Icons.phone_outlined,
//           type: TextInputType.phone,
//           readOnly: _isExisting),
//       const SizedBox(height: 10),
//       _f(
//           ctrl: _emailCtrl,
//           label: 'Email',
//           icon: Icons.email_outlined,
//           type: TextInputType.emailAddress,
//           readOnly: _isExisting),
//       const SizedBox(height: 10),
//       _f(
//           ctrl: _cnicCtrl,
//           label: 'CNIC',
//           icon: Icons.credit_card_outlined,
//           type: TextInputType.number,
//           readOnly: _isExisting),
//       const SizedBox(height: 10),
//       _f(
//           ctrl: _addrCtrl,
//           label: 'Address',
//           icon: Icons.location_on_outlined,
//           readOnly: _isExisting),
//       const SizedBox(height: 10),
//       _f(
//           ctrl: _cityCtrl,
//           label: 'City',
//           icon: Icons.location_city_outlined,
//           readOnly: _isExisting),
//     ],
//   );
//
//   Widget _stepTitle(String title, IconData icon) {
//     return Row(children: [
//       Container(
//         width: 30,
//         height: 30,
//         decoration: BoxDecoration(
//             color: _tealLight, borderRadius: BorderRadius.circular(8)),
//         child: Icon(icon, color: _teal, size: 15),
//       ),
//       const SizedBox(width: 8),
//       Text(title,
//           style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.bold,
//               color: _textDark)),
//     ]);
//   }
//
//   // ── Bottom bar ─────────────────────────────────────────────────────────────
//   Widget _bottomBar() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
//       decoration: const BoxDecoration(
//           color: _card, border: Border(top: BorderSide(color: _border))),
//       child: Consumer<MrProvider>(builder: (_, prov, __) {
//         final isLast = _step == 2;
//         return Row(children: [
//           if (_step > 0) ...[
//             Expanded(
//               flex: 1,
//               child: OutlinedButton(
//                 onPressed: () => setState(() => _step--),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: _textMid,
//                   side: const BorderSide(color: _border),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10)),
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                 ),
//                 child: const Text('Back',
//                     style: TextStyle(fontSize: 13)),
//               ),
//             ),
//             const SizedBox(width: 10),
//           ],
//           Expanded(
//             flex: 2,
//             child: ElevatedButton(
//               onPressed: prov.isCreating
//                   ? null
//                   : isLast
//                   ? _onSave
//                   : () => setState(() => _step++),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _teal,
//                 foregroundColor: Colors.white,
//                 disabledBackgroundColor: _teal.withOpacity(0.5),
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10)),
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//               ),
//               child: prov.isCreating
//                   ? const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(
//                       strokeWidth: 2, color: Colors.white))
//                   : Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     isLast
//                         ? (_isExisting
//                         ? Icons.save_outlined
//                         : Icons.person_add_outlined)
//                         : Icons.arrow_forward_rounded,
//                     size: 15,
//                   ),
//                   const SizedBox(width: 6),
//                   Text(
//                     isLast
//                         ? (_isExisting
//                         ? 'Update Record'
//                         : 'Register Patient')
//                         : 'Continue',
//                     style: const TextStyle(
//                         fontSize: 13, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ]);
//       }),
//     );
//   }
//
//   // ── Bottom sheets ──────────────────────────────────────────────────────────
//   void _openSearchSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _SearchSheet(
//         searchCtrl: _searchCtrl,
//         results: _searchResults,
//         isSearching: _isSearching,
//         onChanged: (q) {
//           setState(() {});
//           _onSearchChanged(q);
//         },
//         onSelect: _selectFromSearch,
//         onClear: () {
//           _searchCtrl.clear();
//           setState(() {
//             _searchResults = [];
//             _isSearching = false;
//           });
//         },
//       ),
//     );
//   }
//
//   void _openHistorySheet() {
//     final patient = context.read<MrProvider>().selectedPatient;
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _HistorySheet(patient: patient),
//     );
//   }
//
//   // ── Shared field widgets ───────────────────────────────────────────────────
//   Widget _mrWidget() {
//     return Consumer<MrProvider>(builder: (_, prov, __) {
//       return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('MR Number',
//                 style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.w600,
//                     color: _teal)),
//             const SizedBox(height: 5),
//             Container(
//               padding: const EdgeInsets.symmetric(
//                   horizontal: 10, vertical: 4),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF8FAFC),
//                 borderRadius: BorderRadius.circular(9),
//                 border: Border.all(
//                     color: _isExisting
//                         ? _teal
//                         : _teal.withOpacity(0.4),
//                     width: _isExisting ? 1.5 : 1),
//               ),
//               child: Row(children: [
//                 Expanded(
//                   child: TextFormField(
//                     controller: _mrCtrl,
//                     focusNode: _mrFocusNode,
//                     style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: 0.5),
//                     onFieldSubmitted: _lookupMr,
//                     onChanged: (v) {
//                       if (_isExisting) {
//                         _clearFields();
//                         context
//                             .read<MrProvider>()
//                             .selectPatient(null);
//                         setState(() => _isExisting = false);
//                       }
//                     },
//                     decoration: InputDecoration(
//                       hintText: prov.isLoading
//                           ? 'Loading...'
//                           : 'Auto-generated or enter to search',
//                       hintStyle: const TextStyle(
//                           color: Color(0xFFBDBDBD), fontSize: 11),
//                       prefixIcon: const Icon(Icons.badge_outlined,
//                           color: Color(0xFFCBD5E0), size: 16),
//                       border: InputBorder.none,
//                       contentPadding:
//                       const EdgeInsets.symmetric(vertical: 8),
//                       isDense: true,
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: _isExisting
//                       ? _clearForm
//                       : () => _lookupMr(_mrCtrl.text),
//                   child: Container(
//                     padding: const EdgeInsets.all(5),
//                     decoration: BoxDecoration(
//                         color: _teal.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(6)),
//                     child: Icon(
//                         _isExisting
//                             ? Icons.check_circle_rounded
//                             : Icons.search_rounded,
//                         color: _teal,
//                         size: 17),
//                   ),
//                 ),
//               ]),
//             ),
//           ]);
//     });
//   }
//
//   Widget _f({
//     required TextEditingController ctrl,
//     required String label,
//     IconData? icon,
//     bool required = false,
//     bool readOnly = false,
//     TextInputType type = TextInputType.text,
//     String? Function(String?)? validator,
//   }) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       RichText(
//           text: TextSpan(
//               text: label,
//               style: const TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w500,
//                   color: _textMid),
//               children: required
//                   ? const [
//                 TextSpan(
//                     text: ' *',
//                     style: TextStyle(color: _red))
//               ]
//                   : [])),
//       const SizedBox(height: 4),
//       TextFormField(
//         controller: ctrl,
//         readOnly: readOnly,
//         keyboardType: type,
//         validator: validator,
//         style: const TextStyle(fontSize: 13, color: _textDark),
//         decoration: InputDecoration(
//           prefixIcon: icon != null
//               ? Icon(icon, color: const Color(0xFFCBD5E0), size: 15)
//               : null,
//           contentPadding:
//           const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
//           isDense: true,
//           border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(9),
//               borderSide: const BorderSide(color: _border)),
//           enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(9),
//               borderSide: const BorderSide(color: _border)),
//           focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(9),
//               borderSide: const BorderSide(color: _teal, width: 1.5)),
//           errorBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(9),
//               borderSide: const BorderSide(color: _red)),
//           filled: true,
//           fillColor:
//           readOnly ? const Color(0xFFF7FAFC) : Colors.white,
//         ),
//       ),
//     ]);
//   }
//
//   Widget _dd({
//     required String label,
//     required String? value,
//     required List<String> items,
//     String hint = '',
//     bool required = false,
//     bool enabled = true,
//     required ValueChanged<String?> onChanged,
//   }) {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       RichText(
//           text: TextSpan(
//               text: label,
//               style: const TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w500,
//                   color: _textMid),
//               children: required
//                   ? const [
//                 TextSpan(
//                     text: ' *',
//                     style: TextStyle(color: _red))
//               ]
//                   : [])),
//       const SizedBox(height: 4),
//       IgnorePointer(
//         ignoring: !enabled,
//         child: DropdownButtonFormField<String>(
//           value: value,
//           isExpanded: true,
//           hint: hint.isNotEmpty
//               ? Text(hint,
//               style: const TextStyle(
//                   color: Color(0xFFBDBDBD), fontSize: 12))
//               : null,
//           style: const TextStyle(fontSize: 13, color: _textDark),
//           decoration: InputDecoration(
//             contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 10, vertical: 11),
//             isDense: true,
//             border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(9),
//                 borderSide: const BorderSide(color: _border)),
//             enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(9),
//                 borderSide: const BorderSide(color: _border)),
//             focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(9),
//                 borderSide:
//                 const BorderSide(color: _teal, width: 1.5)),
//             filled: true,
//             fillColor:
//             !enabled ? const Color(0xFFF7FAFC) : Colors.white,
//           ),
//           items: items
//               .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//               .toList(),
//           onChanged: enabled ? onChanged : null,
//         ),
//       ),
//     ]);
//   }
//
//   Widget _dateWidget() {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       const Text('Date of Birth',
//           style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w500,
//               color: _textMid)),
//       const SizedBox(height: 4),
//       GestureDetector(
//         onTap: _isExisting
//             ? null
//             : () async {
//           final p = await showDatePicker(
//             context: context,
//             initialDate: DateTime(2000),
//             firstDate: DateTime(1900),
//             lastDate: DateTime.now(),
//             builder: (ctx, child) => Theme(
//               data: Theme.of(ctx).copyWith(
//                   colorScheme: const ColorScheme.light(
//                       primary: _teal)),
//               child: child!,
//             ),
//           );
//           if (p != null) {
//             setState(() {
//               _dob = p;
//               _ageCtrl.text =
//                   (DateTime.now().year - p.year).toString();
//             });
//           }
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(
//               horizontal: 10, vertical: 11),
//           decoration: BoxDecoration(
//               color: _isExisting
//                   ? const Color(0xFFF7FAFC)
//                   : Colors.white,
//               border: Border.all(color: _border),
//               borderRadius: BorderRadius.circular(9)),
//           child: Row(children: [
//             Expanded(
//               child: Text(
//                 _dob != null
//                     ? '${_dob!.month.toString().padLeft(2, '0')}/${_dob!.day.toString().padLeft(2, '0')}/${_dob!.year}'
//                     : 'mm/dd/yyyy',
//                 style: TextStyle(
//                     fontSize: 13,
//                     color: _dob != null
//                         ? _textDark
//                         : const Color(0xFFBDBDBD)),
//               ),
//             ),
//             const Icon(Icons.calendar_today_outlined,
//                 size: 13, color: Color(0xFFCBD5E0)),
//           ]),
//         ),
//       ),
//     ]);
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // SEARCH RESULTS LIST
// // ─────────────────────────────────────────────────────────────────────────────
// class _SearchResultsList extends StatelessWidget {
//   final bool isSearching;
//   final List<PatientModel> results;
//   final String query;
//   final Function(PatientModel) onSelect;
//
//   const _SearchResultsList({
//     required this.isSearching,
//     required this.results,
//     required this.query,
//     required this.onSelect,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (isSearching) {
//       return const Center(
//           child:
//           CircularProgressIndicator(strokeWidth: 2, color: _teal));
//     }
//     if (query.isEmpty) {
//       return const Center(
//         child:
//         Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           Icon(Icons.manage_search_rounded,
//               size: 38, color: Color(0xFFCBD5E0)),
//           SizedBox(height: 8),
//           Text('Search for a patient',
//               style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                   color: _textLight)),
//           SizedBox(height: 2),
//           Text('Results appear as you type',
//               style:
//               TextStyle(fontSize: 10, color: Color(0xFFA0AEC0))),
//         ]),
//       );
//     }
//     if (results.isEmpty) {
//       return Center(
//         child:
//         Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//           const Icon(Icons.search_off_rounded,
//               size: 38, color: Color(0xFFCBD5E0)),
//           const SizedBox(height: 8),
//           const Text('No patients found',
//               style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                   color: _textLight)),
//           const SizedBox(height: 2),
//           Text('Try a different name or phone',
//               style: TextStyle(fontSize: 10, color: Colors.grey[400])),
//         ]),
//       );
//     }
//     return ListView.separated(
//       itemCount: results.length,
//       separatorBuilder: (_, __) =>
//       const Divider(height: 1, color: Color(0xFFF0F0F0)),
//       itemBuilder: (_, i) {
//         final p = results[i];
//         return InkWell(
//           onTap: () => onSelect(p),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 14, vertical: 10),
//             child: Row(children: [
//               CircleAvatar(
//                 radius: 17,
//                 backgroundColor: _teal.withOpacity(0.1),
//                 child: Text(
//                   '${p.firstName.isNotEmpty ? p.firstName[0] : ''}${p.lastName.isNotEmpty ? p.lastName[0] : ''}'
//                       .toUpperCase(),
//                   style: const TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                       color: _teal),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('${p.firstName} ${p.lastName}',
//                           style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: _textDark)),
//                       const SizedBox(height: 2),
//                       Row(children: [
//                         Text('MR# ${p.mrNumber}',
//                             style: const TextStyle(
//                                 fontSize: 10,
//                                 color: _textLight,
//                                 fontFamily: 'monospace')),
//                         const Text(' · ',
//                             style: TextStyle(
//                                 color: Color(0xFFCBD5E0))),
//                         Text(p.phoneNumber,
//                             style: const TextStyle(
//                                 fontSize: 10, color: _textLight)),
//                       ]),
//                     ]),
//               ),
//               Text(
//                   '${p.age ?? '—'}y · ${p.gender.isNotEmpty ? p.gender[0] : '—'}',
//                   style:
//                   const TextStyle(fontSize: 10, color: _textLight)),
//             ]),
//           ),
//         );
//       },
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // SEARCH BOTTOM SHEET
// // ─────────────────────────────────────────────────────────────────────────────
// class _SearchSheet extends StatefulWidget {
//   final TextEditingController searchCtrl;
//   final List<PatientModel> results;
//   final bool isSearching;
//   final Function(String) onChanged;
//   final Function(PatientModel) onSelect;
//   final VoidCallback onClear;
//
//   const _SearchSheet({
//     required this.searchCtrl,
//     required this.results,
//     required this.isSearching,
//     required this.onChanged,
//     required this.onSelect,
//     required this.onClear,
//   });
//
//   @override
//   State<_SearchSheet> createState() => _SearchSheetState();
// }
//
// class _SearchSheetState extends State<_SearchSheet> {
//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.88,
//       minChildSize: 0.5,
//       maxChildSize: 0.95,
//       builder: (_, sc) => Container(
//         decoration: const BoxDecoration(
//             color: _card,
//             borderRadius:
//             BorderRadius.vertical(top: Radius.circular(20))),
//         child: Column(children: [
//           const SizedBox(height: 10),
//           Center(
//             child: Container(
//                 width: 36,
//                 height: 4,
//                 decoration: BoxDecoration(
//                     color: _border,
//                     borderRadius: BorderRadius.circular(2))),
//           ),
//           const SizedBox(height: 12),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(children: [
//               Container(
//                 width: 32,
//                 height: 32,
//                 decoration: BoxDecoration(
//                     color: _tealLight,
//                     borderRadius: BorderRadius.circular(8)),
//                 child: const Icon(Icons.search_rounded,
//                     color: _teal, size: 16),
//               ),
//               const SizedBox(width: 10),
//               const Text('Search Patients',
//                   style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: _textDark)),
//               const Spacer(),
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   width: 28,
//                   height: 28,
//                   decoration: BoxDecoration(
//                       color: const Color(0xFFF0F4F8),
//                       borderRadius: BorderRadius.circular(7)),
//                   child: const Icon(Icons.close_rounded,
//                       size: 15, color: _textMid),
//                 ),
//               ),
//             ]),
//           ),
//           const SizedBox(height: 12),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: TextField(
//               controller: widget.searchCtrl,
//               autofocus: true,
//               onChanged: (q) {
//                 setState(() {});
//                 widget.onChanged(q);
//               },
//               style: const TextStyle(fontSize: 13),
//               decoration: InputDecoration(
//                 hintText: 'Name, phone number...',
//                 hintStyle: const TextStyle(
//                     color: Color(0xFFBDBDBD), fontSize: 12),
//                 prefixIcon: const Icon(Icons.search,
//                     size: 16, color: Color(0xFFBDBDBD)),
//                 suffixIcon: widget.searchCtrl.text.isNotEmpty
//                     ? GestureDetector(
//                   onTap: () {
//                     widget.onClear();
//                     setState(() {});
//                   },
//                   child: const Icon(Icons.close,
//                       size: 15, color: Color(0xFFBDBDBD)),
//                 )
//                     : null,
//                 contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 12, vertical: 11),
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: _border)),
//                 enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: const BorderSide(color: _border)),
//                 focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide:
//                     const BorderSide(color: _teal, width: 1.5)),
//                 filled: true,
//                 fillColor: const Color(0xFFF7FAFC),
//               ),
//             ),
//           ),
//           const SizedBox(height: 4),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 18),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text('Type at least 2 characters',
//                   style: TextStyle(
//                       fontSize: 10, color: Color(0xFFBDBDBD))),
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Divider(height: 1, color: _border),
//           Expanded(
//             child: _SearchResultsList(
//               isSearching: widget.isSearching,
//               results: widget.results,
//               query: widget.searchCtrl.text,
//               onSelect: widget.onSelect,
//             ),
//           ),
//         ]),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // HISTORY BOTTOM SHEET
// // ─────────────────────────────────────────────────────────────────────────────
// class _HistorySheet extends StatelessWidget {
//   final PatientModel? patient;
//   const _HistorySheet({this.patient});
//
//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.88,
//       minChildSize: 0.4,
//       maxChildSize: 0.95,
//       builder: (_, sc) => Container(
//         decoration: const BoxDecoration(
//             color: _card,
//             borderRadius:
//             BorderRadius.vertical(top: Radius.circular(20))),
//         child: Column(children: [
//           const SizedBox(height: 10),
//           Center(
//             child: Container(
//                 width: 36,
//                 height: 4,
//                 decoration: BoxDecoration(
//                     color: _border,
//                     borderRadius: BorderRadius.circular(2))),
//           ),
//           const SizedBox(height: 12),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(children: [
//               Container(
//                 width: 32,
//                 height: 32,
//                 decoration: BoxDecoration(
//                     color: _tealLight,
//                     borderRadius: BorderRadius.circular(8)),
//                 child: const Icon(Icons.history_rounded,
//                     color: _teal, size: 16),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Visit History',
//                           style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: _textDark)),
//                       if (patient != null)
//                         Text(
//                             '${patient!.firstName} ${patient!.lastName}',
//                             style: const TextStyle(
//                                 fontSize: 11, color: _textLight)),
//                     ]),
//               ),
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   width: 28,
//                   height: 28,
//                   decoration: BoxDecoration(
//                       color: const Color(0xFFF0F4F8),
//                       borderRadius: BorderRadius.circular(7)),
//                   child: const Icon(Icons.close_rounded,
//                       size: 15, color: _textMid),
//                 ),
//               ),
//             ]),
//           ),
//           const SizedBox(height: 12),
//           if (patient != null)
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//               child: Row(children: [
//                 _statChip(
//                     '${patient!.totalVisits}', 'Total Visits', _teal),
//                 const SizedBox(width: 10),
//                 _statChip(
//                     '${patient!.visitsToday}', 'Today', _green),
//               ]),
//             ),
//           const Divider(height: 1, color: _border),
//           Expanded(child: _HistoryContent(patient: patient)),
//         ]),
//       ),
//     );
//   }
//
//   Widget _statChip(String val, String label, Color color) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//             color: color.withOpacity(0.07),
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: color.withOpacity(0.2))),
//         child: Column(children: [
//           Text(val,
//               style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: color)),
//           Text(label,
//               style: TextStyle(
//                   fontSize: 10, color: color.withOpacity(0.8))),
//         ]),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // HISTORY CONTENT
// // ─────────────────────────────────────────────────────────────────────────────
// class _HistoryContent extends StatelessWidget {
//   final PatientModel? patient;
//   const _HistoryContent({this.patient});
//
//   @override
//   Widget build(BuildContext context) {
//     if (patient == null) {
//       return const Center(
//         child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.description_outlined,
//                   size: 40, color: Color(0xFFCBD5E0)),
//               SizedBox(height: 8),
//               Text('No patient selected',
//                   style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: _textLight)),
//               SizedBox(height: 3),
//               Text('Look up a patient to see visits',
//                   style:
//                   TextStyle(fontSize: 10, color: Color(0xFFA0AEC0))),
//             ]),
//       );
//     }
//     final visits = patient!.visitHistory;
//     if (visits == null || visits.isEmpty) {
//       return const Center(
//         child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.description_outlined,
//                   size: 40, color: Color(0xFFCBD5E0)),
//               SizedBox(height: 8),
//               Text('No visit history',
//                   style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: _textLight)),
//               SizedBox(height: 3),
//               Text('No visits found for this patient',
//                   style:
//                   TextStyle(fontSize: 10, color: Color(0xFFA0AEC0))),
//             ]),
//       );
//     }
//     return ListView.builder(
//       padding: const EdgeInsets.all(14),
//       itemCount: visits.length,
//       itemBuilder: (_, i) {
//         final v = visits[i];
//         final isLast = i == visits.length - 1;
//         return IntrinsicHeight(
//           child: Row(crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 SizedBox(
//                   width: 18,
//                   child: Column(children: [
//                     Container(
//                       width: 11,
//                       height: 11,
//                       decoration: BoxDecoration(
//                           color: _teal,
//                           shape: BoxShape.circle,
//                           border:
//                           Border.all(color: Colors.white, width: 2),
//                           boxShadow: [
//                             BoxShadow(
//                                 color: _teal.withOpacity(0.3),
//                                 blurRadius: 4)
//                           ]),
//                     ),
//                     if (!isLast)
//                       Expanded(
//                           child: Container(
//                               width: 1.5,
//                               color: const Color(0xFFE2E8F0))),
//                   ]),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Container(
//                     margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                         color: const Color(0xFFF7FAFC),
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: _border)),
//                     child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(children: [
//                             const Icon(Icons.calendar_today_outlined,
//                                 size: 10, color: _textLight),
//                             const SizedBox(width: 3),
//                             Text(v.date ?? '',
//                                 style: const TextStyle(
//                                     fontSize: 10,
//                                     color: _textLight,
//                                     fontWeight: FontWeight.w500)),
//                             const Spacer(),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 5, vertical: 2),
//                               decoration: BoxDecoration(
//                                   color: _teal.withOpacity(0.08),
//                                   borderRadius: BorderRadius.circular(4)),
//                               child: Text(v.time ?? '',
//                                   style: const TextStyle(
//                                       fontSize: 9,
//                                       color: _teal,
//                                       fontWeight: FontWeight.w600)),
//                             ),
//                           ]),
//                           const SizedBox(height: 4),
//                           Text(v.opdService ?? 'Consultation',
//                               style: const TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w700,
//                                   color: _textDark)),
//                           if (v.serviceDetail != null &&
//                               v.serviceDetail!.isNotEmpty) ...[
//                             const SizedBox(height: 2),
//                             Text(v.serviceDetail!,
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: const TextStyle(
//                                     fontSize: 10, color: _textLight)),
//                           ],
//                           const SizedBox(height: 6),
//                           Row(
//                               mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(v.receiptId ?? '',
//                                     style: const TextStyle(
//                                         fontSize: 9,
//                                         color: Color(0xFFA0AEC0),
//                                         fontFamily: 'monospace')),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 7, vertical: 3),
//                                   decoration: BoxDecoration(
//                                       color: _green.withOpacity(0.1),
//                                       borderRadius: BorderRadius.circular(20),
//                                       border: Border.all(
//                                           color: _green.withOpacity(0.3))),
//                                   child: Text(
//                                       'PKR ${v.totalAmount ?? v.paid ?? 0}',
//                                       style: const TextStyle(
//                                           fontSize: 10,
//                                           fontWeight: FontWeight.bold,
//                                           color: Color(0xFF276749))),
//                                 ),
//                               ]),
//                         ]),
//                   ),
//                 ),
//               ]),
//         );
//       },
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../custum widgets/drawer/base_scaffold.dart';
import '../../models/mr_model/mr_patient_model.dart';
import '../../providers/mr_provider/mr_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// THEME CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────
const _teal = Color(0xFF00B5AD);
const _tealLight = Color(0xFFE6F7F6);
const _tealDark = Color(0xFF007A75);
const _bg = Color(0xFFF4F7FA);
const _card = Colors.white;
const _textDark = Color(0xFF1A202C);
const _textMid = Color(0xFF4A5568);
const _textLight = Color(0xFF718096);
const _border = Color(0xFFE2E8F0);
const _green = Color(0xFF38A169);
const _purple = Color(0xFF805AD5);

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class MrDetailsScreen extends StatelessWidget {
  const MrDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScaffold(
      title: 'MR Details',
      drawerIndex: 8,
      body: _MrDetailsBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BODY
// ─────────────────────────────────────────────────────────────────────────────
class _MrDetailsBody extends StatefulWidget {
  const _MrDetailsBody();

  @override
  State<_MrDetailsBody> createState() => _MrDetailsBodyState();
}

class _MrDetailsBodyState extends State<_MrDetailsBody>
    with SingleTickerProviderStateMixin {
  final _mrFocusNode = FocusNode();
  final _mrCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  late TabController _tabController;

  PatientModel? _patient;
  bool _isLoading = false;
  List<PatientModel> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _mrFocusNode.addListener(() {
      if (!_mrFocusNode.hasFocus) _lookupMr(_mrCtrl.text);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.dispose();
    _mrFocusNode.dispose();
    _mrCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── MR Lookup ──────────────────────────────────────────────────────────────
  Future<void> _lookupMr(String value) async {
    final input = value.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (input.isEmpty) {
      setState(() => _patient = null);
      context.read<MrProvider>().selectPatient(null);
      return;
    }
    final formatted = input.length < 5 ? input.padLeft(5, '0') : input;
    if (formatted != _mrCtrl.text) {
      _mrCtrl.text = formatted;
      _mrCtrl.selection =
          TextSelection.collapsed(offset: _mrCtrl.text.length);
    }
    setState(() => _isLoading = true);
    final prov = context.read<MrProvider>();
    final patient = await prov.findByMrNumber(formatted);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (patient != null) {
      setState(() => _patient = patient);
      prov.selectPatient(patient);
      if (MediaQuery.of(context).size.width > 820) {
        _tabController.animateTo(1);
      }
    } else {
      setState(() => _patient = null);
      prov.selectPatient(null);
      _snack('No patient found for MR# $formatted');
    }
  }

  void _clearPatient() {
    _mrCtrl.clear();
    _searchCtrl.clear();
    context.read<MrProvider>().selectPatient(null);
    setState(() {
      _patient = null;
      _searchResults = [];
      _isSearching = false;
    });
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    if (q.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final results = await context.read<MrProvider>().searchPatients(q);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _selectFromSearch(PatientModel p) async {
    _mrCtrl.text = p.mrNumber;
    _searchCtrl.clear();
    setState(() {
      _searchResults = [];
      _isSearching = false;
    });
    Navigator.pop(context);
    await _lookupMr(p.mrNumber);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.info_outline, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Flexible(child: Text(msg, style: const TextStyle(fontSize: 12))),
      ]),
      backgroundColor: _textLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 820;
    return Scaffold(
      backgroundColor: _bg,
      body: isWide ? _buildWide() : _buildMobile(),
    );
  }

  // ══════════════════════════════════════════ WIDE LAYOUT ════════════════════
  Widget _buildWide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MR Details',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _textDark)),
                  Text('Patient Master Index — enter MR number to lookup',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ]),
          ),
          if (_patient != null)
            OutlinedButton.icon(
              onPressed: _clearPatient,
              icon: const Icon(Icons.close_rounded, size: 14),
              label: const Text('Clear',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: _textLight,
                side: const BorderSide(color: _border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
        ]),
        const SizedBox(height: 16),
        _mrSearchBar(),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(color: _teal, strokeWidth: 2),
              ))
        else if (_patient != null)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 3, child: _patientInfoCard()),
            const SizedBox(width: 16),
            SizedBox(width: 300, child: _wideSidebar()),
          ])
        else
          _emptyState(),
        const SizedBox(height: 24),
      ]),
    );
  }

  // ── MR Search bar ──────────────────────────────────────────────────────────
  Widget _mrSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: _patient != null ? _teal : _border,
            width: _patient != null ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        const SizedBox(width: 14),
        Icon(Icons.badge_outlined,
            color: _patient != null ? _teal : const Color(0xFFCBD5E0),
            size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _mrCtrl,
            focusNode: _mrFocusNode,
            keyboardType: TextInputType.number,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: _patient != null ? _tealDark : _textDark,
                letterSpacing: 0.5),
            onSubmitted: _lookupMr,
            onChanged: (v) {
              if (_patient != null) {
                setState(() => _patient = null);
                context.read<MrProvider>().selectPatient(null);
              }
            },
            decoration: const InputDecoration(
              hintText: 'Enter MR Number and press Enter to lookup patient',
              hintStyle: TextStyle(color: Color(0xFFBDBDBD), fontSize: 12),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        if (_patient != null)
          GestureDetector(
            onTap: _clearPatient,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _teal.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(11),
                    bottomRight: Radius.circular(11)),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: _teal, size: 20),
            ),
          )
        else
          GestureDetector(
            onTap: () => _lookupMr(_mrCtrl.text),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _teal,
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(11),
                    bottomRight: Radius.circular(11)),
              ),
              child: const Icon(Icons.search_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
      ]),
    );
  }

  // ── Patient info card (wide + mobile share same inner layout) ──────────────
  Widget _patientInfoCard() {
    final p = _patient!;
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(p),
        const Divider(height: 1, color: _border),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _detailGrid(p),
        ),
      ]),
    );
  }

  Widget _mobilePatientCard() {
    final p = _patient!;
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _cardHeader(p),
        const Divider(height: 1, color: _border),
        Padding(
          padding: const EdgeInsets.all(14),
          child: _detailGrid(p),
        ),
      ]),
    );
  }

  // ── Card header: name + chips + visit count ────────────────────────────────
  Widget _cardHeader(PatientModel p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${p.firstName} ${p.lastName}'.trim().isEmpty
                      ? 'Unknown Patient'
                      : '${p.firstName} ${p.lastName}',
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: _textDark),
                ),
                const SizedBox(height: 6),
                Wrap(spacing: 5, runSpacing: 4, children: [
                  _chip('MR# ${p.mrNumber}', _teal, _tealLight,
                      icon: Icons.badge_outlined),
                  if (p.gender.isNotEmpty)
                    _chip(p.gender, _textMid, const Color(0xFFF0F4F8)),
                  if (p.bloodGroup.isNotEmpty)
                    _chip(p.bloodGroup, const Color(0xFFC53030),
                        const Color(0xFFFFF5F5)),
                  if (p.age != null)
                    _chip('${p.age} yrs', _green, const Color(0xFFF0FFF4)),
                ]),
              ]),
        ),
        const SizedBox(width: 10),
        // visit count
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: _tealLight, borderRadius: BorderRadius.circular(10)),
            child: Column(children: [
              Text('${p.totalVisits}',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _teal)),
              const Text('Visits',
                  style: TextStyle(fontSize: 9, color: _teal)),
            ]),
          ),
          if (p.visitsToday > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: const Color(0xFFF0FFF4),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: _green.withOpacity(0.3))),
              child: Text('${p.visitsToday} today',
                  style: const TextStyle(
                      fontSize: 9,
                      color: _green,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ]),
      ]),
    );
  }

  // ── Detail grid: icon + label + value ─────────────────────────────────────
  Widget _detailGrid(PatientModel p) {
    final items = <Map<String, dynamic>>[
      {'icon': Icons.phone_outlined, 'label': 'Phone', 'value': p.phoneNumber, 'full': false},
      {'icon': Icons.credit_card_outlined, 'label': 'CNIC', 'value': p.cnic, 'full': false},
      {'icon': Icons.email_outlined, 'label': 'Email', 'value': p.email, 'full': true},
      {'icon': Icons.people_outline, 'label': 'Guardian', 'value': p.guardianName, 'full': false},
      {'icon': Icons.family_restroom_outlined, 'label': 'Relation', 'value': p.relation, 'full': false},
      {'icon': Icons.cake_outlined, 'label': 'Date of Birth', 'value': p.dateOfBirth, 'full': false},
      {'icon': Icons.work_outline, 'label': 'Profession', 'value': p.profession, 'full': false},
      {'icon': Icons.location_on_outlined, 'label': 'Address', 'value': p.address, 'full': true},
      {'icon': Icons.location_city_outlined, 'label': 'City', 'value': p.city, 'full': false},
    ];

    // split into rows: full-width items get their own row, others pair up
    final List<Widget> rows = [];
    int i = 0;
    while (i < items.length) {
      final item = items[i];
      if (item['full'] == true) {
        rows.add(_detailItem(
            item['icon'] as IconData,
            item['label'] as String,
            item['value'] as String?));
        i++;
      } else {
        // try to pair with next non-full item
        final next = (i + 1 < items.length && items[i + 1]['full'] != true)
            ? items[i + 1]
            : null;
        if (next != null) {
          rows.add(Row(children: [
            Expanded(
                child: _detailItem(
                    item['icon'] as IconData,
                    item['label'] as String,
                    item['value'] as String?)),
            const SizedBox(width: 12),
            Expanded(
                child: _detailItem(
                    next['icon'] as IconData,
                    next['label'] as String,
                    next['value'] as String?)),
          ]));
          i += 2;
        } else {
          rows.add(_detailItem(
              item['icon'] as IconData,
              item['label'] as String,
              item['value'] as String?));
          i++;
        }
      }
      if (i < items.length) rows.add(const SizedBox(height: 10));
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  Widget _detailItem(IconData icon, String label, String? value) {
    final val =
    (value == null || value.trim().isEmpty) ? null : value.trim();
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
            color: _tealLight, borderRadius: BorderRadius.circular(7)),
        child: Icon(icon, size: 13, color: _teal),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: _textLight,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 1),
              Text(
                val ?? '—',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                    val != null ? FontWeight.w600 : FontWeight.normal,
                    color:
                    val != null ? _textDark : const Color(0xFFCBD5E0)),
              ),
            ]),
      ),
    ]);
  }

  // ── Chip ───────────────────────────────────────────────────────────────────
  Widget _chip(String text, Color fg, Color bg, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: fg.withOpacity(0.25))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 9, color: fg),
          const SizedBox(width: 3),
        ],
        Text(text,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
      ]),
    );
  }

  // ── Wide sidebar ───────────────────────────────────────────────────────────
  Widget _wideSidebar() {
    final patient = context.watch<MrProvider>().selectedPatient;
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF7FAFC),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14)),
            border: Border(bottom: BorderSide(color: _border)),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: _teal,
            unselectedLabelColor: _textLight,
            indicatorColor: _teal,
            indicatorWeight: 2,
            labelStyle:
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            tabs: [
              const Tab(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.search, size: 13),
                    SizedBox(width: 4),
                    Text('Search'),
                  ])),
              Tab(
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.history_rounded, size: 13),
                    const SizedBox(width: 4),
                    const Text('History'),
                    if (patient != null && patient.totalVisits > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE9D8FD),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text('${patient.totalVisits}',
                            style: const TextStyle(
                                fontSize: 9,
                                color: _purple,
                                fontWeight: FontWeight.bold)),
                      ),
                    ]
                  ])),
            ],
          ),
        ),
        SizedBox(
          height: 520,
          child: TabBarView(controller: _tabController, children: [
            _wideSearchTab(),
            _HistoryContent(patient: patient),
          ]),
        ),
      ]),
    );
  }

  Widget _wideSearchTab() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child:
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (q) {
              setState(() {});
              _onSearchChanged(q);
            },
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Search by name or phone...',
              hintStyle:
              const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD)),
              prefixIcon: const Icon(Icons.search,
                  size: 15, color: Color(0xFFBDBDBD)),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? GestureDetector(
                onTap: () {
                  _searchCtrl.clear();
                  setState(() {
                    _searchResults = [];
                    _isSearching = false;
                  });
                },
                child: const Icon(Icons.close,
                    size: 15, color: Color(0xFFBDBDBD)),
              )
                  : null,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              isDense: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: _border)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: _border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: _teal, width: 1.5)),
              filled: true,
              fillColor: const Color(0xFFF7FAFC),
            ),
          ),
          const SizedBox(height: 3),
          const Text('Min 2 characters',
              style: TextStyle(fontSize: 9, color: Color(0xFFBDBDBD))),
        ]),
      ),
      Expanded(
        child: _SearchResultsList(
          isSearching: _isSearching,
          results: _searchResults,
          query: _searchCtrl.text,
          onSelect: (p) {
            _searchCtrl.clear();
            setState(() => _searchResults = []);
            _selectFromSearch(p);
          },
        ),
      ),
    ]);
  }

  // ══════════════════════════════════════════ MOBILE LAYOUT ══════════════════
  Widget _buildMobile() {
    return Column(children: [
      _mobileHeader(),
      Expanded(
        child: _isLoading
            ? const Center(
            child: CircularProgressIndicator(
                color: _teal, strokeWidth: 2))
            : _patient == null
            ? _emptyState()
            : SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(children: [
            _mobilePatientCard(),
            const SizedBox(height: 14),
            _mobileVisitStats(),
            const SizedBox(height: 14),
            _mobileHistorySection(),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    ]);
  }

  Widget _mobileHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: _card,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MR Details',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textDark)),
                ]),
          ),
          _iconBtn(icon: Icons.search_rounded, onTap: _openSearchSheet),
          if (_patient != null) ...[
            const SizedBox(width: 6),
            _iconBtn(icon: Icons.close_rounded, onTap: _clearPatient),
          ],
        ]),
        const SizedBox(height: 10),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color:
            _patient != null ? _tealLight : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color:
                _patient != null ? _teal : _teal.withOpacity(0.35),
                width: _patient != null ? 1.5 : 1),
          ),
          child: Row(children: [
            const SizedBox(width: 10),
            Icon(Icons.badge_outlined,
                color: _patient != null ? _teal : const Color(0xFFCBD5E0),
                size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _mrCtrl,
                focusNode: _mrFocusNode,
                keyboardType: TextInputType.number,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _patient != null ? _tealDark : _textDark,
                    letterSpacing: 0.5),
                onSubmitted: _lookupMr,
                onChanged: (v) {
                  if (_patient != null) {
                    setState(() => _patient = null);
                    context.read<MrProvider>().selectPatient(null);
                  }
                },
                decoration: const InputDecoration(
                  hintText: 'Enter MR Number...',
                  hintStyle:
                  TextStyle(color: Color(0xFFBDBDBD), fontSize: 11),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
            GestureDetector(
              onTap: _patient != null
                  ? _clearPatient
                  : () => _lookupMr(_mrCtrl.text),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color:
                  _patient != null ? _teal.withOpacity(0.12) : _teal,
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(9),
                      bottomRight: Radius.circular(9)),
                ),
                child: Icon(
                    _patient != null
                        ? Icons.check_circle_rounded
                        : Icons.search_rounded,
                    color: _patient != null ? _teal : Colors.white,
                    size: 18),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _mobileVisitStats() {
    final p = _patient!;
    return Row(children: [
      Expanded(
          child: _statCard('${p.totalVisits}', 'Total Visits', _teal,
              Icons.history_rounded)),
      const SizedBox(width: 10),
      Expanded(
          child: _statCard(
              '${p.visitsToday}', 'Today', _green, Icons.today_rounded)),
    ]);
  }

  Widget _statCard(String val, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ]),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(val,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color)),
          Text(label,
              style:
              TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
        ]),
      ]),
    );
  }

  Widget _mobileHistorySection() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFFF7FAFC),
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(14)),
            border: Border(bottom: BorderSide(color: _border)),
          ),
          child: Row(children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: _tealLight,
                  borderRadius: BorderRadius.circular(7)),
              child: const Icon(Icons.history_rounded,
                  color: _teal, size: 14),
            ),
            const SizedBox(width: 8),
            const Text('Visit History',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _textDark)),
          ]),
        ),
        _HistoryContent(patient: _patient),
      ]),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: _tealLight,
                borderRadius: BorderRadius.circular(20)),
            child:
            const Icon(Icons.badge_outlined, color: _teal, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('Enter an MR Number',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textDark)),
          const SizedBox(height: 6),
          Text('Type a patient MR number above and press Enter',
              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ]),
      ),
    );
  }

  Widget _iconBtn(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: const Color(0xFFF4F7FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _border)),
        child: Icon(icon, size: 17, color: _textMid),
      ),
    );
  }

  void _openSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SearchSheet(
        searchCtrl: _searchCtrl,
        results: _searchResults,
        isSearching: _isSearching,
        onChanged: (q) {
          setState(() {});
          _onSearchChanged(q);
        },
        onSelect: _selectFromSearch,
        onClear: () {
          _searchCtrl.clear();
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH RESULTS LIST
// ─────────────────────────────────────────────────────────────────────────────
class _SearchResultsList extends StatelessWidget {
  final bool isSearching;
  final List<PatientModel> results;
  final String query;
  final Function(PatientModel) onSelect;

  const _SearchResultsList({
    required this.isSearching,
    required this.results,
    required this.query,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return const Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: _teal));
    }
    if (query.isEmpty) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.manage_search_rounded,
              size: 38, color: Color(0xFFCBD5E0)),
          SizedBox(height: 8),
          Text('Search for a patient',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _textLight)),
          SizedBox(height: 2),
          Text('Results appear as you type',
              style: TextStyle(fontSize: 10, color: Color(0xFFA0AEC0))),
        ]),
      );
    }
    if (results.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.search_off_rounded,
              size: 38, color: Color(0xFFCBD5E0)),
          const SizedBox(height: 8),
          const Text('No patients found',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _textLight)),
          const SizedBox(height: 2),
          Text('Try a different name or phone',
              style: TextStyle(fontSize: 10, color: Colors.grey[400])),
        ]),
      );
    }
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) =>
      const Divider(height: 1, color: Color(0xFFF0F0F0)),
      itemBuilder: (_, i) {
        final p = results[i];
        return InkWell(
          onTap: () => onSelect(p),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: _teal.withOpacity(0.1),
                child: Text(
                  '${p.firstName.isNotEmpty ? p.firstName[0] : ''}${p.lastName.isNotEmpty ? p.lastName[0] : ''}'
                      .toUpperCase(),
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _teal),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${p.firstName} ${p.lastName}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _textDark)),
                      const SizedBox(height: 2),
                      Row(children: [
                        Text('MR# ${p.mrNumber}',
                            style: const TextStyle(
                                fontSize: 10,
                                color: _textLight,
                                fontFamily: 'monospace')),
                        const Text(' · ',
                            style: TextStyle(color: Color(0xFFCBD5E0))),
                        Text(p.phoneNumber,
                            style: const TextStyle(
                                fontSize: 10, color: _textLight)),
                      ]),
                    ]),
              ),
              Text(
                  '${p.age ?? '—'}y · ${p.gender.isNotEmpty ? p.gender[0] : '—'}',
                  style: const TextStyle(fontSize: 10, color: _textLight)),
            ]),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _SearchSheet extends StatefulWidget {
  final TextEditingController searchCtrl;
  final List<PatientModel> results;
  final bool isSearching;
  final Function(String) onChanged;
  final Function(PatientModel) onSelect;
  final VoidCallback onClear;

  const _SearchSheet({
    required this.searchCtrl,
    required this.results,
    required this.isSearching,
    required this.onChanged,
    required this.onSelect,
    required this.onClear,
  });

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
            color: _card,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: _border,
                    borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: _tealLight,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.search_rounded,
                    color: _teal, size: 16),
              ),
              const SizedBox(width: 10),
              const Text('Search Patients',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textDark)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(7)),
                  child: const Icon(Icons.close_rounded,
                      size: 15, color: _textMid),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: widget.searchCtrl,
              autofocus: true,
              onChanged: (q) {
                setState(() {});
                widget.onChanged(q);
              },
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Name, phone number...',
                hintStyle: const TextStyle(
                    color: Color(0xFFBDBDBD), fontSize: 12),
                prefixIcon: const Icon(Icons.search,
                    size: 16, color: Color(0xFFBDBDBD)),
                suffixIcon: widget.searchCtrl.text.isNotEmpty
                    ? GestureDetector(
                  onTap: () {
                    widget.onClear();
                    setState(() {});
                  },
                  child: const Icon(Icons.close,
                      size: 15, color: Color(0xFFBDBDBD)),
                )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 11),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _border)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _border)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    const BorderSide(color: _teal, width: 1.5)),
                filled: true,
                fillColor: const Color(0xFFF7FAFC),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Type at least 2 characters',
                  style: TextStyle(
                      fontSize: 10, color: Color(0xFFBDBDBD))),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: _border),
          Expanded(
            child: _SearchResultsList(
              isSearching: widget.isSearching,
              results: widget.results,
              query: widget.searchCtrl.text,
              onSelect: widget.onSelect,
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HISTORY CONTENT
// ─────────────────────────────────────────────────────────────────────────────
class _HistoryContent extends StatelessWidget {
  final PatientModel? patient;
  const _HistoryContent({this.patient});

  @override
  Widget build(BuildContext context) {
    if (patient == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.description_outlined,
                size: 40, color: Color(0xFFCBD5E0)),
            SizedBox(height: 8),
            Text('No patient selected',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textLight)),
            SizedBox(height: 3),
            Text('Look up a patient to see visits',
                style: TextStyle(fontSize: 10, color: Color(0xFFA0AEC0))),
          ]),
        ),
      );
    }
    final visits = patient!.visitHistory;
    if (visits == null || visits.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.description_outlined,
                size: 40, color: Color(0xFFCBD5E0)),
            SizedBox(height: 8),
            Text('No visit history',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _textLight)),
            SizedBox(height: 3),
            Text('No visits found for this patient',
                style: TextStyle(fontSize: 10, color: Color(0xFFA0AEC0))),
          ]),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(14),
      itemCount: visits.length,
      itemBuilder: (_, i) {
        final v = visits[i];
        final isLast = i == visits.length - 1;
        return IntrinsicHeight(
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 18,
                  child: Column(children: [
                    Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                          color: _teal,
                          shape: BoxShape.circle,
                          border:
                          Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: _teal.withOpacity(0.3),
                                blurRadius: 4)
                          ]),
                    ),
                    if (!isLast)
                      Expanded(
                          child: Container(
                              width: 1.5,
                              color: const Color(0xFFE2E8F0))),
                  ]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF7FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _border)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 10, color: _textLight),
                            const SizedBox(width: 3),
                            Text(v.date ?? '',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: _textLight,
                                    fontWeight: FontWeight.w500)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                  color: _teal.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(v.time ?? '',
                                  style: const TextStyle(
                                      fontSize: 9,
                                      color: _teal,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ]),
                          const SizedBox(height: 4),
                          Text(v.opdService ?? 'Consultation',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark)),
                          if (v.serviceDetail != null &&
                              v.serviceDetail!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(v.serviceDetail!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 10, color: _textLight)),
                          ],
                          const SizedBox(height: 6),
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(v.receiptId ?? '',
                                    style: const TextStyle(
                                        fontSize: 9,
                                        color: Color(0xFFA0AEC0),
                                        fontFamily: 'monospace')),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                      color: _green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: _green.withOpacity(0.3))),
                                  child: Text(
                                      'PKR ${v.totalAmount ?? v.paid ?? 0}',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF276749))),
                                ),
                              ]),
                        ]),
                  ),
                ),
              ]),
        );
      },
    );
  }
}