import 'package:get/get.dart';
import 'package:hm_shop/constants/index.dart';
import 'package:hm_shop/viewmodels/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 全局状态管理-用户信息管理
class UserController extends GetxController {
  var user = UserInfo.fromJSON({}).obs; //UserInfo被监听

  updataUserInfo(UserInfo newUser) {
    // 通过user.value获取值
    user.value = newUser;
  }

  /// 头像本地缓存的 key（按账号隔离）
  String _avatarKey() =>
      '${GlobalConstants.USER_AVATAR_KEY}_${user.value.account}';

  /// 合并本地缓存的头像到当前用户（后端无头像字段，头像仅本地维护）
  Future<void> loadLocalAvatar() async {
    if (user.value.account.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final avatar = prefs.getString(_avatarKey()) ?? '';
    if (avatar.isNotEmpty) {
      final u = user.value;
      u.avatar = avatar;
      user.value = u;
    }
  }

  /// 设置头像（按账号本地持久化）
  Future<void> updateAvatar(String avatar) async {
    final prefs = await SharedPreferences.getInstance();
    if (user.value.account.isNotEmpty) {
      await prefs.setString(_avatarKey(), avatar);
    }
    final u = user.value;
    u.avatar = avatar;
    user.value = u;
  }

  /// 昵称本地缓存的 key（按账号隔离）
  String _nicknameKey() =>
      '${GlobalConstants.USER_NICKNAME_KEY}_${user.value.account}';

  /// 合并本地缓存的昵称到当前用户（后端无 nickname 字段，昵称仅本地维护）
  Future<void> loadLocalNickname() async {
    if (user.value.account.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final nickname = prefs.getString(_nicknameKey()) ?? '';
    if (nickname.isNotEmpty) {
      final u = user.value;
      u.nickname = nickname;
      user.value = u;
    }
  }

  /// 设置昵称（按账号本地持久化）
  Future<void> updateNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    if (user.value.account.isNotEmpty) {
      await prefs.setString(_nicknameKey(), nickname);
    }
    final u = user.value;
    u.nickname = nickname;
    user.value = u;
  }
}
