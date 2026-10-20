import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management/main.dart';
import 'package:hr_management/data/app_state.dart';
import 'package:hr_management/models/models.dart';
import 'package:hr_management/screens/add_employee_screen.dart';
import 'package:hr_management/screens/employees_screen.dart';

void main() {
  Future<void> openConfiguredApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    appState.replaceWith(<String, dynamic>{}); // isolate tests from each other
    appState.completeSetup(
      company: 'Test Co',
      name: 'Test Manager',
      role: 'HR Manager',
      curr: 'BDT',
      overtimeRate: 100,
    );
    await tester.pumpWidget(const HrApp());
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Total Employees'), findsOneWidget);
  }

  testWidgets('Bottom navigation walks every main tab', (tester) async {
    await openConfiguredApp(tester);

    await tester.tap(find.text('Employees').last);
    await tester.pumpAndSettle();
    expect(find.text('No employees yet'), findsOneWidget);

    await tester.tap(find.text('Leaves').last);
    await tester.pumpAndSettle();
    expect(find.text('Leave Requests'), findsOneWidget);
    expect(find.text('Annual Left'), findsOneWidget);

    await tester.tap(find.text('More').last);
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
  });

  testWidgets('Add employee through the UI, then search finds them',
      (tester) async {
    await openConfiguredApp(tester);
    await tester.tap(find.text('Employees').last);
    await tester.pumpAndSettle();

    final addBtn = find.descendant(
      of: find.byType(EmployeesScreen),
      matching: find.text('Add Employee'),
    );
    await tester.tap(addBtn);
    await tester.pumpAndSettle();

    final form = find.byType(AddEmployeeScreen);
    final fields =
        find.descendant(of: form, matching: find.byType(TextFormField));
    await tester.enterText(fields.at(0), 'Rahim Uddin');
    await tester.enterText(fields.at(1), 'Carpenter');
    final submit = find.descendant(
      of: form,
      matching: find.widgetWithText(ElevatedButton, 'Add Employee'),
    );
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(find.text('Rahim Uddin'), findsOneWidget);
    final search = find.descendant(
      of: find.byType(EmployeesScreen),
      matching: find.byType(TextField),
    );
    await tester.enterText(search, 'Rahim');
    await tester.pumpAndSettle();
    expect(find.text('Rahim Uddin'), findsOneWidget);
    await tester.enterText(search, 'Nobody');
    await tester.pumpAndSettle();
    expect(find.text('Rahim Uddin'), findsNothing);
  });

  testWidgets('Attendance clock in/out and employee marking', (tester) async {
    await openConfiguredApp(tester);
    appState.addEmployee(Employee(
      id: 'e-nav-1',
      name: 'Karim Mia',
      role: 'Worker',
      department: 'Operations Department',
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('More').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Attendance'));
    await tester.pumpAndSettle();
    expect(find.text('Clock In'), findsOneWidget);
    await tester.tap(find.text('Clock In'));
    await tester.pumpAndSettle();
    expect(find.text('Clock Out'), findsOneWidget);
    expect(find.text('Karim Mia'), findsOneWidget);
    // Mark Karim present
    await tester.tap(find.text('Mark').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Present').last);
    await tester.pumpAndSettle();
    expect(appState.presentToday, 1);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
  });

  testWidgets('Payroll and overtime screens open with real empty states',
      (tester) async {
    await openConfiguredApp(tester);
    await tester.tap(find.text('More').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Payroll'));
    await tester.pumpAndSettle();
    expect(find.text('Generate Payslip'), findsOneWidget);
    expect(find.text('No payslips yet. Generate the first one above.'),
        findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Overtime'));
    await tester.pumpAndSettle();
    expect(find.text('Total Hours'), findsOneWidget);
    expect(find.text('0h'), findsWidgets);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Settings'));
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Export Binary Backup'), findsOneWidget);
    expect(find.text('Erase All Data'), findsOneWidget);
  });

  testWidgets('Desktop width shows the sidebar layout', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    appState.replaceWith(<String, dynamic>{});
    appState.completeSetup(
      company: 'Test Co',
      name: 'Test Manager',
      role: 'HR Manager',
      curr: 'BDT',
      overtimeRate: 100,
    );
    await tester.pumpWidget(const HrApp());
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    // Sidebar menu items are visible without opening a "More" tab.
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    // No bottom navigation labels row on desktop (sidebar replaces it).
    await tester.tap(find.text('Employees').first);
    await tester.pumpAndSettle();
    expect(find.text('No employees yet'), findsOneWidget);
  });
}
