import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sanitary_mart/cart/provider/cart_provider.dart';
import 'package:sanitary_mart/core/debouncer.dart';
import 'package:sanitary_mart/core/widget/widget.dart';

class ListItemWidget extends StatefulWidget {
  final String? id;
  final String name;
  final String image;
  final String? price;
  final bool cartTextEditDisable;
  final VoidCallback onItemTap;
  final Function(int quantity)? onRemove;
  final Function(int quantity)? onAdd;

  const ListItemWidget({
    super.key,
    required this.name,
    required this.image,
    required this.onItemTap,
    this.id,
    this.price,
    this.cartTextEditDisable = false,
    this.onRemove,
    this.onAdd,
  });

  @override
  ListItemWidgetState createState() => ListItemWidgetState();
}

class ListItemWidgetState extends State<ListItemWidget> {
  int _quantity = 0;
  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantityController.text = _quantity.toString();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _updateQuantity(int newQuantity) {
    setState(() {
      _quantity = newQuantity;
      _quantityController.text = newQuantity.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    return GestureDetector(
      onTap: widget.onItemTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: NetworkImageWidget(
                  widget.image,
                  imgHeight: 80,
                  imgWidth: 80,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.price != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${widget.price}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          widget.id == null
                              ? const SizedBox()
                              : _quantity == 0
                                  ? TextButton(
                                      onPressed: () {
                                        if (!cartProvider.isLoading) {
                                          _updateQuantity(_quantity + 1);
                                          widget.onAdd!(_quantity);
                                        }
                                      },
                                      child: const Text('Add to Cart'))
                                  : Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          onPressed: () {
                                            DeBouncer.run(() {
                                              if (!cartProvider.isLoading) {
                                                if (_quantity > 0) {
                                                  _updateQuantity(
                                                      _quantity - 1);
                                                  widget.onRemove!(_quantity);
                                                }
                                              }
                                            }, milliseconds: 300);
                                          },
                                        ),
                                        const SizedBox(width: 8.0),
                                        SizedBox(
                                          width: 40.0,
                                          child: TextField(
                                            controller: _quantityController,
                                            readOnly: widget.cartTextEditDisable,
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            onChanged: (value) {
                                              int newValue =
                                                  int.tryParse(value) ?? 1;
                                              _updateQuantity(newValue);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          onPressed: () {
                                            DeBouncer.run(() {
                                              if (!cartProvider.isLoading) {
                                                _updateQuantity(_quantity + 1);
                                                widget.onAdd!(_quantity);
                                              }
                                            }, milliseconds: 300);
                                          },
                                        ),
                                      ],
                                    ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
