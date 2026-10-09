import 'package:dio/dio.dart';
import 'package:hm_shop/constants/index.dart';

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
          handle.reject(error);
        },
      ),
    );
  }

  /// 发送GET请求
  Future<dynamic> get(String url, {Map<String, dynamic>? params}) {
    return getResult(_dio.get(url, queryParameters: params));
  }

  /// 进一步结构返回结果
  Future<dynamic> getResult(Future<Response<dynamic>> task) async {
    try {
      Response<dynamic> res = await task;
      final data = res.data as Map<String, dynamic>;
      if (data['code'] == GlobalConstants.SUCCESS_CODE) {
        return data['result'];
      }
      throw Exception(data['msg'] ?? '加载数据异常');
    } catch (err) {
      throw Exception(err);
    }
  }
}

final dioRequest = DioRequest();
