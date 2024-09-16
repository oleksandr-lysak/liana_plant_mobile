import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:liana_plant/services/language_service.dart';
import 'package:liana_plant/services/log_service.dart';
import 'package:liana_plant/widgets/animated_text_field.dart';
import 'package:liana_plant/widgets/loading.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../../services/api_services/slot_service.dart';
import '../../services/fcm_service.dart';
import '../../services/token_service.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  BookingPageState createState() => BookingPageState();
}

class BookingPageState extends State<BookingPage> {
  DateTime selectedDate = DateTime.now();
  String locale = 'en';
  int selectedDayIndex = 0;
  DateTime? selectedTimeSlot;
  late ScrollController _scrollController;
  bool isLoading = false;
  String currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());
  bool isTokenPresent = false;

  // Список зайнятих слотів для прикладу (з датою і часом)
  List<Map<String, dynamic>> bookedSlots = [];
  // List<Map<String, dynamic>> bookedSlots = [
  //   {'date': DateTime.now(), 'client': 'John Doe', 'service': 'Haircut'},
  //   {
  //     'date': DateTime.now().add(const Duration(hours: -10)),
  //     'client': 'Jane Smith',
  //     'service': 'Manicure'
  //   },
  // ];

  List<Map<String, dynamic>> slots = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      int pageIndex = (_scrollController.offset / 70)
          .round(); // 70 - висота контейнера + відступи
      DateTime dateAtIndex = DateTime.now().add(Duration(days: pageIndex));
      String newMonth = DateFormat('MMM yyyy', locale).format(dateAtIndex);

      if (newMonth != currentMonth) {
        setState(() {
          currentMonth = newMonth;
        });
      }
    });
    FCMService.initializeFCM(onMessage: handleFCMMessage);
    initData();
  }

  Future<void> handleFCMMessage(Map<String, dynamic> message) async {
    // Обробка сповіщень та оновлення тайм слотів
    setState(() {
      fetchTimeSlots(); // Перезавантаження тайм слотів при отриманні сповіщення
    });
  }

  Future<void> fetchTimeSlots() async {
    try {
      final slotService = SlotService();
      final fetchedSlots = await slotService.getSlots(selectedDate);
      setState(() {
        slots = fetchedSlots
            .map((slot) => {
                  'date': DateTime.parse(slot['date']),
                  'time': slot['time'],
                  'datetime': DateTime.parse(slot['datetime']),
                  'isBooked': slot['isBooked'],
                  'client': slot['client'],
                  'service': slot['service'],
                  'source': slot['source'],
                })
            .toList();
      });
    } catch (e) {
      LogService.log('Error fetching time slots: $e');
    }
  }

  initData() async {
    final tokenService = TokenService();
    await fetchTimeSlots();
    final token = await tokenService.getToken();

    locale = await LanguageService.getLanguage() ?? 'en';
    DateTime selDate = DateTime.now().add(const Duration(days: 5));
    String newMonth = DateFormat('MMM yyyy', locale).format(selDate);

    if (currentMonth != newMonth) {
      setState(() {
        currentMonth = newMonth;
        isTokenPresent = token != null && token.isNotEmpty;
      });
    }
    _initializeTimeSlots();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeTimeSlots() {
    DateTime startTime =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 7, 0);
    DateTime endTime = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 20, 0);

    List<Map<String, dynamic>> newSlots = [];
    while (startTime.isBefore(endTime)) {
      String formattedTime = DateFormat.jm(locale).format(startTime);

      newSlots.add({
        'date': startTime,
        'time': formattedTime,
        'datetime': startTime,
        'isBooked':
            bookedSlots.any((slot) => _isSameSlot(slot['date'], startTime)),
        'client': bookedSlots.firstWhere(
          (slot) => _isSameSlot(slot['date'], startTime),
          orElse: () => {'client': '', 'service': ''},
        )['client'],
        'service': bookedSlots.firstWhere(
          (slot) => _isSameSlot(slot['date'], startTime),
          orElse: () => {'client': '', 'service': ''},
        )['service'],
      });
      startTime = startTime.add(const Duration(hours: 1));
    }

    setState(() {
      slots = newSlots;
    });
  }

  bool _isSameSlot(DateTime bookedDate, DateTime slotDate) {
    return bookedDate.year == slotDate.year &&
        bookedDate.month == slotDate.month &&
        bookedDate.day == slotDate.day &&
        bookedDate.hour == slotDate.hour;
  }

  Future<void> _showDurationDialog(int index) async {
    Duration? duration = await showDialog(
      context: context,
      builder: (BuildContext context) {
        Duration? initialDuration = slots[index]['duration'];
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(FlutterI18n.translate(context, 'input_details')),
          content: Column(
            children: [
              AnimatedTextField(
                  controller: TextEditingController(),
                  labelText: FlutterI18n.translate(context, 'client_name')),
              const SizedBox(
                height: 20,
              ),
              AnimatedTextField(
                controller: TextEditingController(),
                labelText: FlutterI18n.translate(context, 'duration'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(initialDuration);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (duration != null) {
      setState(() {
        _updateSlotDuration(index, duration);
      });
    }
  }

  void _updateSlotDuration(int index, Duration newDuration) {
    DateTime startTime = slots[index]['datetime'];
    DateTime endTime = startTime.add(newDuration);
    DateTime nextSlotTime = endTime;

    slots[index]['duration'] = newDuration;

    for (int i = index + 1; i < slots.length; i++) {
      slots[i]['datetime'] = nextSlotTime;
      nextSlotTime =
          nextSlotTime.add(slots[i]['duration'] ?? const Duration(hours: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Loading(),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, 'booking_panel')),
          actions: [
            IconButton(
              icon: const Icon(Icons.brightness_6),
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme();
              },
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                currentMonth,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  itemCount: 90,
                  itemBuilder: (context, index) {
                    DateTime date = DateTime.now().add(Duration(days: index));
                    bool isSelected = selectedDayIndex == index;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDayIndex = index;
                            selectedDate = date;
                            _initializeTimeSlots();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).hoverColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).hoverColor,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('EEE', locale).format(date),
                                style: isSelected
                                    ? Theme.of(context).textTheme.labelLarge
                                    : Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                DateFormat('d').format(date),
                                style: isSelected
                                    ? Theme.of(context).textTheme.labelLarge
                                    : Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${FlutterI18n.translate(context, 'selected_date')}: ${DateFormat.yMMMd(locale).format(selectedDate)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: ListView.builder(
                    key: ValueKey(selectedDate),
                    itemCount: slots.length,
                    itemBuilder: (context, index) {
                      DateTime startTime = slots[index]['datetime'];
                      Duration duration =
                          slots[index]['duration'] ?? const Duration(hours: 1);

                      return GestureDetector(
                        onTap: slots[index]['isBooked']
                            ? null
                            : () {
                                _showDurationDialog(index);
                              },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: slots[index]['isBooked']
                                ? // Стиль для заброньованого слоту
                                Theme.of(context).primaryColor.withOpacity(0.1)
                                : Theme.of(context)
                                    .hoverColor, // Стиль для доступного слоту
                            borderRadius:
                                BorderRadius.circular(12), // Закруглення кутів
                            border: Border.all(
                              color: slots[index]['isBooked']
                                  ? Theme.of(context)
                                      .primaryColor // Колір рамки для заброньованого слоту
                                  : Theme.of(context)
                                      .hoverColor, // Колір рамки для доступного слоту
                              width: 2.0,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${DateFormat.jm(locale).format(startTime)} - ${DateFormat.jm(locale).format(startTime.add(duration))}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    slots[index]['isBooked']
                                        ? '${FlutterI18n.translate(context, 'booked_by')}: ${slots[index]['client']}, ${slots[index]['service']}'
                                        : FlutterI18n.translate(
                                            context, 'available'),
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                ],
                              ),
                              Icon(
                                slots[index]['isBooked']
                                    ? Icons.lock
                                    : Icons.event_available,
                                color: slots[index]['isBooked']
                                    ? Colors.grey
                                    : Theme.of(context)
                                        .focusColor, // Іконка залежно від стану слоту
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
