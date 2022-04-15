import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController mapController;
  List<Marker> myMarkers = [];
  String searchAddr;

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }

  @override
  void initState() {
    _getUserLocation();
    polylinePoints = PolylinePoints();
    super.initState();
  }

  searchandNavigate() {
    locationFromAddress(searchAddr).then((result) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(result[0].latitude, result[0].longitude),
          zoom: 12.0)));
      setState(() {
        // print("markerlength${myMarkers.length}");
        destinationPosition = LatLng(result[0].latitude, result[0].longitude);
        myMarkers.add(Marker(
            markerId: MarkerId(
                LatLng(result[0].latitude, result[0].longitude).toString()),
            position: LatLng(result[0].latitude, result[0].longitude),
            draggable: true,
            onDragEnd: (dragPosition) {
              print(dragPosition);
            }));
        print("markerlength${myMarkers.length}");
        setPolylines();
      });
    });
  }

  LatLng currentPostion;
  LatLng destinationPosition;
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;

  void setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyAZRFhQ6Vngbskq0LvzIr2lLhRAJY-N32Y",
        PointLatLng(currentPostion.latitude, currentPostion.longitude),
        PointLatLng(
            destinationPosition.latitude, destinationPosition.longitude));

    if (result.status == 'OK') {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        _polylines.add(Polyline(
            width: 10,
            polylineId: PolylineId('polyLine'),
            color: Color(0xFF08A5CB),
            points: polylineCoordinates));
      });
    }
  }

  void _getUserLocation() async {
    var position = await GeolocatorPlatform.instance
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentPostion = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 20.0)));
    });
  }

  void onHandle(LatLng coordinates) {
    // myMarkers = [];
    setState(() {
      myMarkers.add(Marker(
          markerId: MarkerId(coordinates.toString()),
          position: coordinates,
          draggable: true,
          onDragEnd: (dragPosition) {
            print(dragPosition);
          }));
    });
  }

  @override
  Widget build(BuildContext context) {
    print("currentPostion$currentPostion");
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
                myLocationEnabled: true,
                // myLocationButtonEnabled: true,
                onMapCreated: onMapCreated,
                onTap: onHandle,
                polylines: _polylines,
                markers: Set.from(myMarkers),
                initialCameraPosition: CameraPosition(
                    target: LatLng(40.7128, -74.0060), zoom: 10.0)),
            Positioned(
              top: 15.0,
              right: 15.0,
              left: 15.0,
              child: Container(
                height: 50.0,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white),
                child: TextField(
                  decoration: InputDecoration(
                      hintText: 'Enter Address',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                      suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: searchandNavigate,
                          iconSize: 30.0)),
                  onChanged: (val) {
                    setState(() {
                      searchAddr = val;
                    });
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
