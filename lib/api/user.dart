import 'package:hm_shop/constants/index.dart';
import 'package:hm_shop/utils/DioRequest.dart';
import 'package:hm_shop/viewmodels/users.dart';

Future<UserInfo> loginApi(Map<String, dynamic> data) async {
  return UserInfo.fromJSON(
    await dioRequest.post(HttpConstants.LOGIN, data: data),
  );
}

Future<UserInfo> getUserProfile() async {
  return UserInfo.fromJSON(await dioRequest.get(HttpConstants.USER_PROFILE));
}
