import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/state_manager.dart';
import 'package:hm_shop/api/user.dart';
import 'package:hm_shop/stores/TokenManager.dart';
import 'package:hm_shop/stores/UserController.dart';
import 'package:hm_shop/utils/LoadingDialog.dart';
import 'package:hm_shop/utils/ToastUtils.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// true=登录，false=注册
  bool _isLogin = true;

  final TextEditingController _accountCtrl = TextEditingController();
  final TextEditingController _pwdCtrl = TextEditingController();
  final TextEditingController _codeCtrl = TextEditingController();
  final UserController _userController = Get.find();
  bool _obscure = true;
  bool _agreed = false;

  /// 验证码倒计时
  int _countdown = 0;
  Timer? _timer;

  late final TapGestureRecognizer _privacyTap = TapGestureRecognizer()
    ..onTap = () => _showTip('隐私条款');
  late final TapGestureRecognizer _userTap = TapGestureRecognizer()
    ..onTap = () => _showTip('用户协议');

  @override
  void dispose() {
    _accountCtrl.dispose();
    _pwdCtrl.dispose();
    _codeCtrl.dispose();
    _privacyTap.dispose();
    _userTap.dispose();
    _timer?.cancel();
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

  /// 获取验证码
  Future<void> _sendCode() async {
    final phone = _accountCtrl.text.trim();
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      ToastUtils.showToast(context, '请先输入正确的手机号', showWith: 240);
      return;
    }
    try {
      Loadingdialog.show(context, message: '发送中');
      final r = await sendCodeApi(phone);
      Loadingdialog.hide(context);
      // mock 模式回传 devCode，便于本地演示
      if (r.devCode.isNotEmpty) {
        _codeCtrl.text = r.devCode;
        ToastUtils.showToast(context, '演示验证码：${r.devCode}', showWith: 280);
      } else {
        ToastUtils.showToast(context, '验证码已发送', showWith: 240);
      }
      _startCountdown();
    } catch (e) {
      Loadingdialog.hide(context);
      ToastUtils.showToast(
        context,
        (e as DioException).message ?? '验证码发送失败',
        showWith: 240,
      );
    }
  }

  void _startCountdown() {
    setState(() => _countdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _countdown -= 1);
      if (_countdown <= 0) {
        t.cancel();
      }
    });
  }

  /// 登录
  Future<void> _login() async {
    try {
      Loadingdialog.show(context, message: '努力登陆中');
      final res = await loginApi({
        'account': _accountCtrl.text.trim(),
        'password': _pwdCtrl.text,
      });
      _userController.updataUserInfo(res);
      tokenManager.setToken(res.token);
      // 恢复本地设置项（头像/昵称）
      await _userController.loadLocalAvatar();
      await _userController.loadLocalNickname();
      Loadingdialog.hide(context);
      ToastUtils.showToast(context, '登陆成功');
      Navigator.pop(context);
    } catch (e) {
      Loadingdialog.hide(context);
      ToastUtils.showToast(
        context,
        (e as DioException).message ?? '登陆失败',
        showWith: 240,
      );
    }
  }

  /// 注册
  Future<void> _register() async {
    try {
      Loadingdialog.show(context, message: '注册中');
      await registerApi({
        'phone': _accountCtrl.text.trim(),
        'code': _codeCtrl.text.trim(),
        'password': _pwdCtrl.text,
      });
      Loadingdialog.hide(context);
      ToastUtils.showToast(context, '注册成功，请登录', showWith: 240);
      setState(() {
        _isLogin = true;
        _codeCtrl.clear();
        _pwdCtrl.clear();
      });
    } catch (e) {
      Loadingdialog.hide(context);
      ToastUtils.showToast(
        context,
        (e as DioException).message ?? '注册失败',
        showWith: 240,
      );
    }
  }

  void _handleSubmit() {
    _key.currentState?.validate();
    if (!_agreed) {
      ToastUtils.showToast(context, '请先同意隐私条款和用户协议', showWith: 240);
      return;
    }
    if (_isLogin) {
      _login();
    } else {
      _register();
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
          _isLogin ? '惠多美登录' : '惠多美注册',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _key,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24),
                Text(
                  _isLogin ? '账号密码登录' : '手机号注册',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 24),
                _buildAccountField(),
                SizedBox(height: 16),
                // 注册模式多一个验证码输入
                if (!_isLogin) ...[_buildCodeField(), SizedBox(height: 16)],
                _buildPwdField(),
                SizedBox(height: 20),
                _buildAgreement(),
                SizedBox(height: 28),
                _buildSubmit(),
                SizedBox(height: 16),
                _buildSwitchMode(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountField() {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) return '手机号不能为空';
        if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) return '请输入正确的手机号';
        return null;
      },
      controller: _accountCtrl,
      keyboardType: TextInputType.phone,
      decoration: _inputDecoration(hint: _isLogin ? '请输入手机号（账号）' : '请输入手机号'),
    );
  }

  Widget _buildCodeField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) return '验证码不能为空';
              if (!RegExp(r'^\d{4,6}$').hasMatch(value)) return '请输入正确的验证码';
              return null;
            },
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            decoration: _inputDecoration(hint: '请输入验证码'),
          ),
        ),
        SizedBox(width: 12),
        SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: _countdown > 0 ? null : _sendCode,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: BorderSide(color: Color(0xFFE5E5E5)),
              shape: StadiumBorder(),
            ),
            child: Text(
              _countdown > 0 ? '${_countdown}s' : '获取验证码',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPwdField() {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) return '密码不能为空';
        // 后端要求密码至少 8 位
        if (value.length < 8) return '密码至少需要 8 位';
        return null;
      },
      controller: _pwdCtrl,
      obscureText: _obscure,
      decoration: _inputDecoration(
        hint: _isLogin ? '请输入密码' : '设置密码（至少 8 位）',
        suffix: IconButton(
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
    );
  }

  Widget _buildAgreement() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: Checkbox(
            value: _agreed,
            onChanged: (v) => setState(() => _agreed = v ?? false),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
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
    );
  }

  Widget _buildSubmit() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: StadiumBorder(),
        ),
        child: Text(
          _isLogin ? '登录' : '注册',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSwitchMode() {
    return Center(
      child: GestureDetector(
        onTap: () => setState(() {
          _isLogin = !_isLogin;
          _codeCtrl.clear();
        }),
        child: Text(
          _isLogin ? '没有账号？去注册' : '已有账号？去登录',
          style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Color(0xFF999999), fontSize: 14),
      filled: true,
      fillColor: Color(0xFFF5F5F5),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffix,
    );
  }
}
