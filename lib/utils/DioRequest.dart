import 'package:dio/dio.dart';
import 'package:hm_shop/constants/index.dart';
import 'package:hm_shop/stores/TokenManager.dart';

class DioRequest {
  final Dio _dio = Dio();

  /// 配置请求参数
  DioRequest() {
    _dio.options
      ..baseUrl = GlobalConstants.BASE_URL
      ..connectTimeout = Duration(seconds: 10)
      ..sendTimeout = Duration(seconds: 10)
      ..receiveTimeout = Duration(seconds: 10);
    _getInterceptor();
  }

  /// 配置拦截拦截器
  void _getInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handle) {
          if (tokenManager.getToken().isNotEmpty) {
            request.headers = {
              'Authorization': 'Bearer ${tokenManager.getToken()}',
            };
          }
          handle.next(request);
        },
        onResponse: (response, handle) {
          if (response.statusCode! >= 200 && response.statusCode! < 300) {
            handle.next(response);
            return;
          }

          handle.reject(DioException(requestOptions: response.requestOptions));
        },
        onError: (error, handle) {
          handle.reject(
            DioException(
              requestOptions: error.requestOptions,
              message: error.response?.data['msg'] ?? '',
            ),
          );
        },
      ),
    );
  }

  /// 发送GET请求
  Future<dynamic> get(String url, {Map<String, dynamic>? params}) {
    return getResult(_dio.get(url, queryParameters: params));
  }

  Future<dynamic> post(String url, {Map<String, dynamic>? data}) {
    return getResult(_dio.post(url, data: data));
  }

  /// 发送GET请求（原始返回，不剥离业务包装 code/result）
  /// 用于调用返回纯数组或非标准结构的外部接口
  Future<dynamic> getRaw(String url, {Map<String, dynamic>? params}) async {
    final res = await _dio.get(url, queryParameters: params);
    return res.data;
  }

  /// 进一步结构返回结果
  Future<dynamic> getResult(Future<Response<dynamic>> task) async {
    try {
      Response<dynamic> res = await task;
      final data = res.data as Map<String, dynamic>;
      if (data['code'] == GlobalConstants.SUCCESS_CODE) {
        return data['result'];
      }
      throw DioException(
        requestOptions: res.requestOptions,
        message: data['msg'] ?? '加载数据异常',
      );
    } catch (err) {
      // 不改变原来的异常类型
      rethrow;
    }
  }
}

final dioRequest = DioRequest();
