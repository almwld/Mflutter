import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/voice_search_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    context.read<ChatProvider>().sendMessage(_controller.text);
    _controller.clear();
  }

  void _onVoiceResult(String text) {
    _controller.text = text;
    _send();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('المحادثة', style: TextStyle(color: AppColors.primaryGold)),
        backgroundColor: AppColors.primaryNavy,
        actions: [
          VoiceSearchWidget(onResult: _onVoiceResult),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chat, child) {
                if (chat.messages.isEmpty) {
                  return Center(
                    child: Text('اكتب سؤالك الأول', style: TextStyle(color: Colors.white54, fontSize: 18)),
                  );
                }
                return ListView.builder(
                  itemCount: chat.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chat.messages[index];
                    return Align(
                      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(16),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
                        decoration: BoxDecoration(
                          color: msg.isUser ? AppColors.primaryNavy : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(msg.content, style: TextStyle(color: Colors.white)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            color: AppColors.surface,
            child: Row(
              children: [
                VoiceSearchWidget(onResult: _onVoiceResult),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'اكتب هنا...',
                      hintStyle: TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primaryGold,
                  child: IconButton(
                    icon: Icon(Icons.send, color: AppColors.primaryNavy),
                    onPressed: _send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
