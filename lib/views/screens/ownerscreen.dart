import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';
import '../../models/user.dart';

import '../shared/mainmenu.dart';
import 'detailscreen.dart';
import 'homestayscreen.dart';
import 'package:ndialog/ndialog.dart';
import 'package:intl/intl.dart';

import 'newhomestay.dart';

class OwnerScreen extends StatefulWidget {
  final User user;
  const OwnerScreen({super.key, required this.user});

  @override
  State<OwnerScreen> createState() => _OwnerScreenState();
}

class _OwnerScreenState extends State<OwnerScreen> {
  var _lat, _lng;
  late Position _position;
  List<Product> productList = <Product>[];
  String titlecenter = "Loading...";
  var placemarks;
  final df = DateFormat('dd/MM/yyyy hh:mm a');
  late double screenHeight, screenWidth, resWidth;
  int rowcount = 2;

  @override
  void initState() {
    super.initState();
    // _loadHomestay();
  }

  @override
  void dispose() {
    productList = [];
    print("dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
      rowcount = 2;
    } else {
      resWidth = screenWidth * 0.75;
      rowcount = 3;
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(title: const Text("Seller"), actions: [
            PopupMenuButton(
                // add icon, by default "3 dot" icon
                // icon: Icon(Icons.book)
                itemBuilder: (context) {
              return [
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text("Add new homestay"),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text("My Booking"),
                ),
              ];
            }, onSelected: (value) {
              if (value == 0) {
                _gotoNewHomestay();
                print("My account menu is selected.");
              } else if (value == 1) {
                print("Settings menu is selected.");
              } else if (value == 2) {
                print("Logout menu is selected.");
              }
            }),
          ]),
          body: productList.isEmpty
              ? Center(
                  child: Text(titlecenter,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          "Your current products/services (${productList.length} found)"),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: rowcount,
                        children: List.generate(productList.length, (index) {
                          return Card(
                            elevation: 8,
                            child: InkWell(
                              onTap: _showDetails,
                              child: Column(children: [
                                const SizedBox(
                                  height: 6,
                                ),
                                Flexible(
                                  flex: 4,
                                  child: CachedNetworkImage(
                                    width: resWidth / 4,
                                    fit: BoxFit.cover,
                                    imageUrl:
                                        "${Config.SERVER}/assets/productimages/${productList[index].productId}.png",
                                    placeholder: (context, url) =>
                                        const LinearProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                                Flexible(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            truncateString(
                                                productList[index]
                                                    .productName
                                                    .toString(),
                                                15),
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                              "RM ${productList[index].productPrice}"),
                                          Text(df.format(DateTime.parse(
                                              productList[index]
                                                  .productDate
                                                  .toString()))),
                                        ],
                                      ),
                                    ))
                              ]),
                            ),
                          );
                        }),
                      ),
                    )
                  ],
                ),
          drawer: MainMenuWidget(user: widget.user)),
    );
  }

  String truncateString(String str, int size) {
    if (str.length > size) {
      str = str.substring(0, size);
      return "$str...";
    } else {
      return str;
    }
  }

  Future<void> _gotoNewHomestay() async {
    if (widget.user.id == "0") {
      Fluttertoast.showToast(
          msg: "Please login/register",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return;
    }
    ProgressDialog progressDialog = ProgressDialog(
      context,
      blur: 10,
      message: const Text("Searching your current location"),
      title: null,
    );
    progressDialog.show();
    if (await _checkPermissionGetLoc()) {
      progressDialog.dismiss();
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (content) => NewHomestayScreen(
                  position: _position,
                  user: widget.user,
                  placemarks: placemarks)));
      // _loadHomestay();
    } else {
      Fluttertoast.showToast(
          msg: "Please allow the app to access the location",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    }
  }

//check permission,get location,get address return false if any problem.
  Future<bool> _checkPermissionGetLoc() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(
            msg: "Please allow the app to access the location",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        Geolocator.openLocationSettings();
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: "Please allow the app to access the location",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      Geolocator.openLocationSettings();
      return false;
    }
    _position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    try {
      placemarks = await placemarkFromCoordinates(
          _position.latitude, _position.longitude);
    } catch (e) {
      Fluttertoast.showToast(
          msg:
              "Error in fixing your location. Make sure internet connection is available and try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
      return false;
    }
    return true;
  }

  // void _loadHomestay() {
  //   if (widget.user.id == "0") {
  //     //check if the user is registered or not
  //     Fluttertoast.showToast(
  //         msg: "Please register an account first", //Show toast
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //         timeInSecForIosWeb: 1,
  //         fontSize: 14.0);
  //     return; //exit method if true
  //   }
  //   //if registered user, continue get request
  //   http
  //       .get(
  //     Uri.parse(
  //         "${Config.SERVER}/php/loadsellerproducts.php?userid=${widget.user.id}"),
  //   )
  //       .then((response) {
  //     // wait for response from the request
  //     if (response.statusCode == 200) {
  //       //if statuscode OK
  //       var jsondata =
  //           jsonDecode(response.body); //decode response body to jsondata array
  //       if (jsondata['status'] == 'success') {
  //         //check if status data array is success
  //         var extractdata = jsondata['data']; //extract data from jsondata array
  //         if (extractdata['products'] != null) {
  //           //check if  array object is not null
  //           productList = <Product>[]; //complete the array object definition
  //           extractdata['products'].forEach((v) {
  //             //traverse products array list and add to the list object array productList
  //             productList.add(Product.fromJson(
  //                 v)); //add each product array to the list object array productList
  //           });
  //           titlecenter = "Found";
  //         } else {
  //           titlecenter =
  //               "No Product Available"; //if no data returned show title center
  //           productList.clear();
  //         }
  //       }
  //     } else {
  //       titlecenter = "No Product Available"; //status code other than 200
  //       productList.clear(); //clear productList array
  //     }
  //     setState(() {}); //refresh UI
  //   });
  // }

  void _showDetails() {
    Navigator.push(context,
        MaterialPageRoute(builder: (content) => const DetailsScreen()));
  }
}
