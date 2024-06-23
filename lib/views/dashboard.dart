import 'package:flutter/material.dart';
import 'package:tugasakhirsawihijau/utils/colors.dart';
import 'package:tugasakhirsawihijau/views/daftar.dart';
import 'package:tugasakhirsawihijau/views/deteksi.dart';
import 'package:tugasakhirsawihijau/views/chart.dart';
import 'package:tugasakhirsawihijau/views/riwayat.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool isDeteksiButtonClicked = false;
  bool isDaftarButtonClicked = false;
  bool isRiwayatButtonClicked = false;
  bool isGrafikButtonClicked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 42, 0, 0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'InterMedium',
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Image.asset('assets/images/dashboard.png'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    "Apa yang ingin Anda coba?",
                    style: TextStyle(
                      fontFamily: "InterRegular",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Anda bisa melakukan proses deteksi sawi hijau disini",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "InterMedium",
                fontSize: 18,
                color: fontGreyColor,
              ),
            ),
          ),
          SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isDeteksiButtonClicked = !isDeteksiButtonClicked;
                  isDaftarButtonClicked = false;
                  isRiwayatButtonClicked = false;
                  isGrafikButtonClicked = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeteksiView()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 13.5),
                child: Text(
                  "Deteksi Hama",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "InterMedium",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isDaftarButtonClicked = !isDaftarButtonClicked;
                  isDeteksiButtonClicked = false;
                  isRiwayatButtonClicked = false;
                  isGrafikButtonClicked = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DaftarView()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 13.5),
                child: Text(
                  "Daftar Hama",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "InterMedium",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isRiwayatButtonClicked = !isRiwayatButtonClicked;
                  isDeteksiButtonClicked = false;
                  isDaftarButtonClicked = false;
                  isGrafikButtonClicked = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Riwayat()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 13.5),
                child: Text(
                  "Riwayat",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "InterMedium",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isGrafikButtonClicked = !isGrafikButtonClicked;
                  isDeteksiButtonClicked = false;
                  isDaftarButtonClicked = false;
                  isRiwayatButtonClicked = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Chart()), // Menggunakan widget Chart
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 13.5),
                child: Text(
                  "Grafik Hasil Deteksi",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "InterMedium",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
