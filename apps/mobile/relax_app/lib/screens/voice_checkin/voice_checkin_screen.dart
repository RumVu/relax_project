import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audio_session/audio_session.dart';

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
  String? _detectedMood;

  bool _saving = false;
  late AnimationController _pulseCtrl;
  String _bestLocale = 'vi_VN';
  final _transcriptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _initSpeech();
  }

  @override
  void dispose() {
    _speech.stop();
    _pulseCtrl.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  String _getReadableSpeechError(String errorCode, BuildContext ctx) {
    switch (errorCode) {
      case 'error_retry':
        return ctx.t('Không thể nhận diện. Vui lòng nói to rõ hơn, kiểm tra mạng, hoặc đảm bảo Siri và "Bật đọc chính tả" đã được bật trong Cài đặt iPhone.');
      case 'error_no_match':
        return ctx.t('Không nghe rõ từ nào. Bạn nói lại thử xem nhé.');
      case 'error_busy':
        return ctx.t('Hệ thống giọng nói đang bận. Vui lòng thử lại sau giây lát.');
      case 'error_speech_timeout':
        return ctx.t('Không nghe thấy tiếng nói. Hãy thử lại nhé.');
      case 'error_permission':
        return ctx.t('Ứng dụng chưa có quyền micro hoặc giọng nói. Vui lòng cho phép trong Cài đặt.');
      default:
        return '${ctx.t("Lỗi giọng nói:")} $errorCode';
    }
  }

  Future<void> _initSpeech() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth |
            AVAudioSessionCategoryOptions.defaultToSpeaker |
            AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.measurement,
      ));
      await session.setActive(true);
    } catch (e) {
      debugPrint('Configure audio session failed: $e');
    }

    _available = await _speech.initialize(
      onStatus: (status) {
        debugPrint('Speech status: $status');
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() => _listening = false);
            _pulseCtrl.stop();
          }
        }
      },
      onError: (val) {
        debugPrint('Speech error: ${val.errorMsg} - permanent: ${val.permanent}');
        if (mounted) {
          setState(() => _listening = false);
          _pulseCtrl.stop();
          showSoftToast(
            context,
            message: _getReadableSpeechError(val.errorMsg, context),
            tone: SoftToastTone.error,
          );
        }
      },
    );

    if (_available) {
      try {
        final locales = await _speech.locales();
        final hasVi = locales.any((l) =>
            l.localeId.toLowerCase() == 'vi_vn' ||
            l.localeId.toLowerCase().startsWith('vi-'));
        if (!hasVi && locales.isNotEmpty) {
          _bestLocale = locales.first.localeId;
        }
      } catch (_) {}
    }

    if (mounted) setState(() {});
  }

  void _startListening() async {
    // Configure and activate audio session specifically before listening
    try {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth |
            AVAudioSessionCategoryOptions.defaultToSpeaker |
            AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.measurement,
      ));
      await session.setActive(true);
    } catch (e) {
      debugPrint('Re-configure audio session failed: $e');
    }

    if (!_available) {
      await _initSpeech();
      if (!_available) {
        if (!mounted) return;
        showSoftToast(
          context,
          message: context.t('Vui lòng cấp quyền micro và nhận dạng giọng nói trong Cài đặt.'),
          tone: SoftToastTone.error,
        );
        return;
      }
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _transcriptController.clear();
      _detectedMood = null;
      _listening = true;
    });
    _pulseCtrl.repeat(reverse: true);
    try {
      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _transcriptController.text = result.recognizedWords;
            });
          }
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: _bestLocale,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _listening = false;
          _pulseCtrl.stop();
        });
        showSoftToast(
          context,
          message: '${context.t("Lỗi khởi chạy mic:")} $e',
          tone: SoftToastTone.error,
        );
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _listening = false);
    _pulseCtrl.stop();
  }

  Future<void> _analyzeVoice(String text) async {
    setState(() => _saving = true);
    String detected = 'NEUTRAL';

    // 1. High-priority local check for POOPING (toilet/slang check)
    final lower = text.toLowerCase();
    final words = lower.split(RegExp(r'[\s.,!?;\-\(\)\[\]\n\r]+'));

    final isPooping = lower.contains('mắc ẻ') ||
        lower.contains('mắc ỉa') ||
        lower.contains('đi ẻ') ||
        lower.contains('đi ỉa') ||
        lower.contains('mắc đi ẻ') ||
        lower.contains('mắc đi ỉa') ||
        lower.contains('đau bụng') ||
        lower.contains('đi vệ sinh') ||
        lower.contains('tào tháo rượt') ||
        lower.contains('tiêu chảy') ||
        lower.contains('mắc ị') ||
        lower.contains('đi ị') ||
        lower.contains('mắc đi ị') ||
        lower.contains('mac e') ||
        lower.contains('di e') ||
        lower.contains('mac ia') ||
        lower.contains('di ia') ||
        lower.contains('toilet') ||
        lower.contains('wc') ||
        lower.contains('poop') ||
        words.contains('ẻ') ||
        words.contains('ỉa') ||
        words.contains('ị');

    if (isPooping) {
      detected = 'POOPING';
    } else {
      // 2. Otherwise query backend
      try {
        final res = await RelaxApi.instance.post('/mood-checkins/voice', body: {'text': text});
        if (res.statusCode == 200 || res.statusCode == 201) {
          final data = res.data;
          if (data is Map && data['mood'] != null) {
            detected = data['mood'] as String;
          }
        }
      } catch (_) {
        detected = _localAnalyzeMood(text);
      }
    }

    setState(() {
      _detectedMood = detected;
      _saving = false;
    });

    if (mounted) {
      _showPredictionDialog(context, detected);
    }
  }

  String _localAnalyzeMood(String text) {
    final lower = text.toLowerCase();
    final words = lower.split(RegExp(r'[\s.,!?;\-\(\)\[\]\n\r]+'));

    final moodKeywords = <String, List<String>>{
      'HAPPY': ['vui', 'hạnh phúc', 'tuyệt vời', 'tốt', 'phấn khởi', 'hào hứng', 'sung sướng', 'thích', 'yêu', 'happy', 'great', 'good', 'excited'],
      'CALM': ['bình tĩnh', 'thư giãn', 'nhẹ nhàng', 'yên bình', 'thoải mái', 'ổn', 'calm', 'relaxed', 'peaceful', 'okay'],
      'SAD': ['buồn', 'đau', 'khóc', 'cô đơn', 'trống rỗng', 'thất vọng', 'sad', 'lonely', 'cry', 'hurt'],
      'ANXIOUS': ['lo lắng', 'lo âu', 'bất an', 'sợ', 'hồi hộp', 'căng', 'anxious', 'worried', 'nervous', 'afraid'],
      'STRESSED': ['stress', 'căng thẳng', 'áp lực', 'quá tải', 'mệt mỏi quá', 'kiệt sức', 'stressed', 'overwhelmed', 'pressure'],
      'ANGRY': ['tức', 'giận', 'bực', 'khó chịu', 'phiền', 'điên', 'angry', 'furious', 'annoyed', 'mad'],
      'TIRED': ['mệt', 'buồn ngủ', 'uể oải', 'kiệt', 'chán', 'lười', 'tired', 'sleepy', 'exhausted', 'bored'],
      'POOPING': ['ỉa', 'ẻ', 'ị', 'mắc ẻ', 'mắc ỉa', 'đi vệ sinh', 'toilet', 'wc', 'đau bụng', 'poop', 'tiêu chảy', 'tào tháo rượt'],
    };

    int bestScore = 0;
    String bestMood = 'NEUTRAL';

    for (final entry in moodKeywords.entries) {
      int score = 0;
      for (final keyword in entry.value) {
        if (entry.key == 'POOPING') {
          // Precise matching for POOPING to avoid false substrings
          if (keyword.length <= 3) {
            if (words.contains(keyword)) {
              score += 10;
            }
          } else {
            if (lower.contains(keyword)) {
              score += keyword.length;
            }
          }
        } else {
          if (lower.contains(keyword)) {
            score += keyword.length;
          }
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestMood = entry.key;
      }
    }
    return bestMood;
  }

  void _showPredictionDialog(BuildContext context, String mood) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: context.surface,
        title: Center(
          child: Text(
            ctx.t('Dự đoán cảm xúc 🔮'),
            style: TextStyle(color: context.appText, fontWeight: FontWeight.bold),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ctx.t('Dựa trên những gì bạn chia sẻ, Relax Time đoán bạn đang cảm thấy:'),
              textAlign: TextAlign.center,
              style: TextStyle(color: context.mutedText, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _moodColor(mood).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _moodColor(mood).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_moodEmoji(mood), style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Text(
                    ctx.t(_moodLabel(mood)),
                    style: TextStyle(
                      color: _moodColor(mood),
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _saveCheckin();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _moodColor(mood),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  ctx.t('Nhận lấy tình trạng này ✓'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _detectedMood = null;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.mutedText,
                  side: BorderSide(color: context.fieldBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  ctx.t('Có lẽ sai sai rồi, đoán lại đi ✕'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveCheckin() async {
    if (_detectedMood == null) return;
    setState(() => _saving = true);
    try {
      final res = await RelaxApi.instance.post('/mood-checkins/me', body: {
        'mood': _detectedMood,
        'intensity': 3,
        'note': _transcriptController.text.trim(),
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

              // Layout Row: Mic Button left, Note text area right
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Mic Button & its state status
                  SizedBox(
                    width: 110,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _listening ? _stopListening : _startListening,
                          child: AnimatedBuilder(
                            animation: _pulseCtrl,
                            builder: (ctx, child) {
                              final scale = _listening ? 1.0 + _pulseCtrl.value * 0.15 : 1.0;
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 80,
                                  height: 80,
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
                                        blurRadius: 20,
                                        spreadRadius: _listening ? 6 : 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _listening ? Icons.stop : Icons.mic,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _listening
                              ? context.t('Đang nghe...')
                              : !_available
                                  ? context.t('Không có mic')
                                  : context.t('Nhấn để nói'),
                          style: TextStyle(
                            color: context.mutedText,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Right: TextField area for editing transcript
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.t('Ghi chú tâm sự:'),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: context.appText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _transcriptController,
                          maxLines: 5,
                          style: TextStyle(fontSize: 14, color: context.appText),
                          decoration: InputDecoration(
                            hintText: context.t('Nội dung nói sẽ hiện ở đây. Bạn cũng có thể sửa lại bằng bàn phím nhé.'),
                            contentPadding: const EdgeInsets.all(12),
                            filled: true,
                            fillColor: context.surfaceAlt,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // "Xác nhận & Phân tích cảm xúc" button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving || _listening
                      ? null
                      : () {
                          if (_transcriptController.text.trim().isEmpty) {
                            showSoftToast(
                              context,
                              message: context.t('Vui lòng nói hoặc nhập vài dòng tâm sự'),
                              tone: SoftToastTone.error,
                            );
                            return;
                          }
                          _analyzeVoice(_transcriptController.text.trim());
                        },
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.psychology_outlined),
                  label: Text(context.t('Xác nhận & Phân tích cảm xúc')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RelaxColors.violet,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
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
