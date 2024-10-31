import 'package:flutter/material.dart';
import 'package:english_chatbot/Services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'conversations_screen.dart';
// Tiếp tục màn hình đăng nhập (LoginScreen) với các chức năng bổ sung

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // Hàm xử lý đăng nhập
  void handleLogin(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final login = emailController.text;
    final password = passwordController.text;

    try {
      final response = await ApiServices.loginUser(login, password);

      // Nếu đăng nhập thành công, lưu userId và chuyển màn hình
      String userId = response['userId'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
      print(response['message']);

      // Chuyển sang màn hình Lịch sử cuộc trò chuyện
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ConversationScreen()),
      );
    } catch (e) {
      // Hiển thị thông báo lỗi nếu đăng nhập thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                // Hiển thị logo ứng dụng
                Container(
                  height: 150,
                  child: Image.asset('assets/logo.png'),
                ),
                SizedBox(height: 20),
                // Dòng chào mừng người dùng quay lại
                Text(
                  "Chào Mừng Trở Lại!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: 10),
                // Hướng dẫn ngắn gọn để người dùng đăng nhập
                Text(
                  "Đăng nhập để tiếp tục",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 40),
                // Trường nhập email hoặc tên đăng nhập
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email hoặc Tên Đăng Nhập',
                    prefixIcon: Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                // Trường nhập mật khẩu
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: Icon(Icons.lock, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                // Nút đăng nhập với hiệu ứng tải (nếu đang xử lý đăng nhập)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!isLoading) {
                        handleLogin(context);
                      }
                    },
                    child: isLoading
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : Text(
                      'Đăng Nhập',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Tùy chọn quên mật khẩu
                TextButton(
                  onPressed: () {
                    // TODO: Chức năng quên mật khẩu sẽ được bổ sung sau
                  },
                  child: Text(
                    'Quên Mật Khẩu?',
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                ),
                SizedBox(height: 20),
                // Liên kết để chuyển sang màn hình đăng ký
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Chưa có tài khoản? "),
                    GestureDetector(
                      onTap: () {
                        // TODO: Thêm chức năng đăng ký
                      },
                      child: Text(
                        "Đăng Ký",
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
