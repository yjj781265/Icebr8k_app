import 'package:flutter/material.dart';
import 'package:icebr8k/frontend/ib_colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: IbColors.lightBlue,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
