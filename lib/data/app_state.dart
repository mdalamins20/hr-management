import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'binary_store.dart';

/// Single source of truth for the whole app.
///
/// There is NO demo/seed data: a fresh install starts completely empty and
/// the user builds their real organisation (first-run setup -> employees ->
/// attendance, leave, payroll, overtime). Every change is persisted to
/// local storage as one binary blob (see [BinaryCodec]).
class AppState extends ChangeNotifier {
  AppState();

  factory AppState.fromMap(Map<String, dynamic> m) {
    final s = AppState();
    s._loadFromMap(m);
    return s;
  }

  // ---- Setup / profile ------------------------------------------------------
  bool configured = false;
  String companyName = '';
  String managerName = '';
  String managerRole = 'HR Manager';
  double managerSalary = 0;
  String currency = 'BDT';
  double overtimeRatePerHour = 100;
  int annualLeaveAllowance = 20;
  int sickLeaveAllowance = 10;

  // ---- Preferences ----------------------------------------------------------
  bool notificationsEnabled = true;
  bool biometricEnabled = false;
  bool weeklyReportEnabled = true;

  // ---- My clock ---------------------------------------------------------------
  bool clockedIn = false;
  DateTime? clockInAt;
  final List<AttendanceLog> myAttendanceLog = [];

  // ---- Data (all start EMPTY - no demo data) ----------------------------------
  final List<Employee> employees = [];
  final List<LeaveRequest> leaveRequests = [];
  final List<OvertimeEntry> overtimeEntries = [];
  final List<PayrollRecord> payrollHistory = [];

  /// Employee attendance marks: dateKey -> employeeId -> Present|Late|Absent
  final Map<String, Map<String, String>> attendanceMarks = {};

  /// Payroll draft adjustments: "<subject>|<monthKey>" -> [allowances, deductions]
  final Map<String, List<double>> payrollAdjustments = {};

