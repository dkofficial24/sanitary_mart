import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/category/provider/category_provider.dart';
import 'package:sanitary_mart/product/provider/product_provider.dart';
import 'package:sanitary_mart/product/ui/widget/category_tab_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CategoryProvider>(context, listen: false);
      provider.fetchCategories();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Consumer<ProductProvider>(
            builder: (context, productProvider, _) {
              if (_tabController==null || productProvider.categories.isEmpty) {
                return SizedBox();
              }
              return TabBar(
                controller: _tabController,
                tabs: productProvider.categories.map((category) {
                  return Tab(
                    text: category,
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, _) {
          if (_tabController == null) {
            return Center(
              child:
                  CircularProgressIndicator(), // Show a loading indicator if _tabController is null
            );
          }
          return DefaultTabController(
            length: categoryProvider.categoryList.length,
            child: TabBarView(
              controller: _tabController,
              children: categoryProvider.categoryList.map((category) {
                return ProductCategoryTab(category: category);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
