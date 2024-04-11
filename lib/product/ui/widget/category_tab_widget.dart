import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/category/model/category_model.dart';
import 'package:sanitary_mart/product/model/product_model.dart';
import 'package:sanitary_mart/product/provider/product_provider.dart';

class ProductCategoryTab extends StatelessWidget {
  final Category category;

  const ProductCategoryTab({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox();
    // return Consumer<ProductProvider>(
    //   builder: (context, productProvider, _) {
    //     List<Product> productsInCategory = productProvider.products
    //         .where((product) => product.category == category)
    //         .toList();
    //     return GridView.builder(
    //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //         crossAxisCount: 2,
    //         crossAxisSpacing: 8.0,
    //         mainAxisSpacing: 8.0,
    //       ),
    //       itemCount: productsInCategory.length,
    //       itemBuilder: (context, index) {
    //         return ProductItemWidget(product: productsInCategory[index]);
    //       },
    //     );
    //   },
    // );
  }
}