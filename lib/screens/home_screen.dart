import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'add_employee_screen.dart';
import 'leave_screen.dart' show LeaveFormScreen;
import 'overtime_screen.dart' show OvertimeFormScreen;

/// Home dashboard. Every number is computed from the user's real data -
/// a fresh install honestly shows zeros plus a getting-started checklist.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onGoEmployees,
    required this.onGoLeaves,
    required this.onGoMoreTab,
    required this.onOpenAttendance,
    required this.onOpenPayroll,
    required this.onOpenOvertime,
  });

  final VoidCallback onGoEmployees;
  final VoidCallback onGoLeaves;
  final VoidCallback onGoMoreTab;
  final VoidCallback onOpenAttendance;
  final VoidCallback onOpenPayroll;
  final VoidCallback onOpenOvertime;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning,';
    if (h < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final s = appState;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Avatar(
                          name: s.managerName.isEmpty ? 'U' : s.managerName,
                          size: 46),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12.5,
                              ),
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    s.managerName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '${s.managerRole} • ${s.companyName}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textGrey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: cardShadow,
                            ),
                            child: const Icon(
                              Icons.notifications_none,
                              size: 21,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (s.leaveRequests
                              .any((r) => r.status.name == 'pending'))
                            const Positioned(
                              right: 10,
                              top: 9,
                              child: CircleAvatar(
                                radius: 3.5,
                                backgroundColor: AppColors.red,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Total employees banner (real count)
                  GestureDetector(
                    onTap: onGoEmployees,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2F6BFF), Color(0xFF1D4FD0)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.32),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.groups,
                                color: Colors.white, size: 23),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Employees',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12.5,
                                  ),
                                ),
                                Text(
                                  '${s.totalEmployees}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 27,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${s.activeEmployees} Active  •  ${s.onLeaveCount} On Leave',
                                  style: const TextStyle(
                                    color: Color(0xFFBFE3FF),
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: Colors.white70),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stat tiles (real values from today's attendance marks)
                  Row(
                    children: [
                      _StatTile(
                        icon: Icons.calendar_month_outlined,
                        bg: AppColors.pinkBg,
                        iconColor: const Color(0xFFDE6FA1),
                        label: 'On Leave',
                        value: '${s.onLeaveCount}',
                        onTap: onGoLeaves,
                      ),
                      _StatTile(
                        icon: Icons.access_time,
                        bg: AppColors.mintBg,
                        iconColor: AppColors.green,
                        label: 'Present Today',
                        value: '${s.presentToday}',
                        onTap: onOpenAttendance,
                      ),
                      _StatTile(
                        icon: Icons.access_time_filled,
                        bg: AppColors.peachBg,
                        iconColor: AppColors.orange,
                        label: 'Late',
                        value: '${s.lateToday}',
                        onTap: onOpenAttendance,
                      ),
                      _StatTile(
                        icon: Icons.more_time,
                        bg: AppColors.lavenderBg,
                        iconColor: AppColors.primary,
                        label: 'Overtime',
                        value: '${s.overtimePeopleThisMonth}',
                        onTap: onOpenOvertime,
                        last: true,
                      ),
                    ],
                  ),
                  if (s.totalEmployees == 0) ...[
                    const SizedBox(height: 22),
                    _GettingStarted(
                      hasEmployee: false,
                      hasMarks: s.todayMarks.isNotEmpty,
                      hasPayslip: s.payrollHistory.isNotEmpty,
                      onAddEmployee: () async {
                        final added = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                              builder: (_) => const AddEmployeeScreen()),
                        );
                        if (added == true && context.mounted) {
                          showSnack(context, 'Employee added successfully');
                        }
                      },
                      onMarkAttendance: onOpenAttendance,
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, c) {
                      final cols = c.maxWidth >= 760 ? 4 : 2;
                      return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: cols == 4 ? 2.1 : 2.45,
                        children: [
                          _QuickAction(
                            icon: Icons.person_add_alt_1,
                            label: 'Add Employee',
                            onTap: () async {
                              final added =
                                  await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                    builder: (_) => const AddEmployeeScreen()),
                              );
                              if (added == true && context.mounted) {
                                showSnack(
                                    context, 'Employee added successfully');
                              }
                            },
                          ),
                          _QuickAction(
                            icon: Icons.description_outlined,
                            label: 'Request Leave',
                            onTap: () async {
                              final done =
                                  await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                    builder: (_) => const LeaveFormScreen()),
                              );
                              if (done == true && context.mounted) {
                                onGoLeaves();
                              }
                            },
                          ),
                          _QuickAction(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'View Payroll',
                            onTap: onOpenPayroll,
                          ),
                          _QuickAction(
                            icon: Icons.more_time,
                            label: 'Overtime',
                            onTap: () async {
                              final done =
                                  await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                    builder: (_) => const OvertimeFormScreen()),
                              );
                              if (done == true && context.mounted) {
                                onOpenOvertime();
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GettingStarted extends StatelessWidget {
  const _GettingStarted({
    required this.hasEmployee,
    required this.hasMarks,
    required this.hasPayslip,
    required this.onAddEmployee,
    required this.onMarkAttendance,
  });
  final bool hasEmployee;
  final bool hasMarks;
  final bool hasPayslip;
  final VoidCallback onAddEmployee;
  final VoidCallback onMarkAttendance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Getting Started',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text(
            'Your workspace is empty. Add your real data to begin:',
            style: TextStyle(color: AppColors.textGrey, fontSize: 12.5),
          ),
          const SizedBox(height: 10),
          _step(true, 'Company setup completed', null),
          _step(hasEmployee, 'Add your first employee', onAddEmployee),
          _step(hasMarks, "Mark today's attendance", onMarkAttendance),
          _step(hasPayslip, 'Generate the first payslip', null),
        ],
      ),
    );
  }

  Widget _step(bool done, String label, VoidCallback? onTap) => ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          color: done ? AppColors.green : AppColors.textGrey,
          size: 20,
        ),
        title: Text(label, style: const TextStyle(fontSize: 13.5)),
        trailing: (!done && onTap != null)
            ? const Icon(Icons.chevron_right, size: 18)
            : null,
        onTap: done ? null : onTap,
      );
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.bg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
    this.last = false,
  });
  final IconData icon;
  final Color bg;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: last ? 0 : 10),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
            decoration: cardDecoration(radius: 16),
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: cardDecoration(radius: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.lavenderBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 19),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
