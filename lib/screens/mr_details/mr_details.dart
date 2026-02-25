import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../custum widgets/drawer/base_scaffold.dart';
import '../../providers/mr_provider/mr_provider.dart';

class MrDetailsScreen extends StatelessWidget {
  const MrDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'MR Details',
      drawerIndex: 8,
      actions: [
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: Colors.white, size: 15),
                SizedBox(width: 4),
                Text(
                  'New Patient',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      body: const _MrDetailsBody(),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _MrDetailsBody extends StatefulWidget {
  const _MrDetailsBody();

  @override
  State<_MrDetailsBody> createState() => _MrDetailsBodyState();
}

class _MrDetailsBodyState extends State<_MrDetailsBody> {
  final _formKey = GlobalKey<FormState>();
  final _mrFocusNode = FocusNode();

  final _mrNumberCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _guardianCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _professionCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  String _relation = 'Parent';
  String _gender = 'Male';
  String _bloodGroup = '';
  DateTime? _dob;
  bool _isExistingPatient = false;

  final List<String> _relations = ['Parent', 'Spouse', 'Sibling', 'Child', 'Other'];
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    // Trigger lookup when MR field loses focus
    _mrFocusNode.addListener(() {
      if (!_mrFocusNode.hasFocus) {
        _lookupMrNumber(_mrNumberCtrl.text);
      }
    });
  }

  @override
  void dispose() {
    _mrFocusNode.dispose();
    _mrNumberCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _guardianCtrl.dispose();
    _ageCtrl.dispose();
    _professionCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _cnicCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  // ── Called on Enter key OR focus lost ─────────────────────────────────────
  void _lookupMrNumber(String value) {
    final input = value.trim();

    // If field is empty, just reset
    if (input.isEmpty) {
      if (_isExistingPatient) {
        _clearFields();
        context.read<MrProvider>().selectPatient(null);
        setState(() => _isExistingPatient = false);
      }
      return;
    }

    final provider = context.read<MrProvider>();
    final patient = provider.findByMrNumber(input);

    if (patient != null) {
      // Found — fill the form and show padded MR in the field
      _mrNumberCtrl.text = patient.mrNumber;
      _mrNumberCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: patient.mrNumber.length),
      );
      _fillForm(patient);
      provider.selectPatient(patient);
      setState(() => _isExistingPatient = true);
    } else {
      // Not found — clear any previous autofill, let user fill new patient
      if (_isExistingPatient) {
        _clearFields();
        provider.selectPatient(null);
        setState(() => _isExistingPatient = false);
      }
    }
  }

  void _fillForm(PatientModel p) {
    _firstNameCtrl.text = p.firstName;
    _lastNameCtrl.text = p.lastName;
    _guardianCtrl.text = p.guardianName;
    _ageCtrl.text = p.age?.toString() ?? '';
    _professionCtrl.text = p.profession;
    _phoneCtrl.text = p.phoneNumber;
    _emailCtrl.text = p.email;
    _cnicCtrl.text = p.cnic;
    _addressCtrl.text = p.address;
    _cityCtrl.text = p.city;
    setState(() {
      _relation = _relations.contains(p.relation) ? p.relation : 'Parent';
      _gender = _genders.contains(p.gender) ? p.gender : 'Male';
      _bloodGroup = _bloodGroups.contains(p.bloodGroup) ? p.bloodGroup : '';
    });
  }

  void _clearFields() {
    _firstNameCtrl.clear();
    _lastNameCtrl.clear();
    _guardianCtrl.clear();
    _ageCtrl.clear();
    _professionCtrl.clear();
    _phoneCtrl.clear();
    _emailCtrl.clear();
    _cnicCtrl.clear();
    _addressCtrl.clear();
    _cityCtrl.clear();
    setState(() {
      _relation = 'Parent';
      _gender = 'Male';
      _bloodGroup = '';
      _dob = null;
    });
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _mrNumberCtrl.clear();
    _clearFields();
    context.read<MrProvider>().selectPatient(null);
    setState(() => _isExistingPatient = false);
  }

