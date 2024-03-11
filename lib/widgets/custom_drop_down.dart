// ignore_for_file: must_be_immutable
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';

import '../utils/color_constants.dart';

class CustomDropDown extends StatelessWidget {
  CustomDropDown(
      {Key? key,
        this.hint,
        required this.items,
        required this.initialValue,
        required this.searchFieldController,
        required this.onChanged,
        required this.searchMatchFn,
        required this.onMenuStateChange})
      : super(key: key);
  String? hint;
  List<DropdownMenuItem<Object>>? items;
  String initialValue;
  void Function(Object?)? onChanged;
  TextEditingController? searchFieldController;
  bool Function(DropdownMenuItem<dynamic>, String)? searchMatchFn;
  void Function(bool)? onMenuStateChange;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color:  white,
            boxShadow: [
              BoxShadow(
                  color: greenBasic.withOpacity(0.25),
                  blurRadius: 2
              )
            ]
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            dropdownDecoration: const BoxDecoration(color: Colors.white),
            isExpanded: true,
            hint: hint == null
                ? null
                : Text(
              hint!,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).hintColor,
              ),
            ),
            items: items,

            value: initialValue,
            onChanged: onChanged,
            icon:const Icon(
              FeatherIcons.chevronDown,
              size: 20,
              color: black,
            ),
            buttonHeight: 40,
            buttonWidth: 200,
            itemHeight: 40,
            dropdownMaxHeight: 300,
            searchController: searchFieldController,
            searchInnerWidgetHeight: 20,
            searchInnerWidget: Padding(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 4,
                right: 8,
                left: 8,
              ),
              child: TextFormField(
                controller: searchFieldController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  hintText: hint,
                  hintStyle: const TextStyle(fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            searchMatchFn: searchMatchFn,
            //This to clear the search value when you close the menu
            onMenuStateChange: onMenuStateChange,
          ),
        ));
  }
}
