import 'package:flutter/material.dart';

class CarouselWidget extends StatefulWidget {
  final List<Widget> items;
  final double height;
  final ValueChanged? onTap;
  final double? itemWidth;

  const CarouselWidget({
    this.onTap,
    this.height = 180,
    this.itemWidth,
    super.key,
    required this.items,
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
    final itemWidth =
        widget.itemWidth ?? MediaQuery.of(context).size.width * 0.75;
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
    final itemWidth =
        widget.itemWidth ?? MediaQuery.of(context).size.width * 0.75;
    const double dotSize = 6.0;

    return Column(
      mainAxisSize:
          MainAxisSize.min, 
      children: [
        Expanded(
          
          child: CarouselView(
            controller: _controller,
            itemExtent: itemWidth,
            shrinkExtent: itemWidth,
            itemSnapping: true,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            shape: Border.all(style: BorderStyle.none),
            onTap: widget.onTap,
            children: widget.items,
          ),
        ),
        const SizedBox(height: 10), 
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (index) => Container(
              width: _currentIndex == index ? dotSize * 1.4 : dotSize * 1.2,
              height: dotSize,
              margin: const EdgeInsets.symmetric(horizontal: dotSize / 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(dotSize / 2),
                color:
                    _currentIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