  void _onRegisterTapped() {
    if (!_formKey.currentState!.validate()) return;

    if (_isExistingPatient) {
      _showSnack('Patient already registered. Info loaded.', isInfo: true);
      return;
    }

    final provider = context.read<MrProvider>();
    final patient = provider.registerPatient(
      mrNumber: _mrNumberCtrl.text,
      firstName: _firstNameCtrl.text,
      lastName: _lastNameCtrl.text,
      guardianName: _guardianCtrl.text,
      relation: _relation,
      gender: _gender,
      dateOfBirth: _dob != null
          ? '${_dob!.day.toString().padLeft(2, '0')}/'
          '${_dob!.month.toString().padLeft(2, '0')}/'
          '${_dob!.year}'
          : '',
      age: int.tryParse(_ageCtrl.text),
      bloodGroup: _bloodGroup,
      profession: _professionCtrl.text,
      phoneNumber: _phoneCtrl.text,
      email: _emailCtrl.text,
      cnic: _cnicCtrl.text,
      address: _addressCtrl.text,
      city: _cityCtrl.text,
    );

    // Show the assigned MR number back in the field
    _mrNumberCtrl.text = patient.mrNumber;
    setState(() => _isExistingPatient = true);
    _showSnack('Patient registered! MR: ${patient.mrNumber}');
  }

