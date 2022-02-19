import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/places_nearby_controller.dart';

import '../ib_colors.dart';
import '../ib_config.dart';

///TODO Beta 3.0
class PlacesNearbyPage extends StatelessWidget {
  final PlacesNearbyController _controller = Get.put(PlacesNearbyController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 8,
              child: Container(
                alignment: Alignment.center,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: TextField(
                  onSubmitted: (value) async {},
                  textInputAction: TextInputAction.search,
                  controller: _controller.editingController,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                        onPressed: () {
                          _controller.editingController.clear();
                        },
                        icon: const Icon(
                          Icons.cancel,
                          color: IbColors.lightGrey,
                        )),
                    hintText: '🔍 Search Places',
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {},
              child: const Text(
                'Search',
                style: TextStyle(fontSize: IbConfig.kNormalTextSize),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
