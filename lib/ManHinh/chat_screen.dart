import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:english_chatbot/Services/api_services.dart';
import 'package:english_chatbot/Models/conversation_model.dart';

// Màn hình trò chuyện chính với AI
class ChatScreen extends StatefulWidget {
  final String conversationId;

  // Constructor để nhận ID cuộc trò chuyện từ màn hình trước
  ChatScreen({required this.conversationId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, String>> messages = []; // Danh sách các tin nhắn
  bool isLoading = true; // Biến kiểm tra trạng thái tải
  bool isSending = false; // Biến kiểm tra trạng thái gửi tin nhắn
  TextEditingController _messageController = TextEditingController(); // Điều khiển input
  ScrollController _scrollController = ScrollController(); // Điều khiển cuộn của danh sách

  @override
  void initState() {
    super.initState();
    // Lấy tin nhắn khi màn hình được tạo
    _fetchMessages();
  }

  // Hàm lấy tin nhắn từ API
  Future<void> _fetchMessages() async {
    try {
      List<Map<String, String>> fetchedMessages = await ApiServices.fetchMessagesByConversationId(widget.conversationId);

      // Cập nhật danh sách tin nhắn và dừng tải
      setState(() {
        messages = fetchedMessages;
        isLoading = false;
      });

      // Cuộn xuống cuối danh sách sau khi tải
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi tải tin nhắn')),
      );
      print('Error fetching messages: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Hàm gửi tin nhắn
  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();

    if (messageText.isEmpty) {
      return; // Không gửi nếu tin nhắn rỗng
    }

    setState(() {
      isSending = true; // Bắt đầu trạng thái gửi tin nhắn
    });

    try {
      // Gửi tin nhắn đến API và lưu vào cuộc trò chuyện
      await ApiServices.addMessage(widget.conversationId, messageText, 'User');

      _messageController.clear(); // Xóa nội dung ô nhập sau khi gửi

      // Tải lại danh sách tin nhắn sau khi gửi
      await _fetchMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi gửi tin nhắn')),
      );
      print('Error sending message: $e');
    } finally {
      setState(() {
        isSending = false; // Dừng trạng thái gửi
      });
    }
  }

  // Hàm cuộn xuống cuối danh sách
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trò Chuyện Với AI'),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        elevation: 0,
      ),
      // Kiểm tra trạng thái tải để hiển thị các thành phần UI
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: <Widget>[
          // Danh sách tin nhắn
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Đính kèm điều khiển cuộn
              itemCount: messages.length,
              itemBuilder: (context, index) {
                bool isUserMessage = messages[index]['sender'] == 'User'; // Kiểm tra xem tin nhắn có phải của người dùng không

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Align(
                    alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isUserMessage ? Colors.blue[800] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUserMessage ? 'Bạn' : 'AI',
                            style: TextStyle(
                              color: isUserMessage ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          // Hiển thị nội dung tin nhắn hỗ trợ Markdown
                          MarkdownBody(
                            data: messages[index]['message']!,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                color: isUserMessage ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Hiển thị loading khi chờ phản hồi từ AI
          if (isSending)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          // Khu vực nhập tin nhắn và nút gửi
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendMessage, // Gửi tin nhắn khi bấm
                  child: Icon(Icons.send, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: EdgeInsets.all(16),
                    shape: CircleBorder(),
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
