import 'package:flutter/material.dart';
import 'package:hm_shop/api/guessLike.dart';
import 'package:hm_shop/api/hot.dart';
import 'package:hm_shop/api/inVogue.dart';
import 'package:hm_shop/api/recommend.dart';
import 'package:hm_shop/api/suggestion.dart';
import 'package:hm_shop/viewmodels/index.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const Color _primary = Color(0xFFFA6D6D);
  static const Color _textMain = Color(0xFF333333);
  static const Color _textSub = Color(0xFF999999);

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  /// 全量商品池（预加载，用于搜索和下拉联想）
  List<ItemsData> _allProducts = [];

  /// 是否已预加载完成
  bool _preloaded = false;

  /// 关键词过滤后的搜索结果
  List<ItemsData> _results = [];

  /// 下拉联想词条（最多 10 个）
  List<ItemsData> _suggestions = [];

  /// 是否显示下拉框
  bool _showDropdown = false;

  /// 当前选中的价格筛选词条索引（0=全部）
  int _filterIndex = 0;

  /// 排序方式：0=默认，1=价格升序，2=价格降序
  int _sortIndex = 0;

  bool _loading = false;
  bool _hasSearched = false;

  /// 价格区间词条
  static const List<Map<String, dynamic>> _filters = [
    {'label': '全部', 'min': 0.0, 'max': double.infinity},
    {'label': '¥0-50', 'min': 0.0, 'max': 50.0},
    {'label': '¥50-100', 'min': 50.0, 'max': 100.0},
    {'label': '¥100-300', 'min': 100.0, 'max': 300.0},
    {'label': '¥300以上', 'min': 300.0, 'max': double.infinity},
  ];

  @override
  void initState() {
    super.initState();
    _preloadProducts();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// 预加载全量商品数据（用于搜索和下拉联想）
  Future<void> _preloadProducts() async {
    final Map<String, ItemsData> merged = {};

    final futures = <Future<void>>[
      // 猜你喜欢
      () async {
        try {
          final data = await getGuessLikeData({'page': 1, 'pageSize': 20});
          for (final item in data.itemsData) {
            merged[item.id] = item;
          }
        } catch (_) {}
      }(),
      // 推荐商品
      () async {
        try {
          final list = await getRecommendData({'skip': 0, 'limit': 20});
          for (final item in list) {
            merged.putIfAbsent(
              item.id,
              () => ItemsData(
                id: item.id,
                name: item.name,
                desc: '',
                price: item.price,
                picture: item.picture,
                orderNum: item.payCount.toString(),
              ),
            );
          }
        } catch (_) {}
      }(),
      // 流行精选
      () async {
        try {
          final data = await getInVogueData();
          _extractFromSuggestion(data, merged);
        } catch (_) {}
      }(),
      // 热门商品
      () async {
        try {
          final data = await getHotData();
          _extractFromSuggestion(data, merged);
        } catch (_) {}
      }(),
      // 推荐分类
      () async {
        try {
          final data = await getSuggestionData();
          _extractFromSuggestion(data, merged);
        } catch (_) {}
      }(),
    ];

    await Future.wait(futures);

    if (mounted) {
      setState(() {
        _allProducts = merged.values.toList();
        _preloaded = true;
      });
    }
  }

  /// 从 SuggestionData 中提取商品并合并到 merged
  void _extractFromSuggestion(
    SuggestionData data,
    Map<String, ItemsData> merged,
  ) {
    for (final subType in data.subTypes) {
      for (final goods in subType.goodsItems.items) {
        merged.putIfAbsent(
          goods.id,
          () => ItemsData(
            id: goods.id,
            name: goods.name,
            desc: goods.desc ?? '',
            price: goods.price,
            picture: goods.picture,
            orderNum: goods.orderNum.toString(),
          ),
        );
      }
    }
  }

  /// 输入时更新下拉联想词条（最多 10 个）
  void _onChanged(String text) {
    setState(() {});
    if (text.trim().isEmpty) {
      _suggestions = [];
      _showDropdown = false;
      return;
    }
    final lower = text.toLowerCase();
    _suggestions = _allProducts
        .where(
          (item) =>
              item.name.toLowerCase().contains(lower) ||
              item.desc.toLowerCase().contains(lower),
        )
        .take(10)
        .toList();
    _showDropdown = _suggestions.isNotEmpty && _focusNode.hasFocus;
    setState(() {});
  }

  /// 执行搜索
  void _doSearch() {
    final keyword = _controller.text.trim();
    if (keyword.isEmpty) return;

    _focusNode.unfocus();
    setState(() {
      _showDropdown = false;
      _loading = true;
      _hasSearched = true;
    });

    final lower = keyword.toLowerCase();
    _results = _allProducts.where((item) {
      return item.name.toLowerCase().contains(lower) ||
          item.desc.toLowerCase().contains(lower);
    }).toList();

    setState(() {
      _loading = false;
      _filterIndex = 0;
      _sortIndex = 0;
    });
  }

  /// 点击下拉联想词条：填充输入并搜索
  void _onSuggestionTap(ItemsData item) {
    _controller.text = item.name;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: item.name.length),
    );
    _doSearch();
  }

  /// 在关键词结果基础上，按价格区间 + 排序过滤
  List<ItemsData> get _displayList {
    final filter = _filters[_filterIndex];
    final min = filter['min'] as double;
    final max = filter['max'] as double;

    var list = _results.where((item) {
      final price = double.tryParse(item.price) ?? 0;
      if (max == double.infinity) return price >= min;
      return price >= min && price < max;
    }).toList();

    if (_sortIndex == 1) {
      list.sort(
        (a, b) => (double.tryParse(a.price) ?? 0).compareTo(
          double.tryParse(b.price) ?? 0,
        ),
      );
    } else if (_sortIndex == 2) {
      list.sort(
        (a, b) => (double.tryParse(b.price) ?? 0).compareTo(
          double.tryParse(a.price) ?? 0,
        ),
      );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(
        title: Text('搜索'),
        centerTitle: true,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // 搜索输入栏（放在 body 中，避免 AppBar 中 TextField 导致中文 IME 失效）
        _buildSearchBar(),
        // 下拉联想框或搜索结果
        Expanded(
          child: Stack(
            children: [
              // 基础层：价格筛选 + 结果列表
              _buildResultsArea(),
              // 联想下拉框（覆盖在结果上方）
              if (_showDropdown) _buildDropdown(),
            ],
          ),
        ),
      ],
    );
  }

  /// 搜索输入栏
  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _doSearch(),
                style: TextStyle(fontSize: 14, color: _textMain),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: '搜索商品',
                  hintStyle: TextStyle(fontSize: 14, color: _textSub),
                  prefixIcon: Icon(Icons.search, color: _textSub, size: 20),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                  border: InputBorder.none,
                  suffixIcon: _controller.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _controller.clear();
                            _onChanged('');
                          },
                          child: Icon(Icons.close, color: _textSub, size: 18),
                        )
                      : null,
                ),
                onChanged: _onChanged,
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: _doSearch,
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '搜索',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 联想下拉框（最多 10 个词条）
  Widget _buildDropdown() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        elevation: 4,
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12),
          constraints: BoxConstraints(maxHeight: 350),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: _suggestions.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: Color(0xFFEEEEEE)),
            itemBuilder: (context, index) {
              final item = _suggestions[index];
              return ListTile(
                dense: true,
                leading: Icon(Icons.search, color: _textSub, size: 18),
                title: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: _textMain),
                ),
                trailing: Text(
                  '¥${item.price}',
                  style: TextStyle(fontSize: 13, color: Colors.deepOrange),
                ),
                onTap: () => _onSuggestionTap(item),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 结果区域（价格筛选 + 商品列表）
  Widget _buildResultsArea() {
    if (!_preloaded) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _primary),
            SizedBox(height: 12),
            Text(
              '正在加载商品数据...',
              style: TextStyle(color: _textSub, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _primary),
            SizedBox(height: 12),
            Text('正在搜索...', style: TextStyle(color: _textSub, fontSize: 14)),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey.shade400),
            SizedBox(height: 12),
            Text('输入关键词搜索商品', style: TextStyle(color: _textSub, fontSize: 14)),
          ],
        ),
      );
    }

    final displayList = _displayList;

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: displayList.isEmpty
              ? _buildEmpty()
              : ListView.separated(
                  padding: EdgeInsets.all(10),
                  itemCount: displayList.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _buildItem(displayList[index]),
                ),
        ),
      ],
    );
  }

  /// 价格筛选 + 排序词条
  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < _filters.length; i++)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(_filters[i]['label'] as String),
                  selected: _filterIndex == i,
                  selectedColor: _primary.withOpacity(0.15),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: _filterIndex == i ? _primary : _textSub,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: _filterIndex == i ? _primary : Colors.transparent,
                    ),
                  ),
                  onSelected: (_) => setState(() => _filterIndex = i),
                ),
              ),
            Container(
              width: 1,
              height: 20,
              margin: EdgeInsets.symmetric(horizontal: 6),
              color: Colors.black12,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text('价格升序'),
                selected: _sortIndex == 1,
                selectedColor: _primary.withOpacity(0.15),
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: _sortIndex == 1 ? _primary : _textSub,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _sortIndex == 1 ? _primary : Colors.transparent,
                  ),
                ),
                onSelected: (_) =>
                    setState(() => _sortIndex = _sortIndex == 1 ? 0 : 1),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text('价格降序'),
                selected: _sortIndex == 2,
                selectedColor: _primary.withOpacity(0.15),
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: _sortIndex == 2 ? _primary : _textSub,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _sortIndex == 2 ? _primary : Colors.transparent,
                  ),
                ),
                onSelected: (_) =>
                    setState(() => _sortIndex = _sortIndex == 2 ? 0 : 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
          SizedBox(height: 12),
          Text('未找到相关商品', style: TextStyle(color: _textSub, fontSize: 14)),
        ],
      ),
    );
  }

  /// 横向列表项：左商品图 + 右商品数据
  Widget _buildItem(ItemsData item) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/product', arguments: item),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.picture,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade100,
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: _textMain),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '¥${item.price}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (item.orderNum.isNotEmpty && item.orderNum != '0') ...[
                    SizedBox(height: 4),
                    Text(
                      '已售 ${item.orderNum}',
                      style: TextStyle(fontSize: 12, color: _textSub),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
