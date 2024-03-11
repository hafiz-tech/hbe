// ignore_for_file: depend_on_referenced_packages

import 'package:hbe/controllers/po_cart_provider.dart';
import 'package:provider/provider.dart';

var multiProvider = [
  ChangeNotifierProvider<POCartProvider>(
    create: (_) => POCartProvider(),
    lazy: true,
  ),



];
