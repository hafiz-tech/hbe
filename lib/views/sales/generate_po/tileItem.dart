
// ignore_for_file: must_be_immutable

import 'package:hbe/utils/toast_utils.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/po_cart_provider.dart';
import '../../../utils/color_constants.dart';

class ListTileItem extends StatefulWidget {
   String price;
   int index;
   ListTileItem({Key? key,required this.price,required this.index}) : super(key: key);
  @override
  _ListTileItemState createState() => new _ListTileItemState();
}
class _ListTileItemState extends State<ListTileItem> {
  var price;
 // late POCartProvider poCartProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //poCartProvider = Provider.of<POCartProvider>(context, listen: false);
  }
  @override
  Widget build(BuildContext context) {
    final poCartProvider = Provider.of<POCartProvider>(context);
    return  Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: (){
            setState((){
              poCartProvider.selectedIndex=widget.index;
              poCartProvider.originalPrice = widget.price.toString();
              poCartProvider.itemCount++;
              poCartProvider.price = (double.parse(poCartProvider.originalPrice.toString()) * double.parse(poCartProvider.itemCount.toString())).toInt();
            });
          },
          child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  color: greenBasic,
                  boxShadow: [
                    BoxShadow(
                        color: black.withOpacity(0.2),
                        blurRadius: 3
                    )
                  ],
                  shape: BoxShape.circle
              ),
              child: Icon(
                FeatherIcons.plus,color: white,
                size: 15,
              )
          ),
        ),
        SizedBox(width: 5),
        Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
                color: white,
                boxShadow: [
                  BoxShadow(
                      color: black.withOpacity(0.2),
                      blurRadius: 3
                  )
                ],
                borderRadius: BorderRadius.circular(5)
            ),
            child: Center(child: Text( poCartProvider.selectedIndex==widget.index? poCartProvider.itemCount.toString():"0",style: TextStyle(fontSize: 12,fontFamily: "Poppins-Medium",color: greenBasic),))),
        SizedBox(width: 5),
        InkWell(
          onTap: (){
            if(poCartProvider.itemCount!=0){
              setState((){
                poCartProvider.selectedIndex=widget.index;
                poCartProvider.originalPrice = widget.price.toString();
                poCartProvider.itemCount--;
                poCartProvider.price = (double.parse(poCartProvider.price.toString()) - double.parse(poCartProvider.originalPrice.toString())).toInt();
              });
            }
            else{
              ToastUtils.infoToast("Quantity is zero", context);
            }
          },
          child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                  color: greenBasic,
                  boxShadow: [
                    BoxShadow(
                        color: black.withOpacity(0.2),
                        blurRadius: 3
                    )
                  ],
                  shape: BoxShape.circle
              ),
              child: Icon(
                FeatherIcons.minus,color: white,
                size: 15,
              )
          ),
        ),
      ],
    );
  }
}