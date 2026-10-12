import 'package:hm_shop/constants/index.dart';
import 'package:hm_shop/utils/DioRequest.dart';
import 'package:hm_shop/viewmodels/index.dart';

Future<GuessLikeData> getGuessLikeData(Map<String, int> p) async {
  final res = await dioRequest.get(HttpConstants.GUESSLIKE_LIST, params: p);
  return GuessLikeData.fromJson(res as Map<String, dynamic>);
}
