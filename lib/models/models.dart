import 'package:flutter/material.dart';

enum EmployeeStatus { active, onLeave }

extension EmployeeStatusX on EmployeeStatus {
  String get label => this == EmployeeStatus.active ? 'Active' : 'On Leave';
}

class Employee {
  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    this.email = '',
    this.phone = '',
    this.salary = 0,
    this.joiningDate,
    this.status = EmployeeStatus.active,
  });

  final String id;
  String name;
  String role;
  String department;
  String email;
  String phone;
  double salary;
  DateTime? joiningDate;
  EmployeeStatus status;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'role': role,
        'department': department,
        'email': email,
        'phone': phone,
        'salary': salary,
        'joiningDate': joiningDate?.toIso8601String(),
        'status': status.name,
      };

  factory Employee.fromMap(Map<String, dynamic> m) => Employee(
        id: m['id'] as String,
        name: m['name'] as String,
        role: m['role'] as String,
        department: m['department'] as String,
        email: (m['email'] ?? '') as String,
        phone: (m['phone'] ?? '') as String,
        salary: (m['salary'] as num?)?.toDouble() ?? 0,
        joiningDate: m['joiningDate'] != null
            ? DateTime.tryParse(m['joiningDate'] as String)
            : null,
        status: EmployeeStatus.values.firstWhere(
          (s) => s.name == m['status'],
          orElse: () => EmployeeStatus.active,
        ),
      );
}

