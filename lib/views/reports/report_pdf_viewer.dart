// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:hbe/enums/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file_safe/open_file_safe.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../service/api_urls.dart';
import '../../utils/color_constants.dart';
import '../../utils/toast_utils.dart';

class ReportPDFViewer extends StatefulWidget {
  bool isSale;
  String fromDate,toDate,GM,ST,DM,SDM,SO,reportName;
  ReportPDFViewer({Key? key,required this.isSale,required this.DM,required this.GM,required this.SDM,required this.SO,required this.ST,required this.reportName,required this.fromDate,required this.toDate}) : super(key: key);

  @override
  State<ReportPDFViewer> createState() => _ReportPDFViewerState();
}

class _ReportPDFViewerState extends State<ReportPDFViewer> {
  String pdfUrl = "";
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.isSale){
      getStoreReport();
    }
    else{
      getAttendanceReport();
    }
  }

  //GET SALE REPORT API
  Future<void> getStoreReport() async {
    try {
      log('${ApiUrls.baseURL}${ApiUrls.loadSaleReport}?DateFrom=${widget.fromDate}&DateTo=${widget.toDate}&LoginUserID=${globalData.userId}&GM=${widget.GM}&ST=${widget.ST}&DM=${widget.DM}&SDM=${widget.SDM}&SOID=${widget.SO}&ReportName=${Uri.encodeComponent(widget.reportName)}');
      var response = await http.post(
        Uri.parse('${ApiUrls.baseURL}${ApiUrls.loadSaleReport}?DateFrom=${widget.fromDate}&DateTo=${widget.toDate}&LoginUserID=${globalData.userId}&GM=${widget.GM}&ST=${widget.ST}&DM=${widget.DM}&SDM=${widget.SDM}&SOID=${widget.SO}&ReportName=${Uri.encodeComponent(widget.reportName)}'),
        headers: {
          ApiUrls.key_name: ApiUrls.apikey,
          "Content-Type": "application/json; charset=utf-8"
        },
      );

      var res = jsonDecode(response.body);


      if (response.statusCode == 200) {

        if (mounted) {
          setState(() {
            isLoading = false;
            pdfUrl = res.toString();

          });
        }
      }  else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }

        ToastUtils.failureToast("Something went wrong", context);
        throw Exception('Failed to load data');
      }
    } on SocketException {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ToastUtils.failureToast("No Internet Connection", context);
    } on HttpException {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      ToastUtils.failureToast("Couldn't find the data 😱", context);

    } on FormatException {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ToastUtils.failureToast("Internal Server Error ", context);
    }

  }


  //GET ATTENDANCE REPORT API
  Future<void> getAttendanceReport() async {
    try {
      log('${ApiUrls.baseURL}${ApiUrls.loadAttendanceReport}?DateFrom=${widget.fromDate}&DateTo=${widget.toDate}&LoginUserID=${globalData.userId}&GM=${widget.GM}&ST=${widget.ST}&DM=${widget.DM}&SDM=${widget.SDM}&SOID=${widget.SO}&ReportName=${Uri.encodeComponent(widget.reportName)}');
      var response = await http.post(
        Uri.parse('${ApiUrls.baseURL}${ApiUrls.loadAttendanceReport}?DateFrom=${widget.fromDate}&DateTo=${widget.toDate}&LoginUserID=${globalData.userId}&GM=${widget.GM}&ST=${widget.ST}&DM=${widget.DM}&SDM=${widget.SDM}&SOID=${widget.SO}&ReportName=${Uri.encodeComponent(widget.reportName)}'),
        headers: {
          ApiUrls.key_name: ApiUrls.apikey,
          "Content-Type": "application/json; charset=utf-8"
        },
      );

      var res = jsonDecode(response.body);


      if (response.statusCode == 200) {

        if (mounted) {
          setState(() {
            isLoading = false;
            pdfUrl = res.toString();

          });
        }
      }  else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }

        ToastUtils.failureToast("Something went wrong", context);
        throw Exception('Failed to load data');
      }
    } on SocketException {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ToastUtils.failureToast("No Internet Connection", context);
    } on HttpException {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      ToastUtils.failureToast("Couldn't find the data 😱", context);

    } on FormatException {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ToastUtils.failureToast("Internal Server Error ", context);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: white,
        appBar: AppBar(
          backgroundColor: greenBasic,
          title: Text(widget.isSale?"Sales Report":"Attendance Report",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16,color: white)),

        ),
        body:isLoading? Center(child: CircularProgressIndicator(color: greenBasic)):
        Container(child: SfPdfViewer.network(pdfUrl)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "DownloadBtn",
        onPressed: () {
          if (pdfUrl == "null" || pdfUrl == "" || pdfUrl.isEmpty) {
            ToastUtils.failureToast("No Pdf Found", context);
          } else {
            downloadFileandOpen(
                context, pdfUrl, pdfUrl.substring(pdfUrl.length - 5));
          }
        },
        label: Text(
          "Download",
          style: TextStyle(fontFamily: 'Poppins-SemiBold', fontSize: 14),
        ),
        icon: const Icon(
          Icons.download,
          color: white,
        ),
        backgroundColor: greenBasic,
      ),
    );
  }

  void downloadFileandOpen(
      BuildContext context, String url, String fileName) async {
    Permission permission = await Permission.storage;
    PermissionStatus permissionStatus = await permission.request();
    if (permissionStatus == PermissionStatus.granted) {
      var directory = Platform.isAndroid
          ? await getApplicationSupportDirectory() //FOR ANDROID
          : await getApplicationSupportDirectory();

      String dir = directory.path;
      log(dir.toString());
      File file = new File('$dir/$fileName');

      if (await file.exists()) {
        OpenFile.open(file.path);
        ToastUtils.infoToast("Already Downloaded", context);
      } else {
        ToastUtils.infoToast("Downloading...", context);

        HttpClient httpClient = new HttpClient();

        try {
          var request = await httpClient.getUrl(Uri.parse(url));
          var response = await request.close();
          print(response.statusCode);
          if (response.statusCode == 200) {
            var bytes = await consolidateHttpClientResponseBytes(response);
            log(file.path.toString());
            await file.writeAsBytes(bytes);
          }
          Navigator.pop(context);
          ToastUtils.successToast("Downloaded Successful", context);
        } catch (ex) {
          Navigator.pop(context);
          print(ex.toString());

          ToastUtils.failureToast(ex.toString(), context);
        } finally {
          OpenFile.open(file.path);
        }
      }
    } else if (permissionStatus == PermissionStatus.denied) {
      ToastUtils.failureToast(
          "Permission Denied, Please allow for file to download.", context);
      Permission permission2 = await Permission.storage;
      PermissionStatus permissionStatus2 = await permission.request();
    }
  }
}
