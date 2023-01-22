import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../ServerConfig.dart';
import '../../models/homestay.dart';
import '../../models/user.dart';

class ClientHomestayDetails extends StatefulWidget {
  final Homestay homestay;
  final User user;
  final User owner;
  const ClientHomestayDetails(
      {super.key,
      required this.homestay,
      required this.user,
      required this.owner});

  @override
  State<ClientHomestayDetails> createState() => _ClientHomestayDetailsState();
}

class _ClientHomestayDetailsState extends State<ClientHomestayDetails> {
  late double screenHeight, screenWidth, resWidth;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
    } else {
      resWidth = screenWidth * 0.90;
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Details")),
      body: Column(children: [
        Card(
          elevation: 8,
          child: SizedBox(
              height: screenHeight / 3,
              width: resWidth,
              child: CachedNetworkImage(
                width: resWidth,
                fit: BoxFit.cover,
                imageUrl:
                    "${ServerConfig.SERVER}/assets/homestayimages/${widget.homestay.homestayId}.1.png",
                placeholder: (context, url) => const LinearProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          widget.homestay.homestayName.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: screenWidth - 16,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
                border: TableBorder.all(
                    color: Colors.black, style: BorderStyle.none, width: 1),
                columnWidths: const {
                  0: FixedColumnWidth(70),
                  1: FixedColumnWidth(200),
                },
                children: [
                  TableRow(children: [
                    SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Description',
                                style: TextStyle(fontSize: 14.0))
                          ]),
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.homestay.homestayDesc.toString(),
                              style: const TextStyle(fontSize: 14.0))
                        ]),
                  ]),
                  TableRow(children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Price', style: TextStyle(fontSize: 14.0))
                        ]),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("RM ${widget.homestay.homestayPrice}",
                              style: const TextStyle(fontSize: 14.0))
                        ]),
                  ]),
                  TableRow(children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Address', style: TextStyle(fontSize: 14.0))
                        ]),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${widget.homestay.homestayAddress}",
                              style: const TextStyle(fontSize: 14.0))
                        ]),
                  ]),
                  TableRow(children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('State', style: TextStyle(fontSize: 14.0))
                        ]),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${widget.homestay.homestayState}",
                              style: const TextStyle(fontSize: 14.0))
                        ]),
                  ]),
                  TableRow(children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Owner', style: TextStyle(fontSize: 14.0))
                        ]),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${widget.owner.name}",
                              style: const TextStyle(fontSize: 14.0))
                        ]),
                  ])
                ]),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Align(
            alignment: FractionalOffset.bottomCenter,
            child: Card(
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                        iconSize: 32,
                        onPressed: _makePhoneCall,
                        icon: const Icon(Icons.call)),
                    IconButton(
                        iconSize: 32,
                        onPressed: _makeSmS,
                        icon: const Icon(Icons.message)),
                    IconButton(
                        iconSize: 32,
                        onPressed: openwhatsapp,
                        icon: const Icon(Icons.whatsapp)),
                    IconButton(
                        iconSize: 32,
                        onPressed: _onRoute,
                        icon: const Icon(Icons.map)),
                    const IconButton(
                        iconSize: 32,
                        onPressed: null,
                        icon: Icon(Icons.maps_home_work))
                  ],
                ),
              ),
            ),
          ),
        )
      ]),
    );
  }

  Future<void> _makePhoneCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: widget.owner.phone,
    );
    await launchUrl(launchUri);
  }

  Future<void> _makeSmS() async {
    final Uri launchUri = Uri(
      scheme: 'sms',
      path: widget.owner.phone,
    );
    await launchUrl(launchUri);
  }

  Future<void> _onRoute() async {
    final Uri launchUri = Uri(
        scheme: 'https',
        // ignore: prefer_interpolation_to_compose_strings
        path: "www.google.com/maps/@" +
            widget.homestay.homestayLat.toString() +
            "," +
            widget.homestay.homestayLng.toString() +
            "20z");
    await launchUrl(launchUri);
  }

  openwhatsapp() async {
    var whatsapp = widget.owner.phone;
    var whatsappURlAndroid = "whatsapp://send?phone=$whatsapp&text=hello";
    var whatappURLIos = "https://wa.me/$whatsapp?text=${Uri.parse("hello")}";
    if (Platform.isIOS) {
      // for iOS phone only
      if (await canLaunch(whatappURLIos)) {
        await launch(whatappURLIos, forceSafariVC: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("whatsapp not installed")));
      }
    } else {
      // android , web
      if (await canLaunch(whatsappURlAndroid)) {
        await launch(whatsappURlAndroid);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("whatsapp not installed")));
      }
    }
  }

  int generateIds() {
    var rng = Random();
    int randomInt;
    randomInt = rng.nextInt(100);
    return randomInt;
  }

  // void _onShowMap() {
  //   double lat = double.parse(widget.homestay.homestayLat.toString());
  //   double lng = double.parse(widget.homestay.homestayLng.toString());
  //   Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  //   int markerIdVal = generateIds();
  //   MarkerId markerId = MarkerId(markerIdVal.toString());
  //   final Marker marker = Marker(
  //     markerId: markerId,
  //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
  //     position: LatLng(
  //       lat,
  //       lng,
  //     ),
  //   );
  //   markers[markerId] = marker;

  //   CameraPosition campos = CameraPosition(
  //     target: LatLng(lat, lng),
  //     zoom: 16.4746,
  //   );
  //   Completer<GoogleMapController> ncontroller =
  //       Completer<GoogleMapController>();

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: const RoundedRectangleBorder(
  //             borderRadius: BorderRadius.all(Radius.circular(10.0))),
  //         title: const Text(
  //           "Location",
  //           style: TextStyle(),
  //         ),
  //         content: SizedBox(
  //           //color: Colors.red,
  //           height: screenHeight,
  //           width: screenWidth,
  //           child: GoogleMap(
  //             mapType: MapType.satellite,
  //             initialCameraPosition: campos,
  //             markers: Set<Marker>.of(markers.values),
  //             onMapCreated: (GoogleMapController controller) {
  //               ncontroller.complete(controller);
  //             },
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text(
  //               "Close",
  //               style: TextStyle(),
  //             ),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
