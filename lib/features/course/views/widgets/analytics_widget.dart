import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsWidget extends StatefulWidget {
  const AnalyticsWidget({super.key});

  @override
  State createState() => _AnalyticsWidgetState();
}

class _AnalyticsWidgetState extends State<AnalyticsWidget> {
  final List<FlSpot> monthlyProgress = [
    const FlSpot(0, 65),
    const FlSpot(1, 75),
    const FlSpot(2, 82),
    const FlSpot(3, 78),
    const FlSpot(4, 85),
    const FlSpot(5, 90),
    const FlSpot(6, 93),
    const FlSpot(7, 89),
    const FlSpot(8, 92),
  ];

  final List<FlSpot> monthlyProgressWithError = [
    const FlSpot(0, 65),
    const FlSpot(1, 75),
    const FlSpot(2, 82),
    const FlSpot(3, 78),
    const FlSpot(4, 85),
    const FlSpot(5, 90),
    const FlSpot(6, 93),
    FlSpot(7, 89, yError: FlErrorRange(lowerBy: 3, upperBy: 3)),
    const FlSpot(8, 92),
  ];

  final List<String> months = [
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
  ];

  late final double avgScore = _calculateAverage();
  final double chartPadding = 12.0;

  double _calculateAverage() {
    return monthlyProgress.map((spot) => spot.y).reduce((a, b) => a + b) /
        monthlyProgress.length;
  }

  Widget _buildChartLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _buildLegendItem(
            color: Theme.of(context).colorScheme.primary,
            label: 'Monthly',
          ),
          _buildLegendItem(
            color: Colors.red.withValues(alpha: 0.8),
            label: 'Average',
            isDashed: true,
          ),
          _buildLegendItem(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            label: 'Error',
            showBox: false,
            icon: Icons.error_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool isDashed = false,
    bool showBox = true,
    IconData? icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showBox)
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
            child:
                isDashed
                    ? CustomPaint(
                      painter: DashedLinePainter(color: Colors.white),
                    )
                    : null,
          )
        else if (icon != null)
          Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        padding: EdgeInsets.all(chartPadding),
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: surfaceColor.withValues(alpha: 0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: monthlyProgressWithError,
                isCurved: true,
                curveSmoothness: 0.25,
                gradient: LinearGradient(
                  colors: [primaryColor.withValues(alpha: 0.7), primaryColor],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                barWidth: 3.0,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter:
                      (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 3.5,
                        color: primaryColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.3),
                      primaryColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                errorIndicatorData: FlErrorIndicatorData(show: true),
              ),
            ],
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: avgScore,
                  color: Colors.red.withValues(alpha: 0.8),
                  strokeWidth: 1.5,
                  dashArray: [4, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: 10,
              verticalInterval: 1,
              getDrawingHorizontalLine:
                  (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.15),
                    strokeWidth: 0.8,
                  ),
              getDrawingVerticalLine:
                  (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.1),
                    strokeWidth: 0.8,
                    dashArray: [4, 4],
                  ),
              checkToShowHorizontalLine: (value) => value % 10 == 0,
            ),
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                axisNameWidget: Container(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: const Text(
                    'Progress (%)',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                axisNameSize: 20,
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 10,
                  reservedSize: 25,
                  getTitlesWidget:
                      (value, meta) => Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Text(
                          '${value.toInt()}',
                          style: TextStyle(
                            fontSize: 9,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight:
                                value % 20 == 0
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                ),
              ),
              bottomTitles: AxisTitles(
                axisNameWidget: Container(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: const Text(
                    'Month (2024-2025)',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                axisNameSize: 20,
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 20,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    return index >= 0 && index < months.length
                        ? Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            months[index],
                            style: TextStyle(
                              fontSize: 9,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        : const SizedBox.shrink();
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                  width: 1,
                ),
                left: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipRoundedRadius: 8,
                tooltipPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                tooltipMargin: 8,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final month = months[spot.x.toInt()];
                    final progress = spot.y.toStringAsFixed(1);
                    final difference = (spot.y - avgScore)
                        .abs()
                        .toStringAsFixed(1);
                    final isAboveAverage = spot.y > avgScore;

                    return LineTooltipItem(
                      '$month: $progress%\n',
                      TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text:
                              isAboveAverage
                                  ? '↑ $difference% above avg'
                                  : '↓ $difference% below avg',
                          style: TextStyle(
                            color: isAboveAverage ? Colors.green : Colors.red,
                            fontWeight: FontWeight.normal,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
              getTouchedSpotIndicator: (barData, spotIndexes) {
                return spotIndexes.map((index) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: primaryColor,
                      strokeWidth: 1.5,
                      dashArray: [3, 3],
                    ),
                    FlDotData(
                      getDotPainter:
                          (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: 5,
                            color: Colors.white,
                            strokeWidth: 2.5,
                            strokeColor: primaryColor,
                          ),
                    ),
                  );
                }).toList();
              },
            ),
            minX: 0,
            maxX: 8,
            minY: 50,
            maxY: 100,
            clipData: FlClipData.all(),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final previousProgress = monthlyProgress[monthlyProgress.length - 2].y;
    final changePercentage = ((monthlyProgress.last.y - previousProgress) /
            previousProgress *
            100)
        .toStringAsFixed(1);
    final isPositiveChange = monthlyProgress.last.y >= previousProgress;
    final currentProgress = monthlyProgress.last.y;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.insights,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 16),
                ),
                Text(
                  'Current: ${currentProgress.toStringAsFixed(1)}% | '
                  'Avg: ${avgScore.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isPositiveChange
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isPositiveChange ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPositiveChange ? Colors.green : Colors.red,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '$changePercentage%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isPositiveChange ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          _buildLineChart(),
          _buildChartLegend(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    const dashWidth = 2;
    const dashSpace = 2;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
