// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:googlemap_tracking/consts.dart';
// import 'package:location/location.dart';

// class MapPage extends StatefulWidget {
//   const MapPage({super.key});

//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   Location _locationController= new Location();
  
//   final Completer<GoogleMapController> _mapController = 
//   Completer<GoogleMapController>();

//   static LatLng _pGoogleplex = const LatLng(10.9611201, 78.0739596);
//   static LatLng _AppleParl = const LatLng(10.9651039, 78.0851220);

//   LatLng? _CurrentPosition=null;

//   Map<PolylineId,Polyline> polylines={};

// @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     GetLocationUpdates().then((_)=> {
//      getpolylinePoints().then((coordinates)=>{
//       GenratePolyLineFromPoints(coordinates)

//      })
    
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//     body:_CurrentPosition==null?
//     const Center(child: const CircularProgressIndicator(),)
//     : GoogleMap(
//      onMapCreated: ((GoogleMapController controller)=>
//      _mapController.complete(controller)),

//     initialCameraPosition: CameraPosition(target: _pGoogleplex,zoom: 13),
//     markers: {
//         Marker(
//     markerId: const MarkerId("_CurrentLoction"),
//     icon: BitmapDescriptor.defaultMarker,
//     position: _CurrentPosition!),

//     Marker(
//     markerId: const MarkerId("_SourceLoction"),
//     icon: BitmapDescriptor.defaultMarker,
//     position: _pGoogleplex),
//        Marker(
//     markerId: const MarkerId("_destinayionLoction"),
//     icon: BitmapDescriptor.defaultMarker,
//     position: _AppleParl)
//     },
//     polylines:Set<Polyline>.of(polylines.values),
//     ),
//     );
//   }

//   //point thre camera

//   Future<void> _CameraPosition(LatLng pos)async{
//    final GoogleMapController controller = await _mapController.future;
//    CameraPosition _newCameraPosition = CameraPosition(
//     target: pos,
//     zoom: 13
//     );
//     await controller.animateCamera(
//       CameraUpdate.newCameraPosition(_newCameraPosition));
//   }


//   Future<void> GetLocationUpdates()async{
//     bool _ServiceEnabled;
//     PermissionStatus _permissionGranted;

//     _ServiceEnabled = await _locationController.serviceEnabled();
//     if (_ServiceEnabled) {
//       _ServiceEnabled=await _locationController.requestService();
//     }
//     else{
//       return;
//     }

//   _permissionGranted= await _locationController.hasPermission();
//   if (_permissionGranted== PermissionStatus.denied) {
//     _permissionGranted= await _locationController.requestPermission();
//     if (_permissionGranted !=PermissionStatus.granted) {
//       return;
//     }
//   }

//   _locationController.onLocationChanged.listen((LocationData currentLocation){
//    if (currentLocation.latitude!= null &&
//       currentLocation.longitude!=null
//    ) {
//      setState(() {
//        _CurrentPosition=LatLng(currentLocation.latitude!, currentLocation.longitude!);
//       _CameraPosition(_CurrentPosition!);
//      });
//    }
//   });
//   }

//   //polyline
//   Future<List<LatLng>> getpolylinePoints()async{
//     List<LatLng> polylineCoordinates =[];
//     PolylinePoints polylinePoints = PolylinePoints();
//     PolylineResult result =  await polylinePoints.getRouteBetweenCoordinates(
//     googleApiKey: GOOGLE_MAPS_API_KEY,
//     request:PolylineRequest(
//     origin: PointLatLng(_pGoogleplex.latitude, _pGoogleplex.longitude), 
//     destination: PointLatLng(_AppleParl.latitude, _AppleParl.longitude),
//      mode: TravelMode.driving
//   ));
//   if (result.points.isNotEmpty) {
//     result.points.forEach((PointLatLng point){
//       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//     });
//   }
//   else{
//     print(result.errorMessage);
//   }
//   return polylineCoordinates;

//   }
// //

// void GenratePolyLineFromPoints(List<LatLng> polylineCoordinates)async{
//   PolylineId id= const PolylineId("poly");
//   Polyline polyline = Polyline(polylineId:id,color: Colors.pink,points: polylineCoordinates,width: 8);
//   setState(() {
//     polylines[id]=polyline;
//   });
// }
// }









// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class MapPage extends StatefulWidget {
//   const MapPage({super.key});

//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   Location _locationController = Location();
//   final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

//   LatLng? _CurrentPosition;
//   LatLng? _StartPosition; // First recorded position (where user starts moving)
  
//   Map<PolylineId, Polyline> polylines = {};
//   List<LatLng> _userPath = []; // Store user travel path

