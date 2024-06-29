import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tugasakhirsawihijau/data/database_helper.dart';
import 'package:intl/intl.dart';

class Chart extends StatefulWidget {
  @override
  _ChartState createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  Map<String, int> predictionData = {};
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (startDate != null && endDate != null) {
      DateTime effectiveEndDate = endDate!.add(Duration(days: 1));
      final data = await DatabaseHelper()
          .getDetectionCountsByJenisHamaInRange(startDate!, effectiveEndDate);
      setState(() {
        predictionData = data;
      });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: (isStart ? startDate : endDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          startDate = date;
          if (endDate != null && startDate!.isAfter(endDate!)) {
            endDate = startDate;
          }
        } else {
          endDate = date;
          if (startDate != null && endDate!.isBefore(startDate!)) {
            startDate = endDate;
          }
        }
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, size: 30, color: Colors.black),
                  padding: EdgeInsets.zero,
                ),
                SizedBox(width: 2),
                Text(
                  'Grafik Hasil Deteksi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InterMedium',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () async {
                    _pickDate(isStart: true);
                  },
                  child: Text(
                    startDate != null
                        ? DateFormat('yyyy-MM-dd').format(startDate!)
                        : 'Pilih Tanggal Mulai',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  '-', // Dash separator
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    _pickDate(isStart: false);
                  },
                  child: Text(
                    endDate != null
                        ? DateFormat('yyyy-MM-dd').format(endDate!)
                        : 'Pilih Tanggal Akhir',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: predictionData.isNotEmpty
                  ? PieChartWidget(data: predictionData)
                  : Center(child: Text('Tidak ada data yang tersedia')),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LegendItem(color: Colors.green, text: 'Tanpa Hama'),
                  LegendItem(color: Colors.blue, text: 'Kumbang Daun'),
                  LegendItem(color: Colors.red, text: 'Ulat Krop Kubis'),
                  LegendItem(color: Colors.orange, text: 'Ulat Perusak Daun'),
                  LegendItem(
                      color: Colors.grey,
                      text:
                          'Tidak Diketahui'), // Added legend item for "Tidak Diketahui"
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final Map<String, int> data;

  const PieChartWidget({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0, (prev, deteksi) => prev + deteksi);
    final dataPercentage =
        data.map((jenis, deteksi) => MapEntry(jenis, deteksi / total));

    return Container(
      alignment: Alignment.topCenter,
      height: 300,
      child: PieChart(
        PieChartData(
          sections: _buildPieChartSections(data, dataPercentage),
          sectionsSpace: 0,
          centerSpaceRadius: 50,
          startDegreeOffset: 180,
          borderData: FlBorderData(show: false),
          pieTouchData: PieTouchData(enabled: false),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
      Map<String, int> data, Map<String, double> dataPercentage) {
    return dataPercentage.entries.map((entry) {
      final jenis = entry.key;
      final percentage = entry.value;
      final jumlah = data[jenis] ?? 0;
      return PieChartSectionData(
        color: _getColor(jenis),
        value: percentage,
        title: '${(percentage * 100).toStringAsFixed(2)}%\nJumlah : $jumlah',
        radius: 100,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getColor(String key) {
    switch (key) {
      case 'Tanpa Hama':
        return Colors.green;
      case 'Kumbang Daun':
        return Colors.blue;
      case 'Ulat Krop Kubis':
        return Colors.red;
      case 'Ulat Perusak Daun':
        return Colors.orange; // Color for "Tidak Diketahui"
      default:
        return Colors.grey;
    }
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
