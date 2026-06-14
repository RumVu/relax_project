import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/api_client.dart';
import '../../core/audio_controller.dart';
import '../../core/auth_state.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';

class RoutineRunScreen extends StatefulWidget {
  const RoutineRunScreen({super.key, required this.routine});
  final Map<String, dynamic> routine;

  @override
  State<RoutineRunScreen> createState() => _RoutineRunScreenState();
}

class _RoutineRunScreenState extends State<RoutineRunScreen> {
  int _currentStepIndex = 0;
  bool _completed = false;
  late final List<dynamic> _steps;

  // Step state: Quote
  String _quoteText = 'Hành trình vạn dặm khởi đầu từ một bước chân lẻ loi.';
  String _quoteAuthor = 'Lão Tử';
  bool _loadingQuote = false;

  // Step state: Breathing
  Timer? _breathingTimer;
  int _breathingSeconds = 15;
  String _breathingPhase = 'Hít vào...'; // 'Hít vào', 'Giữ lại', 'Thở ra'
  int _breathingCycleCount = 0;
  double _bubbleScale = 1.0;

  // Step state: Journal
  final _journalCtrl = TextEditingController();
  bool _savingJournal = false;

  // Step state: Grounding
  int _groundingSubStep = 5; // 5 -> 4 -> 3 -> 2 -> 1
  final List<String> _groundingInputs = List.generate(5, (_) => '');

  // Step state: Check-in
  String _selectedMood = 'NEUTRAL';
  int _selectedIntensity = 5;

  @override
  void initState() {
    super.initState();
    _steps = widget.routine['steps'] as List;
    _startStep(0);
  }

  @override
  void dispose() {
    _breathingTimer?.cancel();
    _journalCtrl.dispose();
    super.dispose();
  }

  void _startStep(int index) {
    if (index >= _steps.length) {
      setState(() => _completed = true);
      _onRoutineCompleted();
      return;
    }

    final step = _steps[index];
    final type = step['type'];

    if (type == 'quote') {
      _loadQuote();
    } else if (type == 'breathing') {
      _startBreathing();
    } else if (type == 'soundscape') {
      _startSoundscape();
    }
  }

  // --- Quote Logic ---
  Future<void> _loadQuote() async {
    setState(() => _loadingQuote = true);
    try {
      final res = await RelaxApi.instance.get('/cozy-quotes/random');
      final data = res.data;
      if (data is Map) {
        setState(() {
          _quoteText = (data['content'] as String?) ?? _quoteText;
          _quoteAuthor = (data['author'] as String?) ?? _quoteAuthor;
        });
      }
    } catch (_) {}
    setState(() => _loadingQuote = false);
  }