//   BitmapDescriptor? startIcon; // Custom marker for start position

//   @override
//   void initState() {
//     super.initState();
//     loadCustomMarker();
//     loadUserPath().then((_) {
//       GetLocationUpdates();
//     });
//   }

//   // Load Custom Marker for Start Position
// Future<void> loadCustomMarker() async {
//   setState(() {
//     startIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
//   });
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("User Travel Path"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete),
//             onPressed: () => clearUserPath(),
//           )
//         ],
//       ),
//       body: _CurrentPosition == null
//           ? const Center(child: CircularProgressIndicator())
//           : GoogleMap(
//               onMapCreated: (GoogleMapController controller) =>
//                   _mapController.complete(controller),
//               initialCameraPosition: CameraPosition(target: _CurrentPosition!, zoom: 13),
//               markers: {
//                 if (_StartPosition != null)
//                   Marker(
//                     markerId: const MarkerId("_StartPosition"),
//                     icon: startIcon ?? BitmapDescriptor.defaultMarker,
//                     position: _StartPosition!,
//                   ),
//                 Marker(
//                   markerId: const MarkerId("_CurrentLocation"),
//                   icon: BitmapDescriptor.defaultMarker,
//                   position: _CurrentPosition!,
//                 ),
//               },
//               polylines: Set<Polyline>.of(polylines.values),
//             ),
//     );
//   }

//   Future<void> _CameraPosition(LatLng pos) async {
//     final GoogleMapController controller = await _mapController.future;
//     CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 13);
//     await controller.animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
//   }

//   Future<void> GetLocationUpdates() async {
//     bool _ServiceEnabled;
//     PermissionStatus _permissionGranted;

//     _ServiceEnabled = await _locationController.serviceEnabled();
//     if (!_ServiceEnabled) {
//       _ServiceEnabled = await _locationController.requestService();
//       if (!_ServiceEnabled) return;
//     }

//     _permissionGranted = await _locationController.hasPermission();
//     if (_permissionGranted == PermissionStatus.denied) {
//       _permissionGranted = await _locationController.requestPermission();
//       if (_permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }

//     _locationController.onLocationChanged.listen((LocationData currentLocation) {
//       if (currentLocation.latitude != null && currentLocation.longitude != null) {
//         setState(() {
//           _CurrentPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);

//           // If Start Position is not set, set it to the first location
//           if (_StartPosition == null) {
//             _StartPosition = _CurrentPosition;
//             saveStartPosition(); // Save Start Position for persistence
//           }

//           _userPath.add(_CurrentPosition!);
//           saveUserPath();
//           _CameraPosition(_CurrentPosition!);
//           GenratePolyLineFromPoints(_userPath);
//         });
//       }
//     });
//   }

//   // Save User Travel Path
//   Future<void> saveUserPath() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String> stringList = _userPath
//         .map((e) => jsonEncode({'lat': e.latitude, 'lng': e.longitude}))
//         .toList();
//     await prefs.setStringList('user_path', stringList);
//   }

//   // Save Start Position
//   Future<void> saveStartPosition() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     if (_StartPosition != null) {
//       await prefs.setString('start_position', jsonEncode({
//         'lat': _StartPosition!.latitude,
//         'lng': _StartPosition!.longitude,
//       }));
//     }
//   }

//   // Load User Travel Path and Start Position
//   Future<void> loadUserPath() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();

//     // Load Start Position
//     String? startPosString = prefs.getString('start_position');
//     if (startPosString != null) {
//       final decoded = jsonDecode(startPosString);
//       _StartPosition = LatLng(decoded['lat'], decoded['lng']);
//     }

//     // Load User Path
//     List<String>? stringList = prefs.getStringList('user_path');
//     if (stringList != null) {
//       _userPath = stringList.map((e) {
//         final decoded = jsonDecode(e);
//         return LatLng(decoded['lat'], decoded['lng']);
//       }).toList();
// print("polyline:$stringList");
//       if (_userPath.isNotEmpty) {
//         setState(() {
//           _CurrentPosition = _userPath.last;
//           GenratePolyLineFromPoints(_userPath);
//         });
//       }
//     }
//   }

//   // Clear User Travel Path and Start Position
//   Future<void> clearUserPath() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.remove('user_path');
//     await prefs.remove('start_position');
//     setState(() {
//       _userPath.clear();
//       polylines.clear();
//       _CurrentPosition = null;
//       _StartPosition = null;
//     });
//   }