  // ---- Persistence -------------------------------------------------------------
  static bool persistenceEnabled = false;
  Timer? _saveTimer;

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (persistenceEnabled) {
      _saveTimer?.cancel();
      _saveTimer = Timer(const Duration(milliseconds: 250), () {
        LocalStore.save(toMap());
      });
    }
  }

  /// Replace the whole state with imported/backup data.
  void replaceWith(Map<String, dynamic> m) {
    _clearAllFields();
    _loadFromMap(m);
    notifyListeners();
  }

  /// Wipe everything back to a fresh install.
  Future<void> wipeAll() async {
    _clearAllFields();
    await LocalStore.clear();
    notifyListeners();
  }

  void _clearAllFields() {
    configured = false;
    companyName = '';
    managerName = '';
    managerRole = 'HR Manager';
    managerSalary = 0;
    currency = 'BDT';
    overtimeRatePerHour = 100;
    annualLeaveAllowance = 20;
    sickLeaveAllowance = 10;
    clockedIn = false;
    clockInAt = null;
    myAttendanceLog.clear();
    employees.clear();
    leaveRequests.clear();
    overtimeEntries.clear();
    payrollHistory.clear();
    attendanceMarks.clear();
    payrollAdjustments.clear();
  }

  void _loadFromMap(Map<String, dynamic> m) {
    configured = (m['configured'] ?? false) as bool;
    companyName = (m['companyName'] ?? '') as String;
    managerName = (m['managerName'] ?? '') as String;
    managerRole = (m['managerRole'] ?? 'HR Manager') as String;
    managerSalary = (m['managerSalary'] as num?)?.toDouble() ?? 0;
    currency = (m['currency'] ?? 'BDT') as String;
    overtimeRatePerHour = (m['overtimeRatePerHour'] as num?)?.toDouble() ?? 100;
    annualLeaveAllowance = (m['annualLeaveAllowance'] as num?)?.toInt() ?? 20;
    sickLeaveAllowance = (m['sickLeaveAllowance'] as num?)?.toInt() ?? 10;
    notificationsEnabled = (m['notificationsEnabled'] ?? true) as bool;
    biometricEnabled = (m['biometricEnabled'] ?? false) as bool;
    weeklyReportEnabled = (m['weeklyReportEnabled'] ?? true) as bool;
    clockedIn = (m['clockedIn'] ?? false) as bool;
    clockInAt = m['clockInAt'] != null
        ? DateTime.tryParse(m['clockInAt'] as String)
        : null;

    myAttendanceLog.addAll(((m['myAttendanceLog'] ?? []) as List).map(
        (e) => AttendanceLog.fromMap(Map<String, dynamic>.from(e as Map))));
    employees.addAll(((m['employees'] ?? []) as List)
        .map((e) => Employee.fromMap(Map<String, dynamic>.from(e as Map))));
    leaveRequests.addAll(((m['leaveRequests'] ?? []) as List)
        .map((e) => LeaveRequest.fromMap(Map<String, dynamic>.from(e as Map))));
    overtimeEntries.addAll(((m['overtimeEntries'] ?? []) as List).map(
        (e) => OvertimeEntry.fromMap(Map<String, dynamic>.from(e as Map))));
    payrollHistory.addAll(((m['payrollHistory'] ?? []) as List).map(
        (e) => PayrollRecord.fromMap(Map<String, dynamic>.from(e as Map))));

    final marks = (m['attendanceMarks'] ?? {}) as Map;
    marks.forEach((k, v) {
      attendanceMarks[k as String] = Map<String, String>.from(v as Map);
    });
    final adj = (m['payrollAdjustments'] ?? {}) as Map;
    adj.forEach((k, v) {
      payrollAdjustments[k as String] =
          (v as List).map((e) => (e as num).toDouble()).toList();
    });
  }

  Map<String, dynamic> toMap() => {
        'configured': configured,
        'companyName': companyName,
        'managerName': managerName,
        'managerRole': managerRole,
        'managerSalary': managerSalary,
        'currency': currency,
        'overtimeRatePerHour': overtimeRatePerHour,
        'annualLeaveAllowance': annualLeaveAllowance,
        'sickLeaveAllowance': sickLeaveAllowance,
        'notificationsEnabled': notificationsEnabled,
        'biometricEnabled': biometricEnabled,
        'weeklyReportEnabled': weeklyReportEnabled,
        'clockedIn': clockedIn,
        'clockInAt': clockInAt?.toIso8601String(),
        'myAttendanceLog': myAttendanceLog.map((e) => e.toMap()).toList(),
        'employees': employees.map((e) => e.toMap()).toList(),
        'leaveRequests': leaveRequests.map((e) => e.toMap()).toList(),
        'overtimeEntries': overtimeEntries.map((e) => e.toMap()).toList(),
        'payrollHistory': payrollHistory.map((e) => e.toMap()).toList(),
        'attendanceMarks': attendanceMarks,
        'payrollAdjustments': payrollAdjustments,
      };

  // ---- Derived values (everything computed from real data) -------------------
  int get totalEmployees => employees.length;
  int get activeEmployees =>
      employees.where((e) => e.status == EmployeeStatus.active).length;
  int get onLeaveCount =>
      employees.where((e) => e.status == EmployeeStatus.onLeave).length;

  String get todayKey => dateKeyOf(DateTime.now());

  Map<String, String> get todayMarks => attendanceMarks[todayKey] ?? const {};

  int _countToday(String status) =>
      todayMarks.values.where((v) => v == status).length;
  int get presentToday => _countToday('Present');
  int get lateToday => _countToday('Late');
  int get absentToday => _countToday('Absent');
  int get unmarkedToday => totalEmployees - todayMarks.length;

  int get overtimePeopleThisMonth {
    final now = DateTime.now();
    return overtimeEntries
        .where((o) => o.date.year == now.year && o.date.month == now.month)
        .map((o) => o.employeeName)
        .toSet()
        .length;
  }

  List<LeaveRequest> get myLeaveRequests =>
      leaveRequests.where((r) => r.isMine).toList();
  List<LeaveRequest> get teamLeaveRequests =>
      leaveRequests.where((r) => !r.isMine).toList();

  int usedLeaveDays(String type) => myLeaveRequests
      .where((r) => r.type == type && r.status == LeaveStatus.approved)
      .fold(0, (sum, r) => sum + r.days);

  int get annualLeaveUsed => usedLeaveDays('Annual Leave');
  int get sickLeaveUsed => usedLeaveDays('Sick Leave');
  int get unpaidLeaveUsed => usedLeaveDays('Unpaid Leave');

  double overtimeHoursFor(String name, {bool mineOnly = false}) =>
      overtimeEntries
          .where((o) => o.employeeName == name && (!mineOnly || o.isMine))
          .fold(0.0, (sum, o) => sum + o.hours);

  double get myTotalOvertimeHours => overtimeEntries
      .where((o) => o.isMine)
      .fold(0.0, (sum, o) => sum + o.hours);

  double myMonthOvertimeHours(int year, int month) => overtimeEntries
      .where((o) => o.isMine && o.date.year == year && o.date.month == month)
      .fold(0.0, (sum, o) => sum + o.hours);

  double get myPendingOvertimeHours => overtimeEntries
      .where((o) => o.isMine && o.status == OvertimeStatus.pending)
      .fold(0.0, (sum, o) => sum + o.hours);

  /// Approved overtime pay for a person in a given month.
  double approvedOvertimePay(String name, int year, int month) =>
      overtimeEntries
          .where((o) =>
              o.employeeName == name &&
              o.status == OvertimeStatus.approved &&
              o.date.year == year &&
              o.date.month == month)
          .fold(0.0, (sum, o) => sum + o.amount);

  double approvedOvertimeHours(String name, int year, int month) =>
      overtimeEntries
          .where((o) =>
              o.employeeName == name &&
              o.status == OvertimeStatus.approved &&
              o.date.year == year &&
              o.date.month == month)
          .fold(0.0, (sum, o) => sum + o.hours);

  String attendanceOf(Employee e, String dateKey) {
    final mark = attendanceMarks[dateKey]?[e.id];
    if (mark != null) return mark;
    if (e.status == EmployeeStatus.onLeave) return 'On Leave';
    return 'Not marked';
  }

  // ---- Actions ------------------------------------------------------------------
  void completeSetup({
    required String company,
    required String name,
    required String role,
    required String curr,
    required double overtimeRate,
  }) {
    companyName = company;
    managerName = name;
    managerRole = role;
    currency = curr;
    overtimeRatePerHour = overtimeRate;
    configured = true;
    notifyListeners();
  }

  void updateProfile(String name, String role, String company,
      {double? salary}) {
    managerName = name;
    managerRole = role;
    companyName = company;
    if (salary != null) managerSalary = salary;
    notifyListeners();
  }

  void updatePreferences({
    String? curr,
    double? overtimeRate,
    int? annualAllowance,
    int? sickAllowance,
  }) {
    if (curr != null) currency = curr;
    if (overtimeRate != null) overtimeRatePerHour = overtimeRate;
    if (annualAllowance != null) annualLeaveAllowance = annualAllowance;
    if (sickAllowance != null) sickLeaveAllowance = sickAllowance;
    notifyListeners();
  }

  void addEmployee(Employee e) {
    employees.insert(0, e);
    notifyListeners();
  }

  void updateEmployee(Employee e) {
    notifyListeners();
  }

  void removeEmployee(Employee e) {
    employees.remove(e);
    for (final day in attendanceMarks.values) {
      day.remove(e.id);
    }
    notifyListeners();
  }

  void toggleEmployeeStatus(Employee e) {
    e.status = e.status == EmployeeStatus.active
        ? EmployeeStatus.onLeave
        : EmployeeStatus.active;
    notifyListeners();
  }

  void setAttendanceMark(Employee e, String status, {DateTime? date}) {
    final key = dateKeyOf(date ?? DateTime.now());
    attendanceMarks.putIfAbsent(key, () => {});
    if (status == 'Not marked') {
      attendanceMarks[key]!.remove(e.id);
    } else {
      attendanceMarks[key]![e.id] = status;
    }
    notifyListeners();
  }

  void addLeaveRequest(LeaveRequest r) {
    leaveRequests.insert(0, r);
    notifyListeners();
  }

  void removeLeaveRequest(LeaveRequest r) {
    leaveRequests.remove(r);
    notifyListeners();
  }

  void setLeaveStatus(LeaveRequest r, LeaveStatus s) {
    r.status = s;
    notifyListeners();
  }

  void addOvertime(OvertimeEntry o) {
    overtimeEntries.insert(0, o);
    notifyListeners();
  }

  void removeOvertime(OvertimeEntry o) {
    overtimeEntries.remove(o);
    notifyListeners();
  }

  void setOvertimeStatus(OvertimeEntry o, OvertimeStatus s) {
    o.status = s;
    notifyListeners();
  }

  void savePayrollAdjustment(
      String subject, String monthKey, double allowances, double deductions) {
    payrollAdjustments['$subject|$monthKey'] = [allowances, deductions];
    notifyListeners();
  }

  List<double> payrollAdjustment(String subject, String monthKey) =>
      payrollAdjustments['$subject|$monthKey'] ?? const [0, 0];

  void addPayrollRecord(PayrollRecord r) {
    payrollHistory.removeWhere(
        (p) => p.subjectName == r.subjectName && p.monthKey == r.monthKey);
    payrollHistory.insert(0, r);
    notifyListeners();
  }

  void setPayrollPaid(PayrollRecord r, bool paid) {
    final i = payrollHistory.indexOf(r);
    if (i >= 0) {
      payrollHistory[i] = r.copyWith(paid: paid);
      notifyListeners();
    }
  }

  void removePayrollRecord(PayrollRecord r) {
    payrollHistory.remove(r);
    notifyListeners();
  }

  void clockIn() {
    clockedIn = true;
    clockInAt = DateTime.now();
    notifyListeners();
  }

  void clockOut() {
    if (clockInAt != null) {
      myAttendanceLog.insert(
        0,
        AttendanceLog(
          dateKey: dateKeyOf(clockInAt!),
          clockInIso: clockInAt!.toIso8601String(),
          clockOutIso: DateTime.now().toIso8601String(),
        ),
      );
    }
    clockedIn = false;
    clockInAt = null;
    notifyListeners();
  }

  void setNotifications(bool v) {
    notificationsEnabled = v;
    notifyListeners();
  }

  void setBiometric(bool v) {
    biometricEnabled = v;
    notifyListeners();
  }

  void setWeeklyReport(bool v) {
    weeklyReportEnabled = v;
    notifyListeners();
  }
}

/// Global app state instance. Replaced at startup with the persisted state
/// when binary local storage has data.
AppState appState = AppState();
