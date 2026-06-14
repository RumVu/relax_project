import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../core/theme_controller.dart';
import '../../widgets/soft_toast.dart';

class EmotionWheelCheckin extends StatefulWidget {
  const EmotionWheelCheckin({super.key});

  @override
  State<EmotionWheelCheckin> createState() => _EmotionWheelCheckinState();
}

class _EmotionWheelCheckinState extends State<EmotionWheelCheckin> {
  String? _primaryMood;
  String? _subMood;
  int _intensity = 5;
  final Set<String> _bodyFeelings = {};
  final _noteCtrl = TextEditingController();
  bool _saving = false;
  String? _energyLevel;
  String? _mentalClarity;
  String? _stressLoad;

  static const _primaryMoods = [
    ('STRESSED', 'Căng thẳng', '😫', RelaxColors.plum),
    ('ANXIOUS', 'Lo âu', '😰', RelaxColors.violet),
    ('SAD', 'Buồn bã', '😢', Color(0xFF3B82F6)),
    ('TIRED', 'Mệt mỏi', '🥱', Color(0xFF6B7280)),
    ('HAPPY', 'Vui vẻ', '😊', RelaxColors.mint),
    ('CALM', 'Bình yên', '😌', Color(0xFF10B981)),
    ('ANGRY', 'Giận dữ', '😠', Color(0xFFEF4444)),
  ];

  static const _subMoodsMap = <String, List<(String, String)>>{
    'STRESSED': [
      ('OVERWHELMED', 'Quá tải'),
      ('BURNT_OUT', 'Kiệt sức'),
      ('PRESSURED', 'Áp lực'),
      ('RESTLESS', 'Bồn chồn'),
    ],
    'ANXIOUS': [
      ('INSECURE', 'Bất an'),
      ('PANICKED', 'Hoảng loạn'),
      ('UNEASY', 'Khó chịu'),
      ('WORRIED', 'Lo lắng'),
    ],
    'SAD': [
      ('LONELY', 'Cô đơn'),
      ('EMPTY', 'Trống rỗng'),
      ('DISAPPOINTED', 'Thất vọng'),
      ('HURT', 'Tổn thương'),
    ],
    'TIRED': [
      ('SLEEPY', 'Buồn ngủ'),
      ('FOGGY', 'Mơ hồ'),
      ('DRAINED', 'Cạn kiệt'),
      ('BORED', 'Chán nản'),
    ],
    'HAPPY': [
      ('EXCITED', 'Hào hứng'),
      ('GRATEFUL', 'Biết ơn'),
      ('PROUD', 'Tự hào'),
      ('JOYFUL', 'Vui sướng'),
    ],
    'CALM': [
      ('PEACEFUL', 'Yên bình'),
      ('CONTENT', 'Hài lòng'),
      ('RELAXED', 'Thư thái'),
      ('SAFE', 'An toàn'),
    ],
    'ANGRY': [
      ('IRRITATED', 'Bực mình'),
      ('FRUSTRATED', 'Nản lòng'),
      ('HURT', 'Tổn thương'),
      ('ANNOYED', 'Khó chịu'),
    ],
  };

