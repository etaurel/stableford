import 'dart:io';

/// MY APP SCORING GOLF GUIDE PRO

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:golfguidescorecard/herramientas/bottonNavigator.dart';
import 'package:golfguidescorecard/mod_serv/model.dart';
import 'package:golfguidescorecard/loginhttp/home.dart';
import 'package:golfguidescorecard/models/postTorneo.dart';
import 'package:golfguidescorecard/scoresCard/torneo.dart';
import 'package:golfguidescorecard/services/db-admin.dart';
import 'package:golfguidescorecard/services/db-local.dart';
import 'package:golfguidescorecard/utilities/fecha.dart';
import 'package:golfguidescorecard/utilities/global-data.dart';
import 'package:golfguidescorecard/utilities/seguridad.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:page_transition/page_transition.dart';
import 'package:golfguidescorecard/mod_serv/servicesApp.dart';
import 'package:golfguidescorecard/utilities/Utilities.dart';
import 'package:admob_flutter/admob_flutter.dart';

import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';

String scoreCardStbType = "scoreCardStb"; // por defecto

int hcpStbTorneo = 0; // valor inicial

void setHcpStbTorneo(String scoreCardStbType, int hcpTorneo) {
  if (scoreCardStbType == "scoreCardStb") {
    hcpStbTorneo = (hcpTorneo * 0.85).round();
  } else if (scoreCardStbType == "scoreCardStb2") {
    hcpStbTorneo = hcpTorneo.round();
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Admob.initialize();

  // obtener la hora actual
  final now = DateTime.now();

  // establecer la hora en que se debe ejecutar la acción
  final scheduledTime = DateTime(now.year, now.month, now.day, 23, 58, 0); // por ejemplo, a las 1 am

  // calcular el tiempo hasta la hora programada
  final duration = scheduledTime.difference(now);

  // crear un temporizador que se ejecute después de la duración calculada
  Timer(duration, () {
    // aquí puedes colocar la acción que deseas realizar a la hora programada
    exit(0);
  });


  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primaryColor: const Color(0xFF000000),
      ),
      home: MyApp()
  ));
}

class MyApp extends StatefulWidget {
  Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // Si la conexión es a través de datos móviles, se verifica la conexión de datos móviles con DataConnectionChecker
      return await DataConnectionChecker().hasConnection;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // Si la conexión es a través de WiFi, se verifica la conexión de WiFi
      return true;
    }
    // Si no hay conexión o la conexión es desconocida, se considera que no hay conexión
    return false;
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformImei = 'Unknown';
  String uniqueId = "Unknown";

  AdmobInterstitial interstitialAd;

  @override
  void initState() {
    super.initState();
    interstitialAd = AdmobInterstitial(adUnitId: "ca-app-pub-3940256099942544/4411468910",
        listener: (AdmobAdEvent event, Map<String, dynamic> args){
          if (event == AdmobAdEvent.closed) {
            interstitialAd.load();
          }
        });
    interstitialAd.load();

    initializeDateFormatting('es'); // This will initialize Spanish locale
    initPlatformState();
    Future.delayed(
      Duration(seconds: 5),
          () {
        print('main, despues del delay de 3seg ${GlobalData.isWorkUrlPubli}');
        if(GlobalData.isWorkUrlPubli ?? false) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Publi(),
            ),
          );
        } else {

          if (GlobalData.postUser == null) {
            initSecurity('to Login');
            Navigator.pushReplacement(
              context,
              PageTransition(
                ctx: context,
                type: PageTransitionType.fade,
                child: LoginHttp (),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              PageTransition(
                ctx: context,
                type: PageTransitionType.fade,
                child: BottonNav(),
              ),
            );
          }
        }
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: new Container(
          color: Color(0xFF1f2f50),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 350,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/clubes/logoblanco.png'),
                      fit: BoxFit.fitWidth),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                height: 40,
              ),
              CircularProgressIndicator(
                backgroundColor: Color(0xFF1f2f50),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Text('GOLF PRO 1.0',
                  style: TextStyle(color: Colors.white, fontSize: 20),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // print('************ SALIENDO DE LA APP ***********');
    // GlobalData.dbConn.closeDB();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {

      DBLocal dbConn = DBLocal();
      GlobalData.dbConn = dbConn;
      print(dbConn);

      PostUser postUserPru = await GlobalData.dbConn.dbUserGet();
      if (postUserPru != null) {
        // envia el token a la api para verificar
        if (await verifySecurity(postUserPru)==false){
          postUserPru=null;
        }
      }

      if (postUserPru == null) {
        initSecurity('to Login');
      } else {
        GlobalData.postUser = postUserPru;

        print(GlobalData.postUser.matricula);
        actualizaHcpLs();
        print(
            '*********INGRESANDO POR DATOS PERSISTENTES**************************************');
        List<PostTorneo> postUserTorneos = await Torneo.getTorneos( GlobalData.postUser.matricula, Fecha.fechaHoy );
        GlobalData.postUserTorneos = postUserTorneos;

        List<DataJugadorScore> dataJS = await DBAdmin.getTarjetaJuego( GlobalData.postUser.matricula, Fecha.fechaHoy );
        Torneo.dataJugadoresScore = dataJS;

        if (dataJS == null) {
          //ver
        } else {
          PostTorneo postTorneo = await DBAdmin.dbTorneoGet(dataJS[0].idTorneo);
          Torneo.postTorneoJuego = postTorneo;
        }
        initSecurity('login by local data');
        print('*********INGRESANDO a Usuarios **************************************');
      }

      GlobalData.dispositivoPlatformImei = await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
      GlobalData.dispositivoIdUnique = await ImeiPlugin.getId();
      print(' ************************************----------------> ${GlobalData.dispositivoPlatformImei}');
      print(' ************************************----------------> ${GlobalData.dispositivoIdUnique}');

      // verifico si tengo conexion a la ruta de la publicidad http://scoring.com.ar/app/images/publi/scoringpro/publi_home.jpg
      GlobalData.isWorkUrlPubli = await ServicesScoring.isWorkUrlPubli();
      print('---------------- ScoringServerOnline ${GlobalData.isWorkUrlPubli}');

    } on PlatformException {
      GlobalData.dispositivoPlatformImei = 'Failed to get platform version.';
    }
  }

}

