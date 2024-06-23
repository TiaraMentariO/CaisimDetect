import 'package:flutter/material.dart';

class DaftarView extends StatefulWidget {
  const DaftarView({Key? key}) : super(key: key);

  @override
  State<DaftarView> createState() => _DaftarViewState();
}

class _DaftarViewState extends State<DaftarView> {
  void _showDetails(
      // menampilkan dialog dg gmbr & informasi detail ttg hama ketika item diklik.
      BuildContext context,
      String title,
      String latinName,
      String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(imagePath),
              SizedBox(height: 10),
              Text(
                '$title',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "InterRegular",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (latinName.isNotEmpty)
                Text(
                  '$latinName',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: "InterRegular",
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.black, // Tulisan hitam
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Tutup"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRow(BuildContext context, String title, String latinName,
      String imagePath, bool hasHama) {
    // menampilkan informasi ttg hama/tdk & mengatur warna2
    Color backgroundColor = hasHama
        ? Color.fromARGB(255, 255, 235, 235)
        : Color.fromARGB(255, 204, 255, 204);
    Color textColor = hasHama
        ? Colors.black
        : Colors.black; // Tulisan hitam untuk grup dengan hama
    Color borderColor = hasHama
        ? Colors.redAccent
        : Colors
            .green; // Border merah untuk grup dengan hama, hijau untuk tanpa hama
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 10),
        GestureDetector(
          onTap: () => _showDetails(context, title, latinName, imagePath),
          child: Container(
            width: 100,
            height: 100,
            color: Colors.grey,
            child: Image.asset(imagePath),
          ),
        ),
        SizedBox(width: 10),
        Container(
          width: 230,
          height: 100,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor), // Border jika terdapat hama
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$title',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "InterRegular",
                  color: textColor, // Warna tulisan sesuai kondisi
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
              if (latinName.isNotEmpty)
                Text(
                  '$latinName',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "InterRegular",
                      color: textColor, // Warna tulisan sesuai kondisi
                      fontSize: 16,
                      fontStyle: FontStyle.italic),
                ),
            ],
          ),
        ),
      ],
    );
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
                  'Daftar Hama',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'InterMedium',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Dengan Hama',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'InterMedium',
            ),
          ),
          SizedBox(height: 8),
          _buildRow(context, 'Ulat Perusak Daun', 'Plutella Xylostella',
              'assets/images/perusak_daun.png', true),
          SizedBox(height: 20),
          _buildRow(context, 'Kumbang Daun', 'Phyllotetra Sp',
              'assets/images/kumbang_daun.png', true),
          SizedBox(height: 20),
          _buildRow(context, 'Ulat Krop Kubis', 'Crocidolomia Binotalis',
              'assets/images/krop_kubis.png', true),
          SizedBox(height: 20),
          Text(
            'Tanpa Hama',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'InterMedium',
            ),
          ),
          SizedBox(height: 8),
          _buildRow(
              context,
              'Sawi Tanpa Hama',
              'Brassica Rapa Var Parachinensis',
              'assets/images/tanpa_hama.png',
              false),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
