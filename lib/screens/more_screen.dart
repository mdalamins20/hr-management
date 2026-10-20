import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import '../data/app_state.dart';
import '../data/binary_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'splash_screen.dart';

/// Screen 8 of the reference design: side-menu style "More" screen.
/// Navigation callbacks are supplied by MainShell.
class MoreScreen extends StatelessWidget {
  const MoreScreen({
    super.key,
    required this.onGoHome,
    required this.onGoEmployees,
    required this.onGoLeaves,
    required this.onOpenAttendance,
    required this.onOpenPayroll,
    required this.onOpenOvertime,
    required this.onOpenReports,
    required this.onOpenSettings,
  });

  final VoidCallback onGoHome;
  final VoidCallback onGoEmployees;
  final VoidCallback onGoLeaves;
  final VoidCallback onOpenAttendance;
  final VoidCallback onOpenPayroll;
  final VoidCallback onOpenOvertime;
  final VoidCallback onOpenReports;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final s = appState;
        return Column(
          children: [
            // Profile header (dark navy, as in the design)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 46, 20, 22),
              decoration: const BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white38, width: 1.6),
                    ),
                    child: Avatar(name: s.managerName, size: 52),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.managerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              s.managerRole,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12.5),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.chevron_right,
                                color: Colors.white54, size: 15),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 20),
                child: Column(
                  children: [
                    _item(Icons.home_outlined, 'Dashboard', onGoHome),
                    _item(Icons.groups_outlined, 'Employees', onGoEmployees),
                    _item(Icons.access_time, 'Attendance', onOpenAttendance),
                    _item(Icons.calendar_month_outlined, 'Leave Requests',
                        onGoLeaves),
                    _item(Icons.account_balance_wallet_outlined, 'Payroll',
                        onOpenPayroll),
                    _item(Icons.more_time, 'Overtime', onOpenOvertime),
                    _item(Icons.bar_chart, 'Reports', onOpenReports),
                    _item(Icons.settings_outlined, 'Settings', onOpenSettings),
                    const SizedBox(height: 18),
                    // Need Help card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.lavenderBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.headset_mic_outlined,
                                color: AppColors.navy, size: 19),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Need Help?',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5)),
                                Text('Contact HR Support',
                                    style: TextStyle(
                                        color: AppColors.textGrey,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Log out?'),
                            content: const Text(
                                'You will return to the welcome screen.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (_) => const SplashScreen()),
                                    (_) => false,
                                  );
                                },
                                child: const Text('Log Out',
                                    style: TextStyle(color: AppColors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: AppColors.red, size: 21),
                            SizedBox(width: 14),
                            Text(
                              'Log Out',
                              style: TextStyle(
                                color: AppColors.red,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _item(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.textDark, size: 22),
      title: Text(label,
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

/// Reports screen (opened from the More menu) - real summaries from app data.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final s = appState;
        final attendanceRate = s.totalEmployees == 0
            ? 0.0
            : (s.presentToday + s.lateToday) / s.totalEmployees;
        final deptCounts = <String, int>{};
        for (final e in s.employees) {
          deptCounts[e.department] = (deptCounts[e.department] ?? 0) + 1;
        }
        final maxDept = deptCounts.values.fold<int>(1, (a, b) => a > b ? a : b);
        final pendingLeaves =
            s.leaveRequests.where((r) => r.status.name == 'pending').length;
        final totalPayroll =
            s.payrollHistory.fold(0.0, (sum, p) => sum + p.net);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Reports'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: cardDecoration(radius: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Attendance Rate (Today)',
                          style: TextStyle(
                              color: AppColors.textGrey, fontSize: 12.5)),
                      const SizedBox(height: 6),
                      Text('${(attendanceRate * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: attendanceRate,
                          minHeight: 9,
                          color: AppColors.primary,
                          backgroundColor: AppColors.border,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${s.presentToday} present • ${s.lateToday} late • ${s.absentToday} absent',
                        style: const TextStyle(
                            color: AppColors.textGrey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const SectionTitle(title: 'Employees by Department'),
                const SizedBox(height: 12),
                ...deptCounts.entries.map(
                  (en) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 132,
                          child: Text(en.key.replaceAll(' Department', ''),
                              style: const TextStyle(fontSize: 13)),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: en.value / maxDept,
                              minHeight: 10,
                              color: AppColors.primary,
                              backgroundColor: AppColors.border,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('${en.value}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _summaryCard('Pending Leaves', '$pendingLeaves'),
                    const SizedBox(width: 12),
                    _summaryCard('Payroll Total', money(totalPayroll)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _summaryCard('Total Employees', '${s.totalEmployees}'),
                    const SizedBox(width: 12),
                    _summaryCard('On Leave', '${s.onLeaveCount}'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _summaryCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: cardDecoration(radius: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(color: AppColors.textGrey, fontSize: 12)),
            const SizedBox(height: 5),
            Text(value,
                style: const TextStyle(
                    fontSize: 15.5, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

/// Settings screen: profile, company, payroll preferences, binary backup
/// export/import, and danger-zone data wipe.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _name = TextEditingController(text: appState.managerName);
  final _role = TextEditingController(text: appState.managerRole);
  final _company = TextEditingController(text: appState.companyName);
  final _salary = TextEditingController(
      text: appState.managerSalary == 0
          ? ''
          : appState.managerSalary.toStringAsFixed(0));
  final _rate = TextEditingController(
      text: appState.overtimeRatePerHour.toStringAsFixed(0));
  final _annual =
      TextEditingController(text: appState.annualLeaveAllowance.toString());
  final _sick =
      TextEditingController(text: appState.sickLeaveAllowance.toString());
  final _import = TextEditingController();
  String _currency = appState.currency;

  static const currencies = ['BDT', 'EGP', 'USD', 'EUR', 'INR', 'SAR', 'AED'];

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _company.dispose();
    _salary.dispose();
    _rate.dispose();
    _annual.dispose();
    _sick.dispose();
    _import.dispose();
    super.dispose();
  }

  void _saveAll() {
    if (_name.text.trim().isEmpty) {
      showSnack(context, 'Name cannot be empty');
      return;
    }
    appState.updateProfile(
      _name.text.trim(),
      _role.text.trim().isEmpty ? appState.managerRole : _role.text.trim(),
      _company.text.trim(),
      salary: double.tryParse(_salary.text.trim()) ?? 0,
    );
    appState.updatePreferences(
      curr: _currency,
      overtimeRate: double.tryParse(_rate.text.trim()),
      annualAllowance: int.tryParse(_annual.text.trim()),
      sickAllowance: int.tryParse(_sick.text.trim()),
    );
    showSnack(context, 'Settings saved');
  }

  void _showExport() {
    final code = BinaryCodec.encodeToBase64(appState.toMap());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Binary Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This is your complete app data as a binary (.hrmb) blob, '
              'shown as Base64 so you can copy it anywhere. Keep it safe - '
              'anyone with it can restore your data.',
              style: TextStyle(fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxHeight: 130),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SingleChildScrollView(
                child: SelectableText(code,
                    style: const TextStyle(fontSize: 10.5)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(ctx);
              await Clipboard.setData(ClipboardData(text: code));
              if (ctx.mounted) Navigator.pop(ctx);
              messenger.showSnackBar(
                SnackBar(
                  content: const Text('Backup copied to clipboard'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Copy Backup'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _doImport() {
    final data = BinaryCodec.decodeFromBase64(_import.text);
    if (data == null) {
      showSnack(context, 'Invalid backup - nothing was changed');
      return;
    }
    appState.replaceWith(data);
    showSnack(context, 'Backup restored successfully');
    _import.clear();
    setState(() {
      _name.text = appState.managerName;
      _role.text = appState.managerRole;
      _company.text = appState.companyName;
      _currency = appState.currency;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final s = appState;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Settings'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Profile & Company',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _company,
                      decoration:
                          const InputDecoration(labelText: 'Company Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Your Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _role,
                      decoration: const InputDecoration(labelText: 'Role'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _salary,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'My Monthly Salary (${s.currency})'),
                    ),
                    const SizedBox(height: 20),
                    const Text('Payroll & Leave Preferences',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: currencies.contains(_currency)
                          ? _currency
                          : currencies.first,
                      decoration: const InputDecoration(labelText: 'Currency'),
                      items: currencies
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _currency = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _rate,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'Overtime Rate per hour (${s.currency})'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _annual,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Annual Leave Days / year'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _sick,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: 'Sick Leave Days / year'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saveAll,
                        child: const Text('Save Settings'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Notifications',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                      title: const Text('Notifications'),
                      subtitle: const Text('Leave and payroll alerts'),
                      value: s.notificationsEnabled,
                      onChanged: s.setNotifications,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                      title: const Text('Biometric Login'),
                      subtitle: const Text('Fingerprint / face unlock'),
                      value: s.biometricEnabled,
                      onChanged: s.setBiometric,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                      title: const Text('Weekly Report Email'),
                      subtitle: const Text('Summary every Monday'),
                      value: s.weeklyReportEnabled,
                      onChanged: s.setWeeklyReport,
                    ),
                    const SizedBox(height: 24),
                    const Text('Backup (Binary)',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    const Text(
                      'All data already auto-saves on this device in binary '
                      'local storage. Export a portable binary backup, or '
                      'restore one below.',
                      style:
                          TextStyle(color: AppColors.textGrey, fontSize: 12.5),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _showExport,
                        icon: const Icon(Icons.upload_file_outlined, size: 18),
                        label: const Text('Export Binary Backup'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _import,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Paste a backup to restore',
                        hintText: 'Paste Base64 backup here...',
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _doImport,
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text('Restore Backup'),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text('Danger Zone',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.red)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.red,
                          side: const BorderSide(color: AppColors.red),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete ALL data?'),
                              content: const Text(
                                  'Employees, attendance, leave, payroll - '
                                  'everything stored on this device will be '
                                  'erased and the app returns to first-run '
                                  'setup. This cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await appState.wipeAll();
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    if (context.mounted) {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const SplashScreen()),
                                        (_) => false,
                                      );
                                    }
                                  },
                                  child: const Text('Delete Everything',
                                      style: TextStyle(color: AppColors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        icon:
                            const Icon(Icons.delete_forever_outlined, size: 18),
                        label: const Text('Erase All Data'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('App version 2.0.0',
                        style:
                            TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
