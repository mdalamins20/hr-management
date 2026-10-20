import 'dart:async';
import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Attendance: my live clock in/out plus per-employee marking for today.
/// All numbers come from real marks - nothing is pre-filled.
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _timeLabel(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    return '${_two(h)}:${_two(t.minute)} ${t.hour >= 12 ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final s = appState;
        final now = DateTime.now();
        final elapsed = s.clockedIn && s.clockInAt != null
            ? now.difference(s.clockInAt!)
            : Duration.zero;
        final progress =
            (elapsed.inSeconds / const Duration(hours: 8).inSeconds)
                .clamp(0.0, 1.0);
        final workedLabel = s.clockedIn
            ? '${elapsed.inHours}h ${_two(elapsed.inMinutes % 60)}m worked'
            : 'Not clocked in';

        final body = SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                children: [
                  Text(
                    'Today, ${fmtDate(now)}',
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: 196,
                    height: 196,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(
                          width: 196,
                          height: 196,
                          child: CircularProgressIndicator(
                            value: 1,
                            strokeWidth: 11,
                            color: AppColors.border,
                          ),
                        ),
                        SizedBox(
                          width: 196,
                          height: 196,
                          child: CircularProgressIndicator(
                            value: progress.toDouble(),
                            strokeWidth: 11,
                            strokeCap: StrokeCap.round,
                            color: AppColors.primary,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: s.clockedIn
                                        ? AppColors.green
                                        : AppColors.textGrey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  s.clockedIn ? 'In Office' : 'Out of Office',
                                  style: TextStyle(
                                    color: s.clockedIn
                                        ? AppColors.green
                                        : AppColors.textGrey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.clockedIn && s.clockInAt != null
                                  ? _timeLabel(s.clockInAt!)
                                  : '--:--',
                              style: const TextStyle(
                                fontSize: 31,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              s.clockedIn ? 'Clocked in at' : 'Working Hours',
                              style: const TextStyle(
                                  color: AppColors.textGrey, fontSize: 12),
                            ),
                            Text(
                              workedLabel,
                              style: const TextStyle(
                                  color: AppColors.textGrey, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      MiniStat(
                          label: 'Present',
                          value: '${s.presentToday}',
                          dotColor: AppColors.green),
                      const SizedBox(width: 10),
                      MiniStat(
                          label: 'Late',
                          value: '${s.lateToday}',
                          dotColor: AppColors.orange),
                      const SizedBox(width: 10),
                      MiniStat(
                          label: 'Absent',
                          value: '${s.absentToday}',
                          dotColor: AppColors.red),
                    ],
                  ),
                  if (s.unmarkedToday > 0 && s.totalEmployees > 0) ...[
                    const SizedBox(height: 10),
                    Text(
                      '${s.unmarkedToday} employee(s) not marked yet today - tap a person below to mark them.',
                      style: const TextStyle(
                          color: AppColors.textGrey, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (s.clockedIn) {
                          s.clockOut();
                          showSnack(context, 'Clocked out. Day saved.');
                        } else {
                          s.clockIn();
                          showSnack(context, 'Clocked in successfully');
                        }
                      },
                      icon: Icon(s.clockedIn ? Icons.logout : Icons.login,
                          size: 19),
                      label: Text(s.clockedIn ? 'Clock Out' : 'Clock In'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle(title: "Today's Attendance"),
                  const SizedBox(height: 12),
                  if (s.employees.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'No employees yet. Add employees first, then mark their attendance here.',
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                    )
                  else
                    ...s.employees.map((e) => _markTile(context, e)),
                  if (s.myAttendanceLog.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const SectionTitle(title: 'My Recent Days'),
                    const SizedBox(height: 10),
                    ...s.myAttendanceLog.take(5).map(
                          (log) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 11),
                            decoration: cardDecoration(radius: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.history,
                                    size: 18, color: AppColors.primary),
                                const SizedBox(width: 10),
                                Expanded(child: Text(log.dateKey)),
                                Text(
                                  '${_timeLabel(DateTime.parse(log.clockInIso))} → ${_timeLabel(DateTime.parse(log.clockOutIso))}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          ),
        );

        if (widget.embedded) return body;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Attendance'),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 18),
                child: Icon(Icons.calendar_month_outlined, size: 21),
              ),
            ],
          ),
          body: body,
        );
      },
    );
  }

  Widget _markTile(BuildContext context, Employee e) {
    final status = appState.attendanceOf(e, appState.todayKey);
    final Color dot = switch (status) {
      'Present' => AppColors.green,
      'Late' => AppColors.orange,
      'Absent' => AppColors.red,
      'On Leave' => AppColors.orange,
      _ => AppColors.textGrey,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: cardDecoration(radius: 14),
      child: Row(
        children: [
          Avatar(name: e.name, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13.5)),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration:
                          BoxDecoration(color: dot, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text(status,
                        style: const TextStyle(
                            color: AppColors.textGrey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.lavenderBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Mark',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  Icon(Icons.arrow_drop_down,
                      color: AppColors.primary, size: 17),
                ],
              ),
            ),
            onSelected: (v) {
              appState.setAttendanceMark(e, v);
              showSnack(context, '${e.name} marked $v');
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'Present', child: Text('Present')),
              PopupMenuItem(value: 'Late', child: Text('Late')),
              PopupMenuItem(value: 'Absent', child: Text('Absent')),
              PopupMenuItem(value: 'Not marked', child: Text('Clear mark')),
            ],
          ),
        ],
      ),
    );
  }
}
