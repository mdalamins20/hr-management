import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'add_employee_screen.dart';

/// Payroll - fully computed from real data:
/// basic salary (employee record / your Settings salary) + approved
/// overtime pay for the month + your allowances/deductions.
/// "Generate Payslip" saves a snapshot into Recent Payrolls.
class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  String? _subject; // null = me
  late int _month = DateTime.now().month;
  late int _year = DateTime.now().year;
  final _allowances = TextEditingController();
  final _deductions = TextEditingController();
  String _loadedKey = '';

  @override
  void dispose() {
    _allowances.dispose();
    _deductions.dispose();
    super.dispose();
  }

  String get _subjectName => _subject ?? appState.managerName;
  String get _monthKey => monthKeyOf(_year, _month);
  String get _monthLabel => '${monthNamesLong[_month - 1]} $_year';

  double get _basic {
    if (_subject == null) return appState.managerSalary;
    final e = appState.employees
        .where((e) => e.name == _subject)
        .cast<Employee?>()
        .firstWhere((e) => true, orElse: () => null);
    return e?.salary ?? 0;
  }

  void _syncFields() {
    final key = '$_subjectName|$_monthKey';
    if (key != _loadedKey) {
      _loadedKey = key;
      final adj = appState.payrollAdjustment(_subjectName, _monthKey);
      _allowances.text = adj[0] == 0 ? '' : adj[0].toStringAsFixed(0);
      _deductions.text = adj[1] == 0 ? '' : adj[1].toStringAsFixed(0);
    }
  }

  void _shift(int delta) {
    setState(() {
      _month += delta;
      if (_month > 12) {
        _month = 1;
        _year++;
      }
      if (_month < 1) {
        _month = 12;
        _year--;
      }
    });
  }

  void _saveAdjustments() {
    appState.savePayrollAdjustment(
      _subjectName,
      _monthKey,
      double.tryParse(_allowances.text.trim()) ?? 0,
      double.tryParse(_deductions.text.trim()) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final s = appState;
        _syncFields();
        final overtimePay = s.approvedOvertimePay(_subjectName, _year, _month);
        final overtimeHours =
            s.approvedOvertimeHours(_subjectName, _year, _month);
        final allowances = double.tryParse(_allowances.text.trim()) ?? 0;
        final deductions = double.tryParse(_deductions.text.trim()) ?? 0;
        final net = _basic + allowances + overtimePay - deductions;

        final body = SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject selector
                  DropdownButtonFormField<String?>(
                    isExpanded: true,
                    value: _subject,
                    decoration: const InputDecoration(labelText: 'Employee'),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Me (${s.managerName})'),
                      ),
                      ...s.employees.map(
                        (e) => DropdownMenuItem<String?>(
                          value: e.name,
                          child: Text(e.name),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _subject = v),
                  ),
                  const SizedBox(height: 10),
                  // Month selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => _shift(-1),
                        icon: const Icon(Icons.chevron_left,
                            color: AppColors.textGrey),
                      ),
                      Text(
                        _monthLabel,
                        style: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        onPressed: () => _shift(1),
                        icon: const Icon(Icons.chevron_right,
                            color: AppColors.textGrey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Total salary card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.lavenderBg,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.account_balance_wallet,
                              color: Colors.white, size: 23),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Net Salary',
                                  style: TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 12.5)),
                              Text(
                                money(net),
                                style: const TextStyle(
                                    fontSize: 21, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                _basic == 0
                                    ? 'Set a salary first (Employees / Settings)'
                                    : 'For $_subjectName • $_monthLabel',
                                style: const TextStyle(
                                    color: AppColors.textGrey, fontSize: 11.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _salaryRow(Icons.account_balance_wallet_outlined,
                      'Basic Salary', _basic),
                  _salaryRow(
                    Icons.access_time,
                    'Overtime (${overtimeHours % 1 == 0 ? overtimeHours.toInt() : overtimeHours}h approved)',
                    overtimePay,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _allowances,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Allowances'),
                          onChanged: (_) => setState(() {}),
                          onEditingComplete: _saveAdjustments,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _deductions,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Deductions'),
                          onChanged: (_) => setState(() {}),
                          onEditingComplete: _saveAdjustments,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        _saveAdjustments();
                        showSnack(context, 'Allowances/deductions saved');
                      },
                      icon: const Icon(Icons.save_outlined, size: 17),
                      label: const Text('Save Amounts'),
                    ),
                  ),
                  const Divider(height: 20, color: AppColors.border),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Net Salary',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800)),
                      ),
                      Text(
                        money(net),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _saveAdjustments();
                        final record = PayrollRecord(
                          id: 'p${DateTime.now().millisecondsSinceEpoch}',
                          subjectName: _subjectName,
                          monthLabel: _monthLabel,
                          monthKey: _monthKey,
                          dateLabel: fmtDate(DateTime.now()),
                          basic: _basic,
                          allowances: allowances,
                          overtimePay: overtimePay,
                          deductions: deductions,
                        );
                        s.addPayrollRecord(record);
                        showSnack(
                            context, 'Payslip generated for $_subjectName');
                        _showPayslip(context, record);
                      },
                      icon: const Icon(Icons.description_outlined, size: 19),
                      label: const Text('Generate Payslip'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'Recent Payrolls'),
                  const SizedBox(height: 12),
                  if (s.payrollHistory.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'No payslips yet. Generate the first one above.',
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                    )
                  else
                    ...s.payrollHistory.map((p) => _historyTile(context, p)),
                  if (s.employees.isEmpty && _subject == null) ...[
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const AddEmployeeScreen()),
                        );
                      },
                      icon: const Icon(Icons.person_add_alt_1, size: 17),
                      label: const Text('Add your first employee'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );

        if (widget.embedded) return body;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Payroll'),
          ),
          body: body,
        );
      },
    );
  }

  Widget _historyTile(BuildContext context, PayrollRecord p) {
    return GestureDetector(
      onTap: () => _showPayslip(context, p),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: cardDecoration(radius: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.lavenderBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.receipt_long_outlined,
                  color: AppColors.primary, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${p.subjectName} • ${p.monthLabel}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5)),
                  Text('Generated ${p.dateLabel}',
                      style: const TextStyle(
                          color: AppColors.textGrey, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(money(p.net),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                StatusChip(
                  label: p.paid ? 'Paid' : 'Unpaid',
                  color: p.paid ? AppColors.green : AppColors.orange,
                  bg: p.paid ? AppColors.greenBg : AppColors.orangeBg,
                ),
              ],
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert,
                  color: AppColors.textGrey, size: 19),
              onSelected: (v) {
                if (v == 'toggle') {
                  appState.setPayrollPaid(p, !p.paid);
                } else if (v == 'delete') {
                  appState.removePayrollRecord(p);
                  showSnack(context, 'Payslip deleted');
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(p.paid ? 'Mark Unpaid' : 'Mark Paid'),
                ),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _salaryRow(IconData icon, String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textGrey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13.5)),
          ),
          Text(money(amount),
              style:
                  const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showPayslip(BuildContext context, PayrollRecord p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Payslip - ${p.monthLabel}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text(
              '${appState.companyName} • ${p.subjectName}',
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12.5),
            ),
            const SizedBox(height: 16),
            _slipRow('Basic Salary', p.basic),
            _slipRow('Allowances', p.allowances),
            _slipRow('Overtime', p.overtimePay),
            _slipRow('Deductions', -p.deductions),
            const Divider(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text('Net Salary',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
                Text(money(p.net),
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _slipRow(String label, double amount) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(
          children: [
            Expanded(
                child: Text(label, style: const TextStyle(fontSize: 13.5))),
            Text(
              '${amount < 0 ? '-' : ''}${money(amount.abs())}',
              style:
                  const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
}
