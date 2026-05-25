import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smartcool/data/api_services.dart';
import 'package:smartcool/theme/app_color.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int suhu = 0;
  String fanStatus = "OFF";
  String mode = "AUTO";

  Timer? timer;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      fetchData();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    if (isLoading) return;
    isLoading = true;

    try {
      final data = await ApiService.getData();
      final control = await ApiService.getControl();

      if (!mounted) return;

      setState(() {
        suhu = data["suhu"] ?? 0;
        fanStatus = data["fan"] ?? "OFF";
        mode = control["mode"] ?? "AUTO";
      });
    } catch (e) {
      print("Error: $e");
    }

    isLoading = false;
  }

  void setMode(String newMode) async {
    setState(() => mode = newMode);
    await ApiService.setControl(newMode, 0);
  }

  void setFan(int value) async {
    setState(() {
      fanStatus = value == 1 ? "MANUAL ON" : "MANUAL OFF";
    });
    await ApiService.setControl("MANUAL", value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "SMARTCOOL",
          style: TextStyle(color: AppColors.secondary),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[900],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Temperatur suhu laptop",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: suhu > 35
                      ? [Colors.red, Colors.orange]
                      : [Colors.blue[900]!, Colors.lightBlueAccent],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  "$suhu°C",
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _modeButton("AUTO"),
                const SizedBox(width: 10),
                _modeButton("MANUAL"),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Status Fan",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    fanStatus,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: fanStatus.contains("ON")
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            if (mode == "MANUAL")
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _fanButton("ON", 1),
                  const SizedBox(width: 10),
                  _fanButton("OFF", 0),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _modeButton(String text) {
    bool isActive = mode == text;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.blue : Colors.grey[400],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => setMode(text),
      child: Text(text, style: const TextStyle(color: AppColors.secondary)),
    );
  }

  Widget _fanButton(String text, int value) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: text == "ON" ? Colors.green : Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => setFan(value),
      child: Text(text, style: const TextStyle(color: AppColors.secondary)),
    );
  }
}