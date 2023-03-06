// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:golfguidescorecard/clubes/clubGolfGuide.dart';
// import 'package:golfguidescorecard/herramientas/myClipper.dart';
// import 'package:golfguidescorecard/mod_serv/model.dart';
// import 'package:golfguidescorecard/mod_serv/servicesApp.dart';
// import 'package:page_transition/page_transition.dart';
// import 'dart:async';
// import 'package:recase/recase.dart';
//
// class ListaLeaderboard extends StatefulWidget {
//   @override
//   ListaLeaderboardState createState() => ListaLeaderboardState();
// }
//
// class Debouncer {
//   final int milliseconds;
//   VoidCallback action;
//   Timer _timer;
//
//   Debouncer({this.milliseconds});
//
//   run(VoidCallback action) {
//     if (null != _timer) {
//       _timer.cancel();
//     }
//     _timer = Timer(Duration(milliseconds: milliseconds), action);
//   }
// }
//
// class ListaLeaderboardState extends State<ListaLeaderboard> {
//   List<PostClub> _employees;
//
//   List<PostClub> _filterEmployees;
//   GlobalKey<ScaffoldState> _scaffoldKey;
//
//   final _debouncer = Debouncer(milliseconds: 500);
//
//   @override
//   void initState() {
//     super.initState();
//     _employees = [];
//     _filterEmployees = [];
//     _scaffoldKey = GlobalKey(); // key to get the context to show a SnackBar
//     _getPosts();
//   }
//
//   _getPosts() {
//     ServicesClubBusca.getPosts().then((employees) {
//       setState(() {
//         _employees = employees;
//         _filterEmployees = employees;
//       });
//       print("Length ${employees.length}");
//       print(employees);
//       print(
//           '<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<employees>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
//     });
//   }
//
//   // UI
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         backgroundColor: Color(0xFFE1E1E1),
//         appBar: PreferredSize(
//           preferredSize: Size.fromHeight(300),
//           child: SingleChildScrollView(
//             child: Column(
//               children: <Widget>[
//                 ClipPath(
//                   clipper: MyClipper(),
//                   child: Container(
//                     padding: EdgeInsets.all(50.0),
//                     height: 330.0,
//                     decoration: BoxDecoration(
//                       color: Color(0xFF1f2f50),
// //                      color: Color(0xFFFF0030),
//                       image: DecorationImage(
//                           image: AssetImage('assets/clubes/logoblanco.png'),
//                           fit: BoxFit.contain),
//                     ),
//                   ),
//                 ),
//                 Stack(
//                   children: <Widget>[
//                     Container(
//                       child: Image.asset('assets/jugadores/fondoClub1.jpg',
//                           fit: BoxFit.fill),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             children: <Widget>[
//               searchField(),
//               listaCanchas(),
//             ],
//           ),
//         ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
//         floatingActionButton: FloatingActionButton(
//           child: Icon(Icons.keyboard_arrow_left, size: 40,), backgroundColor: Colors.black,
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//         bottomNavigationBar: CurvedNavigationBar(
//           index: 0,
//           height: 61.0,
//           items: <Widget>[
//             IconButton(
//               icon: Icon(Icons.golf_course, size: 30, color: Colors.white),
//             ),
//           ],
//           color: Color(0xFF1f2f50),
//           buttonBackgroundColor: Color(0xFF1f2f50),
//           backgroundColor: Colors.transparent,
//           animationCurve: Curves.easeInOut,
//           animationDuration: Duration(milliseconds: 600),
//         ),
//       ),
//     );
//   }
//
//   ///////SEARCH BUSCADOR BASE
//
//   searchField() {
//     return Padding(
//       padding: EdgeInsets.only(top: 30, left: 25, right: 25),
//       child: Container(
//         padding: EdgeInsets.only(left: 20, bottom: 5),
//         color: Colors.black12,
//         child: TextField(
//             decoration: InputDecoration(
//                 contentPadding: EdgeInsets.all(0),
//                 icon: Icon(
//                   Icons.golf_course,
//                   color: Colors.black54,
//                   size: 30,
//                 ),
//                 hintText: 'BUSCAR TORNEO',
//                 hintStyle: TextStyle(
//                   fontSize: 12,
//                   color: Colors.black54,
//                 )),
//             onChanged: (string) {
//               _debouncer.run(() {
//                 setState(() {
//                   _filterEmployees = _employees
//                       .where((u) => (u.nombre
//                               .toLowerCase()
//                               .contains(string.toLowerCase()) ||
//                           u.nombre
//                               .toLowerCase()
//                               .contains(string.toLowerCase())))
//                       .toList();
//                   if (_filterEmployees.length == _employees.length) {
//                     _filterEmployees = [];
//                   }
//                 });
//               });
//             }),
//       ),
//     );
//   }
//
//   listaCanchas() {
//     return Column(
//       children: <Widget>[
//         SingleChildScrollView(
//           child: DataTable(
//             columnSpacing: 5,
//             horizontalMargin: 20,
//             headingRowHeight: 5,
//             dataRowHeight: 90,
//             columns: [
//               DataColumn(
//                 label: Text(''),
//               ),
//             ],
//             rows: _filterEmployees
//                 .map(
//                   (employee) => DataRow(cells: [
//                     DataCell(
//                       Align(
//                         child:
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               "${employee.nombre.trim().toLowerCase().titleCase}",
//                               textScaleFactor: 1,
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 color: Colors.black,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                             RichText(
//                               textScaleFactor: 1,
//                               text: TextSpan(
//                                 text:
//                                 "${employee.id_localidad.trim() ?? ''} | ",
//                                 style: TextStyle(
//                                     fontSize: 14, color: Color(0xFF016b69)),
//                                 children: <TextSpan>[
//                                   TextSpan(
//                                     text: "${employee.id_provincia.trim()}",
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Color(0xFF1f2f50),
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           PageTransition(
//                             type: PageTransitionType.fade,
//                             child: ClubesGG(
//                               postClubGG: employee,
// //                              postJuga: employee,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ]),
//                 )
//                 .toList(),
//           ),
//         ),
//       ],
//     );
//   }
// }