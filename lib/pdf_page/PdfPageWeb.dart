import 'dart:html';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'package:permission_handler/permission_handler.dart';

class PdfPage extends StatelessWidget {
  PdfPage(this.token, this.regNo);
  final String token, regNo;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getPdf(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                title: Text("Loading"),
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            Response? response = snapshot.data as http.Response?;
            print(response?.body);
            if (response?.statusCode == 200) {
              // save file

              print(response);
              print("Body" + response!.body);

              createPdf(response.bodyBytes);

              return Scaffold(
                appBar: AppBar(
                  title: Text("Downloaded"),
                ),
                body: Center(
                  child: Column(
                    children: [
                      Text("File Downloaded"),
                      ElevatedButton(
                        child: Text("Go back to home"),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Scaffold(
                appBar: AppBar(
                  title: Text("Opps!"),
                ),
                body: Center(
                  child: Column(
                    children: [
                      Text("Something Went wrong"),
                      ElevatedButton(
                        child: Text("Go back to home"),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              );
            }
          }
        });
  }

  getPdf() async {
    return http.get(
      Uri.parse(
          "https://cdn-api.co-vin.in/api/v2/registration/certificate/public/download?beneficiary_reference_id=$regNo"),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
      },
    );
  }

  void createPdf(Uint8List bytes) async {
    final blob = Blob([bytes.buffer]);
    final url = Url.createObjectUrlFromBlob(blob);

    AnchorElement()
      ..href = url
      ..style.display = 'none'
      ..download = "certificate-$regNo.pdf"
      ..click();
  }

  Future<bool> checkStoragePermission() async {
    var status = await Permission.storage.status;
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      await Permission.storage.request();
      return checkStoragePermission();
    }
  }
}
