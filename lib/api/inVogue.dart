import 'package:hm_shop/constants/index.dart';
import 'package:hm_shop/utils/DioRequest.dart';
import 'package:hm_shop/viewmodels/index.dart';

Future<SuggestionData> getInVogueData() async {
  final res = await dioRequest.get(HttpConstants.INVOGUE_LIST);
  return SuggestionData.fromJson(res as Map<String, dynamic>);
}
