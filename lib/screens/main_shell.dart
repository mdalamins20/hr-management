import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'attendance_screen.dart';
import 'employees_screen.dart';
import 'home_screen.dart';
import 'leave_screen.dart';
import 'more_screen.dart';
import 'overtime_screen.dart';
import 'payroll_screen.dart';
import 'splash_screen.dart';

/// App shell with two layouts:
///  * Phone / tablet portrait (< 900dp): bottom navigation
///    Home | Employees | Leaves | More  (as in the reference design)
///  * Desktop / large screens (>= 900dp): permanent navy sidebar with
///    profile header and full menu, content area on the right.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0; // 0 Home, 1 Employees, 2 Leaves, 3 More (mobile tabs)
  String _deskPage = 'home';

  void _go(int i) => setState(() {
        _index = i;
        _deskPage = const ['home', 'employees', 'leaves', 'more'][i];
      });

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  bool get _isDesktop => MediaQuery.of(context).size.width >= 900;

  // ---- navigation actions shared by both layouts --------------------------
  void _openAttendance() {
    if (_isDesktop) {
      setState(() => _deskPage = 'attendance');
    } else {
      _push(const AttendanceScreen());
    }
  }

  void _openPayroll() {
    if (_isDesktop) {
      setState(() => _deskPage = 'payroll');
    } else {
      _push(const PayrollScreen());
    }
  }

  void _openOvertime() => _push(const OvertimeScreen());
  void _openReports() => _push(const ReportsScreen());
  void _openSettings() => _push(const SettingsScreen());

  HomeScreen get _home => HomeScreen(
        onGoEmployees: () => _go(1),
        onGoLeaves: () => _go(2),
        onGoMoreTab: () => _go(3),
        onOpenAttendance: _openAttendance,
        onOpenPayroll: _openPayroll,
        onOpenOvertime: _openOvertime,
      );

  MoreScreen get _more => MoreScreen(
        onGoHome: () => _go(0),
        onGoEmployees: () => _go(1),
        onGoLeaves: () => _go(2),
        onOpenAttendance: _openAttendance,
        onOpenPayroll: _openPayroll,
        onOpenOvertime: _openOvertime,
        onOpenReports: _openReports,
        onOpenSettings: _openSettings,
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) return _desktop();
        return _mobile();
      },
    );
  }

  // ============================ MOBILE =====================================
  Widget _mobile() {
    final pages = <Widget>[
      _home,
      const EmployeesScreen(),
      const LeaveScreen(),
      _more,
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home, Icons.home_outlined, 'Home'),
                _navItem(1, Icons.groups, Icons.groups_outlined, 'Employees'),
                _navItem(
                    2, Icons.description, Icons.description_outlined, 'Leaves'),
                _navItem(3, Icons.menu, Icons.menu, 'More'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData activeIcon, IconData icon, String label) {
    final selected = _index == i;
    return GestureDetector(
      onTap: () => _go(i),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? activeIcon : icon,
              color: selected ? AppColors.primary : AppColors.textGrey,
              size: 23,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.primary : AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================ DESKTOP ====================================
  Widget _desktop() {
    final Widget content;
    switch (_deskPage) {
      case 'employees':
        content = const EmployeesScreen();
        break;
      case 'leaves':
        content = const LeaveScreen();
        break;
      case 'attendance':
        content = const SafeArea(child: AttendanceScreen(embedded: true));
        break;
      case 'payroll':
        content = const SafeArea(child: PayrollScreen(embedded: true));
        break;
      case 'more':
        content = _more;
        break;
      default:
        content = _home;
    }

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sidebar(),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget _sidebar() {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final s = appState;
        return Container(
          width: 264,
          color: AppColors.navy,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 22, 20, 6),
                  child: Row(
                    children: [
                      Icon(Icons.groups, color: Colors.white, size: 26),
                      SizedBox(width: 8),
                      Text(
                        'HR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 16),
                  child: Text(
                    s.companyName.isEmpty ? 'HR Management' : s.companyName,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Avatar(
                          name: s.managerName.isEmpty ? 'U' : s.managerName,
                          size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.managerName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                              ),
                            ),
                            Text(
                              s.managerRole,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        _sideItem('home', Icons.home_outlined, 'Dashboard'),
                        _sideItem(
                            'employees', Icons.groups_outlined, 'Employees'),
                        _sideItem('attendance', Icons.access_time, 'Attendance',
                            onTap: _openAttendance),
                        _sideItem('leaves', Icons.calendar_month_outlined,
                            'Leave Requests'),
                        _sideItem('payroll',
                            Icons.account_balance_wallet_outlined, 'Payroll',
                            onTap: _openPayroll),
                        _sideItem('overtime', Icons.more_time, 'Overtime',
                            onTap: _openOvertime),
                        _sideItem('reports', Icons.bar_chart, 'Reports',
                            onTap: _openReports),
                        _sideItem(
                            'settings', Icons.settings_outlined, 'Settings',
                            onTap: _openSettings),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const SplashScreen()),
                        (_) => false,
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.logout, color: Color(0xFFFF8A8A), size: 20),
                        SizedBox(width: 10),
                        Text('Log Out',
                            style: TextStyle(
                                color: Color(0xFFFF8A8A),
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sideItem(String page, IconData icon, String label,
      {VoidCallback? onTap}) {
    final selected = _deskPage == page;
    return ListTile(
      dense: true,
      selected: selected,
      selectedTileColor: Colors.white.withOpacity(0.10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading:
          Icon(icon, color: selected ? Colors.white : Colors.white70, size: 21),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.white70,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      onTap: onTap ?? () => setState(() => _deskPage = page),
    );
  }
}
