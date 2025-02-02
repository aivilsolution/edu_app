import 'package:flutter/material.dart';

class CarouselWidget extends StatefulWidget {
  final List<Widget> items;
  final double height;
  final double dotSize;
  final Color activeDotColor;
  final Color inactiveDotColor;
  final ValueChanged? onTap;

  const CarouselWidget({
    super.key,
    required this.items,
    this.height = 180,
    this.dotSize = 6.0,
    this.activeDotColor = Colors.white,
    this.inactiveDotColor = Colors.grey,
    this.onTap,
  });

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  late final CarouselController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = CarouselController();
    _controller.addListener(_handlePageChange);
  }

  void _handlePageChange() {
    if (!_controller.hasClients) return;

    final position = _controller.position.pixels;
    final itemWidth = MediaQuery.of(context).size.width * 0.8;
    final newIndex = (position / itemWidth).round();

    if (newIndex != _currentIndex) {
      setState(() => _currentIndex = newIndex);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handlePageChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemWidth = MediaQuery.of(context).size.width * 0.75;

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: CarouselView(
            controller: _controller,
            itemExtent: itemWidth,
            shrinkExtent: itemWidth,
            itemSnapping: true,
            padding: EdgeInsets.symmetric(horizontal: 10),
            shape: Border.all(style: BorderStyle.none),
            onTap: widget.onTap,
            children: widget.items,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (index) => Container(
              width: _currentIndex == index
                  ? widget.dotSize * 1.4
                  : widget.dotSize * 1.2,
              height: widget.dotSize,
              margin: EdgeInsets.symmetric(horizontal: widget.dotSize / 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.dotSize / 2),
                color: _currentIndex == index
                    ? widget.activeDotColor
                    : widget.inactiveDotColor,
              ),
            ),
          ),
        )
      ],
    );
  }
}
