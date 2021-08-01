import 'dart:convert';
import "/pdf_page/PdfPage.dart";
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class OtpPage extends StatelessWidget {
  OtpPage({required this.tnxId, required this.regNo});
  final String tnxId, regNo;
  static String otp = "";
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Certificate"),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Form(
            key: formkey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    maxLength: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter the Otp";
                      } else if (value.length < 6) {
                        return "Enter correct otp";
                      } else {
                        otp = value;
                        return null;
                      }
                    },
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        hintText: "Enter OTP",
                        labelText: "OTP",
                        border: OutlineInputBorder()),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      validateOtp(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Download Certificate"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void validateOtp(BuildContext context) async {
    if (formkey.currentState!.validate()) {
      print("validated " + otp + " " + tnxId);
      try {
        var response = await http.post(
            Uri.parse(
                'https://cdn-api.co-vin.in/api/v2/auth/public/confirmOTP'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              "otp": sha256.convert(utf8.encode(otp)).toString(),
              "txnId": tnxId,
            }));

        if (response.statusCode == 200) {
          print(response.body);
          Map<String, dynamic> body = jsonDecode(response.body);
          print(body["token"]);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PdfPage(body["token"], regNo)),
          );
        } else if (response.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Enter correct Otp"),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(response.body),
          ));
        }
      } catch (e) {
        print("Exception:$e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Something went wrong"),
        ));
      }
    }
  }
}
