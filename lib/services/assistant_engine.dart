import '../data/timetable_data.dart';
import 'attendance_api.dart';
import 'results_api.dart';

class AssistantEngine {
  static Future<String> respond(String question) async {
    final q = question.toLowerCase();

    if (_matches(q, ['fee', 'balance', 'pay', 'owe'])) {
      return _feesAnswer();
    }
    if (_matches(q, ['attendance', 'present', 'absent', 'biometric'])) {
      return _attendanceAnswer();
    }
    if (_matches(q, ['result', 'grade', 'mark', 'cat', 'score'])) {
      return _resultsAnswer();
    }
    if (_matches(q, ['class', 'timetable', 'schedule', 'lesson', 'next class'])) {
      return _timetableAnswer();
    }
    if (_matches(q, ['retake', 're-retake', 'special exam', 'exam registration', 'register for exam'])) {
      return _examRegistrationAnswer(q);
    }
    if (_matches(q, ['register', 'course registration', 'unit'])) {
      return 'You can register for your units and confirm your course under Course registration on your dashboard. Make sure to add each unit code before submitting.';
    }
    if (_matches(q, ['hello', 'hi', 'hey'])) {
      return 'Hi! I can help with questions about your fees, attendance, results, timetable, or exam registration. What would you like to know?';
    }

    return 'I\'m not sure about that one yet. I can currently help with fees, attendance, results, your timetable, and exam registration — try asking about one of those.';
  }

  static bool _matches(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  static Future<String> _feesAnswer() async {
    return 'You can see your exact fee balance, total billed, and payment status on the Fees screen. If your balance is high relative to what you\'ve paid, I\'d recommend clearing some before exams to avoid delays accessing your results.';
  }

  static Future<String> _attendanceAnswer() async {
    try {
      final record = await AttendanceApi.fetchAttendance();
      final percent = (record.overallRate * 100).round();
      if (percent < 75) {
        return 'Your overall attendance is currently $percent%, which is below the 75% typically required for exam eligibility. Check the Attendance screen to see which unit needs the most attention.';
      }
      return 'Your overall attendance is $percent%, which meets the standard requirement. Nice work staying consistent.';
    } catch (_) {
      return 'I couldn\'t fetch your attendance right now — check your connection and try the Attendance screen directly.';
    }
  }

  static Future<String> _resultsAnswer() async {
    try {
      final results = await ResultsApi.fetchResults();
      if (results.isEmpty) return 'I don\'t see any results yet for this semester.';
      final weakest = results.reduce((a, b) => a.total < b.total ? a : b);
      final best = results.reduce((a, b) => a.total > b.total ? a : b);
      return 'Your strongest unit so far is ${best.unitCode} at ${best.total}%, and ${weakest.unitCode} is your weakest at ${weakest.total}%. Tap any unit on the Results screen to see the CAT and exam breakdown.';
    } catch (_) {
      return 'I couldn\'t fetch your results right now — check your connection and try the Results screen directly.';
    }
  }

  static String _timetableAnswer() {
    final next = TimetableData.nextClass(DateTime.now());
    final onlineNote = next.isOnline ? ' This one is online — you can join it from the Timetable screen.' : '';
    return 'Your next class is ${next.unit} on ${next.day} at ${next.time} in ${next.room}.$onlineNote';
  }

  static String _examRegistrationAnswer(String q) {
    if (q.contains('re-retake') || q.contains('reretake')) {
      return 'A re-retake is for a unit you\'ve already retaken once and still haven\'t passed. It requires a reason and Dean\'s approval, and carries a KES 2,500 fee. You can submit one under Exam registration.';
    }
    if (q.contains('retake')) {
      return 'A retake is for a unit you sat once before and didn\'t pass. It carries a KES 1,500 fee per unit. Submit it under Exam registration.';
    }
    if (q.contains('special')) {
      return 'A special exam is for a first sitting you missed for a valid reason, like illness. It needs a reason and supporting evidence, and carries a KES 1,000 fee. You\'ll find it under Exam registration.';
    }
    return 'You can register for exams — first attempt, special, retake, or re-retake — under Exam registration. Each type has different requirements and fees, so check the notes shown when you select a type.';
  }
}
