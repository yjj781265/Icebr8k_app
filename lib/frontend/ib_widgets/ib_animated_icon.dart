import 'package:flutter/material.dart';

class IbAnimatedIcon extends StatefulWidget {
  const IbAnimatedIcon({required Key? key, required this.icon})
      : super(key: key);
  final AnimatedIconData icon;

  @override
  IbAnimatedIconState createState() => IbAnimatedIconState();
}

class IbAnimatedIconState extends State<IbAnimatedIcon>
    with TickerProviderStateMixin {
  final Curve _curve = Curves.linear;
  late Animation<double> _myAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _myAnimation = CurvedAnimation(parent: _animationController, curve: _curve);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedIcon(
        icon: widget.icon,
        progress: _myAnimation,
      ),
    );
  }

  void forward() {
    _animationController.forward();
  }

  void reverse() {
    _animationController.reverse();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }
}