  static const _bodyFeelingsList = [
    ('HEADACHE', 'Đau đầu', Icons.psychology),
    ('CHEST_TIGHTNESS', 'Tức ngực', Icons.heart_broken),
    ('FATIGUE', 'Uể oải', Icons.battery_alert),
    ('SLEEPY', 'Buồn ngủ', Icons.bedtime),
    ('RESTLESS_BODY', 'Bứt rứt', Icons.directions_run),
    ('TENSE_MUSCLES', 'Căng cơ', Icons.fitness_center),
    ('HEAVY_EYES', 'Mỏi mắt', Icons.visibility_off),
    ('OKAY', 'Bình thường', Icons.sentiment_satisfied),
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _showVoiceCheckinDialog() async {
    final textController = TextEditingController();
    bool isAnalyzing = false;
    bool isRecording = false;

    await showModalBottomSheet(
      context: context,
      backgroundColor: context.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.t('AI Voice Mood Check-in 🎙️'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: context.appText,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.t('Nói hoặc gõ tâm trạng của bạn để AI tự động điền form.'),
                    style: TextStyle(fontSize: 13, color: context.mutedText),
                  ),
                  const SizedBox(height: 20),
                  
                  // Simulated Waveform or Recording Button
                  Center(
                    child: GestureDetector(
                      onTap: isAnalyzing ? null : () async {
                        if (isRecording) {
                          setModalState(() {
                            isRecording = false;
                          });
                        } else {
                          setModalState(() {
                            isRecording = true;
                            textController.text = "Hôm nay mình hơi mệt, không biết vì sao.";
                          });
                          await Future.delayed(const Duration(milliseconds: 1500));
                          if (context.mounted) {
                            setModalState(() {
                              isRecording = false;
                            });
                          }
                        }
                      },
                      child: Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isRecording 
                              ? Colors.redAccent.withValues(alpha: 0.15) 
                              : RelaxColors.violet.withValues(alpha: 0.1),
                          border: Border.all(
                            color: isRecording ? Colors.redAccent : RelaxColors.violet,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          isRecording ? Icons.fiber_manual_record : Icons.mic,
                          color: isRecording ? Colors.redAccent : RelaxColors.violet,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      isRecording 
                          ? context.t('Đang thu âm... (Chạm để dừng)') 
                          : context.t('Chạm Micro để nói'),
                      style: TextStyle(
                        fontSize: 11,
                        color: isRecording ? Colors.redAccent : context.mutedText,
                        fontWeight: isRecording ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  TextField(
                    controller: textController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: context.t('Nội dung giọng nói...'),
                      hintStyle: TextStyle(color: context.mutedText, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Suggestion chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _suggestionChip(context, "Hôm nay mình hơi mệt, không biết vì sao.", textController, setModalState),
                        const SizedBox(width: 8),
                        _suggestionChip(context, "Mới bị sếp dí deadline xong stress quá.", textController, setModalState),
                        const SizedBox(width: 8),
                        _suggestionChip(context, "Ngày hôm nay thật tuyệt, nhẹ nhõm vô cùng.", textController, setModalState),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  ElevatedButton(
                    onPressed: (textController.text.trim().isEmpty || isAnalyzing)
                        ? null
                        : () async {
                            setModalState(() {
                              isAnalyzing = true;
                            });
                            try {
                              final res = await RelaxApi.instance.post(
                                '/mood-checkins/voice',
                                body: {'text': textController.text.trim()},
                              );
                              if (!context.mounted) return;
                              if (res.statusCode == 201 || res.statusCode == 200) {
                                final data = res.data;
                                setState(() {
                                  final mood = data['mood'] as String?;
                                  final tagsList = List<String>.from(data['tags'] ?? []);
                                  if (mood == 'STRESSED' && tagsList.contains('sub:ANGRY')) {
                                    _primaryMood = 'ANGRY';
                                  } else {
                                    _primaryMood = mood;
                                  }
                                  _subMood = null;
                                  _bodyFeelings.clear();
                                  for (var t in tagsList) {
                                    if (t.startsWith('sub:')) {
                                      _subMood = t.substring(4);
                                    } else if (t.startsWith('body:')) {
                                      _bodyFeelings.add(t.substring(5));
                                    }
                                  }
                                  _intensity = data['intensity'] ?? 5;
                                  _noteCtrl.text = data['journalDraft'] ?? '';
                                });
                                showSoftToast(
                                  context,
                                  message: context.t('AI đã phân tích và điền form check-in thành công 🎙️✨'),
                                  tone: SoftToastTone.success,
                                );
                                Navigator.pop(context);
                              } else {
                                showSoftToast(
                                  context,
                                  message: context.t('Có lỗi khi kết nối AI'),
                                  tone: SoftToastTone.error,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                showSoftToast(
                                  context,
                                  message: e.toString(),
                                  tone: SoftToastTone.error,
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setModalState(() {
                                  isAnalyzing = false;
                                });
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RelaxColors.violet,
                      disabledBackgroundColor: context.fieldBorder,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isAnalyzing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            context.t('Xác nhận & Phân tích'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _suggestionChip(
    BuildContext context,
    String text,
    TextEditingController controller,
    StateSetter setModalState,
  ) {
    return GestureDetector(
      onTap: () {
        setModalState(() {
          controller.text = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: context.fieldBorder.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.fieldBorder),
        ),
        child: Text(
          context.t(text),
          style: TextStyle(fontSize: 11, color: context.appText),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_primaryMood == null) return;
    setState(() => _saving = true);
    HapticFeedback.mediumImpact();

    final apiMood = _primaryMood == 'ANGRY' ? 'STRESSED' : _primaryMood;
    final tags = [
      if (_primaryMood == 'ANGRY') 'sub:ANGRY',
      if (_subMood != null) 'sub:$_subMood',
      ..._bodyFeelings.map((f) => 'body:$f'),
      if (_energyLevel != null) 'energy:$_energyLevel',
      if (_mentalClarity != null) 'clarity:$_mentalClarity',
      if (_stressLoad != null) 'stress:$_stressLoad',
      'wheel_checkin',
    ];

    try {
      final res = await RelaxApi.instance.post('/mood-checkins/me', body: {
        'mood': apiMood,
        'intensity': _intensity,
        if (_noteCtrl.text.trim().isNotEmpty) 'note': _noteCtrl.text.trim(),
        'tags': tags,
      });

      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        // Update theme accent based on mood check-in
        Color? moodColor;
        switch (_primaryMood) {
          case 'HAPPY':
            moodColor = RelaxColors.sun;
            break;
          case 'CALM':
            moodColor = RelaxColors.mint;
            break;
          case 'STRESSED':
          case 'ANGRY':
            moodColor = RelaxColors.coral;
            break;
          case 'SAD':
            moodColor = const Color(0xFFB084EE);
            break;
          case 'TIRED':
            moodColor = const Color(0xFF6B7280);
            break;
          case 'ANXIOUS':
            moodColor = RelaxColors.violet;
            break;
        }
        if (moodColor != null) {
          try {
            context.read<ThemeController>().setAccent(moodColor);
          } catch (_) {}
        }

        showSoftToast(
          context,
          message: context.t('Đã ghi lại cảm xúc sâu sắc của bạn 🌸'),
          tone: SoftToastTone.success,
        );
        context.pop(true);
      } else {
        final msg = (res.data?['message'] as String?) ?? context.t('Không lưu được cảm xúc');
        showSoftToast(context, message: msg, tone: SoftToastTone.error);
      }
    } catch (cause) {
      if (mounted) {
        showSoftToast(context, message: cause.toString(), tone: SoftToastTone.error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subs = _primaryMood != null ? (_subMoodsMap[_primaryMood] ?? []) : <(String, String)>[];

    return Scaffold(
      backgroundColor: context.isDark ? const Color(0xFF0d1117) : RelaxColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('Bánh xe cảm xúc 🎡'),
          style: TextStyle(color: context.appText, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic, color: RelaxColors.violet),
            tooltip: context.t('Check-in bằng giọng nói'),
            onPressed: _showVoiceCheckinDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            Text(
              context.t('Gọi tên chính xác cảm xúc của bạn'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: context.appText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.t('Khám phá sâu hơn trạng thái tinh thần và thể chất lúc này.'),
              style: TextStyle(color: context.mutedText, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Step 1: Primary Mood
            _sectionHeader('1. ${context.t('Cảm xúc chủ đạo')}'),
            const SizedBox(height: 10),
            LayoutBuilder(builder: (context, constraints) {
              final cols = constraints.maxWidth < 320 ? 3 : 4;
              return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.88,
              ),
              itemCount: _primaryMoods.length,
              itemBuilder: (context, idx) {
                final pm = _primaryMoods[idx];
                final selected = _primaryMood == pm.$1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _primaryMood = pm.$1;
                      _subMood = null; // reset sub mood
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected
                          ? pm.$4.withValues(alpha: 0.15)
                          : context.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? pm.$4 : context.fieldBorder,
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: pm.$4.withValues(alpha: 0.2),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(pm.$3, style: const TextStyle(fontSize: 26)),
                        const SizedBox(height: 6),
                        Text(
                          context.t(pm.$2),
                          style: TextStyle(
                            color: selected ? pm.$4 : context.appText,
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
            }),

            if (_primaryMood != null && subs.isNotEmpty) ...[
              const SizedBox(height: 24),
              // Step 2: Sub Mood
              _sectionHeader('2. ${context.t('Sắc thái cảm xúc cụ thể')}'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: subs.map((sub) {
                  final selected = _subMood == sub.$1;
                  final pmColor = _primaryMoods.firstWhere((p) => p.$1 == _primaryMood).$4;
                  return ChoiceChip(
                    label: Text(context.t(sub.$2)),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        _subMood = val ? sub.$1 : null;
                      });
                    },
                    selectedColor: pmColor.withValues(alpha: 0.15),
                    checkmarkColor: pmColor,
                    side: BorderSide(
                      color: selected ? pmColor : context.fieldBorder,
                    ),
                    labelStyle: TextStyle(
                      color: selected ? pmColor : context.appText,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),
            // Step 3: Intensity
            _sectionHeader('3. ${context.t('Cường độ cảm xúc')}: $_intensity/10'),
            Slider(
              value: _intensity.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: RelaxColors.violet,
              inactiveColor: context.fieldBorder,
              onChanged: (v) => setState(() => _intensity = v.round()),
            ),

            const SizedBox(height: 16),
            // Step 4: Body feeling
            _sectionHeader('4. ${context.t('Biểu hiện cơ thể')}'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _bodyFeelingsList.map((f) {
                final selected = _bodyFeelings.contains(f.$1);
                return FilterChip(
                  avatar: Icon(
                    f.$3,
                    size: 16,
                    color: selected ? RelaxColors.mint : context.appText.withValues(alpha: 0.6),
                  ),
                  label: Text(context.t(f.$2)),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _bodyFeelings.add(f.$1);
                      } else {
                        _bodyFeelings.remove(f.$1);
                      }
                    });
                  },
                  selectedColor: RelaxColors.mint.withValues(alpha: 0.12),
                  checkmarkColor: RelaxColors.mint,
                  side: BorderSide(
                    color: selected ? RelaxColors.mint : context.fieldBorder,
                  ),
                  labelStyle: TextStyle(
                    color: selected ? RelaxColors.mint : context.appText,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            // Step 5: Energy & Stress level
            _sectionHeader('5. ${context.t('Năng lượng & Áp lực')}'),
            const SizedBox(height: 12),
            Text(
              context.t('Mức năng lượng'),
              style: TextStyle(
                color: context.appText,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(context, 'THẤP', _energyLevel == 'LOW', () => setState(() => _energyLevel = 'LOW')),
                _chip(context, 'TRUNG BÌNH', _energyLevel == 'MEDIUM', () => setState(() => _energyLevel = 'MEDIUM')),
                _chip(context, 'CAO', _energyLevel == 'HIGH', () => setState(() => _energyLevel = 'HIGH')),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.t('Độ minh mẫn'),
              style: TextStyle(
                color: context.appText,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(context, 'MƠ HỒ', _mentalClarity == 'FOGGY', () => setState(() => _mentalClarity = 'FOGGY')),
                _chip(context, 'BÌNH THƯỜNG', _mentalClarity == 'OKAY', () => setState(() => _mentalClarity = 'OKAY')),
                _chip(context, 'TẬP TRUNG', _mentalClarity == 'FOCUSED', () => setState(() => _mentalClarity = 'FOCUSED')),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              context.t('Tải áp lực'),
              style: TextStyle(
                color: context.appText,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(context, 'NHẸ', _stressLoad == 'LIGHT', () => setState(() => _stressLoad = 'LIGHT')),
                _chip(context, 'VỪA', _stressLoad == 'MEDIUM', () => setState(() => _stressLoad = 'MEDIUM')),
                _chip(context, 'NẶNG', _stressLoad == 'HEAVY', () => setState(() => _stressLoad = 'HEAVY')),
              ],
            ),

            const SizedBox(height: 24),
            // Step 6: Note
            _sectionHeader('6. ${context.t('Ghi chú cảm xúc')}'),
            const SizedBox(height: 10),
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              maxLength: 120,
              decoration: InputDecoration(
                hintText: context.t('Điều gì đang xảy ra trong lòng bạn…'),
              ),
            ),

            const SizedBox(height: 32),
            // Action Button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _primaryMood != null && !_saving ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RelaxColors.violet,
                  disabledBackgroundColor: context.fieldBorder,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        context.t('Hoàn thành Check-in'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? RelaxColors.violet.withValues(alpha: 0.15)
              : context.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? RelaxColors.violet : context.fieldBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          context.t(label),
          style: TextStyle(
            color: selected ? RelaxColors.violet : context.appText,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 15,
        color: context.appText,
      ),
    );
  }
}
