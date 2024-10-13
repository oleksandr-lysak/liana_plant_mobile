import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';
import 'package:liana_plant/constants/app_constants.dart';
import 'package:liana_plant/models/service.dart';
import 'package:liana_plant/models/user.dart';
import 'package:liana_plant/services/api_services/auth_service.dart';
import 'package:liana_plant/services/api_services/service_service.dart';
import 'package:liana_plant/services/language_service.dart';
import 'package:liana_plant/services/log_service.dart';
import 'package:liana_plant/widgets/animated_text_field.dart';
import 'package:liana_plant/widgets/loading.dart';
import 'package:provider/provider.dart';

import '../../models/slot.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_services/slot_service.dart';
import '../../services/fcm_service.dart';
import '../../services/token_service.dart';

class BookingPage extends StatefulWidget {
  final int masterId;
  final String masterName;

  const BookingPage(
      {super.key, required this.masterId, required this.masterName});

  @override
  BookingPageState createState() => BookingPageState();
}

class BookingPageState extends State<BookingPage> {
  DateTime selectedDate = DateTime.now();
  List<Service> specialtyList = [];
  String locale = 'en';
  int selectedDayIndex = 0;
  DateTime? selectedTimeSlot;
  late ScrollController _scrollController;
  bool isLoading = false;
  String currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());
  bool isTokenPresent = false;

  List<Slot> bookedSlots = [];

  List<Slot> slots = [];

  @override
  void initState() {
    super.initState();

    setState(() {
      isLoading = true;
    });
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      int pageIndex = (_scrollController.offset / 70).round();
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
      final fetchedSlots =
          await slotService.getSlots(selectedDate, masterId: widget.masterId);
      setState(() {
        bookedSlots = fetchedSlots;
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
    ServiceService specialtyService = ServiceService();
    List<Service> specialtyListFromServer =
        await specialtyService.getServiceForMaster(widget.masterId);
    setState(() {
      specialtyList = specialtyListFromServer;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeTimeSlots() {
    DateTime currentDateTime = DateTime.now();
    int startHour = 7;
    if (currentDateTime.hour > startHour &&
        selectedDate.day == currentDateTime.day &&
        selectedDate.month == currentDateTime.month &&
        selectedDate.year == currentDateTime.year) {
      startHour = currentDateTime.hour;
    }
    DateTime startTime = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, startHour, 0);
    DateTime endTime = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 20, 0);

    List<Slot> newSlots = [];

    while (startTime.isBefore(endTime)) {
      var bookedSlot = bookedSlots.firstWhere(
        (slot) => _isSameSlot(slot.date, startTime),
        orElse: () => Slot(
          id: 0,
          date: startTime,
          isBooked: false,
          duration: const Duration(minutes: 30), // Тривалість 30 хв
        ),
      );

      if (bookedSlot.id != 0) {
        // Додаємо слот перед заброньованим
        if (startTime != bookedSlot.date) {
          newSlots.add(Slot(
            id: 0,
            date: startTime,
            isBooked: false,
            duration: const Duration(minutes: 30), // Тривалість 30 хв
          ));
        }

        // Додаємо заброньований слот
        newSlots.add(Slot(
          id: bookedSlot.id,
          date: bookedSlot.date,
          isBooked: true,
          clientName: bookedSlot.clientName,
          source: bookedSlot.source,
          duration: bookedSlot.duration,
          clientPhone: bookedSlot.clientPhone,
          service: bookedSlot.service,
        ));

        // Пересуваємо startTime до кінця заброньованого слота
        startTime = bookedSlot.date.add(bookedSlot.duration);
      } else {
        // Якщо слот не заброньований, додаємо стандартний слот
        newSlots.add(Slot(
          id: 0,
          date: startTime,
          isBooked: false,
          duration: const Duration(
              hours: 1), // Стандартна тривалість для вільних слотів
        ));
        startTime = startTime.add(const Duration(hours: 1));
      }
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

  Future<void> _showClientDialog(int index) async {
    // Змінна для збереження вибраної послуги
    int? selectedSpecialtyIndex;

    var data = await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController();
        TextEditingController phoneController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(FlutterI18n.translate(context, 'input_details')),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    AnimatedTextField(
                      controller: nameController,
                      labelText: FlutterI18n.translate(context, 'booking.name'),
                    ),
                    const SizedBox(height: 20),
                    AnimatedTextField(
                      controller: phoneController,
                      labelText:
                          FlutterI18n.translate(context, 'booking.phone'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    Text(FlutterI18n.translate(context, 'select_service')),
                    const SizedBox(height: 10),
                    // Додавання RadioListTile для вибору лише однієї спеціальності
                    Column(
                      children: List.generate(specialtyList.length, (i) {
                        return RadioListTile<int>(
                          title: Text(
                              specialtyList[i].name), // Назва спеціальності
                          value: i, // Індекс спеціальності
                          groupValue: selectedSpecialtyIndex,
                          onChanged: (int? value) {
                            setState(() {
                              selectedSpecialtyIndex =
                                  value; // Оновлення вибору
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Отримання вибраної спеціальності
                    Service? selectedSpecialty;
                    if (selectedSpecialtyIndex != null) {
                      selectedSpecialty =
                          specialtyList[selectedSpecialtyIndex!];
                    }

                    Navigator.of(context).pop({
                      "name": nameController.text,
                      "phone": phoneController.text,
                      "specialty": selectedSpecialty,
                      "slot_index": index,
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (data != null) {
      // Показуємо діалог для введення SMS-коду
      bool isVerified = await _showSmsVerificationDialog(
          data["phone"], data['name'], data['slot_index'], data['specialty']);

      if (isVerified) {
        // Якщо код підтверджено, викликаємо _updateSlotDuration
        setState(() {
          _updateSlotDuration(index, const Duration(minutes: 60), data: data);
        });
      } else {
        // Обробка невірного коду
        // Наприклад, показати повідомлення про помилку або повернути користувача до діалогу
        print("SMS verification failed");
      }
    }
  }

  // Функція для відображення діалогу введення SMS-коду
  Future<bool> _showSmsVerificationDialog(
      String phoneNumber, String name, int slotIndex, Service specialty) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        );
      },
    );
    await AuthService().registerClient(name, phoneNumber, context);
    await AuthService().sendSms(phoneNumber);
    Navigator.of(context).pop();

    TextEditingController smsCodeController = TextEditingController();

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(FlutterI18n.translate(context, 'enter_sms_code')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      '${FlutterI18n.translate(context, 'sms_sent_to')} $phoneNumber'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: smsCodeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: FlutterI18n.translate(context, 'sms_code'),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        );
                      },
                    );
                    bool isVerified = await AuthService().confirmLogin(
                        phoneNumber,
                        int.parse(smsCodeController.text),
                        context);

                    Navigator.of(context).pop();

                    if (isVerified) {
                      SlotService slotService = SlotService();
                      await slotService.bookSlotFromClient(
                        name,
                        phoneNumber,
                        true,
                        slots[slotIndex].date,
                        specialty,
                        widget.masterId,
                      );
                      Navigator.of(context).pop(true);
                    } else {
                      smsCodeController.text = '';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(FlutterI18n.translate(
                                context, 'system.filed_verify'))),
                      );
                    }
                  },
                  child: Text(FlutterI18n.translate(context, 'verify')),
                ),
              ],
            );
          },
        ) ??
        false; // Якщо діалог було закрито, повертаємо false
  }

  Future<void> _showDurationDialog(int index) async {
    Duration? duration = await showDialog(
      context: context,
      builder: (BuildContext context) {
        Duration? initialDuration = slots[index].duration;
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

  void _updateSlotDuration(int index, Duration newDuration, {data}) {
    DateTime startTime = slots[index].date;
    DateTime endTime = startTime.add(newDuration);
    DateTime nextSlotTime = endTime;

    slots[index].duration = newDuration;
    if (data != null) {
      slots[index].isBooked = true;
      slots[index].clientName = data['name'];
      slots[index].clientPhone = data['phone'];
      slots[index].service = data['specialty'];
    }

    for (int i = index + 1; i < slots.length; i++) {
      slots[i].date = nextSlotTime;
      nextSlotTime = nextSlotTime.add(slots[i].duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Loading(),
      );
    } else {
      double hourHeight = 80.0; // Висота одного годинного слоту
      String masterTitle = currentMonth;
      if (widget.masterId != 0) {
        masterTitle = '${widget.masterName}, $currentMonth';
      }

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            FlutterI18n.translate(context, 'booking_panel'),
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.brightness_6, color: Colors.black),
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
                masterTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 95,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  itemCount: 90,
                  itemBuilder: (context, index) {
                    DateTime date = DateTime.now().add(Duration(days: index));
                    bool isSelected = selectedDayIndex == index;

                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: 15, left: 8, right: 8),
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
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).shadowColor,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
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
                  child: Stack(
                    children: [
                      ListView.builder(
                        key: ValueKey(selectedDate),
                        itemCount: slots.length,
                        itemBuilder: (context, index) {
                          DateTime startTime = slots[index].date;
                          Duration duration = slots[index].duration;

                          // Розрахунок висоти контейнера
                          double slotHeight =
                              hourHeight * (duration.inMinutes / 60);

                          Function dialog = _showDurationDialog;
                          if (widget.masterId != 0) {
                            dialog = _showClientDialog;
                          }
                          return GestureDetector(
                            onTap: slots[index].isBooked
                                ? null
                                : () {
                                    dialog(index);
                                  },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  top: 0.0,
                                  bottom: 0.0),
                              height: slotHeight,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).shadowColor,
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                                color: slots[index].isBooked
                                    ? Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1)
                                    : Theme.of(context).hoverColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: slots[index].isBooked
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).hoverColor,
                                  width: 2.0,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                      const SizedBox(height: 2),
                                      slots[index].isBooked
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${FlutterI18n.translate(context, 'booked_by')}: ${slots[index].clientName}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall,
                                                ),
                                                Text(
                                                  FlutterI18n.translate(context,
                                                      '${slots[index].service?.name}'),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall,
                                                ),
                                              ],
                                            )
                                          : const SizedBox(),
                                    ],
                                  ),
                                  Icon(
                                    slots[index].isBooked
                                        ? Icons.timelapse
                                        : Icons.event_available,
                                    color: slots[index].isBooked
                                        ? Theme.of(context).focusColor
                                        : Theme.of(context).focusColor,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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