  // --- Breathing Logic ---
  void _startBreathing() {
    _breathingSeconds = 15;
    _breathingCycleCount = 0;
    _breathingPhase = 'Hít vào...';
    _bubbleScale = 1.0;
    _breathingTimer?.cancel();

    _breathingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_breathingSeconds <= 1) {
          // Xoay vòng nhịp thở 4-2-4
          if (_breathingPhase.startsWith('Hít vào')) {
            _breathingPhase = 'Giữ thở...';
            _breathingSeconds = 4;
            _bubbleScale = 1.5;
          } else if (_breathingPhase.startsWith('Giữ thở')) {
            _breathingPhase = 'Thở ra nhẹ nhàng...';
            _breathingSeconds = 6;
            _bubbleScale = 1.0;
          } else {
            _breathingPhase = 'Hít vào...';
            _breathingSeconds = 4;
            _bubbleScale = 1.2;
            _breathingCycleCount++;
          }
        } else {
          _breathingSeconds--;
          // Hiệu ứng phồng xẹp
          if (_breathingPhase.startsWith('Hít vào')) {
            _bubbleScale += 0.08;
          } else if (_breathingPhase.startsWith('Thở ra')) {
            _bubbleScale -= 0.05;
          }
        }
      });

      // Dừng sau 3 chu kỳ hoàn chỉnh
      if (_breathingCycleCount >= 3) {
        _breathingTimer?.cancel();
        _nextStep();
      }
    });
  }

  // --- Soundscape Logic ---
  void _startSoundscape() {
    final audio = context.read<AudioController>();
    // Chọn bài hát mưa thiên nhiên mặc định
    final mockTrack = {
      'id': 'soundscape_preset_rain',
      'title': 'Tiếng mưa rơi nhẹ',
      'category': 'AMBIENT',
      'soundUrl': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      'duration': 300,
    };
    audio.setQueue([mockTrack]);
    audio.playAt(0);
  }

  // --- Journal Logic ---
  Future<void> _saveJournal() async {
    if (_journalCtrl.text.trim().isEmpty) {
      _nextStep();
      return;
    }
    setState(() => _savingJournal = true);
    try {
      await RelaxApi.instance.post('/journals/me', body: {
        'title': 'Nhật ký routine: ${widget.routine['title']}',
        'content': _journalCtrl.text.trim(),
        'mood': 'NEUTRAL',
        'tags': ['routine', widget.routine['id']],
        'isPrivate': true,
      });
      if (mounted) {
        showSoftToast(context, message: context.t('Đã lưu nhật ký!'), tone: SoftToastTone.success);
      }
    } catch (_) {}
    setState(() => _savingJournal = false);
    _nextStep();
  }

  // --- Check-in Submit ---
  Future<void> _submitCheckin() async {
    try {
      await RelaxApi.instance.post('/mood-checkins/me', body: {
        'mood': _selectedMood,
        'intensity': _selectedIntensity,
        'note': 'Hoàn thành routine: ${widget.routine['title']}',
        'tags': ['routine', widget.routine['id']],
      });
    } catch (_) {}
    _nextStep();
  }

  // --- Routine Completion ---
  void _onRoutineCompleted() {
    final audio = context.read<AudioController>();
    audio.stop();

    // Tăng điểm năng lượng hoặc streak local
    Hive.openBox('mood_budget').then((box) {
      final currentEnergy = box.get('energy', defaultValue: 70) as int;
      final currentStress = box.get('stress', defaultValue: 45) as int;
      box.put('energy', (currentEnergy + 15).clamp(0, 100));
      box.put('stress', (currentStress - 15).clamp(0, 100));
    }).catchError((_) {});

    // Lưu vào lịch sử streak ở Backend (nếu có)
    // Thêm log hoàn thành routine vào feed
    final auth = context.read<AuthState>();
    if (auth.activeSessionId != null) {
      auth.finishRelaxSession(
        auth.activeSessionId!,
        moodAfter: _selectedMood,
        reliefLevel: _selectedIntensity,
        note: 'Routine hoàn thành: ${widget.routine['title']}',
      );
    }
  }

  void _nextStep() {
    _breathingTimer?.cancel();
    setState(() {
      _currentStepIndex++;
      _startStep(_currentStepIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return _buildCompletionScreen();
    }

    final step = _steps[_currentStepIndex];
    final type = step['type'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.appText),
          onPressed: () {
            final audio = context.read<AudioController>();
            audio.stop();
            context.pop();
          },
        ),
        title: Text(
          '${widget.routine['emoji']} ${context.t(widget.routine['title'] ?? '')} (${_currentStepIndex + 1}/${_steps.length})',
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentStepIndex + 1) / _steps.length,
                backgroundColor: context.fieldBorder,
                color: RelaxColors.violet,
                borderRadius: BorderRadius.circular(6),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: _buildStepContent(type, step),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildStepActions(type),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(String type, dynamic step) {
    if (type == 'quote') {
      return _buildQuoteStep();
    } else if (type == 'breathing') {
      return _buildBreathingStep();
    } else if (type == 'soundscape') {
      return _buildSoundscapeStep();
    } else if (type == 'journal') {
      return _buildJournalStep();
    } else if (type == 'grounding') {
      return _buildGroundingStep();
    } else if (type == 'checkin') {
      return _buildCheckinStep();
    }
    return Text(context.t('Bước không xác định'));
  }

  Widget _buildStepActions(String type) {
    if (type == 'quote') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _nextStep,
          child: Text(context.t('Đồng ý, đi tiếp')),
        ),
      );
    } else if (type == 'breathing') {
      return Text(
        context.t('Hoàn thành 3 chu kỳ thở để tự động tiếp tục...'),
        style: TextStyle(color: context.mutedText, fontSize: 12),
      );
    } else if (type == 'soundscape') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _nextStep,
          child: Text(context.t('Tiếp tục')),
        ),
      );
    } else if (type == 'journal') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _savingJournal ? null : _saveJournal,
          child: _savingJournal
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(context.t('Lưu nhật ký & Đi tiếp')),
        ),
      );
    } else if (type == 'grounding') {
      final isLast = _groundingSubStep == 1;
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (isLast) {
              _nextStep();
            } else {
              setState(() {
                _groundingSubStep--;
              });
            }
          },
          child: Text(isLast ? context.t('Hoàn thành Grounding') : context.t('Tiếp tục bước kế')),
        ),
      );
    } else if (type == 'checkin') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _submitCheckin,
          child: Text(context.t('Hoàn tất check-in')),
        ),
      );
    }
    return const SizedBox();
  }

  // --- Step Content Widgets ---

  Widget _buildQuoteStep() {
    return _loadingQuote
        ? const CircularProgressIndicator(color: RelaxColors.violet)
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💬', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                '“$_quoteText”',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: context.appText,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '- $_quoteAuthor',
                style: TextStyle(color: context.mutedText, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          );
  }

  Widget _buildBreathingStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          scale: _bubbleScale,
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          child: Container(
            height: 140,
            width: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  RelaxColors.violet.withValues(alpha: 0.6),
                  RelaxColors.violet.withValues(alpha: 0.1),
                ],
              ),
              border: Border.all(color: RelaxColors.violet.withValues(alpha: 0.4), width: 3),
            ),
            child: const Center(
              child: Text('🌬️', style: TextStyle(fontSize: 40)),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          context.t(_breathingPhase),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.appText),
        ),
        const SizedBox(height: 10),
        Text(
          '${_breathingSeconds}s',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: RelaxColors.violet),
        ),
        const SizedBox(height: 16),
        Text(
          '${context.t("Nhịp thở")}: ${_breathingCycleCount + 1}/3',
          style: TextStyle(color: context.mutedText, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSoundscapeStep() {
    final audio = context.watch<AudioController>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🎵', style: TextStyle(fontSize: 54)),
        const SizedBox(height: 16),
        Text(
          context.t('Đang phát tiếng mưa rơi...'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.appText),
        ),
        const SizedBox(height: 20),
        IconButton(
          iconSize: 64,
          icon: Icon(audio.playing ? Icons.pause_circle_filled : Icons.play_circle_filled, color: RelaxColors.violet),
          onPressed: () => audio.toggle(),
        ),
        const SizedBox(height: 12),
        Text(
          context.t('Bạn có thể nhắm mắt thư giãn 5 phút.'),
          style: TextStyle(color: context.mutedText, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildJournalStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('✍️', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 12),
        Text(
          context.t('Lắng đọng tâm tư'),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.appText),
        ),
        const SizedBox(height: 6),
        Text(
          context.t('Viết ra những gì đang hiện lên trong đầu bạn để dọn dẹp suy nghĩ.'),
          style: TextStyle(color: context.mutedText, fontSize: 13),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _journalCtrl,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: context.t('Hôm nay cảm xúc của tôi là...'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildGroundingStep() {
    String stepTitle = '';
    String stepDesc = '';
    String stepIcon = '⚓';

    switch (_groundingSubStep) {
      case 5:
        stepIcon = '👀';
        stepTitle = '5 thứ bạn nhìn thấy';
        stepDesc = 'Tìm xung quanh 5 đồ vật và gọi tên chúng thầm trong đầu.';
        break;
      case 4:
        stepIcon = '✋';
        stepTitle = '4 thứ bạn cảm nhận';
        stepDesc = 'Cảm nhận quần áo, mặt bàn, hay làn gió đang chạm vào da.';
        break;
      case 3:
        stepIcon = '👂';
        stepTitle = '3 thứ bạn nghe thấy';
        stepDesc = 'Lắng nghe âm thanh xung quanh: tiếng quạt, xe cộ, tiếng chim.';
        break;
      case 2:
        stepIcon = '👃';
        stepTitle = '2 thứ bạn ngửi thấy';
        stepDesc = 'Mùi hương nước hoa, mùi cà phê hoặc đơn giản là mùi giấy.';
        break;
      case 1:
        stepIcon = '👅';
        stepTitle = '1 thứ bạn nếm thấy';
        stepDesc = 'Cảm nhận vị nước bọt, vị bạc hà hay một ngụm nước ấm.';
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(stepIcon, style: const TextStyle(fontSize: 54)),
        const SizedBox(height: 16),
        Text(
          context.t(stepTitle),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.appText),
        ),
        const SizedBox(height: 12),
        Text(
          context.t(stepDesc),
          textAlign: TextAlign.center,
          style: TextStyle(color: context.mutedText, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildCheckinStep() {
    final moods = [
      {'code': 'HAPPY', 'name': 'Vui vẻ', 'emoji': '😊'},
      {'code': 'CALM', 'name': 'Bình yên', 'emoji': '😌'},
      {'code': 'NEUTRAL', 'name': 'Bình thường', 'emoji': '😐'},
      {'code': 'ANXIOUS', 'name': 'Lo lắng', 'emoji': '😰'},
      {'code': 'SAD', 'name': 'Buồn bã', 'emoji': '😢'},
      {'code': 'STRESSED', 'name': 'Căng thẳng', 'emoji': '🤯'},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('📊', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(
          context.t('Hoàn thành chuỗi: Bạn thấy thế nào?'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.appText),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: moods.map((m) {
            final sel = _selectedMood == m['code'];
            return GestureDetector(
              onTap: () => setState(() => _selectedMood = m['code']!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? RelaxColors.violet.withValues(alpha: 0.15) : context.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sel ? RelaxColors.violet : context.fieldBorder, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(m['emoji']!, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(context.t(m['name']!), style: TextStyle(color: context.appText, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          '${context.t("Cường độ cảm xúc")}: $_selectedIntensity/10',
          style: TextStyle(color: context.appText, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: _selectedIntensity.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: RelaxColors.violet,
          onChanged: (val) => setState(() => _selectedIntensity = val.round()),
        ),
      ],
    );
  }

  Widget _buildCompletionScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 20),
              Text(
                context.t('Tuyệt vời!'),
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: context.appText),
              ),
              const SizedBox(height: 10),
              Text(
                context.t('Bạn đã hoàn thành trọn vẹn chuỗi Routine.'),
                textAlign: TextAlign.center,
                style: TextStyle(color: context.mutedText, fontSize: 14),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  child: Text(context.t('Hoàn thành')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