class Publi extends StatefulWidget {
  _PubliState createState() => _PubliState();
}

class _PubliState extends State<Publi> {
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer(Duration(seconds: 6), () {
      _initSCApp(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }



  @override
  Widget build(BuildContext context) {
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    // ]);

    return WillPopScope(
      onWillPop: () {
        if(Navigator.canPop(context)) {
          Navigator.pop(context);
          return Future.value(false);
        } else {
          return Utilities.onWillPop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        height: 800,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(
                                  'http://scoring.com.ar/app/images/publi/scoringpro/publi_home.jpg'),
                              fit: BoxFit.contain),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  GestureDetector(
                      child: Container(
                        color: Colors.cyanAccent,
                        alignment: Alignment.center,
                        height: 25,
                        width: 80,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 20,
                            ),
                            Text(
                              'Continuar',
                              style: TextStyle(fontSize: 12, color: Colors.black),
                              textScaleFactor: 1,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        timer.cancel();
                        _initSCApp(context);
                      }
                  ),
                  Container(
                    height: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initSCApp(BuildContext context) async {

    if (GlobalData.postUser == null) {
      initSecurity('to Login');
      Navigator.pushReplacement(
        context,
        PageTransition(
          ctx: context,
          type: PageTransitionType.fade,
          child: LoginHttp(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageTransition(
          ctx: context,
          type: PageTransitionType.fade,
          child: BottonNav(),
        ),
      );
    }
  }
}

// /// MY APP SCORING GOLF GUIDE PRO
//
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:flutter/services.dart';
// import 'package:golfguidescorecard/herramientas/bottonNavigator.dart';
// import 'package:golfguidescorecard/mod_serv/model.dart';
// import 'package:golfguidescorecard/loginhttp/home.dart';
// import 'package:golfguidescorecard/models/postTorneo.dart';
// import 'package:golfguidescorecard/scoresCard/torneo.dart';
// import 'package:golfguidescorecard/services/db-admin.dart';
// import 'package:golfguidescorecard/services/db-local.dart';
// import 'package:golfguidescorecard/utilities/fecha.dart';
// import 'package:golfguidescorecard/utilities/global-data.dart';
// import 'package:golfguidescorecard/utilities/seguridad.dart';
// import 'package:imei_plugin/imei_plugin.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:page_transition/page_transition.dart';
// import 'package:golfguidescorecard/mod_serv/servicesApp.dart';
// import 'package:golfguidescorecard/utilities/Utilities.dart';
// import 'package:admob_flutter/admob_flutter.dart';
//
// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   Admob.initialize();
//
//   runApp(MaterialApp(
//     debugShowCheckedModeBanner: false,
//     theme: new ThemeData(
//       primaryColor: const Color(0xFF000000),
//     ),
//     home: MyApp()
//   ));
// }
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   String _platformImei = 'Unknown';
//   String uniqueId = "Unknown";
//
//   AdmobInterstitial interstitialAd;
//
//   @override
//   void initState() {
//     super.initState();
//
//     initializeDateFormatting('es'); // This will initialize Spanish locale
//     initPlatformState();
//
//     Future.delayed(
//       Duration(seconds: 4),
//       () {
//         //   print('main, despues del delay de 3seg ${GlobalData.isWorkUrlPubli}');
//         //   if(GlobalData.isWorkUrlPubli ?? false) {
//         //     Navigator.pushReplacement(
//         //       context,
//         //       MaterialPageRoute(
//         //         builder: (context) => Publi(),
//         //       ),
//         //     );
//         //   } else {
//         //     if (GlobalData.postUser == null) {
//         //       initSecurity('to Login');
//         //       Navigator.pushReplacement(
//         //         context,
//         //         PageTransition(
//         //           ctx: context,
//         //           type: PageTransitionType.fade,
//         //           child: LoginHttp (),
//         //         ),
//         //       );
//         //     } else {
//         //       Navigator.pushReplacement(
//         //         context,
//         //         PageTransition(
//         //           ctx: context,
//         //           type: PageTransitionType.fade,
//         //           child: BottonNav(),
//         //         ),
//         //       );
//         //     }
//         //   }
//         // },
//         if (GlobalData.isWorkUrlPubli ?? false) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => Publi( ),
//             ),
//           );
//         } else if (GlobalData.postUser == null) {
//           initSecurity( 'to Login' );
//           Navigator.pushReplacement(
//             context,
//             PageTransition(
//               ctx: context,
//               type: PageTransitionType.fade,
//               child: LoginHttp( ),
//             ),
//           );
//         } else {
//           Navigator.pushReplacement(
//             context,
//             PageTransition(
//               ctx: context,
//               type: PageTransitionType.fade,
//               child: BottonNav( ),
//             ),
//           );
//         }
//       }
//     );
//
//     interstitialAd = AdmobInterstitial(adUnitId: "ca-app-pub-3940256099942544/4411468910",
//         listener: (AdmobAdEvent event, Map<String, dynamic> args){
//           if (event == AdmobAdEvent.closed) {
//             interstitialAd.load();
//           }
//         });
//     interstitialAd.load();
//
//   }
//
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Center(
//           child: new Container(
//             color: Color(0xFF1f2f50),
//             child: Column(
//               mainAxisSize: MainAxisSize.max,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Container(
//                   height: 350,
//                   decoration: BoxDecoration(
//                     image: DecorationImage(
//                         image: AssetImage('assets/clubes/logoblanco.png'),
//                         fit: BoxFit.fitWidth),
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.all(10),
//                   height: 40,
//                 ),
//                 CircularProgressIndicator(
//                   backgroundColor: Color(0xFF1f2f50),
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//                 Container(
//                   padding: EdgeInsets.all(10),
//                   child: Text('GOLF PRO 1.0',
//                     style: TextStyle(color: Colors.white, fontSize: 20),),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//   }
//
//   @override
//   void dispose() {
//     // print('************ SALIENDO DE LA APP ***********');
//     // GlobalData.dbConn.closeDB();
//     super.dispose();
//   }
//
//   Future<void> initPlatformState() async {
//         // Platform messages may fail, so we use a try/catch PlatformException.
//     try {
//
//       DBLocal dbConn = DBLocal();
//       GlobalData.dbConn = dbConn;
//       print(dbConn);
//
//       PostUser postUserPru = await GlobalData.dbConn.dbUserGet();
//       if (postUserPru != null) {
//         // envia el token a la api para verificar
//         if (await verifySecurity(postUserPru)==false){
//           postUserPru=null;
//         }
//       }
//
//       if (postUserPru == null) {
//         initSecurity('to Login');
//       } else {
//         GlobalData.postUser = postUserPru;
//
//         print(GlobalData.postUser.matricula);
//         actualizaHcpLs();
//         print(
//             '*********INGRESANDO POR DATOS PERSISTENTES**************************************');
//         List<PostTorneo> postUserTorneos = await Torneo.getTorneos( GlobalData.postUser.matricula, Fecha.fechaHoy );
//         GlobalData.postUserTorneos = postUserTorneos;
//
//         List<DataJugadorScore> dataJS = await DBAdmin.getTarjetaJuego( GlobalData.postUser.matricula, Fecha.fechaHoy );
//         Torneo.dataJugadoresScore = dataJS;
//
//         if (dataJS == null) {
//           //ver
//         } else {
//           PostTorneo postTorneo = await DBAdmin.dbTorneoGet(dataJS[0].idTorneo);
//           Torneo.postTorneoJuego = postTorneo;
//         }
//         initSecurity('login by local data');
//         print('*********INGRESANDO a Usuarios **************************************');
//       }
//
//       GlobalData.dispositivoPlatformImei = await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
//       GlobalData.dispositivoIdUnique = await ImeiPlugin.getId();
//       print(' ************************************----------------> ${GlobalData.dispositivoPlatformImei}');
//       print(' ************************************----------------> ${GlobalData.dispositivoIdUnique}');
//
//       // verifico si tengo conexion a la ruta de la publicidad http://scoring.com.ar/app/images/publi/scoringpro/publi_home.jpg
//       GlobalData.isWorkUrlPubli = await ServicesScoring.isWorkUrlPubli();
//       print('---------------- ScoringServerOnline ${GlobalData.isWorkUrlPubli}');
//
//     } on PlatformException {
//       GlobalData.dispositivoPlatformImei = 'Failed to get platform version.';
//     }
//   }
//
// }
//
// class Publi extends StatefulWidget {
//   _PubliState createState() => _PubliState();
// }
//
// class _PubliState extends State<Publi> {
//   Timer timer;
//
//   @override
//   void initState() {
//     super.initState();
//     timer = Timer(Duration(seconds: 6), () {
//       _initSCApp(context);
//     });
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     timer.cancel();
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     // SystemChrome.setPreferredOrientations([
//     //   DeviceOrientation.portraitUp,
//     // ]);
//
//     return WillPopScope(
//       onWillPop: () {
//         if(Navigator.canPop(context)) {
//           Navigator.pop(context);
//           return Future.value(false);
//         } else {
//           return Utilities.onWillPop(context);
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(
//             child: Stack(
//               alignment: Alignment.bottomCenter,
//               children: <Widget>[
//                 Container(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.max,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       Expanded(
//                         child: Container(
//                           padding: EdgeInsets.all(10),
//                           height: 800,
//                           decoration: BoxDecoration(
//                             image: DecorationImage(
//                                 image: NetworkImage(
//                                     'http://scoring.com.ar/app/images/publi/scoringpro/publi_home.jpg'),
//                                 fit: BoxFit.contain),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: <Widget>[
//                     GestureDetector(
//                       child: Container(
//                         color: Colors.cyanAccent,
//                         alignment: Alignment.center,
//                         height: 25,
//                         width: 80,
//                         child: Row(
//                           mainAxisSize: MainAxisSize.max,
//                           children: <Widget>[
//                             Icon(
//                               Icons.close,
//                               color: Colors.black,
//                               size: 20,
//                             ),
//                             Text(
//                               'Continuar',
//                               style: TextStyle(fontSize: 12, color: Colors.black),
//                               textScaleFactor: 1,
//                             ),
//                           ],
//                         ),
//                       ),
//                       onTap: () {
//                         timer.cancel();
//                         _initSCApp(context);
//                       }
//                     ),
//                     Container(
//                       height: 20,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//       ),
//     );
//   }
//
//   void _initSCApp(BuildContext context) async {
//
//     if (GlobalData.postUser == null) {
//       initSecurity('to Login');
//       Navigator.pushReplacement(
//         context,
//         PageTransition(
//           ctx: context,
//           type: PageTransitionType.fade,
//           child: LoginHttp(),
//         ),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         PageTransition(
//           ctx: context,
//           type: PageTransitionType.fade,
//           child: BottonNav(),
//         ),
//       );
//     }
//   }
// }