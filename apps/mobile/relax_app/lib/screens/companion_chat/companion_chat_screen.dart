import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_client.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../widgets/soft_toast.dart';
import 'widgets/chat_bubble.dart';

class CompanionChatScreen extends StatefulWidget {
  const CompanionChatScreen({super.key});

  @override
  State<CompanionChatScreen> createState() => _CompanionChatScreenState();
}

class _CompanionChatScreenState extends State<CompanionChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = true;
  bool _sending = false;
  String? _error;
  String _companionName = 'Linh thú';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final compRes = await RelaxApi.instance.get('/user-companions/me');
      if (compRes.data is Map) {
        _companionName = compRes.data['name'] as String? ?? 'Linh thú';
      }

      final res =
          await RelaxApi.instance.get('/user-companions/me/chat/history');
      if (res.data is List) {
        _messages.clear();
        for (final item in res.data) {
          if (item is Map) {
            _messages.add(Map<String, dynamic>.from(item));
          }
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    _controller.clear();
    setState(() {
      _messages.add({
        'sender': 'user',
        'text': text,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });
      _sending = true;
    });
    _scrollToBottom();

    try {
      final res = await RelaxApi.instance.post(
        '/user-companions/me/chat',
        body: {'message': text},
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data;
        if (data is Map) {
          setState(() {
            _messages.add({
              'sender': 'companion',
              'text': data['reply'] as String,
              'createdAt': DateTime.now().toUtc().toIso8601String(),
            });
          });
        }
      } else {
        if (mounted) {
          showSoftToast(context,
              message: context.t('Không gửi được tin nhắn'),
              tone: SoftToastTone.error);
        }
      }
    } catch (e) {
      if (mounted) {
        showSoftToast(context,
            message: e.toString(), tone: SoftToastTone.error);
      }
    } finally {
      setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.appText),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _companionName,
              style: TextStyle(
                  color: context.appText,
                  fontWeight: FontWeight.w800,
                  fontSize: 16),
            ),
            Text(
              context.t('Trực tuyến'),
              style: const TextStyle(
                  color: RelaxColors.mint,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: RelaxColors.violet))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!,
                                  style: const TextStyle(
                                      color: RelaxColors.coral)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                  onPressed: _loadHistory,
                                  child: Text(context.t('Thử lại'))),
                            ],
                          ),
                        )
                      : _messages.isEmpty
                          ? Center(
                              child: Text(
                                context.t(
                                    'Hãy gửi lời chào đầu tiên tới linh thú nhé!'),
                                style: TextStyle(
                                    color: context.mutedText, fontSize: 13),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final msg = _messages[index];
                                return ChatBubble(
                                  text: msg['text'] as String? ?? '',
                                  isUser: msg['sender'] == 'user',
                                );
                              },
                            ),
            ),
            if (_sending)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    context.t('Linh thú đang nhập tin nhắn...'),
                    style: TextStyle(
                        color: context.mutedText,
                        fontSize: 11,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.surface,
                border:
                    Border(top: BorderSide(color: context.fieldBorder)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText:
                            context.t('Nhắn gì đó với linh thú...'),
                        hintStyle: TextStyle(color: context.mutedText),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send,
                        color: RelaxColors.violet),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
