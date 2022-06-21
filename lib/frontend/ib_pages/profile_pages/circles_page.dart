import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_circle_card.dart';

import '../../../backend/models/ib_chat_models/ib_chat.dart';

class CirclesPage extends StatelessWidget {
  final List<IbChat> circles;

  const CirclesPage(this.circles);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Circles'),
      ),
      body: StaggeredGrid.count(
        crossAxisCount: 3,
        children: circles.map((e) => IbCircleCard(e)).toList(),
      ),
    );
  }
}
