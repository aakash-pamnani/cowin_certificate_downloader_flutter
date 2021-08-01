import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'otpPage.dart';
import 'package:http/http.dart' as http;

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/": (context) => HomePage(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<FormState> key = GlobalKey<FormState>();
  String phn = "", regNo = "";

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
            key: key,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    maxLength: 10,
                    validator: (value) {
                      String pattern = "(^(?:[+0]9)?[0-9]{10}\$)";
                      RegExp number = RegExp(pattern);
                      if (value == null) {
                        return "Enter the number";
                      } else if (number.hasMatch(value)) {
                        phn = value;
                        return null;
                      } else {
                        return "Enter Correct Number";
                      }
                    },
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                        hintText: "Enter Your phone number",
                        labelText: "Phone Number",
                        border: OutlineInputBorder()),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null) {
                        return "Enter correct Registratrion Number";
                      } else if (value.isEmpty) {
                        return "Enter correct Registratrion Number";
                      } else {
                        regNo = value;
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                        hintText: "Enter Your registration number",
                        labelText: "Registration Number",
                        border: OutlineInputBorder()),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      validateForm();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Download Certificate"),
                    ),
                  ),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     // var data = await rootBundle.load("/certificate.txt");
                  //     print(kIsWeb);
                  //     // final dir = "/storage/emulated/0/Download";
                  //     // final file = IO.File(dir + "/certificate-$regNo.pdf");
                  //     // await file.writeAsBytes(data.buffer.asUint8List());

                  //     // final blob = Blob([data.buffer]);
                  //     // final url = Url.createObjectUrlFromBlob(blob);

                  //     // final anchor =
                  //     //     document.createElement('a') as AnchorElement
                  //     //       ..href = url
                  //     //       ..style.display = 'none'
                  //     //       ..download = "output3.pdf"
                  //     //       ..click();
                  //   },
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: Text("Test"),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void validateForm() async {
    if (key.currentState!.validate()) {
      print("validated");
      try {
        var response = await http.post(
            Uri.parse(
                'https://cdn-api.co-vin.in/api/v2/auth/public/generateOTP'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              "mobile": phn,
            }));

        if (response.statusCode == 200) {
          Map<String, dynamic> body = json.decode(response.body);
          print(body["txnId"]);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OtpPage(tnxId: body["txnId"]!, regNo: regNo)),
          );
        } else if (response.body == "OTP Already Sent") {
          print(response.body);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    OtpPage(tnxId: response.body[0], regNo: regNo)),
          );
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