  void _showSnack(String msg, {bool isInfo = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isInfo ? Icons.info_outline : Icons.check_circle,
                color: Colors.white),
            const SizedBox(width: 10),
            Flexible(child: Text(msg)),
          ],
        ),
        backgroundColor:
        isInfo ? const Color(0xFF718096) : const Color(0xFF00B5AD),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isWide = screenW > 820;
    final padding = screenW < 400 ? 10.0 : 16.0;

    return Container(
      color: const Color(0xFFF0F4F8),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(),
            SizedBox(height: isWide ? 16 : 12),
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildFormCard(screenW)),
                  const SizedBox(width: 14),
                  SizedBox(width: 260, child: _buildSidebar()),
                ],
              )
            else
              Column(
                children: [
                  _buildFormCard(screenW),
                  const SizedBox(height: 14),
                  _buildSidebar(),
                ],
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MR Details',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C))),
        const SizedBox(height: 2),
        Text('Patient Master Index & Medical Record',
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  // ── Form card ──────────────────────────────────────────────────────────────
  Widget _buildFormCard(double screenW) {
    final isSmall = screenW < 520;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: const Border(
            left: BorderSide(color: Color(0xFF00B5AD), width: 4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormHeader(),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── MR Number with search button ────────────────────────
                  _buildMrNumberField(),
                  const SizedBox(height: 14),

                  // ── First + Last Name ───────────────────────────────────
                  _row2(
                    isSmall: isSmall,
                    left: _textField(
                      ctrl: _firstNameCtrl,
                      label: 'First Name',
                      required: true,
                      icon: Icons.person_outline,
                      readOnly: _isExistingPatient,
                      validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    right: _textField(
                      ctrl: _lastNameCtrl,
                      label: 'Last Name',
                      icon: Icons.person_outline,
                      readOnly: _isExistingPatient,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Guardian + Relation ─────────────────────────────────
                  _row2(
                    isSmall: isSmall,
                    leftFlex: 2,
                    left: _textField(
                      ctrl: _guardianCtrl,
                      label: 'Guardian Name (Father/Husband)',
                      icon: Icons.people_outline,
                      readOnly: _isExistingPatient,
                    ),
                    right: _dropdown(
                      label: 'Relation',
                      value: _relation,
                      items: _relations,
                      enabled: !_isExistingPatient,
                      onChanged: (v) => setState(() => _relation = v!),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Gender + DOB + Age + Blood Group ────────────────────
                  isSmall
                      ? Column(children: [
                    _row2(
                      isSmall: false,
                      left: _dropdown(
                        label: 'Gender',
                        value: _gender,
                        items: _genders,
                        required: true,
                        enabled: !_isExistingPatient,
                        onChanged: (v) =>
                            setState(() => _gender = v!),
                      ),
                      right: _dateField(),
                    ),
                    const SizedBox(height: 14),
                    _row2(
                      isSmall: false,
                      left: _textField(
                        ctrl: _ageCtrl,
                        label: 'Age',
                        keyboardType: TextInputType.number,
                        readOnly: _isExistingPatient,
                      ),
                      right: _dropdown(
                        label: 'Blood Group',
                        value: _bloodGroup.isEmpty ? null : _bloodGroup,
                        items: _bloodGroups,
                        hint: 'Select...',
                        enabled: !_isExistingPatient,
                        onChanged: (v) =>
                            setState(() => _bloodGroup = v ?? ''),
                      ),
                    ),
                  ])
                      : Row(children: [
                    Expanded(
                        child: _dropdown(
                          label: 'Gender',
                          value: _gender,
                          items: _genders,
                          required: true,
                          enabled: !_isExistingPatient,
                          onChanged: (v) => setState(() => _gender = v!),
                        )),
                    const SizedBox(width: 12),
                    Expanded(child: _dateField()),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _textField(
                          ctrl: _ageCtrl,
                          label: 'Age',
                          keyboardType: TextInputType.number,
                          readOnly: _isExistingPatient,
                        )),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _dropdown(
                          label: 'Blood Group',
                          value: _bloodGroup.isEmpty ? null : _bloodGroup,
                          items: _bloodGroups,
                          hint: 'Select...',
                          enabled: !_isExistingPatient,
                          onChanged: (v) =>
                              setState(() => _bloodGroup = v ?? ''),
                        )),
                  ]),
                  const SizedBox(height: 14),

                  // ── Profession ──────────────────────────────────────────
                  _textField(
                    ctrl: _professionCtrl,
                    label: 'Profession',
                    icon: Icons.work_outline,
                    readOnly: _isExistingPatient,
                  ),
                  const SizedBox(height: 14),

                  // ── Phone + Email + CNIC ────────────────────────────────
                  isSmall
                      ? Column(children: [
                    _textField(
                      ctrl: _phoneCtrl,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      readOnly: _isExistingPatient,
                    ),
                    const SizedBox(height: 14),
                    _textField(
                      ctrl: _emailCtrl,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: _isExistingPatient,
                    ),
                    const SizedBox(height: 14),
                    _textField(
                      ctrl: _cnicCtrl,
                      label: 'CNIC',
                      icon: Icons.credit_card_outlined,
                      keyboardType: TextInputType.number,
                      readOnly: _isExistingPatient,
                    ),
                  ])
                      : Row(children: [
                    Expanded(
                        child: _textField(
                          ctrl: _phoneCtrl,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          readOnly: _isExistingPatient,
                        )),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _textField(
                          ctrl: _emailCtrl,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          readOnly: _isExistingPatient,
                        )),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _textField(
                          ctrl: _cnicCtrl,
                          label: 'CNIC',
                          icon: Icons.credit_card_outlined,
                          keyboardType: TextInputType.number,
                          readOnly: _isExistingPatient,
                        )),
                  ]),
                  const SizedBox(height: 14),

                  // ── Address + City ──────────────────────────────────────
                  _row2(
                    isSmall: isSmall,
                    leftFlex: 2,
                    left: _textField(
                      ctrl: _addressCtrl,
                      label: 'Address',
                      icon: Icons.location_on_outlined,
                      readOnly: _isExistingPatient,
                    ),
                    right: _textField(
                      ctrl: _cityCtrl,
                      label: 'City',
                      icon: Icons.location_city_outlined,
                      readOnly: _isExistingPatient,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Action Buttons ──────────────────────────────────────
                  isSmall
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _clearBtn(),
                      const SizedBox(height: 10),
                      _registerBtn(),
                    ],
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _clearBtn(),
                      const SizedBox(width: 12),
                      _registerBtn(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Form header ────────────────────────────────────────────────────────────
  Widget _buildFormHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF00B5AD).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_add_outlined,
                color: Color(0xFF00B5AD), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New Patient Registration',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1A202C))),
                const SizedBox(height: 2),
                Text(
                  'Type MR number and press Enter or tap 🔍 to search.',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                if (_isExistingPatient) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B5AD).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Color(0xFF00B5AD), size: 14),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Existing patient — info auto-filled',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF00B5AD),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── MR Number field (search on Enter / focus-lost / search button) ─────────
  Widget _buildMrNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MR Number',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00B5AD))),
        const SizedBox(height: 6),
        TextFormField(
          controller: _mrNumberCtrl,
          focusNode: _mrFocusNode,
          keyboardType: TextInputType.text,
          style: const TextStyle(fontSize: 14),
          // ── Trigger lookup on Enter / Done ─────────────────────────────
          onFieldSubmitted: (value) => _lookupMrNumber(value),
          // ── Reset existing state when user starts typing again ──────────
          onChanged: (value) {
            if (_isExistingPatient) {
              _clearFields();
              context.read<MrProvider>().selectPatient(null);
              setState(() => _isExistingPatient = false);
            }
          },
          decoration: InputDecoration(
            hintText: 'Enter MR No (e.g. 1, 2, 3) then press Enter or 🔍',
            hintStyle:
            const TextStyle(color: Color(0xFFBDBDBD), fontSize: 11),
            prefixIcon: const Icon(Icons.badge_outlined,
                color: Color(0xFFBDBDBD), size: 18),
            // Search icon button on the right
            suffixIcon: _isExistingPatient
                ? IconButton(
              icon: const Icon(Icons.check_circle,
                  color: Color(0xFF00B5AD), size: 20),
              onPressed: _clearForm,
              tooltip: 'Clear / New Patient',
            )
                : IconButton(
              icon: const Icon(Icons.search,
                  color: Color(0xFF00B5AD), size: 20),
              tooltip: 'Search patient',
              onPressed: () =>
                  _lookupMrNumber(_mrNumberCtrl.text),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: const Color(0xFF00B5AD).withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: _isExistingPatient
                      ? const Color(0xFF00B5AD)
                      : const Color(0xFF00B5AD).withOpacity(0.4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              const BorderSide(color: Color(0xFF00B5AD), width: 1.8),
            ),
            filled: true,
            fillColor: _isExistingPatient
                ? const Color(0xFF00B5AD).withOpacity(0.05)
                : Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        // Helper text
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            _isExistingPatient
                ? 'Patient found ✓  Tap ✓ icon to clear and register a new patient.'
                : 'Tip: type any number (1–5 for demo) then press Enter or tap the 🔍 icon.',
            style: TextStyle(
              fontSize: 10,
              color: _isExistingPatient
                  ? const Color(0xFF00B5AD)
                  : Colors.grey[500],
            ),
          ),
        ),
      ],
    );
  }

  // ── Sidebar ────────────────────────────────────────────────────────────────
  Widget _buildSidebar() {
    final patient = context.watch<MrProvider>().selectedPatient;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: _cardDeco(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Visit Summary',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1A202C))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _VisitStatCard(
                        value: patient?.totalVisits ?? 0,
                        label: 'Total Visits',
                        color: const Color(0xFF00B5AD)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _VisitStatCard(
                        value: patient?.visitsToday ?? 0,
                        label: 'Visits Today',
                        color: const Color(0xFF48BB78)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: _cardDeco(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                        color: const Color(0xFFE9D8FD),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.history_rounded,
                        color: Color(0xFF805AD5), size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Visit History',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF1A202C))),
                        Text('Recent OPD visits and consultations',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF718096))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.description_outlined,
                        size: 44, color: Color(0xFFCBD5E0)),
                    SizedBox(height: 10),
                    Text('No visit history',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF718096),
                            fontSize: 13)),
                    SizedBox(height: 4),
                    Text('No visits found for this patient.',
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFFA0AEC0))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDeco() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2))
    ],
  );

  Widget _clearBtn() => OutlinedButton.icon(
    onPressed: _clearForm,
    icon: const Icon(Icons.refresh_rounded, size: 15),
    label: const Text('Clear Form'),
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF718096),
      side: const BorderSide(color: Color(0xFFE2E8F0)),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      padding:
      const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
    ),
  );

  Widget _registerBtn() => ElevatedButton.icon(
    onPressed: _onRegisterTapped,
    icon: Icon(
        _isExistingPatient
            ? Icons.visibility_outlined
            : Icons.save_outlined,
        size: 15),
    label: Text(
      _isExistingPatient ? 'View Patient' : 'Register Patient',
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF00B5AD),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      padding:
      const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
    ),
  );

  // ── Two-col helper ─────────────────────────────────────────────────────────
  Widget _row2({
    required bool isSmall,
    required Widget left,
    required Widget right,
    int leftFlex = 1,
    int rightFlex = 1,
  }) {
    if (isSmall) {
      return Column(children: [left, const SizedBox(height: 14), right]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: leftFlex, child: left),
        const SizedBox(width: 12),
        Expanded(flex: rightFlex, child: right),
      ],
    );
  }

  // ── TextField ──────────────────────────────────────────────────────────────
  Widget _textField({
    required TextEditingController ctrl,
    required String label,
    IconData? icon,
    bool required = false,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A5568)),
            children: required
                ? const [
              TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFE53E3E)))
            ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          readOnly: readOnly,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, color: const Color(0xFFCBD5E0), size: 17)
                : null,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              const BorderSide(color: Color(0xFF00B5AD), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE53E3E)),
            ),
            filled: true,
            fillColor: readOnly ? const Color(0xFFF7FAFC) : Colors.white,
          ),
        ),
      ],
    );
  }

  // ── Dropdown ───────────────────────────────────────────────────────────────
  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    String hint = '',
    bool required = false,
    bool enabled = true,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A5568)),
            children: required
                ? const [
              TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFE53E3E)))
            ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        IgnorePointer(
          ignoring: !enabled,
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            hint: hint.isNotEmpty
                ? Text(hint,
                style: const TextStyle(
                    color: Color(0xFFBDBDBD), fontSize: 13))
                : null,
            style:
            const TextStyle(fontSize: 13, color: Color(0xFF1A202C)),
            decoration: InputDecoration(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                const BorderSide(color: Color(0xFF00B5AD), width: 1.5),
              ),
              filled: true,
              fillColor: !enabled ? const Color(0xFFF7FAFC) : Colors.white,
            ),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }

  // ── Date field ─────────────────────────────────────────────────────────────
  Widget _dateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date of Birth',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A5568))),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _isExistingPatient
              ? null
              : () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(
                      primary: Color(0xFF00B5AD)),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              setState(() {
                _dob = picked;
                _ageCtrl.text =
                    (DateTime.now().year - picked.year).toString();
              });
            }
          },
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              color: _isExistingPatient
                  ? const Color(0xFFF7FAFC)
                  : Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _dob != null
                        ? '${_dob!.month.toString().padLeft(2, '0')}/'
                        '${_dob!.day.toString().padLeft(2, '0')}/'
                        '${_dob!.year}'
                        : 'mm/dd/yyyy',
                    style: TextStyle(
                      fontSize: 13,
                      color: _dob != null
                          ? const Color(0xFF1A202C)
                          : const Color(0xFFBDBDBD),
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today_outlined,
                    size: 15, color: Color(0xFFCBD5E0)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Visit Stat Card ──────────────────────────────────────────────────────────
class _VisitStatCard extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _VisitStatCard(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value.toString(),
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style:
              TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }
}