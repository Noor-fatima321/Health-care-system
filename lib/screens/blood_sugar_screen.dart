import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BloodSugarScreen extends StatefulWidget {
  @override
  _BloodSugarScreenState createState() => _BloodSugarScreenState();
}

class _BloodSugarScreenState extends State<BloodSugarScreen> {
  final _levelController = TextEditingController();
  String _mealTime = 'Before Meal';

  Future<void> _saveRecord() async {
    final level = int.tryParse(_levelController.text);
    if (level != null) {
      final now = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());

      await FirebaseFirestore.instance.collection('blood_sugar').add({
        'level': level,
        'meal_time': _mealTime,
        'date': now,
        'userId': FirebaseAuth.instance.currentUser?.uid,
      });

      _levelController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Record saved to Firestore')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid sugar level'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text('Blood Sugar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Form
            TextField(
              controller: _levelController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Sugar Level (mg/dL)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _mealTime,
              items: ['Before Meal', 'After Meal']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _mealTime = val!),
              decoration: InputDecoration(
                labelText: 'Meal Time',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _saveRecord,
              icon: Icon(Icons.save),
              label: Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            // Firestore List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('blood_sugar')
                    .where('userId', isEqualTo: userId)
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                  final records = snapshot.data!.docs;
                  if (records.isEmpty) return Center(child: Text('No records yet.'));

                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final data = records[index].data() as Map<String, dynamic>;
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: ListTile(
                          leading: Icon(Icons.bloodtype, color: Colors.deepPurple),
                          title: Text('Level: ${data['level']} mg/dL'),
                          subtitle: Text('${data['meal_time']}  |  ${data['date']}'),
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
