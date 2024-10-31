import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:english_chatbot/Models/conversation_model.dart';

class ApiServices {
  // Địa chỉ cơ bản của máy chủ API
  static const baseUrl = 'https://english-chatbot-be.onrender.com';

  // Đăng ký tài khoản người dùng
  static Future<http.Response> registerUser(String email, String tenNguoiDung, String matKhau) async {
    final String url = '$baseUrl/users/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'email': email,
          'userName': tenNguoiDung,
          'password': matKhau,
        }),
      );

      return response;
    } catch (e) {
      throw Exception('Lỗi khi đăng ký tài khoản: $e');
    }
  }

  // Đăng nhập người dùng
  static Future<Map<String, dynamic>> loginUser(String dangNhap, String matKhau) async {
    final url = Uri.parse('$baseUrl/users/login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"login": dangNhap, "password": matKhau}),
      );

      print('Mã trạng thái: ${response.statusCode}');
      print('Nội dung phản hồi: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'userId': responseData['userId'],
          'message': responseData['message'],
        };
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      print('Lỗi khi đăng nhập: $e');
      throw Exception('Lỗi khi đăng nhập: $e');
    }
  }

  // Lấy cuộc trò chuyện theo ID của người dùng
  static Future<List<Conversation>> fetchConversationsByUserId(String userId) async {
    final url = Uri.parse('$baseUrl/api/conversations/user/$userId');

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      print('Mã trạng thái: ${response.statusCode}');
      print('Nội dung phản hồi: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        print('Dữ liệu phản hồi: $responseData');
        return responseData.map((data) {
          print('Đang xử lý dữ liệu: $data');
          return Conversation.fromJson(data);
        }).toList();
      } else {
        final responseData = jsonDecode(response.body);
        print('Phản hồi lỗi: $responseData');
        throw Exception(responseData['error'] ?? 'Không thể lấy cuộc trò chuyện');
      }
    } catch (e) {
      print('Lỗi khi lấy cuộc trò chuyện: $e');
      throw Exception('Lỗi khi lấy cuộc trò chuyện: $e');
    }
  }

  // Tạo cuộc trò chuyện mới
  static Future<http.Response> createNewConversation(String userId) async {
    final String url = '$baseUrl/api/conversations';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'userId': userId,
        }),
      );

      if (response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Tạo cuộc trò chuyện mới thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi khi tạo cuộc trò chuyện mới: $e');
    }
  }

  // Thêm tin nhắn vào cuộc trò chuyện
  static Future<http.Response> addMessage(String conversationId, String noiDung, String nguoiGui) async {
    final String url = '$baseUrl/api/conversations/$conversationId/message';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'message': noiDung,
          'sender': nguoiGui,
        }),
      );

      print('Phản hồi khi thêm tin nhắn: ${response.statusCode}');
      print('Nội dung phản hồi khi thêm tin nhắn: ${response.body}');

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Không thể thêm tin nhắn');
      }
    } catch (e) {
      print('Lỗi khi thêm tin nhắn: $e');
      throw Exception('Lỗi khi thêm tin nhắn: $e');
    }
  }

  // Lấy tin nhắn của cuộc trò chuyện theo ID của cuộc trò chuyện
  static Future<List<Map<String, String>>> fetchMessagesByConversationId(String conversationId) async {
    final url = Uri.parse('$baseUrl/api/conversations/$conversationId');

    try {
      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      print('Mã trạng thái: ${response.statusCode}');
      print('Nội dung phản hồi: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print('Dữ liệu cuộc trò chuyện đã lấy: $responseData');

        // Lấy danh sách tin nhắn từ dữ liệu phản hồi
        final List<dynamic> messages = responseData['messages'];
        return messages.map((msg) => {
          'sender': msg['sender'].toString(),
          'message': msg['message'].toString()
        }).toList();
      } else {
        final responseData = jsonDecode(response.body);
        print('Phản hồi lỗi: $responseData');
        throw Exception(responseData['error'] ?? 'Không thể lấy cuộc trò chuyện');
      }
    } catch (e) {
      print('Lỗi khi lấy cuộc trò chuyện: $e');
      throw Exception('Lỗi khi lấy cuộc trò chuyện: $e');
    }
  }
  // Thêm chức năng xóa cuộc trò chuyện
  static Future<http.Response> deleteConversation(String conversationId) async {
    final String url = '$baseUrl/api/conversations/$conversationId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      print('Phản hồi khi xóa cuộc trò chuyện: ${response.statusCode}');
      print('Nội dung phản hồi khi xóa cuộc trò chuyện: ${response.body}');

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Không thể xóa cuộc trò chuyện');
      }
    } catch (e) {
      print('Lỗi khi xóa cuộc trò chuyện: $e');
      throw Exception('Lỗi khi xóa cuộc trò chuyện: $e');
    }
  }

}
