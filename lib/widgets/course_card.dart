import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';

class CourseCard extends StatefulWidget {
  final List<String> images;
  final bool enableInfiniteScroll;
  final bool enlargeCenterPage;

  const CourseCard({
    super.key,
    required this.images,
    this.enableInfiniteScroll = true,
    this.enlargeCenterPage = true,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carousel Slider
        CarouselSlider(
          controller: _controller,
          options: CarouselOptions(
            enableInfiniteScroll: widget.enableInfiniteScroll,
            enlargeCenterPage: widget.enlargeCenterPage,
            onPageChanged: (index, reason) {
              setState(() {
                _currentPage = index;
              });
            },
          ),
          items: widget.images.map((item) {
            return ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(16.0)),
              child: Image.network(
                item,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),

        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.images.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _currentPage == entry.key ? 16.0 : 12.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 4.0,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == entry.key
                      ? Colors.blueAccent
                      : Colors.grey.shade700,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
