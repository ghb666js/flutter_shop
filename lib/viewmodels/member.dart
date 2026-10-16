import 'package:flutter/material.dart';

/// 会员套餐
class MemberPackage {
  final String id;
  final String name; // 一个月 / 一个季度 / 包年 / 连续包月
  final double price;
  final String duration; // 时长描述
  final String? tag; // 角标：热门 / 超值 / 首月特惠
  final bool isContinuous; // 是否连续包月

  const MemberPackage({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    this.tag,
    this.isContinuous = false,
  });
}

/// 会员权益
class MemberBenefit {
  final IconData icon;
  final String title;
  final String desc;

  const MemberBenefit({
    required this.icon,
    required this.title,
    required this.desc,
  });
}

/// 会员状态信息
class MemberInfo {
  final bool isMember;
  final String? packageType;
  final DateTime? buyTime;
  final DateTime? expireTime;

  MemberInfo({
    this.isMember = false,
    this.packageType,
    this.buyTime,
    this.expireTime,
  });

  factory MemberInfo.empty() => MemberInfo();
}

/// 4 个会员套餐（连续包月 / 一个月 / 一个季度 / 包年）
const List<MemberPackage> memberPackages = [
  MemberPackage(
    id: 'continuous',
    name: '连续包月',
    price: 1,
    duration: '1个月',
    tag: '首月特惠',
    isContinuous: true,
  ),
  MemberPackage(id: 'month', name: '一个月', price: 10, duration: '1个月'),
  MemberPackage(
    id: 'quarter',
    name: '一个季度',
    price: 25,
    duration: '3个月',
    tag: '热门',
  ),
  MemberPackage(id: 'year', name: '包年', price: 99, duration: '12个月', tag: '超值'),
];

/// 6 大会员权益
const List<MemberBenefit> memberBenefits = [
  MemberBenefit(
    icon: Icons.local_shipping,
    title: '全场免邮',
    desc: '会员尊享全场商品包邮权益',
  ),
  MemberBenefit(icon: Icons.discount, title: '专属折扣', desc: '会员专享商品额外95折优惠'),
  MemberBenefit(icon: Icons.bolt, title: '优先发货', desc: '订单优先处理，极速发货'),
  MemberBenefit(icon: Icons.cake, title: '生日礼遇', desc: '生日月专享大额优惠券'),
  MemberBenefit(
    icon: Icons.support_agent,
    title: '专属客服',
    desc: '7×24小时一对一专属客服',
  ),
  MemberBenefit(icon: Icons.stars, title: '积分翻倍', desc: '购物消费积分双倍累计'),
];
