import 'package:hm_shop/constants/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 全局状态管理-token管理
class TokenManager {
  String _token = '';

  /// 返回持久化对象的实例
  Future<SharedPreferences> _getInstances() {
    return SharedPreferences.getInstance();
  }

  /// 初始化token
  init() async {
    final prefs = await _getInstances();
    _token = prefs.getString(GlobalConstants.TOKEN_KEY) ?? '';
  }

  /// 设置token
  setToken(String val) async {
    final prefs = await _getInstances();
    prefs.setString(GlobalConstants.TOKEN_KEY, val);
    _token = val;
  }

  /// 获取token
  getToken() {
    return _token;
  }

  /// 移除token
  removeToken() async {
    final prefs = await _getInstances();
    prefs.remove(GlobalConstants.TOKEN_KEY); //移除磁盘token
    _token = ''; //清空内存token
  }
}

final tokenManager = TokenManager();
