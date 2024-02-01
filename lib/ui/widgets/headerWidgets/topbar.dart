import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_praktikum/core/services/weather_service.dart';
import 'package:internet_praktikum/ui/views/weather/weather.dart';
import 'package:internet_praktikum/ui/widgets/bottom_sheet.dart';
import 'package:internet_praktikum/ui/widgets/errorSnackbar.dart';
import 'package:internet_praktikum/ui/widgets/headerWidgets/header_button.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final bool? isDash;
  final bool? isFinanz;
  final IconData? icon;
  final String? title;
  final Function()? onTapForIconWidget;
  final PopupMenuButton? popupButton;

  const TopBar({
    super.key,
    this.isDash,
    this.icon,
    this.title,
    this.onTapForIconWidget,
    this.popupButton,
    this.isFinanz,
  });

  @override
  State<TopBar> createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(
      56); // hier kann man die Size der AppBar beeinflussen
}

class _TopBarState extends State<TopBar> {
  final WeatherService _weatherHandler =
      WeatherService("5a9d3eda46bcddc1662d351abc13c798");
  Weather? actualWeather;

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    // is not the same as in weather_info.dart
    final weather = await _weatherHandler.fetchWeather();
    if (mounted) {
      setState(() {
        actualWeather = weather;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: widget.isDash != null
            ? Text(
                actualWeather?.cityName ?? "Loading...",
                style: const TextStyle(fontSize: 20),
              )
            : Text(
                widget.title!,
                style: const TextStyle(fontSize: 20),
              ),
        leadingWidth: (widget.isDash != null || widget.isFinanz != null)
            ? 66
            : 0, // defaul 56 + 10
        leading: widget.isDash != null
            ? HeaderButton(
                onTap: () {
                  if (actualWeather != null) {
                    context.go('/weatherpage', extra: actualWeather);
                  } else {
                    ErrorSnackbar.showErrorSnackbar(
                        context, "Please wait until the weather is loaded.");
                  }
                },
                temperature: '${actualWeather?.temperature.round()}°C',
                weatherImage:
                    WeatherService.getWeatherIcon(actualWeather?.mainCondition),
              )
            : widget.isFinanz != null
                ? HeaderButton(
                    icon: Icons.payment,
                    onTap: () {
                      CustomBottomSheet.show(context,
                          title: "Change your Payment Method",
                          content: [
                            Builder(
                              builder: (context) {
                                return Center(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 16),
                                      const Text(
                                          "Currently you can only Recharge \nto your Account with Credit Card."),
                                      const SizedBox(height: 12),
                                      const Text(
                                          "And you can only Refund to your Bank Account."),
                                      const SizedBox(height: 12),
                                      const Text(
                                          "We are working on adding more payment methods."),
                                      const SizedBox(height: 32),
                                      Image.asset("assets/coding.png",
                                          height: 150),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ]);
                    },
                  )
                : null,
        actions: widget.popupButton != null
            ? [widget.popupButton as Widget, const SizedBox(width: 10)]
            : widget.icon != null
                ? [
                    HeaderButton(
                        onTap: widget.onTapForIconWidget, icon: widget.icon),
                    const SizedBox(width: 10)
                  ]
                : null);
  }
}
