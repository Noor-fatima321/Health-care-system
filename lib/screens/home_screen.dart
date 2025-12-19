import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'blood_pressure_screen.dart';
import 'blood_sugar_screen.dart';
import 'bmi_screen.dart';
import 'medication_screen.dart';
import '../report_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  // ❌ Remove const here
  final List<Widget> _screens = [
    BloodPressureScreen(),
    BloodSugarScreen(),
    BmiScreen(),
    MedicationScreen(),
  ];

  final List<String> _titles = [
    'Blood Pressure',
    'Blood Sugar',
    'BMI Calculator',
    'Medication Reminder',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F8F7),

      /// 🔹 Gradient AppBar
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff0BA360), Color(0xff3CBA92)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),

      /// 🔹 Body with smooth transitions
      body: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _screens[_currentIndex],
            ),
          ),
        ],
      ),

      /// 🔹 Floating Export Button
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GestureDetector(
        onTap: () {
          ReportService.generateAndShareHealthReport();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xff11998E), Color(0xff38EF7D)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.picture_as_pdf, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Export Health Report',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),

      /// 🔹 Modern Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(22),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xff11998E),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'BP',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.water_drop),
              label: 'Sugar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.monitor_weight),
              label: 'BMI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.alarm),
              label: 'Meds',
            ),
          ],
        ),
      ),
    );
  }
}
