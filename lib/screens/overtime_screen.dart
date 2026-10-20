import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Overtime: my/team tabs, live stats from real entries only.
class OvertimeScreen extends StatefulWidget {
  const OvertimeScreen({super.key});

  @override
  State<OvertimeScreen> createState() => _OvertimeScreenState();
}

class _OvertimeScreenState extends State<OvertimeScreen> {
  int _tab = 0;

  String _h(double v) => v % 1 == 0 ? '${v.toInt()}h' : '${v}h';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final s = appState;
        final list = s.overtimeEntries
            .where((o) => o.isMine == (_tab == 0))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Overtime'),
            actions: [
              IconButton(
                onPressed: () async {
                  final done = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                        builder: (_) => const OvertimeFormScreen()),
                  );
                  if (done == true && context.mounted) {
                    setState(() => _tab = 0);
                    showSnack(context, 'Overtime request added');
                  }
                },
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.textDark),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      _tabButton('My Overtime', 0),
                      const SizedBox(width: 26),
                      _tabButton('Team Overtime', 1),
                    ],
                  ),
                ),
              ),
              const Divider(height: 22, thickness: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    MiniStat(
                      label: 'Total Hours',
                      value: _h(s.myTotalOvertimeHours),
                      dotColor: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    MiniStat(
                      label: 'This Month',
                      value: _h(s.myMonthOvertimeHours(
                          DateTime.now().year, DateTime.now().month)),
                      dotColor: AppColors.green,
                    ),
                    const SizedBox(width: 10),
                    MiniStat(
                      label: 'Pending',
                      value: _h(s.myPendingOvertimeHours),
                      dotColor: AppColors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: list.isEmpty
                    ? const Center(
                        child: Text('No overtime records',
                            style: TextStyle(color: AppColors.textGrey)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
                        itemCount: list.length,
                        itemBuilder: (context, i) => _OvertimeTile(
                          entry: list[i],
                          teamView: _tab == 1,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tabButton(String label, int index) {
    final selected = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.primary : AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            height: 2.4,
            width: label.length * 7.6,
            color: selected ? AppColors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _OvertimeTile extends StatelessWidget {
  const _OvertimeTile({required this.entry, required this.teamView});
  final OvertimeEntry entry;
  final bool teamView;

  @override
  Widget build(BuildContext context) {
    final hoursLabel = entry.hours % 1 == 0
        ? '${entry.hours.toInt()} hours'
        : '${entry.hours} hours';
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: cardDecoration(radius: 15),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.lavenderBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.access_time,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teamView
                          ? '${fmtDate(entry.date)} • ${entry.employeeName}'
                          : fmtDate(entry.date),
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(hoursLabel,
                        style: const TextStyle(
                            color: AppColors.textGrey, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(
                    label: entry.status.label,
                    color: entry.status.color,
                    bg: entry.status.bgColor,
                  ),
                  const SizedBox(height: 4),
                  Text(money(entry.amount),
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w600)),
                ],
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.textGrey, size: 19),
            ],
          ),
          if (teamView && entry.status == OvertimeStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      appState.setOvertimeStatus(
                          entry, OvertimeStatus.rejected);
                      showSnack(context, 'Overtime rejected');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                      side: const BorderSide(color: AppColors.red),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      appState.setOvertimeStatus(
                          entry, OvertimeStatus.approved);
                      showSnack(context, 'Overtime approved');
                    },
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Functional add-overtime form.
class OvertimeFormScreen extends StatefulWidget {
  const OvertimeFormScreen({super.key});

  @override
  State<OvertimeFormScreen> createState() => _OvertimeFormScreenState();
}

class _OvertimeFormScreenState extends State<OvertimeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();
  String? _forName; // null = me
  late DateTime _date = DateTime.now();
  double _hours = 2;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final isMine = _forName == null;
    appState.addOvertime(
      OvertimeEntry(
        id: 'o${DateTime.now().millisecondsSinceEpoch}',
        employeeName: isMine ? appState.managerName : _forName!,
        date: _date,
        hours: _hours,
        reason: _reason.text.trim(),
        ratePerHour: appState.overtimeRatePerHour,
        status: OvertimeStatus.pending,
        isMine: isMine,
      ),
    );
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
        title: const Text('Add Overtime'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('For',
                  style:
                      TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 7),
              DropdownButtonFormField<String?>(
                isExpanded: true,
                value: _forName,
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Me (${appState.managerName})'),
                  ),
                  ...appState.employees.map(
                    (e) => DropdownMenuItem<String?>(
                      value: e.name,
                      child: Text('${e.name} (Employee)'),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _forName = v),
              ),
              const SizedBox(height: 16),
              const Text('Date',
                  style:
                      TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 7),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined,
                          size: 18, color: AppColors.textGrey),
                      const SizedBox(width: 8),
                      Text(fmtDate(_date)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Hours: ${_hours % 1 == 0 ? _hours.toInt() : _hours}',
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w600)),
              Slider(
                value: _hours,
                min: 1,
                max: 8,
                divisions: 14,
                activeColor: AppColors.primary,
                label: '${_hours}h',
                onChanged: (v) => setState(() => _hours = v),
              ),
              Text(
                'Estimated pay: ${money(_hours * appState.overtimeRatePerHour)} (${money(appState.overtimeRatePerHour)}/hour)',
                style: const TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              const Text('Reason',
                  style:
                      TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 7),
              TextFormField(
                controller: _reason,
                maxLines: 3,
                decoration:
                    const InputDecoration(hintText: 'Why was overtime needed?'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a reason' : null,
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit Overtime'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
