import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hm_shop/stores/MemberController.dart';
import 'package:hm_shop/utils/LoginGuard.dart';
import 'package:hm_shop/utils/ToastUtils.dart';
import 'package:hm_shop/viewmodels/member.dart';

class MemberPage extends StatefulWidget {
  MemberPage({Key? key}) : super(key: key);

  @override
  _MemberPageState createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  static const Color _primary = Color(0xFFFA6D6D);
  static const Color _gold1 = Color(0xFFFFD700);
  static const Color _gold2 = Color(0xFFE5A100);
  static const Color _goldDark = Color(0xFF8A6D00);
  static const Color _textMain = Color(0xFF333333);
  static const Color _textSub = Color(0xFF999999);

  late final MemberController _memberController;
  int _selected = 0; // 默认选中连续包月

  @override
  void initState() {
    super.initState();
    _memberController = Get.find<MemberController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isMember = _memberController.isMember;
      return Scaffold(
        backgroundColor: Color(0xFFF6F6F6),
        appBar: AppBar(
          title: Text(isMember ? '我的会员' : '开通会员'),
          centerTitle: true,
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: isMember ? _buildMemberView() : _buildActivationView(),
        bottomNavigationBar: isMember ? null : _buildBuyBar(),
      );
    });
  }

  // ============ 开通视图 ============

  Widget _buildActivationView() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildHero(),
        SizedBox(height: 20),
        Text(
          '选择套餐',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _textMain,
          ),
        ),
        SizedBox(height: 12),
        _buildPackageGrid(),
        SizedBox(height: 12),
        Text(
          '购买即视为同意《会员服务协议》，连续包月次月自动续费1元/月，可随时取消。',
          style: TextStyle(fontSize: 11, color: _textSub),
        ),
      ],
    );
  }

  /// 顶部金色渐变权益卡片
  Widget _buildHero() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gold1, _gold2],
        ),
        boxShadow: [
          BoxShadow(
            color: _gold2.withOpacity(.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.white, size: 26),
              SizedBox(width: 6),
              Text(
                '尊享会员',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '开通即享 6 大专属权益，购物更省更尊贵',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(.92),
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: memberBenefits
                .map((b) => _buildHeroChip(b.title))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, color: Colors.white)),
    );
  }

  /// 套餐 2x2 网格
  Widget _buildPackageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: memberPackages.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) =>
          _buildPackageCard(memberPackages[index], index),
    );
  }

  Widget _buildPackageCard(MemberPackage pkg, int index) {
    final selected = _selected == index;
    return GestureDetector(
      onTap: () => setState(() => _selected = index),
      child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? _gold2 : Colors.transparent,
                width: selected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  pkg.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _textMain,
                  ),
                ),
                SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '¥',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: pkg.price.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  pkg.duration,
                  style: TextStyle(fontSize: 12, color: _textSub),
                ),
                if (pkg.isContinuous)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      '次月续费1元',
                      style: TextStyle(fontSize: 10, color: _goldDark),
                    ),
                  ),
              ],
            ),
          ),
          if (pkg.tag != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_gold1, _gold2]),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Text(
                  pkg.tag!,
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          if (selected)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: _gold2,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(11),
                    bottomRight: Radius.circular(11),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 底部购买栏
  Widget _buildBuyBar() {
    final pkg = memberPackages[_selected];
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('应付', style: TextStyle(fontSize: 11, color: _textSub)),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '¥',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: pkg.price.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _onBuy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold2,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  '立即购买',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onBuy() {
    if (!requireLogin(context)) return;
    _memberController.purchase(memberPackages[_selected]);
    ToastUtils.showToast(context, '购买成功', showWith: 200);
    // Obx 自动切换到会员视图
  }

  // ============ 会员视图 ============

  Widget _buildMemberView() {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _buildMemberHeader(),
        SizedBox(height: 20),
        Row(
          children: [
            Text(
              '会员权益',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _textMain,
              ),
            ),
            SizedBox(width: 6),
            Text('共6项', style: TextStyle(fontSize: 12, color: _textSub)),
          ],
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: memberBenefits.map((b) => _buildBenefitItem(b)).toList(),
          ),
        ),
        SizedBox(height: 12),
        Text(
          '权益以实际使用为准，会员到期后自动失效。',
          style: TextStyle(fontSize: 11, color: _textSub),
        ),
      ],
    );
  }

  /// 会员状态卡片（剩余时间）
  Widget _buildMemberHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_gold1, _gold2],
        ),
        boxShadow: [
          BoxShadow(
            color: _gold2.withOpacity(.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.white, size: 26),
              SizedBox(width: 6),
              Text(
                '尊享会员',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _memberController.packageName,
                  style: TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          Text(
            _memberController.remainingText,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(MemberBenefit b) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black.withOpacity(.05)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _gold1.withOpacity(.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(b.icon, color: _gold2, size: 22),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textMain,
                  ),
                ),
                SizedBox(height: 2),
                Text(b.desc, style: TextStyle(fontSize: 12, color: _textSub)),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: _gold2, size: 20),
        ],
      ),
    );
  }
}