//   // Generate Polyline
//   void GenratePolyLineFromPoints(List<LatLng> polylineCoordinates) {
//     PolylineId id = const PolylineId("poly");
//     Polyline polyline = Polyline(
//       polylineId: id,
//       color: Colors.pink,
//       points: polylineCoordinates,
//       width: 8,
//     );
//     setState(() {
//       polylines[id] = polyline;
//     });
//   }
// }




import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  LatLng? _CurrentPosition;
  LatLng? _StartPosition; // First recorded position (where user starts moving)
  
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> _userPath = []; // Store user travel path

  BitmapDescriptor? startIcon; // Custom marker for start position

  @override
  void initState() {
    super.initState();
    loadCustomMarker();
    loadUserPath().then((_) {
      GetLocationUpdates();
    });
    _enableWakelock();

  }
    Future<void> _enableWakelock() async {
    try {
      await WakelockPlus.enable();
    } catch (e) {
      print('Error enabling wakelock: $e');
    }
  }

  // Load Custom Marker for Start Position
  Future<void> loadCustomMarker() async {
    setState(() {
      startIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Travel Path"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => clearUserPath(),
          )
        ],
      ),
      body: _CurrentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) =>
                  _mapController.complete(controller),
              initialCameraPosition: CameraPosition(
                target: _CurrentPosition ?? const LatLng(0, 0), // Prevent null errors
                zoom: 13,
              ),
              markers: {
                if (_StartPosition != null)
                  Marker(
                    markerId: const MarkerId("_StartPosition"),
                    icon: startIcon ?? BitmapDescriptor.defaultMarker,
                    position: _StartPosition!,
                  ),
                if (_CurrentPosition != null)
                  Marker(
                    markerId: const MarkerId("_CurrentLocation"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: _CurrentPosition!,
                  ),
              },
              polylines: Set<Polyline>.of(polylines.values),
            ),
    );
  }

  Future<void> _CameraPosition(LatLng? pos) async {
    if (pos == null) return; // Prevent null errors
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 13);
    await controller.animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }

Future<void> GetLocationUpdates() async {
  bool _ServiceEnabled;
  PermissionStatus _permissionGranted;

  _ServiceEnabled = await _locationController.serviceEnabled();
  if (!_ServiceEnabled) {
    _ServiceEnabled = await _locationController.requestService();
    if (!_ServiceEnabled) return;
  }

  _permissionGranted = await _locationController.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await _locationController.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }

  // Enable background mode
  await _locationController.enableBackgroundMode(enable: true);

  _locationController.onLocationChanged.listen((LocationData currentLocation) {
    if (currentLocation.latitude != null && currentLocation.longitude != null) {
      setState(() {
        _CurrentPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);

        if (_StartPosition == null) {
          _StartPosition = _CurrentPosition;
          saveStartPosition();
        }

        _userPath.add(_CurrentPosition!);
        saveUserPath();
        _CameraPosition(_CurrentPosition!);
        GenratePolyLineFromPoints(_userPath);
      });
    }
  });
}


  // Save User Travel Path
  Future<void> saveUserPath() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> stringList = _userPath
        .map((e) => jsonEncode({'lat': e.latitude, 'lng': e.longitude}))
        .toList();
    await prefs.setStringList('user_path', stringList);
  }

  // Save Start Position
  Future<void> saveStartPosition() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_StartPosition != null) {
      await prefs.setString('start_position', jsonEncode({
        'lat': _StartPosition!.latitude,
        'lng': _StartPosition!.longitude,
      }));
    }
  }

  // Load User Travel Path and Start Position
  Future<void> loadUserPath() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load Start Position
    String? startPosString = prefs.getString('start_position');
    if (startPosString != null) {
      final decoded = jsonDecode(startPosString);
      _StartPosition = LatLng(decoded['lat'], decoded['lng']);
    }

    // Load User Path
    List<String>? stringList = prefs.getStringList('user_path');
    if (stringList != null) {
      _userPath = stringList.map((e) {
        final decoded = jsonDecode(e);
        return LatLng(decoded['lat'], decoded['lng']);
      }).toList();

      if (_userPath.isNotEmpty) {
        setState(() {
          _CurrentPosition = _userPath.last;
          GenratePolyLineFromPoints(_userPath);
        });
      }
    }
  }

  // Clear User Travel Path and Start Position
  Future<void> clearUserPath() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_path');
    await prefs.remove('start_position');

    setState(() {
      _userPath.clear();
      polylines.clear();
      _StartPosition = null;
      _CurrentPosition = const LatLng(0, 0); // Default instead of null
    });

    _CameraPosition(_CurrentPosition);
  }

  // Generate Polyline
  void GenratePolyLineFromPoints(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.pink,
      points: polylineCoordinates,
      width: 8,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }
}

