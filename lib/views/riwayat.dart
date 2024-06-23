import 'package:flutter/material.dart';
import 'package:tugasakhirsawihijau/data/database_helper.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';

class Riwayat extends StatefulWidget {
  @override
  _RiwayatState createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> {
  List<Map<String, dynamic>> myData = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await DatabaseHelper().getPrediksiHama();
    setState(() {
      myData = data;
    });
  }

  Future<String?> _getExifDate(String imagePath) async {
    final exif = FlutterExif.fromPath(imagePath);
    final dateTimeOriginal = await exif.getAttribute('DateTimeOriginal');
    if (dateTimeOriginal != null) {
      DateTime dateTime =
          DateFormat('yyyy:MM:dd HH:mm:ss').parse(dateTimeOriginal);
      return DateFormat.yMd().add_Hms().format(dateTime);
    }
    return null;
  }

  void showDetail(Map<String, dynamic> data) async {
    String? exifDate =
        data['path'] != null ? await _getExifDate(data['path']) : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(24, 0, 24, 0),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['jenis_hama'] ?? ''),
            SizedBox(height: 0),
            if (exifDate != null)
              Text(
                "Tanggal : $exifDate",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data['path'] != null)
                Image.file(
                  File(data['path']),
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              SizedBox(height: 10),
              RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  text: "Nama Latin : ",
                  style: TextStyle(
                    fontStyle: FontStyle.normal,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: data['nama_latin'] ?? '',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Persentase : ${data['persentase']?.toStringAsFixed(2) ?? '0.00'}%",
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 10),
              Text(
                "Ciri - Ciri :",
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              ..._buildBulletPoints(data['ciri_ciri'] ?? ''),
              SizedBox(height: 10),
              Text(
                "Cara Penanganan :",
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              ..._buildBulletPoints(data['cara_penanganan'] ?? '', true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBulletPoints(String text,
      [bool removeLastBullet = false]) {
    List<String> lines = text.split('\n');
    if (removeLastBullet && lines.isNotEmpty) {
      lines = lines.sublist(0, lines.length - 1);
    }
    return lines.map((line) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              line.trim(),
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () {
            Navigator.pop(context);
          },
          padding: EdgeInsets.zero,
        ),
        title: Text(
          'Riwayat',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'InterMedium',
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SafeArea(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: myData.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    child: Card(
                      color: index % 2 == 0 ? Colors.green : Colors.green[200],
                      margin: const EdgeInsets.all(15),
                      child: ListTile(
                        leading: SizedBox(
                          width: 50,
                          child: myData[index]['path'] != null
                              ? Image.file(
                                  File(myData[index]['path']),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        title: Text(myData[index]['jenis_hama'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              myData[index]['nama_latin'] ?? '',
                              style: TextStyle(
                                color: Colors.black,
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Persentase : ${myData[index]['persentase']?.toStringAsFixed(2) ?? '0.00'}%',
                              style: TextStyle(color: Colors.black),
                            ),
                            FutureBuilder(
                              future: myData[index]['path'] != null
                                  ? _getExifDate(myData[index]['path'])
                                  : Future.value(null),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    "Tanggal : Memuat...",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  );
                                }
                                if (snapshot.hasData && snapshot.data != null) {
                                  return Text(
                                    "Tanggal : ${snapshot.data}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  );
                                } else {
                                  return SizedBox
                                      .shrink(); // Hide if no date available
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () => showDetail(myData[index]),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
