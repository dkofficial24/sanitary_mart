import 'package:flutter/material.dart';
import 'package:sanitary_mart/core/widget/app_image_network_widget.dart';

class GridItemWidget extends StatelessWidget {
  const GridItemWidget({
    required this.name,
    required this.onItemTap,
    this.image = '',
    Key? key,
  }) : super(key: key);

  final String name;
  final String image;
  final Function onItemTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onItemTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: NetworkImageWidget(
                    image,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
