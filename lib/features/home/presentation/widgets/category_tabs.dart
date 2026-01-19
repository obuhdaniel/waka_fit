import 'package:flutter/material.dart';
import 'package:waka_fit/core/theme/app_colors.dart';

class CategoryTabs extends StatefulWidget {
  final List<String> categories;
  final ValueChanged<int> onCategoryChanged;
  final int initialIndex;

  const CategoryTabs({
    Key? key,
    this.categories = const ['For You', 'Coaches', 'Gyms', 'Restaurants'],
    required this.onCategoryChanged,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: widget.categories.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        widget.onCategoryChanged(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      
      decoration: BoxDecoration(
        color: AppColors.wakaSurface,
        border: Border(
          top: BorderSide(
            color: AppColors.wakaStroke,
            width: 2
          ),
          bottom: BorderSide(
            color: AppColors.wakaStroke,
            width: 2
          ),
        )
      ), // optional: match screenshot background
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelPadding: const EdgeInsets.symmetric(horizontal: 20),
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.wakaBlue,     // glowing blue line
        indicatorWeight: 3,  
        indicatorSize: TabBarIndicatorSize.tab,                  // thickness of the line
        tabs: widget.categories
            .map((c) => Tab(text: c))
            .toList(),
      ),
    );
  }
}
