import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:hbe/enums/globals.dart';
import 'package:hbe/service/api_urls.dart';
import 'package:hbe/utils/color_constants.dart';
import 'package:hbe/widgets/loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../utils/toast_utils.dart';

class ViewUploadedImages extends StatefulWidget {
  const ViewUploadedImages({Key? key}) : super(key: key);

  @override
  State<ViewUploadedImages> createState() => _ViewUploadedImagesState();
}

class _ViewUploadedImagesState extends State<ViewUploadedImages> {
  bool isLoading = true;
  List images=[
    {
      "MessageCode": "0000"
    }
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllImages();
  }

  //GET UPLOADED IMAGES API
  void getAllImages() async{
    try {
      final response = await http.get(
          Uri.parse('${ApiUrls.baseURL}${ApiUrls.getMerchandiser_ImagesList}?LoginUserID=${globalData.userId}'),
          headers: {
            ApiUrls.key_name: ApiUrls.apikey,
          });

      var res = json.decode(response.body);

      if (response.statusCode == 200 ) {
        images.clear();
        if(mounted) {
          setState(() {
            images= res as List;
            log(images.toString());
            isLoading = false;
          });
        }
      }
      else {
        if(mounted) {
          setState(() {
            isLoading = false;
          });
        }
        throw Exception('Unexpected error occurred!');
      }
    } on SocketException {
      if(mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ToastUtils.warningToast("No Internet Connection", context);
    } on HttpException {
      if(mounted) {
        setState(() {

          isLoading = false;
        });
      }
      ToastUtils.warningToast("Couldn't find the data 😱", context);
    } on FormatException {
      if(mounted) {
        setState(() {

          isLoading = false;
        });
      }
      ToastUtils.warningToast("Something went wrong ", context);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    images.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenBasic,
        title: Text("View Uploaded Images",style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 16),),
        centerTitle: true,
      ),
      backgroundColor: white,
      body: LoadingAnimation(
        inAsyncCall: isLoading,
        child: images[0]["MessageCode"].toString()!="0000"?
        ListView.builder(itemBuilder: (context,index){
          return Container(
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: black.withOpacity(0.25),
                  blurRadius: 4
                )
              ]
            ),
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child:  Column(
              children: [
                SizedBox(
                  height: 180,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child:  CachedNetworkImage(
                        imageUrl: images[index]["FilePath"].toString(),
                        imageBuilder:
                            (context, imageProvider) =>
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        placeholder: (context, url) =>
                            Image.asset(
                                "assets/images/loader.gif"),
                        errorWidget: (context, url, error) =>
                        const Icon(
                          Icons.error,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Updated At:",style: TextStyle(fontFamily: "Poppins-SemiBold",fontSize: 14,color: greenBasic),),
                    Text(DateFormat("yyyy-MM-dd kk:mm:ss").format(DateTime.parse(images[index]["UpdateAt"].toString())),style: TextStyle(fontFamily: "Poppins-Medium",fontSize: 14,color: greenBasic)),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          );
        },
        itemCount: images.length,):
        Center(
          child: Column(
            children: [
              Lottie.asset("assets/animations/no_data.json",height: 250),
              SizedBox(height: 20,),
              Text("No Images Found",style: TextStyle(
                fontSize: 18,
                fontFamily: "Poppins-SemiBold",
                color: greenBasic
              ),)
            ],
          ),
        ),
      ),
    );
  }
}
