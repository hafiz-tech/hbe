import 'dart:async';
import 'dart:typed_data';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:hbe/utils/app_routes.dart';
import 'package:hbe/utils/mapAsset.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import '../../../utils/color_constants.dart';

class MapViewer extends StatefulWidget {
  final String lat, lng,location,empName,empContact,checkTime;
  const MapViewer({Key? key,required this.location,required this.empName,required this.checkTime,required this.empContact,required this.lat,required this.lng}) : super(key: key);

  @override
  State<MapViewer> createState() => _MapViewerState();
}

class _MapViewerState extends State<MapViewer> {

  Completer<GoogleMapController> _controller = Completer();
  Uint8List? markerIcon;
  Marker? marker;
  final Set<Marker> _markers = {};
  GoogleMapController? mapController;
  static CameraPosition _kLake = CameraPosition(target: LatLng(0.0, 0.0), zoom: 12);
  double lat = 0.0;
  double lng = 0.0;
  String location= "";
  final CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setMarker();
    setValues();
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  //SET VALUES
  void setValues(){
    if(mounted){
      setState(() {
        lat =widget.lat.toString()=="null"? 0.0:double.parse(widget.lat);
        lng =widget.lng.toString()=="null"? 0.0:double.parse(widget.lng);
        location= widget.location;
        _kLake = CameraPosition(
            target: LatLng(lat, lng),
            zoom: 16);
      });
    }
  }

  //SET CUSTOM MARKER
  void setMarker() async{
    markerIcon = await mapAsset.getBytesFromAsset("assets/icons/locationMarker.png", 100);
    if (mounted) {
      setState(() {
        marker = Marker(
            markerId: const MarkerId("home"),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.fromBytes(markerIcon!),
            onTap: () {
              _customInfoWindowController.addInfoWindow!(
                  Container(
                    decoration: BoxDecoration(
                      color: white,
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF000000).withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 4)),
                      ],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 2,
                          left: 10
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text(
                            widget.empName.toString(),
                            style: TextStyle(fontFamily: 'Poppins-SemiBold', fontSize: 12),
                          ),
                          SizedBox(height: 5),
                          Text(
                            widget.empContact.toString(),
                            style: TextStyle(fontFamily: 'Poppins-Medium', fontSize: 12),
                          ),
                          SizedBox(height: 5),
                          Text(
                            widget.checkTime.toString(),
                            style: TextStyle(fontFamily: 'Poppins-Regular', fontSize: 12),
                          ),
                          SizedBox(height: 5),
                          SizedBox(
                            width:200,
                            child: Text(
                              widget.location.toString()=="null"?"N/A":widget.location.toString(),
                              style: TextStyle(fontFamily: 'Poppins-Light', fontSize: 12),overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  LatLng(
                    lat,
                    lng,
                  )
              );
            }
        );
        _markers.add(marker!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body:Stack(
        children:<Widget> [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: const CameraPosition(target: LatLng(0.0, 0.0)),
            onCameraMove: (position) {
              _customInfoWindowController.onCameraMove!();
            },
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              _customInfoWindowController.googleMapController = controller;
              _controller.complete(controller);
              goToLoc();
            },
          ),
          CustomInfoWindow(
            controller: _customInfoWindowController,
            width: 220,
            offset: 55,
            height: 120,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: FloatingActionButton(
          backgroundColor: greenBasic,
          onPressed: (){
            AppRoutes.pop(context);
          },
          child: Icon(FeatherIcons.arrowLeft,color: white),
        ),
      ),
    );
  }

  //GO TO USER LOCATION
  Future<void> goToLoc() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
    _customInfoWindowController.addInfoWindow!(
        Container(
          decoration: BoxDecoration(
            color: white,
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF000000).withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 4)),
            ],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                top: 2,
                left: 10
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Text(
                  widget.empName.toString(),
                  style: TextStyle(fontFamily: 'Poppins-SemiBold', fontSize: 12),
                ),
                SizedBox(height: 5),
                Text(
                  widget.empContact.toString(),
                  style: TextStyle(fontFamily: 'Poppins-Medium', fontSize: 12),
                ),
                SizedBox(height: 5),
                Text(
                  widget.checkTime.toString(),
                  style: TextStyle(fontFamily: 'Poppins-Regular', fontSize: 12),
                ),
                SizedBox(height: 5),
                SizedBox(
                  width:200,
                  child: Text(
                    widget.location.toString()=="null"?"N/A":widget.location.toString(),
                    style: TextStyle(fontFamily: 'Poppins-Light', fontSize: 12),overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          width: double.infinity,
          height: double.infinity,
        ),
        LatLng(
          lat,
          lng,
        )
    );
    mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            lat,
            lng,
          ),
          zoom: 16.0,
        ),
      ),
    );


  }
}
