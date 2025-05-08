import 'dart:async';  // For Timer
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:weatherapp/utils/appErrorScreen.dart';
import 'package:weatherapp/utils/friendlyError.dart';
import 'package:weatherapp/utils/weather_icons.dart';
import 'package:weatherapp/utils/weather_providers.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:weather_icons/weather_icons.dart';

final isCelsiusProvider = StateProvider<bool>((ref) => true);
final selectedDayProvider = StateProvider<int>((ref) => 0);


class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get maxExtent => 100.0; // Height when fully expanded
  @override
  double get minExtent => 100.0; // Height when collapsed (stays the same in this case)

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  final ScrollController _dailyScrollController = ScrollController();

  Future<void> _refresh() async {
    ref.invalidate(weatherReportProvider);
    await ref.read(weatherReportProvider.future);
  }

  @override
  void initState() {
    super.initState();
    // Auto scroll to the initially selected day
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDay(ref.read(selectedDayProvider));
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherReportProvider);
    final isCelsius = ref.watch(isCelsiusProvider);

    return weatherAsync.when(
      data: (weatherReport) {
        final selectedIndex = ref.watch(selectedDayProvider).clamp(0, weatherReport.forecast.length - 1);
        print(weatherReport.forecast);
        final selectedDay = weatherReport.forecast[selectedIndex];
        final currentTime = DateTime.now();
        final isDayTime = currentTime.isAfter(weatherReport.currentWeather.sunrise) && currentTime.isBefore(weatherReport.currentWeather.sunset);


        final filteredHourly = weatherReport.hourly
            .where((hour) => hour.dateTime.day == selectedDay.dateTime.day)
            .toList();

        return Scaffold(
          backgroundColor: Colors.transparent, // Blue background color for the entire app
          resizeToAvoidBottomInset: true,
          body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDayTime
            ? [const Color(0xFF0C1D4D), Color(0xFF1C2B65)] // 🌤️ Day Gradient
            : [const Color(0xFF000428), const Color(0xFF004e92)], // 🌙 Night Gradient
            ),
          ), 
          child:
          
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: [
                  // Sticky header for Location and Weather Animation
                  SliverPersistentHeader(
                    delegate: _StickyHeaderDelegate(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Location and Date
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  weatherReport.currentWeather.name,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                                ),
                                Text(
                                  DateFormat.yMMMMEEEEd().format(weatherReport.currentWeather.dateTime),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
                                ),
                              ],
                            ),
                            // Weather Animation
                            SizedBox(
                              height: 80,
                              width: 80,
                              child: Lottie.asset(
                                'assets/animations/${getLottieFile(weatherReport.currentWeather.currently)}.json',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    pinned: true, // This makes the header sticky
                  ),

                  // 🌡️ Temperature + Toggle
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              formatTemp(weatherReport.currentWeather.temp,isCelsius),
                              style: TextStyle(color: Colors.white, fontSize: 36),
                            ),
                            const SizedBox(width: 8),
                            Transform.scale(
                              scale: 0.6,
                              child: Switch(
                                value: isCelsius,
                                onChanged: (value) {
                                  ref.read(isCelsiusProvider.notifier).state = value;
                                },
                                activeColor: Colors.white,
                                inactiveThumbColor: Colors.blue[200],
                                inactiveTrackColor: Colors.blue[600],
                              ),
                            ),
                            Text("°F", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          toSentenceCase(weatherReport.currentWeather.description),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 📅 Daily Forecast Horizontal Scroll
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ClipRect( // <-- Fix overflow
                        child: SizedBox(
                          height: 120,
                          child: ListView.builder(
                            controller: _dailyScrollController,
                            scrollDirection: Axis.horizontal,
                            itemCount: weatherReport.forecast.length,
                            itemBuilder: (context, index) {
                              final day = weatherReport.forecast[index];
                              final isSelected = index == selectedIndex;

                              return GestureDetector(
                                onTap: () {
                                  ref.read(selectedDayProvider.notifier).state = index;
                                  _scrollToSelectedDay(index);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // reduced vertical margin
                                  padding: const EdgeInsets.all(10), // slightly smaller padding
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: isDayTime ? Color(0xFF1C2B65) : Color(0xFF004e92),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? Colors.white : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        getWeatherIcon(day.currently),
                                        color: isSelected ? Colors.white : Colors.white70,
                                        size: 28,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat.MMMd().format(day.dateTime),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        formatTemp(day.temp, isCelsius),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 📈 Hourly Chart
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                        height: 240,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 3,
                                  getTitlesWidget: (value, meta) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text("${value.toInt()}h", style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: filteredHourly.map((h) {
                                  final temp = isCelsius ? h.temp : (h.temp * 9 / 5 + 32);
                                  return FlSpot(h.dateTime.hour.toDouble(), temp);
                                }).toList(),
                                isCurved: true,
                                color: Colors.white,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.white,
                                    strokeWidth: 1,
                                    strokeColor: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                                tooltipMargin: 4,
                                tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                tooltipRoundedRadius: 10,
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    return LineTooltipItem(
                                      formatTemp(spot.y,isCelsius),
                                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // 📋 Weather Details Panel
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDayTime ? Color(0xFF1C2B65) : Color(0xFF004e92),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _buildTile(FontAwesomeIcons.thermometerHalf, "Temperature",formatTemp(weatherReport.currentWeather.temp,isCelsius)),
                          _buildTile(FontAwesomeIcons.mapPin, "City", weatherReport.currentWeather.name),
                          _buildTile(WeatherIcons.cloud, "Condition", weatherReport.currentWeather.description),
                          _buildTile(WeatherIcons.humidity, "Humidity", "${weatherReport.currentWeather.humidity}%"),
                          _buildTile(FontAwesomeIcons.wind, "Wind", "${weatherReport.currentWeather.windSpeed} m/s"),
                          _buildTile(WeatherIcons.barometer, "Pressure", "${weatherReport.currentWeather.pressure} hPa"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => AppErrorScreen(
      error: FriendlyError.from(err),
      onRetry: () => ref.refresh(weatherReportProvider.future),
  ),
    );
  }

  Widget _buildTile(IconData icon, String title, String trailing) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 3),
      dense: true,
      leading: FaIcon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(fontSize:12, fontWeight:FontWeight.bold, color: Colors.white)),
      trailing: Text(trailing, style: const TextStyle(fontSize:12, fontWeight:FontWeight.bold, color: Colors.white)),
    );
  }

  String getLottieFile(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'clear-day';
      case 'clouds':
        return 'cloudy-day';
      case 'rain':
        return 'rainy-day';
      case 'snow':
        return 'snow';
      case 'haze':
        return 'fog';
      case 'mist':
        return 'fog';
      case 'thunderstorm':
        return 'thunder';
      default:
        return 'weather-default';
    }
  }

  // Function to auto-scroll to the selected day
void _scrollToSelectedDay(int selectedIndex) {
  const tileWidth = 116.0; // Approximate width + margin of each item
  final screenWidth = MediaQuery.of(context).size.width;

  final targetOffset = (selectedIndex * tileWidth) - (screenWidth / 2) + (tileWidth / 2);

  final clampedOffset = targetOffset.clamp(
    _dailyScrollController.position.minScrollExtent,
    _dailyScrollController.position.maxScrollExtent,
  );

  _dailyScrollController.animateTo(
    clampedOffset,
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
  );
}
String formatTemp(double temp, bool isCelsius) {
  return "${isCelsius ? temp.toStringAsFixed(1) : (temp * 9 / 5 + 32).toStringAsFixed(1)}°${isCelsius ? 'C' : 'F'}";
}

}

String toSentenceCase(String input) {
  if (input.trim().isEmpty) return '';

  final sentenceEndings = RegExp(r'([.!?])');
  final sentences = input.split(sentenceEndings);

  final buffer = StringBuffer();

  for (var i = 0; i < sentences.length; i++) {
    final part = sentences[i].trim();
    if (part.isEmpty) continue;

    if (sentenceEndings.hasMatch(part)) {
      // Append punctuation directly
      buffer.write('$part ');
    } else {
      // Capitalize first letter of each sentence part
      final sentence = part[0].toUpperCase() + part.substring(1).toLowerCase();
      buffer.write(sentence);
    }
  }

  return buffer.toString().trim();
}


