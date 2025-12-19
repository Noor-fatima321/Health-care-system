import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'db/database_helper.dart';

class ReportService {
  static Future<void> generateAndShareHealthReport() async {
    final pdf = pw.Document();

    final bpData = await DatabaseHelper.instance.getAllBP();
    final sugarData = await DatabaseHelper.instance.getAllSugar();
    final bmiData = await DatabaseHelper.instance.getAllBMI();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text("Health Report")),
          pw.Text("Blood Pressure Records"),
          pw.Table.fromTextArray(
            headers: ['Systolic', 'Diastolic', 'Date'],
            data: bpData.map((e) => [e['systolic'], e['diastolic'], e['date']]).toList(),
          ),
          pw.SizedBox(height: 10),
          pw.Text("Blood Sugar Records"),
          pw.Table.fromTextArray(
            headers: ['Sugar Level', 'Date'],
            data: sugarData.map((e) => [e['level'], e['date']]).toList(),
          ),
          pw.SizedBox(height: 10),
          pw.Text("BMI Records"),
          pw.Table.fromTextArray(
            headers: ['Weight', 'Height', 'BMI', 'Date'],
            data: bmiData.map((e) => [e['weight'], e['height'], e['bmi'], e['date']]).toList(),
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/Health_Report.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'My Health Report');
  }
}
