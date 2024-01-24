import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyTable(),
    );
  }
}

class MyTable extends StatefulWidget {
  @override
  _MyTableState createState() => _MyTableState();
}

class _MyTableState extends State<MyTable> {
  void _deleteTask(int row, int col) {
    setState(() {
      schedule[row][col] = '';
    });
    Navigator.of(context).pop();
  }

  void _completeTask(int row, int col) {
    setState(() {
      schedule[row][col] = 'Completed';
    });
    Navigator.of(context).pop();
  }

  List<List<String>> schedule = List.generate(
    24,
    (index) => List.generate(7, (index) => ''),
  );

  List<Color> colors = [
    Color(0xFF8ABAC5),
    Color(0xFFD9D9D9),
    Color(0xFFCDE2E6),
  ];

  DateTime currentDate = DateTime.now();
  int? currentDayIndex;

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        currentDate = DateTime.now();
        currentDayIndex = currentDate.weekday - 1;
      });
    });
  }

  bool isCellEnabled(int dayIndex) {
    return true; // Allows the user to write in any cell
  }

  void _showTaskDialog(int row, int col) async {
    TextEditingController titleController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    String dateHint = 'Date';
    String startTimeHint = 'Start Time';
    String endTimeHint = 'End Time';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Task'),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 30.0,
                  child: TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      icon: Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      fillColor: Colors.grey[300],
                      filled: true,
                      labelStyle: TextStyle(color: Color(0xFF8ABAC5)),
                    ),
                  ),
                ),
                SizedBox(height: 7.0),
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2040),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                        dateHint = DateFormat.yMd().format(selectedDate!);
                      });
                    }
                  },
                  child: Container(
                    height: 30.0,
                    child: TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        hintText: dateHint,
                        icon: Icon(Icons.date_range),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        fillColor: Colors.grey[300],
                        filled: true,
                        labelStyle: TextStyle(color: Color(0xFF8ABAC5)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 7.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              startTime = pickedTime;
                              startTimeHint =
                                  '${startTime!.hour}:${startTime!.minute}';
                            });
                          }
                        },
                        child: Container(
                          height: 30.0,
                          child: TextField(
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'Start Time',
                              hintText: startTimeHint,
                              icon: Icon(Icons.access_time),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              fillColor: Colors.grey[300],
                              filled: true,
                              labelStyle: TextStyle(color: Color(0xFF8ABAC5)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.0),
                    Flexible(
                      child: GestureDetector(
                        onTap: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              endTime = pickedTime;
                              endTimeHint =
                                  '${endTime!.hour}:${endTime!.minute}';
                            });
                          }
                        },
                        child: Container(
                          height: 30.0,
                          child: TextField(
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'End Time',
                              hintText: endTimeHint,
                              icon: Icon(Icons.access_time),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              fillColor: Colors.grey[300],
                              filled: true,
                              labelStyle: TextStyle(color: Color(0xFF8ABAC5)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 7.0),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
              ),
              child: Text('Cancel', style: TextStyle(color: Color(0xFF8ABAC5))),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedDate != null &&
                    startTime != null &&
                    endTime != null) {
                  int startRow = startTime!.hour - 1;
                  int endRow = endTime!.hour - 2;
                  for (int i = startRow; i <= endRow; i++) {
                    int colIndex = DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                        ).weekday -
                        3;

                    if (i >= 0 && i < 24 && colIndex >= 0 && colIndex < 7) {
                      setState(() {
                        schedule[i][colIndex] =
                            '${titleController.text}\n ${endTime!.format(context)}';
                      });
                    }
                  }
                }

                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF8ABAC5),
              ),
              child: Text('Add Task', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  List<String> generateDates() {
    List<String> dates = [];
    for (int i = currentDayIndex!; i < currentDayIndex! + 7; i++) {
      DateTime date = currentDate.add(Duration(days: i - currentDayIndex!));
      dates.add(
          '${DateFormat.d().format(date)} ${DateFormat.MMMM().format(date)}');
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    List<String> daysOfWeek = generateDates();
    return Scaffold(
      appBar: AppBar(
        title: Text('Week View'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              DataTable(
                showCheckboxColumn: false,
                columns: [
                  DataColumn(
                    label: Container(
                      padding: EdgeInsets.all(8.0),
                      color: Colors.white,
                      child: Text('Time'),
                    ),
                  ),
                  for (var date in daysOfWeek) DataColumn(label: Text(date)),
                ],
                rows: [
                  for (int i = 0; i < 24; i++)
                    DataRow(
                      cells: [
                        DataCell(
                          Container(
                            width: 96,
                            height: 96,
                            alignment: Alignment.center,
                            margin: EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}:00 ${i < 12 ? 'AM' : 'PM'}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        for (var j = 0; j < 7; j++)
                          DataCell(
                            GestureDetector(
                              onTap: () {
                                if (isCellEnabled(j)) {
                                  _showTaskDialog(i, j);
                                } else {
                                  _showOptionsDialog(i, j);
                                }
                              },
                              child: Container(
                                width: 96,
                                height: 96,
                                alignment: Alignment.center,
                                margin: EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color: colors[(i + j) % colors.length],
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                                child: Text(
                                  schedule[i][j],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTaskDialog(0, 0);
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF8ABAC5),
      ),
    );
  }

  void _showOptionsDialog(int row, int col) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  _deleteTask(row, col);
                },
                style: ElevatedButton.styleFrom(primary: Colors.red),
                child: Text('Delete', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _completeTask(row, col);
                },
                style: ElevatedButton.styleFrom(primary: Colors.green),
                child: Text('Completed', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}
