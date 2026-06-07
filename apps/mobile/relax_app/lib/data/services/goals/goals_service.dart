import 'package:shared_preferences/shared_preferences.dart';

/// Goals tuần — mục tiêu mềm user tự đặt + tracking progress.
///
/// 3 default goals (user có thể disable nhưng KHÔNG xóa):
///   - mood_checkins_week: số lần check-in mood / tuần
///   - relax_sessions_week: số phiên thư giãn / tuần
///   - journal_entries_week: số nhật ký / tuần
///
/// Lưu target value vào SharedPreferences. Progress được tính từ moodHistory
/// + journal count + session count (truyền từ shell).
class GoalsService {
  GoalsService._();
  static final instance = GoalsService._();

  static const _moodTargetKey = 'goal_mood_week';
  static const _relaxTargetKey = 'goal_relax_week';
  static const _journalTargetKey = 'goal_journal_week';

  Future<Goals> load() async {
    final prefs = await SharedPreferences.getInstance();
    return Goals(
      moodCheckinsWeek: prefs.getInt(_moodTargetKey) ?? 5,
      relaxSessionsWeek: prefs.getInt(_relaxTargetKey) ?? 2,
      journalEntriesWeek: prefs.getInt(_journalTargetKey) ?? 1,
    );
  }

  Future<void> save(Goals goals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_moodTargetKey, goals.moodCheckinsWeek);
    await prefs.setInt(_relaxTargetKey, goals.relaxSessionsWeek);
    await prefs.setInt(_journalTargetKey, goals.journalEntriesWeek);
  }
}

class Goals {
  const Goals({
    required this.moodCheckinsWeek,
    required this.relaxSessionsWeek,
    required this.journalEntriesWeek,
  });

  final int moodCheckinsWeek;
  final int relaxSessionsWeek;
  final int journalEntriesWeek;

  Goals copyWith({
    int? moodCheckinsWeek,
    int? relaxSessionsWeek,
    int? journalEntriesWeek,
  }) =>
      Goals(
        moodCheckinsWeek: moodCheckinsWeek ?? this.moodCheckinsWeek,
        relaxSessionsWeek: relaxSessionsWeek ?? this.relaxSessionsWeek,
        journalEntriesWeek: journalEntriesWeek ?? this.journalEntriesWeek,
      );
}
