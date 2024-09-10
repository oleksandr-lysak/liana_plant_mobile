import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liana_plant/constants/styles.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  BookingPageState createState() => BookingPageState();
}

class BookingPageState extends State<BookingPage> {
  DateTime selectedDate = DateTime.now();
  int selectedDayIndex = 0;
  DateTime? selectedTimeSlot;
  late ScrollController _scrollController;
  String currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());

  // Список зайнятих слотів для прикладу (з датою і часом)
  List<Map<String, dynamic>> bookedSlots = [
    {'date': DateTime.now(),'client': 'John Doe', 'service': 'Haircut'},
    {'date': DateTime.now().add(Duration(hours: 4)), 'client': 'Jane Smith', 'service': 'Manicure'},
  ];

  List<Map<String, dynamic>> slots = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      int pageIndex = (_scrollController.offset / 70).round(); // 70 - висота контейнера + відступи
      DateTime selDate = DateTime.now().add(Duration(days: pageIndex + 5));
      String newMonth = DateFormat('MMMM yyyy').format(selDate);

      if (currentMonth != newMonth) {
        setState(() {
          currentMonth = newMonth;
        });
      }
    });

    // Ініціалізувати слоти часу від 7:00 до 20:00
    _initializeTimeSlots();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeTimeSlots() {
    DateTime startTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 7, 0);
    DateTime endTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 20, 0);

    List<Map<String, dynamic>> newSlots = [];
    while (startTime.isBefore(endTime)) {
      String formattedTime = DateFormat.jm().format(startTime);

      newSlots.add({
        'date': startTime, // Використовуємо DateTime для порівняння
        'time': formattedTime,
        'datetime': startTime,
        'isBooked': bookedSlots.any((slot) => _isSameSlot(slot['date'], startTime)),
        'client': bookedSlots.firstWhere(
          (slot) => _isSameSlot(slot['date'], startTime),
          orElse: () => {'client': '', 'service': ''},
        )['client'],
        'service': bookedSlots.firstWhere(
          (slot) => _isSameSlot(slot['date'], startTime),
          orElse: () => {'client': '', 'service': ''},
        )['service'],
      });
      startTime = startTime.add(Duration(hours: 1));
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
          title: const Text('Select Duration'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter duration in minutes'),
            
            onChanged: (value) {
              int minutes = int.tryParse(value) ?? 60;
              initialDuration = Duration(minutes: minutes);
            },
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

    // Оновлюємо тривалість вибраного слота
    slots[index]['duration'] = newDuration;

    // Пересуваємо наступні слоти
    for (int i = index + 1; i < slots.length; i++) {
      slots[i]['datetime'] = nextSlotTime;
      nextSlotTime = nextSlotTime.add(slots[i]['duration'] ?? const Duration(hours: 1)) ;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Назва місяця і року
            Text(
              currentMonth,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Прокручуваний рядок днів
            SizedBox(
              height: 68,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                itemCount: 90, // Кількість днів для відображення
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
                          _initializeTimeSlots(); // Оновлюємо слоти при зміні дати
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? Styles.primaryColor : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? Styles.primaryColor : Colors.grey,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('EEE').format(date), // День (Mon, Tue)
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            Text(
                              DateFormat('d').format(date), // Номер дня
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: 18,
                              ),
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
            // Вибраний день
            Text(
              'Selected Date: ${DateFormat.yMMMd().format(selectedDate)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            // Список слотів часу
            Expanded(
              child: ListView.builder(
                itemCount: slots.length,
                itemBuilder: (context, index) {
                  DateTime startTime = slots[index]['datetime'];
                  Duration duration = slots[index]['duration'] ?? const Duration(hours: 1);
                  bool isBooked = slots[index]['isBooked'];
                  bool isSelected = selectedTimeSlot == startTime;
                  Map<String, String>? bookingInfo = isBooked
                      ? {'client': slots[index]['client'], 'service': slots[index]['service']}
                      : null;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: GestureDetector(
                      onLongPress: !isBooked ? () => _showDurationDialog(index) : null,
                      onTap: !isBooked ? () {
                        setState(() {
                          selectedTimeSlot = startTime;
                        });
                      } : null,
                      child: Container(
                        height: duration.inMinutes > 60 ? 120.0 : 60.0, // Висота пропорційно тривалості
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isBooked ? Styles.primaryColor : (isSelected ? Colors.blue[200] : Styles.subtitleColor),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isBooked ? Styles.primaryColor : (isSelected ? Colors.blue : Colors.grey),
                            width: 2.0,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  slots[index]['time'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isBooked ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                if (isBooked)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${bookingInfo!['client']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '${bookingInfo['service']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            if (!isBooked && isSelected) const Icon(Icons.check_circle, color: Colors.green),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
