import 'package:get/get.dart';
import 'package:hm_shop/viewmodels/member.dart';

/// 会员状态：内存态，与购物车/收藏/订单一致。
/// 购买需登录态，由调用方（UI）在购买动作时用 LoginGuard 校验。
class MemberController extends GetxController {
  Rx<MemberInfo> member = MemberInfo.empty().obs;

  bool get isMember => member.value.isMember;

  /// 购买套餐：在已有到期时间基础上叠加（支持续费）
  void purchase(MemberPackage pkg) {
    final now = DateTime.now();
    final base = (isMember && member.value.expireTime!.isAfter(now))
        ? member.value.expireTime!
        : now;
    late DateTime expire;
    switch (pkg.id) {
      case 'month':
        expire = base.add(Duration(days: 30));
        break;
      case 'quarter':
        expire = base.add(Duration(days: 90));
        break;
      case 'year':
        expire = base.add(Duration(days: 365));
        break;
      case 'continuous':
        expire = base.add(Duration(days: 30));
        break;
      default:
        expire = base;
    }
    member.value = MemberInfo(
      isMember: true,
      packageType: pkg.id,
      buyTime: now,
      expireTime: expire,
    );
  }

  /// 剩余天数
  int get remainingDays {
    if (!isMember || member.value.expireTime == null) return 0;
    final diff = member.value.expireTime!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// 剩余时间描述
  String get remainingText {
    if (!isMember) return '未开通';
    final exp = member.value.expireTime!;
    final mm = exp.month.toString().padLeft(2, '0');
    final dd = exp.day.toString().padLeft(2, '0');
    return '剩余 $remainingDays 天 · 到期 ${exp.year}年$mm月$dd日';
  }

  /// 套餐名
  String get packageName {
    if (!isMember) return '';
    final type = member.value.packageType;
    final pkg = memberPackages.firstWhere(
      (p) => p.id == type,
      orElse: () => memberPackages.first,
    );
    return pkg.name;
  }

  /// 退出登录时清空会员状态
  void clear() {
    member.value = MemberInfo.empty();
  }
}
