import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:english_chatbot/Services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';
import 'package:english_chatbot/Models/conversation_model.dart';

// Màn hình chính của danh sách cuộc trò chuyện
class ConversationScreen extends StatefulWidget {
  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  // Danh sách các cuộc trò chuyện
  List<Conversation> _conversations = [];
  // Biến để kiểm tra xem dữ liệu đang tải hay không
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Gọi hàm lấy danh sách cuộc trò chuyện khi khởi tạo màn hình
    _fetchConversations();
  }

  // Hàm lấy danh sách các cuộc trò chuyện cho người dùng đã đăng nhập
  Future<void> _fetchConversations() async {
    try {
      // Lấy ID của người dùng từ SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      print('User ID từ SharedPreferences: $userId');

      // Nếu có ID người dùng, gọi API để lấy danh sách cuộc trò chuyện
      if (userId != null) {
        List<Conversation> conversations =
        await ApiServices.fetchConversationsByUserId(userId);

        print('Cuộc trò chuyện đã tải về: $conversations');

        // Cập nhật trạng thái với danh sách cuộc trò chuyện và dừng tải
        setState(() {
          _conversations = conversations;
          isLoading = false;
        });
      } else {
        // Thông báo lỗi nếu không tìm thấy ID người dùng
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy thông tin người dùng')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Thông báo lỗi nếu có vấn đề trong quá trình tải cuộc trò chuyện
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi tải cuộc trò chuyện')),
      );
      print('Lỗi khi tải cuộc trò chuyện: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteConversation(String conversationId) async {
    try {
      // Gọi API để xóa cuộc trò chuyện
      final response = await ApiServices.deleteConversation(conversationId);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa cuộc trò chuyện')),
        );

        // Cập nhật danh sách cuộc trò chuyện sau khi xóa
        await _fetchConversations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể xóa cuộc trò chuyện')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi xóa cuộc trò chuyện')),
      );
      print('Lỗi khi xóa cuộc trò chuyện: $e');
    }
  }
  // Hiển thị hộp thoại xác nhận xóa
  void _confirmDelete(String conversationId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận'),
          content: Text('Bạn có chắc muốn xoá cuộc trò chuyện này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Huỷ'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteConversation(conversationId); // Gọi hàm xóa nếu xác nhận
              },
              child: Text('Xoá', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  // Hàm bắt đầu một cuộc trò chuyện mới
  Future<void> _startNewConversation() async {
    try {
      // Lấy ID người dùng từ SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId != null) {
        // Gọi API để tạo một cuộc trò chuyện mới
        final response = await ApiServices.createNewConversation(userId);

        if (response.statusCode == 201) {
          // Lấy ID của cuộc trò chuyện mới từ phản hồi
          final responseData = jsonDecode(response.body);
          String conversationId = responseData['conversation']['_id'];

          // Cập nhật danh sách cuộc trò chuyện sau khi tạo mới
          await _fetchConversations();

          // Thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bắt đầu cuộc trò chuyện mới thành công')),
          );

          // Chuyển sang màn hình trò chuyện mới
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(conversationId: conversationId),
            ),
          );
        } else {
          // Thông báo lỗi nếu không tạo được cuộc trò chuyện mới
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể tạo cuộc trò chuyện mới')),
          );
        }
      } else {
        // Thông báo nếu không tìm thấy thông tin người dùng
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không tìm thấy thông tin người dùng')),
        );
      }
    } catch (e) {
      // Thông báo lỗi khi xảy ra vấn đề trong quá trình bắt đầu cuộc trò chuyện mới
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi khi bắt đầu cuộc trò chuyện mới')),
      );
      print('Lỗi khi bắt đầu cuộc trò chuyện mới: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch Sử Trò Chuyện với AI'),
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        elevation: 0,
      ),
      // Kiểm tra trạng thái isLoading
      // Nếu đang tải, hiển thị CircularProgressIndicator
      // Nếu đã tải xong, hiển thị danh sách cuộc trò chuyện
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Hộp thông báo phía trên danh sách cuộc trò chuyện
          Container(
            padding: EdgeInsets.all(16.0),
            width: double.infinity,
            color: Colors.blue[100],
            child: Text(
              'Chọn một cuộc trò chuyện trước đây để tiếp tục hoặc bắt đầu cuộc trò chuyện mới với AI!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue[800],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Danh sách các cuộc trò chuyện
          Expanded(
            child: ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                Conversation conversation = _conversations[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue[800],
                        child: Icon(Icons.chat_bubble, color: Colors.white),
                      ),
                      title: Text(
                        'Cuộc trò chuyện ${index + 1}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      subtitle: Text(
                        'Nhấp để mở lại cuộc trò chuyện với AI',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Hiển thị hộp thoại xác nhận khi nhấn vào biểu tượng xóa
                          _confirmDelete(conversation.id!);
                        },
                      ),
                      // Xử lý khi người dùng nhấp vào để mở lại cuộc trò chuyện
                      onTap: () {
                        handleNavigationToChatScreen(context, conversation.id!);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          // Nút để bắt đầu một cuộc trò chuyện mới
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startNewConversation,
                child: Text('Bắt Đầu Cuộc Trò Chuyện Mới',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm điều hướng tới màn hình trò chuyện với ID của cuộc trò chuyện
  void handleNavigationToChatScreen(BuildContext context, String conversationId) {
    print('Conversation ID: $conversationId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(conversationId: conversationId),
      ),
    );
  }
}
