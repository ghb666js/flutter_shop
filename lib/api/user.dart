import 'package:dio/dio.dart';
import 'package:hm_shop/constants/index.dart';
import 'package:hm_shop/utils/DioRequest.dart';
import 'package:hm_shop/viewmodels/users.dart';

// ===== 旧 meikou 接口实现（已废弃，保留注释备查）=====
// Future<UserInfo> loginApi(Map<String, dynamic> data) async {
//   return UserInfo.fromJSON(
//     await dioRequest.post(HttpConstants.LOGIN, data: data),
//   );
// }
//
// Future<UserInfo> getUserProfile() async {
//   return UserInfo.fromJSON(await dioRequest.get(HttpConstants.USER_PROFILE));
// }

/// 新后端认证接口基址
String _u(String path) => '${GlobalConstants.USER_API_BASE}$path';

/// 通用结果解析：新后端成功返回 {code:0, msg, data}，失败 {code:1, msg} / {code:401, msg}
/// 返回 (success, data, msg)
({bool ok, dynamic data, String msg}) _parse(dynamic resp) {
  if (resp is! Map) return (ok: false, data: null, msg: '响应格式异常');
  final m = Map<String, dynamic>.from(resp);
  final code = m['code'];
  final success = code is int ? code == 0 : code == 0 || code == '0';
  return (
    ok: success,
    data: m['data'],
    msg: (m['msg'] ?? '').toString(),
  );
}

/// 登录：POST /api/login  body: {account, password}
/// 成功返回 {code:0, data:{token, user:{account, phone, phoneMask, createdAt}}}
Future<UserInfo> loginApi(Map<String, dynamic> data) async {
  final resp = await dioRequest.postRaw(_u(HttpConstants.LOGIN), data: data);
  final r = _parse(resp);
  if (!r.ok) {
    throw DioException(
      requestOptions: RequestOptions(path: HttpConstants.LOGIN),
      message: r.msg.isEmpty ? '登录失败' : r.msg,
    );
  }
  // data 形如 {token, user:{...}}，UserInfo.fromJSON 会自适应取 data.user 与 data.token
  return UserInfo.fromJSON({'data': r.data});
}

/// 注册：POST /api/register  body: {phone, code, password}
/// 成功返回 {code:0, msg:'注册成功，请登录', data:null}
/// 失败抛出含 msg 的异常
Future<void> registerApi(Map<String, dynamic> data) async {
  final resp = await dioRequest.postRaw(_u(HttpConstants.REGISTER), data: data);
  final r = _parse(resp);
  if (!r.ok) {
    throw DioException(
      requestOptions: RequestOptions(path: HttpConstants.REGISTER),
      message: r.msg.isEmpty ? '注册失败' : r.msg,
    );
  }
}

/// 发送手机验证码：POST /api/sendCode  body: {phone}
/// mock 模式下返回 {code:0, data:{devCode:'xxxxxx'}}，devCode 即演示验证码
/// 返回 (msg, devCode)，devCode 为空表示真实短信通道
Future<({String msg, String devCode})> sendCodeApi(String phone) async {
  final resp = await dioRequest.postRaw(
    _u(HttpConstants.SEND_CODE),
    data: {'phone': phone},
  );
  final r = _parse(resp);
  if (!r.ok) {
    throw DioException(
      requestOptions: RequestOptions(path: HttpConstants.SEND_CODE),
      message: r.msg.isEmpty ? '验证码发送失败' : r.msg,
    );
  }
  final dev = (r.data is Map ? r.data['devCode'] : null)?.toString() ?? '';
  return (msg: r.msg, devCode: dev);
}

/// 获取当前登录用户信息：GET /api/me （Bearer）
/// 返回 {code:0, data:{account, phone, phoneMask, createdAt}}
Future<UserInfo> getUserProfile() async {
  final resp = await dioRequest.getRaw(_u(HttpConstants.USER_PROFILE));
  final r = _parse(resp);
  if (!r.ok) {
    throw DioException(
      requestOptions: RequestOptions(path: HttpConstants.USER_PROFILE),
      message: r.msg.isEmpty ? '获取用户信息失败' : r.msg,
    );
  }
  // /api/me 的 data 直接是用户字段，UserInfo.fromJSON 取 data 作为 user
  return UserInfo.fromJSON({'data': r.data});
}

/// 退出登录：POST /api/logout （Bearer）
Future<void> logoutApi() async {
  try {
    await dioRequest.postRaw(_u(HttpConstants.LOGOUT));
  } catch (_) {
    // 退出失败不阻塞前端清栈
  }
}