/// Deterministic pleasant colour per person (initial avatars).
Color avatarColor(String seed) {
  const palette = <Color>[
    Color(0xFFEF6C6C),
    Color(0xFF5B8DEF),
    Color(0xFF9B6DE3),
    Color(0xFF2FBF9B),
    Color(0xFFF2A93B),
    Color(0xFF4C6FFF),
    Color(0xFFDE6FA1),
    Color(0xFF3AA6A0),
  ];
  var h = 0;
  for (final c in seed.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return palette[h % palette.length];
}

enum LeaveStatus { pending, approved, rejected }

extension LeaveStatusX on LeaveStatus {
  String get label {
    switch (this) {
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case LeaveStatus.pending:
        return const Color(0xFFF5A623);
      case LeaveStatus.approved:
        return const Color(0xFF22C07A);
      case LeaveStatus.rejected:
        return const Color(0xFFF05252);
    }
  }

  Color get bgColor {
    switch (this) {
      case LeaveStatus.pending:
        return const Color(0xFFFDF1DC);
      case LeaveStatus.approved:
        return const Color(0xFFE5F7EE);
      case LeaveStatus.rejected:
        return const Color(0xFFFDE8E8);
    }
  }
}

class LeaveRequest {
  LeaveRequest({
    required this.id,
    required this.employeeName,
    required this.type,
    required this.start,
    required this.end,
    required this.reason,
    this.status = LeaveStatus.pending,
    this.isMine = true,
  });

  final String id;
  final String employeeName;
  final String type; // Annual Leave | Sick Leave | Unpaid Leave
  final DateTime start;
  final DateTime end;
  final String reason;
  LeaveStatus status;
  final bool isMine;

  int get days => end.difference(start).inDays + 1;

  IconData get icon {
    switch (type) {
      case 'Sick Leave':
        return Icons.add_circle_outline;
      case 'Unpaid Leave':
        return Icons.schedule;
      default:
        return Icons.calendar_month_outlined;
    }
  }

  Color get iconColor {
    switch (type) {
      case 'Sick Leave':
        return const Color(0xFF5B8DEF);
      case 'Unpaid Leave':
        return const Color(0xFFF05252);
      default:
        return const Color(0xFF22C07A);
    }
  }

  Color get iconBg {
    switch (type) {
      case 'Sick Leave':
        return const Color(0xFFEAF0FE);
      case 'Unpaid Leave':
        return const Color(0xFFFDE8E8);
      default:
        return const Color(0xFFE5F7EE);
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'employeeName': employeeName,
        'type': type,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'reason': reason,
        'status': status.name,
        'isMine': isMine,
      };

  factory LeaveRequest.fromMap(Map<String, dynamic> m) => LeaveRequest(
        id: m['id'] as String,
        employeeName: m['employeeName'] as String,
        type: m['type'] as String,
        start: DateTime.parse(m['start'] as String),
        end: DateTime.parse(m['end'] as String),
        reason: (m['reason'] ?? '') as String,
        status: LeaveStatus.values.firstWhere(
          (s) => s.name == m['status'],
          orElse: () => LeaveStatus.pending,
        ),
        isMine: (m['isMine'] ?? true) as bool,
      );
}

enum OvertimeStatus { pending, approved, rejected }

extension OvertimeStatusX on OvertimeStatus {
  String get label {
    switch (this) {
      case OvertimeStatus.pending:
        return 'Pending';
      case OvertimeStatus.approved:
        return 'Approved';
      case OvertimeStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case OvertimeStatus.pending:
        return const Color(0xFFF5A623);
      case OvertimeStatus.approved:
        return const Color(0xFF22C07A);
      case OvertimeStatus.rejected:
        return const Color(0xFFF05252);
    }
  }

  Color get bgColor {
    switch (this) {
      case OvertimeStatus.pending:
        return const Color(0xFFFDF1DC);
      case OvertimeStatus.approved:
        return const Color(0xFFE5F7EE);
      case OvertimeStatus.rejected:
        return const Color(0xFFFDE8E8);
    }
  }
}

class OvertimeEntry {
  OvertimeEntry({
    required this.id,
    required this.employeeName,
    required this.date,
    required this.hours,
    required this.reason,
    this.ratePerHour = 100,
    this.status = OvertimeStatus.pending,
    this.isMine = true,
  });

  final String id;
  final String employeeName;
  final DateTime date;
  double hours;
  final String reason;
  final double ratePerHour;
  OvertimeStatus status;
  final bool isMine;

  double get amount => hours * ratePerHour;

  Map<String, dynamic> toMap() => {
        'id': id,
        'employeeName': employeeName,
        'date': date.toIso8601String(),
        'hours': hours,
        'reason': reason,
        'ratePerHour': ratePerHour,
        'status': status.name,
        'isMine': isMine,
      };

  factory OvertimeEntry.fromMap(Map<String, dynamic> m) => OvertimeEntry(
        id: m['id'] as String,
        employeeName: m['employeeName'] as String,
        date: DateTime.parse(m['date'] as String),
        hours: (m['hours'] as num).toDouble(),
        reason: (m['reason'] ?? '') as String,
        ratePerHour: (m['ratePerHour'] as num?)?.toDouble() ?? 100,
        status: OvertimeStatus.values.firstWhere(
          (s) => s.name == m['status'],
          orElse: () => OvertimeStatus.pending,
        ),
        isMine: (m['isMine'] ?? true) as bool,
      );
}

/// A generated payslip (snapshot saved by the user from the Payroll screen).
class PayrollRecord {
  const PayrollRecord({
    required this.id,
    required this.subjectName,
    required this.monthLabel,
    required this.monthKey, // e.g. 2026-08
    required this.dateLabel,
    required this.basic,
    required this.allowances,
    required this.overtimePay,
    required this.deductions,
    this.paid = false,
  });

  final String id;
  final String subjectName;
  final String monthLabel;
  final String monthKey;
  final String dateLabel;
  final double basic;
  final double allowances;
  final double overtimePay;
  final double deductions;
  final bool paid;

  double get net => basic + allowances + overtimePay - deductions;

  PayrollRecord copyWith({bool? paid}) => PayrollRecord(
        id: id,
        subjectName: subjectName,
        monthLabel: monthLabel,
        monthKey: monthKey,
        dateLabel: dateLabel,
        basic: basic,
        allowances: allowances,
        overtimePay: overtimePay,
        deductions: deductions,
        paid: paid ?? this.paid,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'subjectName': subjectName,
        'monthLabel': monthLabel,
        'monthKey': monthKey,
        'dateLabel': dateLabel,
        'basic': basic,
        'allowances': allowances,
        'overtimePay': overtimePay,
        'deductions': deductions,
        'paid': paid,
      };

  factory PayrollRecord.fromMap(Map<String, dynamic> m) => PayrollRecord(
        id: m['id'] as String,
        subjectName: (m['subjectName'] ?? '') as String,
        monthLabel: m['monthLabel'] as String,
        monthKey: (m['monthKey'] ?? '') as String,
        dateLabel: m['dateLabel'] as String,
        basic: (m['basic'] as num).toDouble(),
        allowances: (m['allowances'] as num).toDouble(),
        overtimePay: (m['overtimePay'] as num).toDouble(),
        deductions: (m['deductions'] as num).toDouble(),
        paid: (m['paid'] ?? false) as bool,
      );
}

/// One completed workday of the signed-in user (clock in -> clock out).
class AttendanceLog {
  const AttendanceLog({
    required this.dateKey, // yyyy-MM-dd
    required this.clockInIso,
    required this.clockOutIso,
  });

  final String dateKey;
  final String clockInIso;
  final String clockOutIso;

  Map<String, dynamic> toMap() => {
        'dateKey': dateKey,
        'clockInIso': clockInIso,
        'clockOutIso': clockOutIso,
      };

  factory AttendanceLog.fromMap(Map<String, dynamic> m) => AttendanceLog(
        dateKey: m['dateKey'] as String,
        clockInIso: m['clockInIso'] as String,
        clockOutIso: m['clockOutIso'] as String,
      );
}

String dateKeyOf(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String monthKeyOf(int year, int month) =>
    '$year-${month.toString().padLeft(2, '0')}';
