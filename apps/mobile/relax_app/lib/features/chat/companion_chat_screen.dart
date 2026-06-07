import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../shared/widgets/pixel/cat_widgets.dart';

/// Companion chat — UI dạng chat với Thi Ái.
///
/// KHÔNG dùng AI real (privacy + cost + safety). Thay vào đó:
///   - Quick-reply chips theo cảm xúc (Buồn / Lo / Mệt / Vui / Trống)
///   - Mỗi quick-reply → Thi Ái phản hồi 1-3 câu được curate sẵn
///   - Free-text input cũng được — fallback canned response theo keyword
///
/// Mục đích: cho user feel của "trò chuyện" + acknowledgment cảm xúc,
/// KHÔNG thay thế therapy. Disclaimer banner ở top.
class CompanionChatScreen extends StatefulWidget {
  const CompanionChatScreen({super.key});

  @override
  State<CompanionChatScreen> createState() => _CompanionChatScreenState();
}

class _CompanionChatScreenState extends State<CompanionChatScreen> {
  final _scrollCtrl = ScrollController();
  final _inputCtrl = TextEditingController();
  final List<_Msg> _msgs = [];
  bool _thinking = false;

  @override
  void initState() {
    super.initState();
    // First message from Thi Ái
    _msgs.add(_Msg.bot(
      'Chào bạn ~ Hôm nay bạn thế nào? Mình sẵn sàng nghe 💜',
      withSuggestions: true,
    ));
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _inputCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String text, {String? sentiment}) async {
    final clean = text.trim();
    if (clean.isEmpty) return;
    setState(() {
      _msgs.add(_Msg.user(clean));
      _thinking = true;
      _inputCtrl.clear();
    });
    _scrollToBottom();
    // Simulate "thinking" — 800-1500ms để feel natural
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    final reply = _generateReply(clean, sentiment: sentiment);
    setState(() {
      _thinking = false;
      _msgs.add(_Msg.bot(reply.text, withSuggestions: reply.includeSuggestions));
    });
    _scrollToBottom();
  }

  _Reply _generateReply(String input, {String? sentiment}) {
    final lower = input.toLowerCase();
    // Sentiment-tagged quick reply paths first (chính xác hơn)
    if (sentiment != null) {
      return _Reply(_sentimentReply(sentiment), includeSuggestions: true);
    }
    // Keyword scan
    if (lower.contains('buồn') || lower.contains('sad')) {
      return _Reply(_sentimentReply('SAD'), includeSuggestions: true);
    }
    if (lower.contains('lo') ||
        lower.contains('sợ') ||
        lower.contains('anxious')) {
      return _Reply(_sentimentReply('ANXIOUS'), includeSuggestions: true);
    }
    if (lower.contains('mệt') || lower.contains('kiệt')) {
      return _Reply(_sentimentReply('TIRED'), includeSuggestions: true);
    }
    if (lower.contains('vui') || lower.contains('ổn') || lower.contains('happy')) {
      return _Reply(_sentimentReply('HAPPY'), includeSuggestions: true);
    }
    if (lower.contains('cảm ơn') || lower.contains('thanks')) {
      return _Reply(
        'Mình vui khi được ở đây với bạn ✦ Bất cứ khi nào cần, mình '
        'luôn ở trong app này nha 💜',
      );
    }
    if (lower.contains('giúp') || lower.contains('help')) {
      return _Reply(
        'Mình có thể nghe, có thể gợi ý 1 phiên thư giãn, hoặc nhắc bạn '
        'về Hỗ trợ khẩn cấp nếu cần. Bạn muốn bắt đầu từ đâu?',
        includeSuggestions: true,
      );
    }
    // Default acknowledgment
    return _Reply(
      'Mình nghe rồi ~ Cảm ơn bạn đã chia sẻ. Bạn muốn nói thêm, hay '
      'để mình gợi ý một nhịp nghỉ nhẹ?',
      includeSuggestions: true,
    );
  }

