import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'add_employee_screen.dart';

/// Employees directory: search, filter chips, sorting, responsive grid
/// on large screens, add / edit / details / status / delete.
class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  String _query = '';
  String _filter = 'Total'; // Total | Active | On Leave
  String _sort = 'Newest'; // Newest | Name | Salary

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final s = appState;
        final list = s.employees.where((e) {
          final q = _query;
          final matchesQuery = e.name.toLowerCase().contains(q) ||
              e.role.toLowerCase().contains(q) ||
              e.department.toLowerCase().contains(q);
          final matchesFilter = _filter == 'Total' ||
              (_filter == 'Active' && e.status == EmployeeStatus.active) ||
              (_filter == 'On Leave' && e.status == EmployeeStatus.onLeave);
          return matchesQuery && matchesFilter;
        }).toList();
        if (_sort == 'Name') {
          list.sort((a, b) => a.name.compareTo(b.name));
        } else if (_sort == 'Salary') {
          list.sort((a, b) => b.salary.compareTo(a.salary));
        }

        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Employees',
                            style: TextStyle(
                                fontSize: 21, fontWeight: FontWeight.w800),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.sort,
                              color: AppColors.textDark, size: 21),
                          tooltip: 'Sort',
                          onSelected: (v) => setState(() => _sort = v),
                          itemBuilder: (_) => [
                            for (final o in ['Newest', 'Name', 'Salary'])
                              PopupMenuItem(
                                value: o,
                                child: Row(
                                  children: [
                                    Icon(
                                      _sort == o
                                          ? Icons.check
                                          : Icons.check_box_outline_blank,
                                      size: 16,
                                      color: _sort == o
                                          ? AppColors.primary
                                          : Colors.transparent,
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Sort: $o'),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        IconButton(
                          tooltip: 'Add Employee',
                          onPressed: () => _openForm(context),
                          icon: const Icon(Icons.person_add_alt_1,
                              color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (v) =>
                                setState(() => _query = v.trim().toLowerCase()),
                            decoration: const InputDecoration(
                              hintText: 'Search employees...',
                              prefixIcon: Icon(Icons.search,
                                  color: AppColors.textGrey, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Row(
                      children: [
                        MiniStat(
                          label: 'Total',
                          value: '${s.totalEmployees}',
                          dotColor: AppColors.primary,
                          selected: _filter == 'Total',
                          onTap: () => setState(() => _filter = 'Total'),
                        ),
                        const SizedBox(width: 10),
                        MiniStat(
                          label: 'Active',
                          value: '${s.activeEmployees}',
                          dotColor: AppColors.green,
                          selected: _filter == 'Active',
                          onTap: () => setState(() => _filter = 'Active'),
                        ),
                        const SizedBox(width: 10),
                        MiniStat(
                          label: 'On Leave',
                          value: '${s.onLeaveCount}',
                          dotColor: AppColors.orange,
                          selected: _filter == 'On Leave',
                          onTap: () => setState(() => _filter = 'On Leave'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: list.isEmpty
                        ? _emptyState(context)
                        : LayoutBuilder(
                            builder: (context, c) {
                              if (c.maxWidth >= 980) {
                                return GridView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 6, 20, 20),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 3.4,
                                  ),
                                  itemCount: list.length,
                                  itemBuilder: (context, i) =>
                                      _EmployeeTile(employee: list[i]),
                                );
                              }
                              if (c.maxWidth >= 640) {
                                return GridView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 6, 20, 20),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 3.4,
                                  ),
                                  itemCount: list.length,
                                  itemBuilder: (context, i) =>
                                      _EmployeeTile(employee: list[i]),
                                );
                              }
                              return ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 6, 20, 20),
                                itemCount: list.length,
                                itemBuilder: (context, i) =>
                                    _EmployeeTile(employee: list[i]),
                              );
                            },
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

  Widget _emptyState(BuildContext context) {
    final isSearching = _query.isNotEmpty || _filter != 'Total';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.groups_outlined,
                size: 52, color: AppColors.textGrey),
            const SizedBox(height: 12),
            Text(
              isSearching
                  ? 'No employees match your search'
                  : 'No employees yet',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              isSearching
                  ? 'Try a different name, role or filter.'
                  : 'Add your first real employee to get started. '
                      'Everything is saved on this device.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGrey),
            ),
            if (!isSearching) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.person_add_alt_1, size: 18),
                label: const Text('Add Employee'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, [Employee? employee]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddEmployeeScreen(employee: employee)),
    );
    if (saved == true && context.mounted) {
      showSnack(
          context,
          employee == null
              ? 'Employee added successfully'
              : 'Employee updated successfully');
    }
  }
}

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.employee});
  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final isActive = employee.status == EmployeeStatus.active;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: cardDecoration(radius: 16),
      child: Row(
        children: [
          Avatar(name: employee.name, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  employee.role,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textDark, fontSize: 12.5),
                ),
                Text(
                  employee.department,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          StatusChip(
            label: employee.status.label,
            color: isActive ? AppColors.green : AppColors.orange,
            bg: isActive ? AppColors.greenBg : AppColors.orangeBg,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                color: AppColors.textGrey, size: 20),
            onSelected: (v) => _onAction(context, v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'details', child: Text('View Details')),
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'toggle', child: Text('Change Status')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  void _onAction(BuildContext context, String action) {
    switch (action) {
      case 'details':
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          builder: (_) => _EmployeeDetails(employee: employee),
        );
        break;
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => AddEmployeeScreen(employee: employee)),
        );
        break;
      case 'toggle':
        appState.toggleEmployeeStatus(employee);
        showSnack(context, '${employee.name} is now ${employee.status.label}');
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete employee?'),
            content: Text('${employee.name} will be removed permanently.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  appState.removeEmployee(employee);
                  Navigator.pop(ctx);
                  showSnack(context, 'Employee deleted');
                },
                child: const Text('Delete',
                    style: TextStyle(color: AppColors.red)),
              ),
            ],
          ),
        );
        break;
    }
  }
}

class _EmployeeDetails extends StatelessWidget {
  const _EmployeeDetails({required this.employee});
  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final todayStatus = appState.attendanceOf(employee, appState.todayKey);
    return Padding(
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
          const SizedBox(height: 18),
          Row(
            children: [
              Avatar(name: employee.name, size: 58),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(employee.name,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800)),
                    Text(employee.role,
                        style: const TextStyle(color: AppColors.textGrey)),
                    Text(employee.department,
                        style: const TextStyle(color: AppColors.textGrey)),
                  ],
                ),
              ),
              StatusChip(
                label: employee.status.label,
                color: employee.status == EmployeeStatus.active
                    ? AppColors.green
                    : AppColors.orange,
                bg: employee.status == EmployeeStatus.active
                    ? AppColors.greenBg
                    : AppColors.orangeBg,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _row('Email', employee.email.isEmpty ? '-' : employee.email),
          _row('Phone', employee.phone.isEmpty ? '-' : employee.phone),
          _row('Monthly Salary',
              employee.salary == 0 ? '-' : money(employee.salary)),
          _row(
              'Joining Date',
              employee.joiningDate == null
                  ? '-'
                  : fmtDate(employee.joiningDate!)),
          _row('Attendance Today', todayStatus),
        ],
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            SizedBox(
              width: 130,
              child: Text(k,
                  style:
                      const TextStyle(color: AppColors.textGrey, fontSize: 13)),
            ),
            Expanded(
              child: Text(v,
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}
