import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';

class VoiceCheckinScreen extends StatefulWidget {
  const VoiceCheckinScreen({super.key});

  @override
  State<VoiceCheckinScreen> createState() => _VoiceCheckinScreenState();
}

class _VoiceCheckinScreenState extends State<VoiceCheckinScreen>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _available = false;
  bool _listening = false;
  String _transcript = '';
  String? _detectedMood;
  double _confidence = 0;
  bool _saving = false;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() => _listening = false);
            _pulseCtrl.stop();
            if (_transcript.isNotEmpty) {
              _analyzeMood(_transcript);
            }
          }
        }
      },
      onError: (_) {
        if (mounted) {
          setState(() => _listening = false);
          _pulseCtrl.stop();
        }
      },
    );
    if (mounted) setState(() {});
  }

  void _startListening() {
    if (!_available) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _transcript = '';
      _detectedMood = null;
      _listening = true;
    });
    _pulseCtrl.repeat(reverse: true);
    _speech.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _transcript = result.recognizedWords;
            _confidence = result.confidence;
          });
        }
      },
      localeId: 'vi_VN',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _listening = false);
    _pulseCtrl.stop();
    if (_transcript.isNotEmpty) {
      _analyzeMood(_transcript);
    }
  }

  void _analyzeMood(String text) {
    final lower = text.toLowerCase();

    final moodKeywords = <String, List<String>>{
      'HAPPY': ['vui', 'hạnh phúc', 'tuyệt vời', 'tốt', 'phấn khởi', 'hào hứng', 'sung sướng', 'thích', 'yêu', 'happy', 'great', 'good', 'excited'],
      'CALM': ['bình tĩnh', 'thư giãn', 'nhẹ nhàng', 'yên bình', 'thoải mái', 'ổn', 'calm', 'relaxed', 'peaceful', 'okay'],
      'SAD': ['buồn', 'đau', 'khóc', 'cô đơn', 'trống rỗng', 'thất vọng', 'sad', 'lonely', 'cry', 'hurt'],
      'ANXIOUS': ['lo lắng', 'lo âu', 'bất an', 'sợ', 'hồi hộp', 'căng', 'anxious', 'worried', 'nervous', 'afraid'],
      'STRESSED': ['stress', 'căng thẳng', 'áp lực', 'quá tải', 'mệt mỏi quá', 'kiệt sức', 'stressed', 'overwhelmed', 'pressure'],
      'ANGRY': ['tức', 'giận', 'bực', 'khó chịu', 'phiền', 'điên', 'angry', 'furious', 'annoyed', 'mad'],
      'TIRED': ['mệt', 'buồn ngủ', 'uể oải', 'kiệt', 'chán', 'lười', 'tired', 'sleepy', 'exhausted', 'bored'],
      'POOPING': ['mắc ỉa', 'đi vệ sinh', 'toilet', 'wc', 'đau bụng', 'poop'],
    };

    int bestScore = 0;
    String bestMood = 'NEUTRAL';

    for (final entry in moodKeywords.entries) {
      int score = 0;
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) {
          score += keyword.length;
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestMood = entry.key;
      }
    }

    setState(() => _detectedMood = bestMood);
  }

  Future<void> _saveCheckin() async {
    if (_detectedMood == null) return;
    setState(() => _saving = true);
    try {
      final res = await RelaxApi.instance.post('/mood-checkins/me', body: {
        'mood': _detectedMood,
        'intensity': 3,
        'note': _transcript,
        'tags': ['voice'],
      });
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        showSoftToast(
          context,
          message: context.t('Đã ghi nhận cảm xúc qua giọng nói!'),
          tone: SoftToastTone.success,
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        showSoftToast(
          context,
          message: context.t('Không thể lưu. Thử lại nhé.'),
          tone: SoftToastTone.error,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          context.isDark ? const Color(0xFF0d1117) : RelaxColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Check-in bằng giọng nói'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Mic button
              GestureDetector(
                onTap: _listening ? _stopListening : _startListening,
                child: AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (ctx, child) {
                    final scale = _listening ? 1.0 + _pulseCtrl.value * 0.15 : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _listening
                                ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                                : [RelaxColors.violet, RelaxColors.plum],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_listening
                                      ? const Color(0xFFEF4444)
                                      : RelaxColors.violet)
                                  .withValues(alpha: 0.35),
                              blurRadius: 30,
                              spreadRadius: _listening ? 8 : 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _listening ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              Text(
                _listening
                    ? context.t('Đang nghe... nói về cảm xúc của bạn')
                    : !_available
                        ? context.t('Không thể truy cập micro')
                        : context.t('Nhấn để bắt đầu nói'),
                style: TextStyle(
                  color: context.mutedText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Transcript
              if (_transcript.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.fieldBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.format_quote,
                              color: RelaxColors.violet, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            context.t('Bạn đã nói:'),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: context.appText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _transcript,
                        style: TextStyle(
                          color: context.appText,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Detected mood
              if (_detectedMood != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _moodColor(_detectedMood!).withValues(alpha: 0.15),
                        _moodColor(_detectedMood!).withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _moodColor(_detectedMood!).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _moodEmoji(_detectedMood!),
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.t('Cảm xúc phát hiện:'),
                        style: TextStyle(
                          color: context.mutedText,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _moodLabel(_detectedMood!),
                        style: TextStyle(
                          color: _moodColor(_detectedMood!),
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Change mood
                          TextButton(
                            onPressed: _startListening,
                            child: Text(
                              context.t('Thử lại'),
                              style: TextStyle(
                                color: context.mutedText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Save
                          ElevatedButton(
                            onPressed: _saving ? null : _saveCheckin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _moodColor(_detectedMood!),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    context.t('Ghi nhận'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  String _moodEmoji(String mood) {
    switch (mood) {
      case 'HAPPY': return '😊';
      case 'CALM': return '😌';
      case 'SAD': return '😢';
      case 'ANXIOUS': return '😰';
      case 'STRESSED': return '😫';
      case 'ANGRY': return '😠';
      case 'TIRED': return '🥱';
      case 'POOPING': return '💩';
      default: return '😐';
    }
  }

  String _moodLabel(String mood) {
    switch (mood) {
      case 'HAPPY': return 'Vui vẻ';
      case 'CALM': return 'Bình tĩnh';
      case 'SAD': return 'Buồn';
      case 'ANXIOUS': return 'Lo lắng';
      case 'STRESSED': return 'Căng thẳng';
      case 'ANGRY': return 'Tức giận';
      case 'TIRED': return 'Mệt mỏi';
      case 'POOPING': return 'Mắc ỉa';
      default: return 'Bình thường';
    }
  }

  Color _moodColor(String mood) {
    switch (mood) {
      case 'HAPPY': return RelaxColors.sun;
      case 'CALM': return RelaxColors.mint;
      case 'SAD': return const Color(0xFF6366F1);
      case 'ANXIOUS': return RelaxColors.violet;
      case 'STRESSED': return RelaxColors.coral;
      case 'ANGRY': return const Color(0xFFEF4444);
      case 'TIRED': return const Color(0xFF6B7280);
      case 'POOPING': return const Color(0xFF8B4513);
      default: return const Color(0xFF6366F1);
    }
  }
}