  String _sentimentReply(String sentiment) {
    return switch (sentiment) {
      'SAD' =>
        'Buồn là cảm xúc bình thường — không có gì "sai" về nó cả. Bạn '
            'đã đủ rồi, không cần phải vui ngay 💜 Thử viết vài dòng nhật '
            'ký để gọi tên điều bạn đang cảm nha?',
      'ANXIOUS' =>
        'Lo lắng cho biết bạn quan tâm. Mình hiểu nó nặng. Quick Relief '
            '60 giây có thể giúp dịu hệ thần kinh xuống — bạn muốn thử?',
      'TIRED' =>
        'Mệt là cách cơ thể nói "đủ rồi". Không phải lười — đó là tín '
            'hiệu. Một phiên thiền 10 phút có thể nạp lại một chút năng '
            'lượng cho bạn 🌿',
      'HAPPY' =>
        'Tuyệt! Khi vui, ghi lại điều đang giúp bạn ổn ở nhật ký — sau '
            'này khi khó khăn quay lại, bạn sẽ có "công thức" để dùng lại ✦',
      'NEUTRAL' =>
        'Trống đôi khi là cách tâm trí nghỉ ngơi sau nhiều cảm xúc. '
            'Không cần phải feel gì cụ thể lúc này — đứng yên cũng là tiến.',
      _ => 'Mình nghe rồi ~ Cảm ơn bạn đã chia sẻ với mình.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [RelaxTheme.purple, RelaxTheme.lavender],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Thi Ái', style: TextStyle(fontSize: 15)),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF48D3A8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Đang lắng nghe',
                      style: TextStyle(
                        color: context.relax.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Disclaimer banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: RelaxTheme.lavender.withValues(alpha: .08),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 12,
                  color: RelaxTheme.lavender,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Mình là companion nhỏ, không phải bác sĩ. Cần hỗ trợ '
                    'thật → Setup → Hỗ trợ khẩn cấp ✦',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 10.5,
                      color: context.relax.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              itemCount: _msgs.length + (_thinking ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _msgs.length && _thinking) return const _TypingBubble();
                final msg = _msgs[i];
                return _Bubble(
                  msg: msg,
                  onSuggestionTap: (sentiment, label) =>
                      _send(label, sentiment: sentiment),
                );
              },
            ),
          ),
          // Input
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(color: context.relax.border),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                      decoration: InputDecoration(
                        hintText: 'Viết cho mình nghe...',
                        filled: true,
                        fillColor: context.relax.surfaceSoft,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _thinking ? null : () => _send(_inputCtrl.text),
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: RelaxTheme.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  _Msg.bot(this.text, {this.withSuggestions = false})
      : fromBot = true,
        time = DateTime.now();
  _Msg.user(this.text)
      : fromBot = false,
        withSuggestions = false,
        time = DateTime.now();

  final String text;
  final bool fromBot;
  final bool withSuggestions;
  final DateTime time;
}

class _Reply {
  const _Reply(this.text, {this.includeSuggestions = false});
  final String text;
  final bool includeSuggestions;
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg, required this.onSuggestionTap});
  final _Msg msg;
  final void Function(String sentiment, String label) onSuggestionTap;

  static const _suggestions = [
    ('SAD', '🌧️ Mình đang buồn'),
    ('ANXIOUS', '😰 Mình lo'),
    ('TIRED', '😴 Mình mệt'),
    ('HAPPY', '😊 Mình ổn'),
    ('NEUTRAL', '😶 Trống rỗng'),
  ];

  @override
  Widget build(BuildContext context) {
    final bot = msg.fromBot;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            bot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment:
                bot ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (bot) ...[
                const CatAvatar(size: 28),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .72,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: bot
                        ? context.relax.surfaceSoft
                        : RelaxTheme.purple,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(bot ? 4 : 16),
                      bottomRight: Radius.circular(bot ? 16 : 4),
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: bot ? null : Colors.white,
                      height: 1.45,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (msg.withSuggestions) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final s in _suggestions)
                    ActionChip(
                      label: Text(s.$2, style: const TextStyle(fontSize: 11)),
                      onPressed: () => onSuggestionTap(s.$1, s.$2),
                      backgroundColor:
                          RelaxTheme.lavender.withValues(alpha: .08),
                      side: BorderSide(
                        color: RelaxTheme.lavender.withValues(alpha: .3),
                      ),
                      labelStyle: TextStyle(
                        color: RelaxTheme.lavender,
                        fontWeight: FontWeight.w700,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    duration: const Duration(milliseconds: 900),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const CatAvatar(size: 28),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: context.relax.surfaceSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final t = (_ctrl.value - i * 0.2).clamp(0, 1).toDouble();
                    final wave = (t < .5 ? t * 2 : 2 - t * 2);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: RelaxTheme.lavender.withValues(
                            alpha: .4 + wave * .5,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
