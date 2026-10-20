import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import '../widgets/common.dart';

/// Add a new employee, or edit an existing one when [employee] is given.
class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key, this.employee});
  final Employee? employee;

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _role;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _salary;
  String _department = 'IT Department';
  EmployeeStatus _status = EmployeeStatus.active;
  DateTime? _joiningDate;

  bool get _isEdit => widget.employee != null;

  static const departments = [
    'IT Department',
    'Design Department',
    'Marketing Department',
    'HR Department',
    'Finance Department',
    'Operations Department',
    'Sales Department',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.employee;
    _name = TextEditingController(text: e?.name ?? '');
    _role = TextEditingController(text: e?.role ?? '');
    _email = TextEditingController(text: e?.email ?? '');
    _phone = TextEditingController(text: e?.phone ?? '');
    _salary = TextEditingController(
        text: e == null || e.salary == 0 ? '' : e.salary.toStringAsFixed(0));
    if (e != null) {
      _department =
          departments.contains(e.department) ? e.department : departments.first;
      _status = e.status;
      _joiningDate = e.joiningDate;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _email.dispose();
    _phone.dispose();
    _salary.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_isEdit) {
      final e = widget.employee!;
      e.name = _name.text.trim();
      e.role = _role.text.trim();
      e.department = _department;
      e.email = _email.text.trim();
      e.phone = _phone.text.trim();
      e.salary = double.tryParse(_salary.text.trim()) ?? 0;
      e.status = _status;
      e.joiningDate = _joiningDate;
      appState.updateEmployee(e);
    } else {
      appState.addEmployee(
        Employee(
          id: 'e${DateTime.now().millisecondsSinceEpoch}',
          name: _name.text.trim(),
          role: _role.text.trim(),
          department: _department,
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          salary: double.tryParse(_salary.text.trim()) ?? 0,
          joiningDate: _joiningDate,
          status: _status,
        ),
      );
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isEdit ? 'Edit Employee' : 'Add Employee'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Avatar(
                          name: _name.text.isEmpty ? 'New' : _name.text,
                          size: 74)),
                  const SizedBox(height: 20),
                  _label('Full Name'),
                  TextFormField(
                    controller: _name,
                    onChanged: (_) => setState(() {}),
                    decoration:
                        const InputDecoration(hintText: 'e.g. Ahmed Hassan'),
                    validator: (v) => (v == null || v.trim().length < 3)
                        ? 'Enter a valid name'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _label('Job Title'),
                  TextFormField(
                    controller: _role,
                    decoration: const InputDecoration(
                        hintText: 'e.g. Software Engineer'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter the job title'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _label('Department'),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _department,
                    items: departments
                        .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                        .toList(),
                    onChanged: (v) => setState(() => _department = v!),
                  ),
                  const SizedBox(height: 14),
                  _label('Email'),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                        const InputDecoration(hintText: 'name@company.com'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      if (!v.contains('@') || !v.contains('.')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _label('Phone'),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: '+880 ...'),
                  ),
                  const SizedBox(height: 14),
                  _label('Monthly Salary (${appState.currency})'),
                  TextFormField(
                    controller: _salary,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 30000'),
                  ),
                  const SizedBox(height: 14),
                  _label('Joining Date'),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _joiningDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _joiningDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE8EDF7)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              size: 18, color: Color(0xFF8A94A6)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _joiningDate == null
                                  ? 'Select joining date (optional)'
                                  : fmtDate(_joiningDate!),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _label('Status'),
                  DropdownButtonFormField<EmployeeStatus>(
                    isExpanded: true,
                    value: _status,
                    items: EmployeeStatus.values
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s.label)))
                        .toList(),
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(_isEdit ? 'Save Changes' : 'Add Employee'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Text(t,
            style:
                const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
      );
}
