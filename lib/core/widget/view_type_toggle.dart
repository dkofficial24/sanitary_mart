import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanitary_mart/core/constant/app_const.dart';
import 'package:sanitary_mart/util/storage_helper.dart';

class ViewTypeToggle extends StatefulWidget {
  const ViewTypeToggle({
    required this.onToggle,
    Key? key}) : super(key: key);
  final Function(bool _isGridView) onToggle ;

  @override
  _ViewTypeToggleState createState() => _ViewTypeToggleState();
}

class _ViewTypeToggleState extends State<ViewTypeToggle> {
   late bool _isGridView;

  @override
  void initState() {
    //_isGridView = AppConst.isGridDefaultView;
    super.initState();
   // _loadViewType();
  }

  Future<void> _loadViewType() async {
    StorageHelper storageHelper = Get.find();
    final isGrid = await storageHelper.isGridViewType();
    setState(() {
      _isGridView = isGrid;
      _toggleViewType(_isGridView);
    });
  }

  Future<void> _toggleViewType(bool isGrid) async {
    StorageHelper storageHelper = Get.find();
    await storageHelper.saveViewType(isGrid);
    setState(() {
      _isGridView = isGrid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox();
    return IconButton(
      icon: Icon(_isGridView ? Icons.list : Icons.grid_view,size: 24,),
      onPressed: () {
        _toggleViewType(!_isGridView);
        widget.onToggle(!_isGridView);
      },
    );
  }
}
