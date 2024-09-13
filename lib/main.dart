import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do List',
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Today',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        body: ExpansionPanelDemo(),
      ),
    );
  }
}

class ExpansionItem {
  bool isExpanded;
  final String header;
  final List<String> body;
  List<bool> checkedStates;

  ExpansionItem({
    this.isExpanded = false,
    required this.header,
    required this.body,
    required this.checkedStates,
  });
}

class ExpansionPanelDemo extends StatefulWidget {
  @override
  _ExpansionPanelDemoState createState() => _ExpansionPanelDemoState();
}

class _ExpansionPanelDemoState extends State<ExpansionPanelDemo> {
  List<ExpansionItem> items = [
    ExpansionItem(
      header: "7:00 AM",
      body: [
        '15 min work out (jogging)',
        'Cold shower',
        'Breakfast',
      ],
      checkedStates: [false, false, false],
    ),
    ExpansionItem(
      header: "9:00 AM",
      body: [
        'Meeting with team',
        'Prepare presentation',
      ],
      checkedStates: [false, false],
    ),
    ExpansionItem(
      header: "12:00 PM",
      body: [
        'Read Book',
        'Drink Coffee',
      ],
      checkedStates: [false, false],
    ),
    ExpansionItem(
      header: "3:00 PM",
      body: [
        'Go with friends',
        'Shopping',
      ],
      checkedStates: [false, false],
    ),
    ExpansionItem(
      header: "8:00 PM",
      body: [
        'Take a shower',
        'Sleep',
      ],
      checkedStates: [false, false],
    ),
  ];

  void addNewTask(String header, List<String> body) {
    setState(() {
      items.add(
        ExpansionItem(
          header: header,
          body: body,
          checkedStates: List<bool>.filled(body.length, false),
        ),
      );
    });
  }

  void deleteTask(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateTime.now().toString(),
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Icon(Icons.calendar_today, color: Colors.grey),
            ],
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
                margin: EdgeInsets.symmetric(vertical: 4),
                child: ExpansionPanelList(
                  elevation: 1,
                  expandedHeaderPadding: EdgeInsets.all(0),
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      item.isExpanded = !item.isExpanded;
                    });
                  },
                  children: [
                    ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return Container(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.checkedStates.every((checked) => checked)
                                      ? '${item.header} - Completed'
                                      : item.header,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: item.checkedStates.every((checked) => checked)
                                        ? Colors.green
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  deleteTask(index);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      isExpanded: item.isExpanded,
                      body: Container(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: List<Widget>.generate(item.body.length, (taskIndex) {
                            return Row(
                              children: [
                                Checkbox(
                                  value: item.checkedStates[taskIndex],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      item.checkedStates[taskIndex] = value ?? false;
                                    });
                                  },
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.body[taskIndex],
                                    style: TextStyle(
                                      fontSize: 16,
                                      decoration: item.checkedStates[taskIndex]
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return AddTaskDialog(
                    onAdd: (header, body) {
                      addNewTask(header, body);
                    },
                  );
                },
              );
            },
            child: Text('+ Add Task'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AddTaskDialog extends StatefulWidget {
  final void Function(String header, List<String> body) onAdd;

  AddTaskDialog({required this.onAdd});

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController _headerController = TextEditingController();
  final List<TextEditingController> _bodyControllers = [];
  final int _initialBodyItemCount = 1;
  String _selectedHour = '01:00';

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _initialBodyItemCount; i++) {
      _bodyControllers.add(TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Add Task',
            style: TextStyle(color: Colors.black, fontSize: 24),
          ),
          SizedBox(height: 16),
          // Third Field for Hour Selection
          DropdownButtonFormField<String>(
            value: _selectedHour,
            decoration: InputDecoration(
              labelText: 'Select Hour',
              labelStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            items: [
              '01:00', '02:00', '03:00', '04:00', '05:00',
              '06:00', '07:00', '08:00', '09:00', '10:00',
              '11:00', '12:00', '13:00', '14:00', '15:00',
              '16:00', '17:00', '18:00', '19:00', '20:00',
              '21:00', '22:00', '23:00', '24:00',
            ].map((hour) {
              return DropdownMenuItem<String>(
                value: hour,
                child: Text(hour, style: TextStyle(color: Colors.black)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedHour = newValue!;
                _headerController.text = _selectedHour; // Update the first TextField with selected hour
              });
            },
          ),
          SizedBox(height: 10),
          // First TextField
          TextField(
            controller: _headerController,
            decoration: InputDecoration(
              labelText: '',
              labelStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(height: 10),
          // Other TextFields
          ..._bodyControllers.map((controller) {
            return TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: '',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              style: TextStyle(color: Colors.black),
            );
          }).toList(),
          SizedBox(height: 10),
          // Button to Add More TextFields
          Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _bodyControllers.add(TextEditingController());
                });
              },
              child: Text(
                ' + ',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          SizedBox(height: 16),
          // Confirm Button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  final String header = _headerController.text;
                  final List<String> body = _bodyControllers.map((controller) => controller.text).toList();
                  if (header.isNotEmpty && body.every((item) => item.isNotEmpty)) {
                    Navigator.of(context).pop();
                    widget.onAdd(header, body);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please fill out all fields')),
                    );
                  }
                },
                child: Text('Confirm', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
