import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BloodPressureScreen extends StatefulWidget {
  @override
  _BloodPressureScreenState createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  String? _editingDocId;

  final _collection = FirebaseFirestore.instance.collection('blood_pressure');

  Future<void> _saveRecord() async {
    final systolic = int.tryParse(_systolicController.text);
    final diastolic = int.tryParse(_diastolicController.text);

    if (systolic == null || diastolic == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Enter valid values'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    final data = {
      'systolic': systolic,
      'diastolic': diastolic,
      'date': DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
    };

    if (_editingDocId != null) {
      await _collection.doc(_editingDocId).update(data);
    } else {
      await _collection.add(data);
    }

    _systolicController.clear();
    _diastolicController.clear();
    _editingDocId = null;
  }

  void _editRecord(DocumentSnapshot doc) {
    setState(() {
      _systolicController.text = doc['systolic'].toString();
      _diastolicController.text = doc['diastolic'].toString();
      _editingDocId = doc.id;
    });
  }

  Future<void> _deleteRecord(String docId) async {
    await _collection.doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Blood Pressure')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _systolicController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Systolic (e.g. 120)'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _diastolicController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Diastolic (e.g. 80)'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _saveRecord,
              icon: Icon(Icons.save),
              label: Text(_editingDocId == null ? 'Save' : 'Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _collection.orderBy('date', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return Center(child: Text('No records yet.'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: ListTile(
                          leading: Icon(Icons.favorite, color: Colors.redAccent),
                          title: Text('Systolic: ${doc['systolic']} | Diastolic: ${doc['diastolic']}'),
                          subtitle: Text('Date: ${doc['date']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => _editRecord(doc),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteRecord(doc.id),
                              ),
                            ],
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
