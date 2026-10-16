import 'dart:convert';

// 生成对应的class
class UserInfo {
  String account;
  String avatar;
  String birthday;
  String cityCode;
  String gender;
  String id;
  String mobile;
  String nickname;
  String profession;
  String provinceCode;
  String token;

  UserInfo({
    required this.account,
    required this.avatar,
    required this.birthday,
    required this.cityCode,
    required this.gender,
    required this.id,
    required this.mobile,
    required this.nickname,
    required this.profession,
    required this.provinceCode,
    required this.token,
  });

  // ===== 旧工厂：meikou 接口直接返回用户字段（已废弃，保留注释备查）=====
  // factory UserInfo.fromJSON(Map<String, dynamic> json) => UserInfo(
  //   account: json["account"] ?? "",
  //   avatar: json["avatar"] ?? "",
  //   birthday: json["birthday"] ?? "",
  //   cityCode: json["cityCode"] ?? "",
  //   gender: json["gender"] ?? "",
  //   id: json["id"] ?? "",
  //   mobile: json["mobile"] ?? "",
  //   nickname: json["nickname"] ?? "",
  //   profession: json["profession"] ?? "",
  //   provinceCode: json["provinceCode"] ?? "",
  //   token: json["token"] ?? "",
  // );

  /// 新工厂：解析新后端响应。
  /// 登录响应：{code, msg, data:{ token, user:{ account, phone, phoneMask, createdAt } }}
  /// 用户信息响应：{code, msg, data:{ account, phone, phoneMask, createdAt }}
  /// 用户字段可能在 data.user（登录）或直接在 data（/api/me），这里兼容两种。
  factory UserInfo.fromJSON(Map<String, dynamic> json) {
    final data = _asMap(json['data']) ?? _asMap(json['result']) ?? json;
    // 登录响应里用户在 data.user；/api/me 里用户字段直接在 data
    final user =
        _asMap(data['user']) ??
        _asMap(data['userInfo']) ??
        _asMap(data['info']) ??
        data;
    final account =
        _str(user['account']) ??
        _str(user['username']) ??
        _str(user['name']) ??
        '';
    // 后端无 id 字段，用 account 作为登录态标识（Mine 页据此判断是否登录）
    final id =
        _str(user['id']) ??
        _str(user['userId']) ??
        _str(user['_id']) ??
        account;
    return UserInfo(
      account: account,
      avatar: _str(user['avatar']) ?? _str(user['head']) ?? '',
      birthday: _str(user['birthday']) ?? _str(user['createdAt']) ?? '',
      cityCode: _str(user['cityCode']) ?? '',
      gender: _str(user['gender']) ?? '',
      id: id,
      mobile: _str(user['mobile']) ?? _str(user['phone']) ?? '',
      nickname: _str(user['nickname']) ?? _str(user['nickName']) ?? account,
      profession: _str(user['profession']) ?? '',
      provinceCode: _str(user['provinceCode']) ?? '',
      token:
          _str(user['token']) ??
          _str(data['token']) ??
          _str(json['token']) ??
          _str(data['accessToken']) ??
          '',
    );
  }

  static Map<String, dynamic>? _asMap(dynamic v) =>
      v is Map<String, dynamic> ? v : null;

  /// 安全取字符串，空值返回 null 以便走 ?? 回退
  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v is String ? v : v.toString();
    return s.isEmpty ? null : s;
  }

  /// 序列化为 JSON（用于本地持久化）
  Map<String, dynamic> toJson() => {
    'account': account,
    'avatar': avatar,
    'birthday': birthday,
    'cityCode': cityCode,
    'gender': gender,
    'id': id,
    'mobile': mobile,
    'nickname': nickname,
    'profession': profession,
    'provinceCode': provinceCode,
    'token': token,
  };

  String encode() => jsonEncode(toJson());

  static UserInfo decode(String? raw) {
    if (raw == null || raw.isEmpty) return UserInfo.fromJSON({});
    try {
      return UserInfo.fromJSON(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return UserInfo.fromJSON({});
    }
  }
}
