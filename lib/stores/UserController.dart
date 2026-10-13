import 'package:get/get.dart';
import 'package:hm_shop/viewmodels/users.dart';

/// 全局状态管理-用户信息管理
class UserController extends GetxController {
  var user = UserInfo.fromJSON({}).obs; //UserInfo被监听

  updataUserInfo(UserInfo newUser) {
    // 通过user.value获取值

    user.value = newUser;
  }
}
