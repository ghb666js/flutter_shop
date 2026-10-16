class GlobalConstants {
  // ===== 旧 meikou 测试接口配置（首页/分类/商品等仍使用）=====
  static const String BASE_URL = 'https://meikou-api.itheima.net';
  static const int TIME_OUT = 10;
  static const String SUCCESS_CODE = '1';
  static const String TOKEN_KEY = 'hm_shop_token';

  // ===== 新后端：用户认证服务（http://120.26.231.136:3001）=====
  static const String USER_API_BASE = 'http://120.26.231.136:3001';
  // 登录后用户信息本地缓存 key（含头像等本地设置项）
  static const String USER_INFO_KEY = 'hm_shop_user_info';
  // 本地头像缓存 key（后端无头像接口，头像仅存本地）
  static const String USER_AVATAR_KEY = 'hm_shop_user_avatar';
  // 本地昵称缓存 key（后端无 nickname 字段，昵称仅存本地）
  static const String USER_NICKNAME_KEY = 'hm_shop_user_nickname';
}

class HttpConstants {
  static const String BANNER_LIST = '/home/banner';
  static const String CATEGORY_LIST = '/home/category/head';
  static const String PRODUCT_LIST = '/hot/preference';
  static const String INVOGUE_LIST = '/hot/inVogue';
  static const String ONESTOP_LIST = '/hot/oneStop';
  static const String RECOMMEND_LIST = 'https://dummyjson.com/products';
  static const String GUESSLIKE_LIST = '/home/goods/guessLike';

  // ===== 旧用户接口（已废弃，保留注释备查）=====
  // static const String LOGIN = '/login';
  // static const String USER_PROFILE = '/member/profile';

  // ===== 新用户认证接口（http://120.26.231.136:3001）=====
  static const String LOGIN = '/api/login';
  static const String REGISTER = '/api/register';
  static const String SEND_CODE = '/api/sendCode';
  static const String USER_PROFILE = '/api/me'; // 获取当前登录用户信息（Bearer）
  static const String LOGOUT = '/api/logout';
}
