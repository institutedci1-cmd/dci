import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_chat_model.dart';

class AIChatWidget extends ConsumerStatefulWidget {
  const AIChatWidget({super.key});

  static String routeName = 'AIChat';
  static String routePath = '/aiChat';

  @override
  ConsumerState<AIChatWidget> createState() => _AIChatWidgetState();
}

class _AIChatWidgetState extends ConsumerState<AIChatWidget> {
  late AIChatModel _model;
  final List<Map<String, String>> _messages = [
    {
      'role': 'ai',
      'text': 'Hello! I am your Deshmukh AI Assistant. How can I help you with your classes today?'
    },
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AIChatModel());
    _model.chatInputTextController = TextEditingController();
    _model.chatInputFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_model.chatInputTextController!.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'text': _model.chatInputTextController!.text.trim(),
      });
    });

    final userText = _model.chatInputTextController!.text;
    _model.chatInputTextController!.clear();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'ai',
            'text': _getMockResponse(userText),
          });
        });
        _scrollToBottom();
      }
    });
    _scrollToBottom();
  }

  String _getMockResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('lesson plan')) {
      return 'I can help you create a lesson plan for any subject. Which topic should we start with?';
    } else if (lower.contains('performance')) {
      return 'Based on recent data, Class 10th-A has shown a 15% improvement in Mathematics this month.';
    } else if (lower.contains('attendance')) {
      return 'Today\'s overall attendance is at 92%. The "Absent List" has been updated in your dashboard.';
    }
    return 'That\'s interesting! I am currently processing that request. Is there anything specific you\'d like to know about our curriculum or student data?';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_model.listViewController.hasClients) {
        _model.listViewController.animateTo(
          _model.listViewController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        body: Column(
          children: [
            HeaderSectionWidget(
              title: 'Deshmukh AI Assistant',
              subtitle: 'Smart academic support',
              onBackPressed: () async => context.safePop(),
              showActionIcon: false,
            ),
            Expanded(
              child: ListView.builder(
                controller: _model.listViewController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isAi = msg['role'] == 'ai';
                  return _buildMessageBubble(msg['text']!, isAi);
                },
              ),
            ),
            _buildQuickActions(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isAi) {
    final theme = FlutterFlowTheme.of(context);
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isAi ? theme.secondaryBackground : theme.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAi ? 4 : 16),
            bottomRight: Radius.circular(isAi ? 16 : 4),
          ),
          boxShadow: AppShadows.low,
          border: isAi ? Border.all(color: theme.alternate) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAi)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.secondary),
                    const SizedBox(width: 4),
                    Text('Deshmukh AI', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 11)),
                  ],
                ),
              ),
            Text(
              text,
              style: AppTypography.body.copyWith(
                color: isAi ? theme.primaryText : Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final suggestions = ['Help with lesson plan', 'Analyze performance', 'Attendance trends'];
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(suggestions[index], style: const TextStyle(fontSize: 11)),
              onPressed: () {
                _model.chatInputTextController!.text = suggestions[index];
                _sendMessage();
              },
              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
              side: BorderSide(color: FlutterFlowTheme.of(context).primary.withAlpha(50)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 4, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _model.chatInputTextController,
              focusNode: _model.chatInputFocusNode,
              decoration: InputDecoration(
                hintText: 'Ask anything...',
                hintStyle: AppTypography.caption,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                fillColor: theme.primaryBackground,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              style: AppTypography.body,
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(color: theme.primary, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
