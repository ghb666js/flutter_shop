import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hm_shop/api/user.dart';
import 'package:hm_shop/utils/ToastUtils.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _accountCtrl = TextEditingController();
  final TextEditingController _pwdCtrl = TextEditingController();
  bool _obscure = true;
  bool _agreed = false;

  late final TapGestureRecognizer _privacyTap = TapGestureRecognizer()
    ..onTap = () => _showTip('隐私条款');
  late final TapGestureRecognizer _userTap = TapGestureRecognizer()
    ..onTap = () => _showTip('用户协议');

  @override
  void dispose() {
    _accountCtrl.dispose();
    _pwdCtrl.dispose();
    _privacyTap.dispose();
    _userTap.dispose();
    super.dispose();
  }

  void _showTip(String s) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$s（暂未实现）'),
        duration: Duration(milliseconds: 800),
      ),
    );
  }

  _login() async {
    try {
      final res = await loginApi({
        'account': _accountCtrl.text,
        'password': _pwdCtrl.text,
      });
      ToastUtils.showToast(context, '登陆成功');
      print(res);
      Navigator.pop(context);
    } catch (e) {
      ToastUtils.showToast(
        context,
        (e as DioException).message ?? '登陆失败',
        showWith: 240,
      );
    }
  }

  void _handleLogin() {
    // 执行输入框中的所有validator验证
    _key.currentState?.validate();
    if (_agreed) {
      _login();
    } else {
      ToastUtils.showToast(context, '请先同意隐私条款和用户协议', showWith: 240);
    }
  }

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '惠多美登录',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _key,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 24),
              Text(
                '账号密码登录',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '账号不能为空';
                  }
                  if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                    return '请输入正确的手机号';
                  }
                  return null;
                },
                controller: _accountCtrl,
                decoration: InputDecoration(
                  hintText: '请输入账号',
                  hintStyle: TextStyle(color: Color(0xFF999999), fontSize: 14),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '密码不能为空';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9_]{6,16}$').hasMatch(value)) {
                    return '请输6到16位的字母或者下划线';
                  }
                  return null;
                },
                controller: _pwdCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: '请输入密码',
                  hintStyle: TextStyle(color: Color(0xFF999999), fontSize: 14),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Color(0xFF999999),
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: Checkbox(
                      value: _agreed,
                      onChanged: (v) => setState(() => _agreed = v ?? false),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                        children: [
                          TextSpan(text: '查看并同意'),
                          TextSpan(
                            text: '《隐私条款》',
                            recognizer: _privacyTap,
                            style: TextStyle(color: Color(0xFF1890FF)),
                          ),
                          TextSpan(text: '和'),
                          TextSpan(
                            text: '《用户协议》',
                            recognizer: _userTap,
                            style: TextStyle(color: Color(0xFF1890FF)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: StadiumBorder(),
                  ),
                  child: Text(
                    '登录',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
