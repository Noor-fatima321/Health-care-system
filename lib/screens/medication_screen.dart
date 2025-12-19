import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../notifications/notification_service.dart';

class MedicationScreen extends StatefulWidget {
  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _saveReminder() async {
    if (_nameController.text.isEmpty || _doseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final now = DateTime.now();
      final scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ).isBefore(now)
          ? DateTime(now.year, now.month, now.day + 1, _selectedTime.hour,
          _selectedTime.minute)
          : DateTime(now.year, now.month, now.day, _selectedTime.hour,
          _selectedTime.minute);

      final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await NotificationService.scheduleNotification(
        id: id,
        title: 'Medication Reminder',
        body:
        '${_nameController.text} - ${_doseController.text} at ${_selectedTime.format(context)}',
        scheduledTime: scheduledTime,
      );

      await FirebaseFirestore.instance.collection('medications').add({
        'name': _nameController.text,
        'dosage': _doseController.text,
        'time': _selectedTime.format(context),
        'timestamp': DateTime.now(),
      });

      _nameController.clear();
      _doseController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder saved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {});
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _pickTime() async {
    final picked =
    await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  InputDecoration _field(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      /// 🔹 Add Reminder Card
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Medication',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _nameController,
                      decoration: _field(
                        'Medicine Name',
                        Icons.medication_outlined,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _doseController,
                      decoration: _field(
                        'Dosage (e.g. 1 tablet)',
                        Icons.scale_outlined,
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// Time Picker
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedTime.format(context),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _pickTime,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Pick Time'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    /// Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _saveReminder,
                        icon: const Icon(Icons.alarm),
                        label: const Text(
                          'Save Reminder',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// 🔹 Reminder List
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your Reminders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 400,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('medications')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final meds = snapshot.data!.docs;
                  if (meds.isEmpty) {
                    return const Center(
                      child: Text('No reminders added yet'),
                    );
                  }

                  return ListView.builder(
                    itemCount: meds.length,
                    itemBuilder: (context, index) {
                      final data =
                      meds[index].data() as Map<String, dynamic>;

                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade100,
                            child: const Icon(
                              Icons.medication,
                              color: Colors.teal,
                            ),
                          ),
                          title: Text(
                            data['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${data['dosage']} • ${data['time']}',
                          ),
                        ),
                      );
                    },
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
