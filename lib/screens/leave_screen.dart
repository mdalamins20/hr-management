import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Screen 5 of the reference design: Leave Requests.
class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  int _tab = 0; // 0 = My Requests, 1 = Team Requests

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final s = appState;
        final list =
            s.leaveRequests.where((r) => r.isMine == (_tab == 0)).toList();
        // Real balances: allowance (Settings) minus approved days used.
        final annual = s.annualLeaveAllowance - s.annualLeaveUsed;
        final sick = s.sickLeaveAllowance - s.sickLeaveUsed;
        final unpaid = s.unpaidLeaveUsed;

        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Leave Requests',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final done = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                  builder: (_) => const LeaveFormScreen()),
                            );
                            if (done == true && context.mounted) {
                              setState(() => _tab = 0);
                              showSnack(context, 'Leave request submitted');
                            }
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: cardShadow,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(Icons.add,
                                color: AppColors.primary, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          _tabButton('My Requests', 0),
                          const SizedBox(width: 26),
                          _tabButton('Team Requests', 1),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                      height: 22, thickness: 1, color: AppColors.border),
                  // Balance cards (remaining days; Unpaid shows days used)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _balanceCard(Icons.wb_sunny_outlined, AppColors.orange,
                            'Annual Left', '$annual days'),
                        const SizedBox(width: 10),
                        _balanceCard(Icons.add_circle_outline,
                            AppColors.primary, 'Sick Left', '$sick days'),
                        const SizedBox(width: 10),
                        _balanceCard(Icons.schedule, AppColors.red,
                            'Unpaid Used', '$unpaid days'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: list.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                _tab == 0
                                    ? 'No leave requests yet. Tap + to create your first request.'
                                    : 'No team requests yet. Use + and choose an employee in the "For" field to add one on their behalf.',
                                textAlign: TextAlign.center,
                                style:
                                    const TextStyle(color: AppColors.textGrey),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
                            itemCount: list.length,
                            itemBuilder: (context, i) => _LeaveTile(
                                request: list[i], teamView: _tab == 1),
                          ),
                  ),
                ],
              ),
            ),
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

  Widget _balanceCard(IconData icon, Color color, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        decoration: cardDecoration(radius: 14),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 17),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.textGrey, fontSize: 11)),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaveTile extends StatelessWidget {
  const _LeaveTile({required this.request, required this.teamView});
  final LeaveRequest request;
  final bool teamView;

  @override
  Widget build(BuildContext context) {
    final range = request.start.month == request.end.month &&
            request.start.day == request.end.day
        ? fmtDate(request.start)
        : '${fmtDate(request.start)} - ${fmtDate(request.end)}';
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
                decoration: BoxDecoration(
                  color: request.iconBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(request.icon, color: request.iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teamView
                          ? '${request.type} • ${request.employeeName}'
                          : request.type,
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(range,
                        style: const TextStyle(
                            color: AppColors.textGrey, fontSize: 12)),
                    Text(
                      request.days == 1 ? '1 day' : '${request.days} days',
                      style: const TextStyle(
                          color: AppColors.textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: request.status.label,
                color: request.status.color,
                bg: request.status.bgColor,
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.textGrey, size: 19),
            ],
          ),
          if (teamView && request.status == LeaveStatus.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      appState.setLeaveStatus(request, LeaveStatus.rejected);
                      showSnack(context, 'Request rejected');
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
                      appState.setLeaveStatus(request, LeaveStatus.approved);
                      showSnack(context, 'Request approved');
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

/// Functional leave-request form (opened from + and Quick Actions).
class LeaveFormScreen extends StatefulWidget {
  const LeaveFormScreen({super.key});

  @override
  State<LeaveFormScreen> createState() => _LeaveFormScreenState();
}

class _LeaveFormScreenState extends State<LeaveFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();
  String _type = 'Annual Leave';
  String? _forName; // null = me (the manager)
  late DateTime _start = DateTime.now();
  late DateTime _end = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pick(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (_end.isBefore(_start)) _end = _start;
      } else {
        _end = picked.isBefore(_start) ? _start : picked;
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final isMine = _forName == null;
    appState.addLeaveRequest(
      LeaveRequest(
        id: 'l${DateTime.now().millisecondsSinceEpoch}',
        employeeName: isMine ? appState.managerName : _forName!,
        type: _type,
        start: _start,
        end: _end,
        reason: _reason.text.trim(),
        status: LeaveStatus.pending,
        isMine: isMine,
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final days = _end.difference(_start).inDays + 1;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Request Leave'),
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
              const Text('Leave Type',
                  style:
                      TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 7),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _type,
                items: const ['Annual Leave', 'Sick Leave', 'Unpaid Leave']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child:
                          _dateField('Start Date', _start, () => _pick(true))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _dateField('End Date', _end, () => _pick(false))),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                days == 1 ? 'Total: 1 day' : 'Total: $days days',
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600),
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
                    const InputDecoration(hintText: 'Write your reason...'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please write a reason'
                    : null,
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateField(String label, DateTime value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
        const SizedBox(height: 7),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
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
                Text(fmtDate(value), style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
