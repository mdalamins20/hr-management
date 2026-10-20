import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management/main.dart';
import 'package:hr_management/data/app_state.dart';
import 'package:hr_management/data/binary_store.dart';
import 'package:hr_management/models/models.dart';

void main() {
  testWidgets('App starts on splash with Get Started', (tester) async {
    await tester.pumpWidget(const HrApp());
    expect(find.text('HR Management'), findsWidgets);
    expect(find.text('Better People. Stronger Teams.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('Fresh install goes to Setup, then empty dashboard',
      (tester) async {
    await tester.pumpWidget(const HrApp());
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Set Up Your Company'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Dewan Furniture');
    await tester.enterText(fields.at(1), 'Test Manager');
    await tester.tap(find.text('Start Using HR Management'));
    await tester.pumpAndSettle();

    // No demo data: honest zeros and a getting-started checklist.
    expect(find.text('Total Employees'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
    expect(find.text('Getting Started'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
  });

  test('Fresh AppState has NO demo data', () {
    final s = AppState();
    expect(s.configured, isFalse);
    expect(s.employees, isEmpty);
    expect(s.leaveRequests, isEmpty);
    expect(s.overtimeEntries, isEmpty);
    expect(s.payrollHistory, isEmpty);
    expect(s.totalEmployees, 0);
    expect(s.presentToday, 0);
  });

  test('Binary codec round-trips app data and rejects corruption', () {
    final data = <String, dynamic>{
      'companyName': 'Acme',
      'employees': [
        {'id': 'e1', 'name': 'A'}
      ],
      'count': 42,
    };
    final bytes = BinaryCodec.encode(data);
    expect(bytes.sublist(0, 4), [0x48, 0x52, 0x4D, 0x42]); // HRMB magic
    final back = BinaryCodec.decode(bytes);
    expect(back, isNotNull);
    expect(back!['companyName'], 'Acme');
    expect(back['count'], 42);

    final corrupted = Uint8List.fromList(bytes);
    corrupted[12] = corrupted[12] ^ 0xFF;
    expect(BinaryCodec.decode(corrupted), isNull);

    final b64 = BinaryCodec.encodeToBase64(data);
    expect(BinaryCodec.decodeFromBase64(b64)!['companyName'], 'Acme');
    expect(BinaryCodec.decodeFromBase64('not-a-backup'), isNull);
  });

  test('State serialises to binary and restores with data intact', () {
    final s = AppState();
    s.completeSetup(
      company: 'Acme Ltd',
      name: 'Manager One',
      role: 'HR Manager',
      curr: 'BDT',
      overtimeRate: 120,
    );
    s.addEmployee(Employee(
      id: 'e1',
      name: 'Worker One',
      role: 'Engineer',
      department: 'IT Department',
      salary: 30000,
    ));
    final restored =
        AppState.fromMap(BinaryCodec.decode(BinaryCodec.encode(s.toMap()))!);
    expect(restored.configured, isTrue);
    expect(restored.companyName, 'Acme Ltd');
    expect(restored.employees.single.name, 'Worker One');
    expect(restored.employees.single.salary, 30000);
    expect(restored.currency, 'BDT');
  });

  test('Adding an employee updates counters; leave days are inclusive', () {
    final s = AppState();
    s.addEmployee(Employee(
      id: 'x1',
      name: 'Test Person',
      role: 'Tester',
      department: 'IT Department',
    ));
    expect(s.totalEmployees, 1);
    final r = LeaveRequest(
      id: 't1',
      employeeName: 'A',
      type: 'Annual Leave',
      start: DateTime(2026, 10, 20),
      end: DateTime(2026, 10, 24),
      reason: 'x',
    );
    expect(r.days, 5);
  });
}
