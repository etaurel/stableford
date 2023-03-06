import 'package:connection_status_bar/connection_status_bar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:golfguidescorecard/clubes/bochasColores.dart';
import 'package:golfguidescorecard/jugadores/buscaJugaGralAgrega.dart';
import 'package:golfguidescorecard/jugadores/jugador.dart';
import 'package:golfguidescorecard/mod_serv/model.dart';
import 'package:golfguidescorecard/models/postTorneo.dart';
import 'package:golfguidescorecard/scoresCard/agregarJugadores.dart';
import 'package:golfguidescorecard/scoresCard/agregarJugadores3Match.dart';
import 'package:golfguidescorecard/scoresCard/agregarJugadoresFB.dart';
import 'package:golfguidescorecard/scoresCard/agregarJugadoresFS.dart';
import 'package:golfguidescorecard/scoresCard/agregarJugadoresLaguna.dart';
import 'package:golfguidescorecard/scoresCard/agregarJugadoresMatch.dart';
import 'package:golfguidescorecard/scoresCard/agregarJugadoresPlumas.dart';
import 'package:golfguidescorecard/scoresCard/agregarJugadoresStb.dart';
import 'package:golfguidescorecard/scoresCard/scoreCard.dart';
import 'package:golfguidescorecard/scoresCard/scoreCardPlumas.dart';
import 'package:golfguidescorecard/scoresCard/scoreCardFB.dart';
import 'package:golfguidescorecard/scoresCard/torneo.dart';
import 'package:golfguidescorecard/services/db-api.dart';
import 'package:golfguidescorecard/utilities/display-functions.dart';
import 'package:golfguidescorecard/utilities/global-data.dart';
import 'package:golfguidescorecard/utilities/messages-toast.dart';
import 'package:golfguidescorecard/utilities/user-funtions.dart';
import 'package:page_transition/page_transition.dart';

import '../mod_serv/servicesScore.dart';
import 'package:recase/recase.dart';

class AgregaModalidad extends StatefulWidget {
  final PostTorneo postTorneo;
  AgregaModalidad({@required this.postTorneo});
  @override
  AgregaModalidadState createState() => AgregaModalidadState(postTorneo: postTorneo);
}

class AgregaModalidadState extends State<AgregaModalidad> {
  //******************************************************************************
  var _limiteJugadores = 6;
  //******************************************************************************
  MessagesToast mToast;
  PostUser postUser = GlobalData.postUser;
  PostTorneo postTorneo;
  AgregaModalidadState({@required this.postTorneo});
  PostClub postClub;
  List<DataJugadorScore> _jugadores;
  GlobalKey<ScaffoldState> _scaffoldKey;
  TextEditingController _matriculaController;
  PostJuga _selectedJugador;
  bool _isupdating;
  String _titleProgress;
  bool _isFirstClick = true;


  @override
  void initState() {
    super.initState();
    print('<<<<<<<<<<<<<<<<< agrega jugadores >>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    print(postUser.sexo);

    if (Torneo.dataJugadoresScore == null ||
        Torneo.dataJugadoresScore.length == 0) {
      _jugadores = [];
      _jugadores.add(new DataJugadorScore(
          idTorneo: int.parse(postTorneo.id_torneo),
          matricula: postUser.matricula,
          hcpIndex: double.parse(postUser.hcp),
          hcp3: double.parse(postUser.hcp3),
          hcpTorneo: 0, // int.parse(postUser.hcp),
          nombre_juga: postUser.nombre_juga,
          images: postUser.images,
          pathTeeColor: '',
          sexo: postUser.sexo,
          role: 1));

      //_jugadores[0].addHoyos(_jugadores[0]);
      Torneo.dataJugadoresScore = _jugadores;
    } else {
      _jugadores = Torneo.dataJugadoresScore;
    }

    _isupdating = false;
    _scaffoldKey = GlobalKey(); // key to get the context to show a SnackBar
    _matriculaController = TextEditingController();
  }

  // Method to update title in the AppBar Title
  _showProgress(String message) {
    setState(() {
      _titleProgress = message;
    });
  }

  _showSnackBar(context, message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  _createTable() {
    _showProgress('Creating Table...');
    Services.createTable().then((result) {
      if ('success' == result) {
        // Table is created successfully.
        _showSnackBar(context, result);
//        _showProgress(widget.title);
      }
    });
  }

  _deleteJugador(DataJugadorScore jugador) {
    if (jugador.matricula == postUser.matricula) {
      // NOTA: ¿se avisa?
      print('NO BORRA LA MATRICULA DEL USER');
    } else {
      _showProgress('Deleting Jugador...');
      _jugadores.remove(jugador);
      //Torneo.postJugadores = _jugadores;
    }
  }

  _clearValues() {
    _matriculaController.text = '';
  }

  /// UI
  @override
  Widget build(BuildContext context) {
    mToast = MessagesToast(context: context);
    this.postUser = GlobalData.postUser;
    this.postClub = postTorneo.postClub;
    //print(Torneo.postTorneoJuego.codigo_torneo);
    return Scaffold(
        backgroundColor: Color(0xFFE1E1E1),
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ///IMAGEN
                Container(
                  height: 150,
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Image.network(postClub.imagen.trim() ?? '',
                            fit: BoxFit.fitWidth),
                        color: Colors.black,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.0),
                            height: 90,
                            width: 90,
                            color: Colors.white.withOpacity(.5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
//                             Container(
//                               width: 90,
//                               height: 55,
//                               decoration: BoxDecoration(
//                                 image: DecorationImage(
//                                     image: AssetImage('assets/ScoreCard2.png'),
// //                          image: AssetImage('assets/Logo02.png'),
//                                     fit: BoxFit.contain),
//                               ),
//                             ),
//                             Container(
//                               child: SizedBox(
//                                 height: 10.0,
//                               ),
//                             )
                                Container(
                                  width: 80,
                                  height: 55,
                                  child: Image.network(postClub.logo.trim() ?? '',
                                      fit: BoxFit.contain),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConnectionStatusBar(),
                      ),

                    ],
                  ),
                ),

                Container(
                  child: SizedBox(
                    height: 10.0,
                  ),
                ),
                Text(
                  ':: JUEGOS INDIVIDUALES ::',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center,
                  textScaleFactor: 1,
                ),
                Container(
                  child: SizedBox(
                    height: 10.0,
                  ),
                ),


                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 250,
                      child: RaisedButton(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        color: Colors.black,
//                color: Color(0xFFFF0030),
                        child: Text('Medal | Stroke Play',
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white)),
                        onPressed: () {
                          _verificaTeesMedal();
                        },
                        // onPressed: () {
                        //   Navigator.push(
                        //     context,
                        //     PageTransition(
                        //       type: PageTransitionType.fade,
                        //       child: AgregaJuga(postTorneo: postTorneo,),
                        //       // child: createAlertDialogReg(context),
                        //     ),
                        //   );
                        // },

                      ),
                    ),
                    Container(
                      width: 5,
                    ),
                    SizedBox(
                      width: 60,
                      height: 40,
                      child: RaisedButton(
                        // elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        // color: Color(0xFF1f2f50),
                        color: Colors.black,
                        child: Icon(Icons.info_outline, size: 30, color: Colors.white),
                        onPressed: () {
                          _Medal();
                        },
                      ),

                    ),

                  ],
                ),
                Container(
                  height: 10,
                  child: SizedBox(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 250,
                      child: RaisedButton(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        color: Colors.black,
                        child: Text('Stableford',
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white)),
                        onPressed: () {
                          _verificaTeesStb();
                        },
                        // onPressed: () {
                        //   Navigator.push(
                        //     context,
                        //     PageTransition(
                        //       type: PageTransitionType.fade,
                        //       child: AgregaJuga(postTorneo: postTorneo,),
                        //       // child: createAlertDialogReg(context),
                        //     ),
                        //   );
                        // },

                      ),
                    ),
                    Container(
                      width: 5,
                    ),
                    SizedBox(
                      width: 60,
                      height: 40,
                      child: RaisedButton(
                        // elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        // color: Color(0xFF1f2f50),
                        color: Colors.black,
                        child: Icon(Icons.info_outline, size: 30, color: Colors.white),
                        onPressed: () {
                          _Stableford();
                        },
                      ),

                    ),

                  ],
                ),
                Container(
                  height: 10,
                  child: SizedBox(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 250,
                      child: RaisedButton(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        color: Colors.black,
                        child: Text('Match Play',
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white)),
                        onPressed: () {
                          _verificaTeesMatch();
                        },
                        // onPressed: () {
                        //   Navigator.push(
                        //     context,
                        //     PageTransition(
                        //       type: PageTransitionType.fade,
                        //       child: AgregaJugaMatch(postTorneo: postTorneo,),
                        //       // child: createAlertDialogReg(context),
                        //     ),
                        //   );
                        // },

                      ),
                    ),
                    Container(
                      width: 5,
                    ),
                    SizedBox(
                      width: 60,
                      height: 40,
                      child: RaisedButton(
                        // elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        // color: Color(0xFF1f2f50),
                        color: Colors.black,
                        child: Icon(Icons.info_outline, size: 30, color: Colors.white),
                        onPressed: () {
                          _Match();
                        },
                      ),

                    ),

                  ],
                ),
                Container(
                  child: SizedBox(
                    height: 10.0,
                  ),
                ),

                Text(
                  ':: JUEGOS EN EQUIPOS ::',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center,
                  textScaleFactor: 1,
                ),

                Container(
                  height: 10,
                  child: SizedBox(),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 40,
                      child: RaisedButton(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        color: Color(0xFF1f2f50),
//                color: Color(0xFFFF0030),
                        child: Text('Fourball',
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white)),
                        onPressed: () {
                          _verificaTeesFB();
                        },

                        // onPressed: () {
                        //   Navigator.push(
                        //     context,
                        //     PageTransition(
                        //       type: PageTransitionType.fade,
                        //       child: AgregaJugaFB(postTorneo: postTorneo,),
                        //       // child: createAlertDialogReg(context),
                        //     ),
                        //   );
                        // },
                      ),

                    ),
                    Container(
                      width: 5,
                    ),
                    SizedBox(
                      width: 60,
                      height: 40,
                      child: RaisedButton(
                        // elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        // color: Color(0xFF1f2f50),
                        color: Color(0xFF1f2f50),
                        child: Icon(Icons.info_outline, size: 30, color: Colors.white),
                        onPressed: () {
                          _Fourball();
                        },
                      ),

                    ),

                  ],
                ),
                Container(
                  height: 10,
                  child: SizedBox(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 40,
                      child: RaisedButton(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        color: Color(0xFF1f2f50),
//                color: Color(0xFFFF0030),
                        child: Text('Foursome | Greensome',
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white)),
                        onPressed: () {
                          _verificaTeesFS();
                        },
                      ),

                    ),
                    Container(
                      width: 5,
                    ),
                    SizedBox(
                      width: 60,
                      height: 40,
                      child: RaisedButton(
                        // elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        // color: Color(0xFF1f2f50),
                        color: Color(0xFF1f2f50),
                        child: Icon(Icons.info_outline, size: 30, color: Colors.white),
                        onPressed: () {
                          _Foursome();
                        },
                      ),

                    ),

                  ],
                ),
                Container(
                  height: 10,
                  child: SizedBox(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 40,
                      child: RaisedButton(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        color: Color(0xFF1f2f50),
//                color: Color(0xFFFF0030),
                        child: Text('Laguneada',
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white)),
                        onPressed: () {
                          _verificaTeesLaguna();
                        },
                      ),

                    ),
                    Container(
                      width: 5,
                    ),
                    SizedBox(
                      width: 60,
                      height: 40,
                      child: RaisedButton(
                        // elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        // color: Color(0xFF1f2f50),
                        color: Color(0xFF1f2f50),
                        child: Icon(Icons.info_outline, size: 30, color: Colors.white),
                        onPressed: () {
                          _Laguneada();
                        },
                      ),

                    ),

                  ],
                ),
                Container(
                  child: SizedBox(
                    height: 10.0,
                  ),
                ),
                Text(
                  ':: JUEGOS DE 3 JUGADORES ::',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.center,
                  textScaleFactor: 1,
                ),
                Container(
                  child: SizedBox(
                    height: 10.0,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 40,
                      child: RaisedButton(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        // color: Color(0xFF1f2f50),
               color: Color(0xFFFF0030),
                        child: Text('Plumitas',
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white)),
                        onPressed: () {
                          _verificaTeesPlumas();
                        },
                        // onPressed: () {
                        //   Navigator.push(
                        //     context,
                        //     PageTransition(
                        //       type: PageTransitionType.fade,
                        //       child: AgregaJugaPlumas(postTorneo: postTorneo,),
                        //       // child: createAlertDialogReg(context),
                        //     ),
                        //   );
                        // },
                      ),

                    ),
                    Container(
                      width: 5,
                    ),
                    SizedBox(
                      width: 60,
                      height: 40,
                      child: RaisedButton(
                        // elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        // color: Color(0xFF1f2f50),
                        color: Color(0xFFFF0030),
                        child: Icon(Icons.info_outline, size: 30, color: Colors.white),
                        onPressed: () {
                          _Plumitas();
                        },
                      ),

                    ),

                  ],
                ),
                Container(
                  height: 10,
                  child: SizedBox(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 40,
                      child: RaisedButton(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        color: Color(0xFFFF0030),
                        child: Text('Three Ball Match Play',
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white)),
                        onPressed: () {
                          _verificaTees3();
                        },
                      ),

                    ),
                    Container(
                      width: 5,
                    ),
                    SizedBox(
                      width: 60,
                      height: 40,
                      child: RaisedButton(
                        // elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        // color: Color(0xFF1f2f50),
                        color: Color(0xFFFF0030),
                        child: Icon(Icons.info_outline, size: 30, color: Colors.white),
                          onPressed: () {
                            _3MatchPlay();
                        },
                      ),

                    ),

                  ],
                ),
                Container(
                  height: 10,
                  child: SizedBox(),
                ),

                RaisedButton(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  color: Colors.grey,
                  child: Text('Volver',
                      textScaleFactor: 1.0,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18.0, color: Colors.black)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),

                Container(
                  height: 100,
                  child: SizedBox(),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: 0,
          height: 60.0,
          items: <Widget>[
            IconButton(
              icon: Icon(Icons.golf_course, size: 30, color: Colors.white),
            ),
//          Icon(Icons.zoom_out_map, size: 30, color: Colors.white),
          ],
          color: Color(0xFF1f2f50),
//        color: Color(0xFFFF0030),
          buttonBackgroundColor: Color(0xFF1f2f50),
//        buttonBackgroundColor: Color(0xFFFF0030),
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 600),
        )
    );
  }

  /// Crear info Modalidades

  _Medal() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all( 8 ),
                width: MediaQuery
                    .of( context )
                    .size
                    .width - 50,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      // padding: EdgeInsets.all( 3 ),
                      width: 150,
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            icon: Icon( Icons.close, color: Colors.white ),
                            onPressed: () {
                              Navigator.of( context ).pop( );
                            },
                          ),
                          Text(
                            '  CERRAR',
                            style: TextStyle(
                                fontSize: 17, color: Colors.white ),
                            textScaleFactor: 1,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of( context ).size.width - 50,
                      child:
                      Text(
                        'MEDAL | STROKE PLAY',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1f2f50)),
                        textScaleFactor: 1,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Text(
                      'En modalidad Medal | Stroke Play se contabilizan todos los golpes y todos los competidores compiten contra todos. El jugador que efectúe menos golpes en el recorrido resultará ganador. En esta modalidad se juegan la mayoría de los torneos profesionales.',
                      style: TextStyle(
                          fontSize: 18, color: Colors.black),
                      textScaleFactor: 1,

                    ),

                  ],
                ),
              ), ),
          );
        }
    );
  }

  _Stableford() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all( 8 ),
                width: MediaQuery
                    .of( context )
                    .size
                    .width - 50,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      // padding: EdgeInsets.all( 3 ),
                      width: 150,
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            icon: Icon( Icons.close, color: Colors.white ),
                            onPressed: () {
                              Navigator.of( context ).pop( );
                            },
                          ),
                          Text(
                            '  CERRAR',
                            style: TextStyle(
                                fontSize: 17, color: Colors.white ),
                            textScaleFactor: 1,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of( context ).size.width - 50,
                      child:
                      Text(
                        'STABLEFORD',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1f2f50)),
                        textScaleFactor: 1,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Text(
                      'Fórmula de juego en la que en cada hoyo se puntúa con relación al par: 1 punto por el bogey, 2 por el par, 3 por el birdie, 4 por el eagle, 5 por el albatros. Cuando no se ha podido terminar en los golpes que valen para la puntuación, se levanta la bola. Es la única fórmula en la que gana quien suma más alto. El stableford se utiliza actualmente muchísimo en premios locales, porque es una fórmula más rápida que otras ya que permite levantar la bola. Se juega con el Handicap de Juego al 85%. Es la única Modalidad de juego que gana quien más puntos hace.',
                      style: TextStyle(
                          fontSize: 18, color: Colors.black),
                      textScaleFactor: 1,

                    ),

                  ],
                ),
              ), ),
          );
        }
    );
  }

  _Match() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all( 8 ),
                width: MediaQuery
                    .of( context )
                    .size
                    .width - 50,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      // padding: EdgeInsets.all( 3 ),
                      width: 150,
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            icon: Icon( Icons.close, color: Colors.white ),
                            onPressed: () {
                              Navigator.of( context ).pop( );
                            },
                          ),
                          Text(
                            '  CERRAR',
                            style: TextStyle(
                                fontSize: 17, color: Colors.white ),
                            textScaleFactor: 1,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of( context ).size.width - 50,
                      child:
                      Text(
                        'MATCH PLAY',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1f2f50)),
                        textScaleFactor: 1,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Text(
                      'Es la modalidad más extendida en torneos profesionales después del Stroke Play. Juegan dos jugadores, uno contra otro. Se contabilizan los hoyos ganados y perdidos. Si un jugador lleva un hoyo ganado de ventaja, se denomina “uno arriba” o “uno abajo”, si es el caso contrario. Un partido de golf en la modalidad match play acaba cuando uno de los jugadores lleva más hoyos ganados que los hoyos que quedan para finalizar el recorrido. Entonces se denomina que el jugador vencedor le ha hecho “match” al perdedor. Cuando se da la situación de que quedan el mismo número de hoyos por jugar que hoyos arriba de un jugador a otro, el jugador que va perdiendo va “dormie”, es decir, está obligado a ganar todos los hoyos que quedan para empatar el partido. No es necesario que un jugador termine un hoyo, si no existe posibilidad de empatar o ganar. Un torneo jugado en esta modalidad consiste en sucesivas rondas eliminatorias hasta que queda un ganador.',
                      style: TextStyle(
                          fontSize: 18, color: Colors.black),
                      textScaleFactor: 1,

                    ),

                  ],
                ),
              ), ),
          );
        }
    );
  }

  _Plumitas() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all( 8 ),
                width: MediaQuery
                    .of( context )
                    .size
                    .width - 50,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      // padding: EdgeInsets.all( 3 ),
                      width: 150,
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            icon: Icon( Icons.close, color: Colors.white ),
                            onPressed: () {
                              Navigator.of( context ).pop( );
                            },
                          ),
                          Text(
                            '  CERRAR',
                            style: TextStyle(
                                fontSize: 17, color: Colors.white ),
                            textScaleFactor: 1,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of( context ).size.width - 50,
                      child:
                      Text(
                        'PLUMITAS (SINDICATO)',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1f2f50)),
                        textScaleFactor: 1,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Text(
                      'Modalidad para tres jugadores. En cada hoyo se ponen en juego seis puntos, que se distribuyen de la siguiente forma: - 2 puntos para cada uno en caso de empatar los tres jugadores. - 3, 3 y 0 puntos para los dos jugadores que empaten el hoyo, ganándole al tercer jugador. - 4, 1 y 1 punto cuando un jugador gana el hoyo y los otros dos empatan. - 4, 2 y 0 puntos cuando se producen tres resultados diferentes.',
                      style: TextStyle(
                          fontSize: 18, color: Colors.black),
                      textScaleFactor: 1,

                    ),

                  ],
                ),
              ), ),
          );
        }
    );
  }

  _3MatchPlay() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all( 8 ),
                width: MediaQuery
                    .of( context )
                    .size
                    .width - 50,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      // padding: EdgeInsets.all( 3 ),
                      width: 150,
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            icon: Icon( Icons.close, color: Colors.white ),
                            onPressed: () {
                              Navigator.of( context ).pop( );
                            },
                          ),
                          Text(
                            '  CERRAR',
                            style: TextStyle(
                                fontSize: 17, color: Colors.white ),
                            textScaleFactor: 1,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of( context ).size.width - 50,
                      child:
                      Text(
                        'THREE BALL MATCH PLAY',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1f2f50)),
                        textScaleFactor: 1,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Text(
                      'Es un partido en el que juegan tres jugadores, jugando todos contra todos con su propia bola. Es decir, cada uno de ellos juega partidos individuales contra los otros dos. Cálculo del Handicap: la diferencia del Handicap de juego al 85%. (ej. Hcp 20 - Hcp 15, diferencia = 5, al 85% = 4)',
                      style: TextStyle(
                          fontSize: 18, color: Colors.black),
                      textScaleFactor: 1,

                    ),

                  ],
                ),
              ), ),
          );
        }
    );
  }

  _Fourball() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all( 8 ),
                width: MediaQuery
                    .of( context )
                    .size
                    .width - 50,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      // padding: EdgeInsets.all( 3 ),
                      width: 150,
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            icon: Icon( Icons.close, color: Colors.white ),
                            onPressed: () {
                              Navigator.of( context ).pop( );
                            },
                          ),
                          Text(
                            '  CERRAR',
                            style: TextStyle(
                                fontSize: 17, color: Colors.white ),
                            textScaleFactor: 1,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of( context ).size.width - 50,
                      child:
                      Text(
                        'FOURBALL AMERICANA',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1f2f50)),
                        textScaleFactor: 1,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Text(
                      'Es una modalidad muy usada en partidos entre amigos. Juega una pareja de dos jugadores contra otra. Cada jugador de una pareja juega su bola y puntúa en cada hoyo el resultado más bajo de cada bando. Gana el hoyo el bando que consiga el mejor resultado y no es necesario que los jugadores terminen el hoyo, si su resultado no va a contar para el partido. Esto último agiliza mucho el juego. Se juega con el Handicap de Juego al 85%.',
                      style: TextStyle(
                          fontSize: 18, color: Colors.black),
                      textScaleFactor: 1,
                    ),

                    Container(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of( context ).size.width - 50,
                      child:
                      Text(
                        'FOURBALL AGGREGATE',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1f2f50)),
                        textScaleFactor: 1,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Text(
                      'Se anotan las 2 pelotas en todos los hoyos con el 100% del Handicap de Juego y se suman los 2 scores Netos al final de la vuelta.',
                      style: TextStyle(
                          fontSize: 18, color: Colors.black),
                      textScaleFactor: 1,
                    ),

                    Container(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of( context ).size.width - 50,
                      child:
                      Text(
                        'FOURBALL 3/8',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1f2f50)),
                        textScaleFactor: 1,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Text(
                      'Juega una pareja de dos jugadores contra otra. Cada jugador de una pareja juega su bola y puntúa en cada hoyo el resultado más bajo de cada bando. No puede haber más de 5 golpes de diferencia entre cada jugador de la pareja. Se juntan los 2 Handcaps de Juego, y se toma el 3/8 de esa suma (Handicap de la pareja).',
                      style: TextStyle(
                          fontSize: 18, color: Colors.black),
                      textScaleFactor: 1,
                    ),
                  ],
                ),
              ), ),
          );
        }
    );
  }

  _Foursome() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all( 8 ),
                width: MediaQuery
                    .of( context )
                    .size
                    .width - 50,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      // padding: EdgeInsets.all( 3 ),
                      width: 150,
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            icon: Icon( Icons.close, color: Colors.white ),
                            onPressed: () {
                              Navigator.of( context ).pop( );
                            },
                          ),
                          Text(
                            '  CERRAR',
                            style: TextStyle(
                                fontSize: 17, color: Colors.white ),
                            textScaleFactor: 1,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of( context ).size.width - 50,
                      child:
                      Text(
                        'FOURSOME',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1f2f50)),
                        textScaleFactor: 1,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Text(
                      'Es un partido por parejas donde cada pareja juega una sola bola. En el primer hoyo se decide quién va a salir en los hoyos pares y quién en los impares. Después de la salida, se van alternando los golpes hasta finalizar el hoyo. Cálculo del Handicap: la suma de los 2 Handicap de Juego al 50%. (ej. Hcp 20 - Hcp 15, suma = 35, al 50% = 18)',
                      style: TextStyle(
                          fontSize: 18, color: Colors.black),
                      textScaleFactor: 1,
                    ),

                    Container(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of( context ).size.width - 50,
                      child:
                      Text(
                        'GREENSOME',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1f2f50)),
                        textScaleFactor: 1,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Text(
                      'Modalidad de juego por parejas en la que ejecutan la salida ambos jugadores de cada bando. Después de salir, cada bando elige la mejor salida, se recoge la otra bola y se sigue jugando la bola elegida en golpes alternos hasta teminar el hoyo. Cálculo del Handicap: la suma de los 2 Handicap de Juego al 50%. (ej. Hcp 20 - Hcp 15, suma = 35, al 50% = 18)',
                      style: TextStyle(
                          fontSize: 18, color: Colors.black),
                      textScaleFactor: 1,
                    ),

                    Container(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of( context ).size.width - 50,
                      child:
                      Text(
                        'FOURSOME CHAPMAN',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1f2f50)),
                        textScaleFactor: 1,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Text(
                      'Modalidad de juego por parejas en la que en cada tee de salida salen ambos jugadores y cada uno juega el segundo golpe con la bola de su compañero. Para el tercer golpe se elige una de las dos, que se sigue jugando hasta terminar el hoyo en golpes alternos. Cálculo del Handicap: la suma de los 2 Handicap de Juego al 40%. (ej. Hcp 11 - Hcp 25, suma = 36, al 40% = 14)',
                      style: TextStyle(
                          fontSize: 18, color: Colors.black),
                      textScaleFactor: 1,
                    ),

                  ],
                ),
              ), ),
          );
        }
    );
  }

  _Laguneada() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all( 8 ),
                width: MediaQuery
                    .of( context )
                    .size
                    .width - 50,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      // padding: EdgeInsets.all( 3 ),
                      width: 150,
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            icon: Icon( Icons.close, color: Colors.white ),
                            onPressed: () {
                              Navigator.of( context ).pop( );
                            },
                          ),
                          Text(
                            '  CERRAR',
                            style: TextStyle(
                                fontSize: 17, color: Colors.white ),
                            textScaleFactor: 1,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of( context ).size.width - 50,
                      child:
                      Text(
                        'LAGUNEADA',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1f2f50)),
                        textScaleFactor: 1,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Text(
                      'Modalidad de juego formada por equipos de 3 o 4 jugadores, donde se anota la mejor pelota (o las 2 mejores pelotas) de cada equipo. Se juega con el 85% del Handicap de Juego.',
                      style: TextStyle(
                          fontSize: 18, color: Colors.black),
                      textScaleFactor: 1,

                    ),

                  ],
                ),
              ), ),
          );
        }
    );
  }

  /// Crear Alerta
  _selectTee({BuildContext context, DataJugadorScore jugador}) async {
    final PostTee teeR = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: SingleChildScrollView(
              child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(8),
                    width: MediaQuery.of(context).size.width - 50,
                    color: Colors.black,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Text(
                          'SELECT ',
                          style: TextStyle(fontSize: 17, color: Colors.white),
                          textScaleFactor: 1,
                        ),
                        Text(
                          'TEE ',
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                          textScaleFactor: 1,
                        ),
                        Text(
                          'TO PLAY',
                          style: TextStyle(fontSize: 17, color: Colors.white),
                          textScaleFactor: 1,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 4,
                    child: SizedBox(),
                  ),
                  BochasColores(
                      sexo: jugador.sexo,
                      hcpJuga: jugador.hcpIndex,
                      hcp3Juga: jugador.hcp3,
                      teesBC: Torneo.postTorneoJuego.tees),
                ],
              ),
            ),),
          );
        });
    // print(teeR.tee);
    List<String> scoresOld = [];
    if (jugador.hoyos != null) {
      if (jugador.hoyos.length > 1) {
        for (int idx = 0; idx < jugador.hoyos.length; idx++) {
          scoresOld.insert(
              idx,
              jugador.hoyos[idx].hoyoNro.toString() +
                  ':' +
                  jugador.hoyos[idx].score.toString());
        }
      }
    }

    jugador.hcpTorneo = Jugador.calcularHcp(jugador.hcpIndex, teeR);
    jugador.pathTeeColor = UserFunctions.resolverPathTeeColor(teeR.tee);
    jugador.postTee = teeR;
    jugador.addHoyos(jugador);
    if (scoresOld.length > 1) {
      for (int idx = 0; idx < scoresOld.length; idx++) {
        List<String> infoHoyo = scoresOld[idx].split(':');
        jugador.setScore(int.parse(infoHoyo[0]), int.parse(infoHoyo[1]));
      }
    }

    setState(() {});
    return teeR;
  }

  void buscarMatricula() async {
    _showProgress('Agregando Jugador...');
    PostJuga pJNew =
        await Jugador.getJugador(_matriculaController.text, context);
    if (pJNew != null) {
      //agregar el jugador
      //print(pJNew.nombre_juga);
      int _role = 2;
      if (_jugadores.length >= 2) {
        _role = 3;
      }
      DataJugadorScore tDataJS = new DataJugadorScore(
          idTorneo: int.parse(postTorneo.id_torneo),
          matricula: pJNew.matricula,
          hcpIndex: double.parse(pJNew.hcp),
          hcp3: double.parse(pJNew.hcp3),
          hcpTorneo: 0, // int.parse(postUser.hcp),
          nombre_juga: pJNew.nombre_juga,
          images: pJNew.images,
          pathTeeColor: '',
          sexo: pJNew.sexo,
          role: _role);
      //tDataJS.addHoyos(tDataJS);
      _jugadores.add(tDataJS);

      setState(() {});
    } else {
      // NOTA: Avisar que no existe el codigo
      print('NO EXISTE LA MATRICULA');
      mToast.showToastCancel('NO EXISTE LA MATRICULA');
    }
  }

  String _estableceTeeImage(String pathTeeColor, String pathTeeColorDefault) {
    if (pathTeeColor != null) {
      if (pathTeeColor.length > 10) {
        return pathTeeColor;
      }
    }

    return pathTeeColorDefault;
  }

  void _verificaTeesMedal() async {
    bool _isOk = true;
    String matriculas = '';
    // List<String> _cTee = [];
    List<String> _cMat = [];

    _jugadores.forEach((juga) {
      //print(juga.pathTeeColor);
      // if (juga.pathTeeColor == null || juga.pathTeeColor.length <= 5) {
      //   mToast.showToast('FALTA SELECCIONAR TEE DE: ' + juga.nombre_juga);
      //   print('*** NOTIFICAR ***:  FALTA SELECCIONAR TEE DE: ' +
      //       juga.nombre_juga);
      //   _isOk = false;
      // }
      if (matriculas.length > 1) {
        matriculas = matriculas + ', ';
      }
      matriculas = matriculas + ' ' + juga.matricula.trim();
      // _cTee.insert(0, juga.pathTeeColor);
      _cMat.insert(0, juga.matricula);
    });
    List<DataJugadorScore> dataJSCTrolTee = await DBApi.getTarjetasControlTee(
        matriculas,
        int.parse(postUser.idjuga_arg),
        int.parse(Torneo.postTorneoJuego.id_torneo));
    if (dataJSCTrolTee != null) {
      dataJSCTrolTee.forEach((dJSCTee) {
        for (int IdP = 0; IdP < _cMat.length; IdP++) {
          if (dJSCTee.matricula == _cMat[IdP]) {
            // if (dJSCTee.pathTeeColor != _cTee[IdP]) {
            //   print('*** NOTIFICAR ***:  DIFERENCIA EN LOS TEE DE: ' +
            //       dJSCTee.nombre_juga);
            //
            //   mToast.showToastCancel(
            //       'DIFERENCIA EN LOS TEE DE: ' + dJSCTee.nombre_juga);
            //   _isOk = false;
            // }
          }
        }
      });
    }
    if (_isOk == true) {
      print('PASS CONTROL DE LOS TEES ');
      Torneo.dataJugadoresScore = _jugadores;
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: AgregaJuga(postTorneo: postTorneo,),
        ),

      );
    }
  }

  void _verificaTeesStb() async {
    bool _isOk = true;
    String matriculas = '';
    // List<String> _cTee = [];
    List<String> _cMat = [];

    _jugadores.forEach((juga) {
      //print(juga.pathTeeColor);
      // if (juga.pathTeeColor == null || juga.pathTeeColor.length <= 5) {
      //   mToast.showToast('FALTA SELECCIONAR TEE DE: ' + juga.nombre_juga);
      //   print('*** NOTIFICAR ***:  FALTA SELECCIONAR TEE DE: ' +
      //       juga.nombre_juga);
      //   _isOk = false;
      // }
      if (matriculas.length > 1) {
        matriculas = matriculas + ', ';
      }
      matriculas = matriculas + ' ' + juga.matricula.trim();
      // _cTee.insert(0, juga.pathTeeColor);
      _cMat.insert(0, juga.matricula);
    });
    List<DataJugadorScore> dataJSCTrolTee = await DBApi.getTarjetasControlTee(
        matriculas,
        int.parse(postUser.idjuga_arg),
        int.parse(Torneo.postTorneoJuego.id_torneo));
    if (dataJSCTrolTee != null) {
      dataJSCTrolTee.forEach((dJSCTee) {
        for (int IdP = 0; IdP < _cMat.length; IdP++) {
          if (dJSCTee.matricula == _cMat[IdP]) {
            // if (dJSCTee.pathTeeColor != _cTee[IdP]) {
            //   print('*** NOTIFICAR ***:  DIFERENCIA EN LOS TEE DE: ' +
            //       dJSCTee.nombre_juga);
            //
            //   mToast.showToastCancel(
            //       'DIFERENCIA EN LOS TEE DE: ' + dJSCTee.nombre_juga);
            //   _isOk = false;
            // }
          }
        }
      });
    }
    if (_isOk == true) {
      print('PASS CONTROL DE LOS TEES ');
      Torneo.dataJugadoresScore = _jugadores;
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: AgregaJugaStb (postTorneo: postTorneo,),
        ),

      );
    }
  }

  void _verificaTeesMatch() async {
    bool _isOk = true;
    String matriculas = '';
    // List<String> _cTee = [];
    List<String> _cMat = [];

    _jugadores.forEach((juga) {
      //print(juga.pathTeeColor);
      // if (juga.pathTeeColor == null || juga.pathTeeColor.length <= 5) {
      //   mToast.showToast('FALTA SELECCIONAR TEE DE: ' + juga.nombre_juga);
      //   print('*** NOTIFICAR ***:  FALTA SELECCIONAR TEE DE: ' +
      //       juga.nombre_juga);
      //   _isOk = false;
      // }
      if (matriculas.length > 1) {
        matriculas = matriculas + ', ';
      }
      matriculas = matriculas + ' ' + juga.matricula.trim();
      // _cTee.insert(0, juga.pathTeeColor);
      _cMat.insert(0, juga.matricula);
    });
    List<DataJugadorScore> dataJSCTrolTee = await DBApi.getTarjetasControlTee(
        matriculas,
        int.parse(postUser.idjuga_arg),
        int.parse(Torneo.postTorneoJuego.id_torneo));
    if (dataJSCTrolTee != null) {
      dataJSCTrolTee.forEach((dJSCTee) {
        for (int IdP = 0; IdP < _cMat.length; IdP++) {
          if (dJSCTee.matricula == _cMat[IdP]) {
            // if (dJSCTee.pathTeeColor != _cTee[IdP]) {
            //   print('*** NOTIFICAR ***:  DIFERENCIA EN LOS TEE DE: ' +
            //       dJSCTee.nombre_juga);
            //
            //   mToast.showToastCancel(
            //       'DIFERENCIA EN LOS TEE DE: ' + dJSCTee.nombre_juga);
            //   _isOk = false;
            // }
          }
        }
      });
    }
    if (_isOk == true) {
      print('PASS CONTROL DE LOS TEES ');
      Torneo.dataJugadoresScore = _jugadores;
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: AgregaJugaMatch(postTorneo: postTorneo,),
        ),

      );
    }
  }

  void _verificaTeesPlumas() async {
    bool _isOk = true;
    String matriculas = '';
    // List<String> _cTee = [];
    List<String> _cMat = [];

    _jugadores.forEach((juga) {
      //print(juga.pathTeeColor);
      // if (juga.pathTeeColor == null || juga.pathTeeColor.length <= 5) {
      //   mToast.showToast('FALTA SELECCIONAR TEE DE: ' + juga.nombre_juga);
      //   print('*** NOTIFICAR ***:  FALTA SELECCIONAR TEE DE: ' +
      //       juga.nombre_juga);
      //   _isOk = false;
      // }
      if (matriculas.length > 1) {
        matriculas = matriculas + ', ';
      }
      matriculas = matriculas + ' ' + juga.matricula.trim();
      // _cTee.insert(0, juga.pathTeeColor);
      _cMat.insert(0, juga.matricula);
    });
    List<DataJugadorScore> dataJSCTrolTee = await DBApi.getTarjetasControlTee(
        matriculas,
        int.parse(postUser.idjuga_arg),
        int.parse(Torneo.postTorneoJuego.id_torneo));
    if (dataJSCTrolTee != null) {
      dataJSCTrolTee.forEach((dJSCTee) {
        for (int IdP = 0; IdP < _cMat.length; IdP++) {
          if (dJSCTee.matricula == _cMat[IdP]) {
            // if (dJSCTee.pathTeeColor != _cTee[IdP]) {
            //   print('*** NOTIFICAR ***:  DIFERENCIA EN LOS TEE DE: ' +
            //       dJSCTee.nombre_juga);
            //
            //   mToast.showToastCancel(
            //       'DIFERENCIA EN LOS TEE DE: ' + dJSCTee.nombre_juga);
            //   _isOk = false;
            // }
          }
        }
      });
    }
    if (_isOk == true) {
      print('PASS CONTROL DE LOS TEES ');
      Torneo.dataJugadoresScore = _jugadores;
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: AgregaJugaPlumas(postTorneo: postTorneo,),
        ),

      );
    }
  }

  void _verificaTees3() async {
    bool _isOk = true;
    String matriculas = '';
    List<String> _cTee = [];
    List<String> _cMat = [];

    _jugadores.forEach((juga) {
      //print(juga.pathTeeColor);
      // if (juga.pathTeeColor == null || juga.pathTeeColor.length <= 5) {
      //   mToast.showToast('FALTA SELECCIONAR TEE DE: ' + juga.nombre_juga);
      //   print('*** NOTIFICAR ***:  FALTA SELECCIONAR TEE DE: ' +
      //       juga.nombre_juga);
      //   _isOk = false;
      // }
      if (matriculas.length > 1) {
        matriculas = matriculas + ', ';
      }
      matriculas = matriculas + ' ' + juga.matricula.trim();
      _cTee.insert(0, juga.pathTeeColor);
      _cMat.insert(0, juga.matricula);
    });
    List<DataJugadorScore> dataJSCTrolTee = await DBApi.getTarjetasControlTee(
        matriculas,
        int.parse(postUser.idjuga_arg),
        int.parse(Torneo.postTorneoJuego.id_torneo));
    if (dataJSCTrolTee != null) {
      dataJSCTrolTee.forEach((dJSCTee) {
        for (int IdP = 0; IdP < _cMat.length; IdP++) {
          if (dJSCTee.matricula == _cMat[IdP]) {
            if (dJSCTee.pathTeeColor != _cTee[IdP]) {
              print('*** NOTIFICAR ***:  DIFERENCIA EN LOS TEE DE: ' +
                  dJSCTee.nombre_juga);

              mToast.showToastCancel(
                  'DIFERENCIA EN LOS TEE DE: ' + dJSCTee.nombre_juga);
              _isOk = false;
            }
          }
        }
      });
    }
    if (_isOk == true) {
      print('PASS CONTROL DE LOS TEES ');
      Torneo.dataJugadoresScore = _jugadores;
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: AgregaJuga3Match(postTorneo: postTorneo,),
        ),

      );
    }
  }

  void _verificaTeesFB() async {
    bool _isOk = true;
    String matriculas = '';
    // List<String> _cTee = [];
    List<String> _cMat = [];

    _jugadores.forEach((juga) {
      //print(juga.pathTeeColor);
      // if (juga.pathTeeColor == null || juga.pathTeeColor.length <= 5) {
      //   mToast.showToast('FALTA SELECCIONAR TEE DE: ' + juga.nombre_juga);
      //   print('*** NOTIFICAR ***:  FALTA SELECCIONAR TEE DE: ' +
      //       juga.nombre_juga);
      //   _isOk = false;
      // }
      if (matriculas.length > 1) {
        matriculas = matriculas + ', ';
      }
      matriculas = matriculas + ' ' + juga.matricula.trim();
      // _cTee.insert(0, juga.pathTeeColor);
      _cMat.insert(0, juga.matricula);
    });
    List<DataJugadorScore> dataJSCTrolTee = await DBApi.getTarjetasControlTee(
        matriculas,
        int.parse(postUser.idjuga_arg),
        int.parse(Torneo.postTorneoJuego.id_torneo));
    if (dataJSCTrolTee != null) {
      dataJSCTrolTee.forEach((dJSCTee) {
        for (int IdP = 0; IdP < _cMat.length; IdP++) {
          if (dJSCTee.matricula == _cMat[IdP]) {
            // if (dJSCTee.pathTeeColor != _cTee[IdP]) {
            //   print('*** NOTIFICAR ***:  DIFERENCIA EN LOS TEE DE: ' +
            //       dJSCTee.nombre_juga);
            //
            //   mToast.showToastCancel(
            //       'DIFERENCIA EN LOS TEE DE: ' + dJSCTee.nombre_juga);
            //   _isOk = false;
            // }
          }
        }
      });
    }
    if (_isOk == true) {
      print('PASS CONTROL DE LOS TEES ');
      Torneo.dataJugadoresScore = _jugadores;
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: AgregaJugaFB(postTorneo: postTorneo,),
        ),

      );
    }
  }

  void _verificaTeesFS() async {
    bool _isOk = true;
    String matriculas = '';
    // List<String> _cTee = [];
    List<String> _cMat = [];

    _jugadores.forEach((juga) {
      //print(juga.pathTeeColor);
      // if (juga.pathTeeColor == null || juga.pathTeeColor.length <= 5) {
      //   mToast.showToast('FALTA SELECCIONAR TEE DE: ' + juga.nombre_juga);
      //   print('*** NOTIFICAR ***:  FALTA SELECCIONAR TEE DE: ' +
      //       juga.nombre_juga);
      //   _isOk = false;
      // }
      if (matriculas.length > 1) {
        matriculas = matriculas + ', ';
      }
      matriculas = matriculas + ' ' + juga.matricula.trim();
      // _cTee.insert(0, juga.pathTeeColor);
      _cMat.insert(0, juga.matricula);
    });
    List<DataJugadorScore> dataJSCTrolTee = await DBApi.getTarjetasControlTee(
        matriculas,
        int.parse(postUser.idjuga_arg),
        int.parse(Torneo.postTorneoJuego.id_torneo));
    if (dataJSCTrolTee != null) {
      dataJSCTrolTee.forEach((dJSCTee) {
        for (int IdP = 0; IdP < _cMat.length; IdP++) {
          if (dJSCTee.matricula == _cMat[IdP]) {
            // if (dJSCTee.pathTeeColor != _cTee[IdP]) {
            //   print('*** NOTIFICAR ***:  DIFERENCIA EN LOS TEE DE: ' +
            //       dJSCTee.nombre_juga);
            //
            //   mToast.showToastCancel(
            //       'DIFERENCIA EN LOS TEE DE: ' + dJSCTee.nombre_juga);
            //   _isOk = false;
            // }
          }
        }
      });
    }
    if (_isOk == true) {
      print('PASS CONTROL DE LOS TEES ');
      Torneo.dataJugadoresScore = _jugadores;
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: AgregaJugaFS(postTorneo: postTorneo,),
        ),

      );
    }
  }

  void _verificaTeesLaguna() async {
    bool _isOk = true;
    String matriculas = '';
    // List<String> _cTee = [];
    List<String> _cMat = [];

    _jugadores.forEach((juga) {
      //print(juga.pathTeeColor);
      // if (juga.pathTeeColor == null || juga.pathTeeColor.length <= 5) {
      //   mToast.showToast('FALTA SELECCIONAR TEE DE: ' + juga.nombre_juga);
      //   print('*** NOTIFICAR ***:  FALTA SELECCIONAR TEE DE: ' +
      //       juga.nombre_juga);
      //   _isOk = false;
      // }
      if (matriculas.length > 1) {
        matriculas = matriculas + ', ';
      }
      matriculas = matriculas + ' ' + juga.matricula.trim();
      // _cTee.insert(0, juga.pathTeeColor);
      _cMat.insert(0, juga.matricula);
    });
    List<DataJugadorScore> dataJSCTrolTee = await DBApi.getTarjetasControlTee(
        matriculas,
        int.parse(postUser.idjuga_arg),
        int.parse(Torneo.postTorneoJuego.id_torneo));
    if (dataJSCTrolTee != null) {
      dataJSCTrolTee.forEach((dJSCTee) {
        for (int IdP = 0; IdP < _cMat.length; IdP++) {
          if (dJSCTee.matricula == _cMat[IdP]) {
            // if (dJSCTee.pathTeeColor != _cTee[IdP]) {
            //   print('*** NOTIFICAR ***:  DIFERENCIA EN LOS TEE DE: ' +
            //       dJSCTee.nombre_juga);
            //
            //   mToast.showToastCancel(
            //       'DIFERENCIA EN LOS TEE DE: ' + dJSCTee.nombre_juga);
            //   _isOk = false;
            // }
          }
        }
      });
    }
    if (_isOk == true) {
      print('PASS CONTROL DE LOS TEES ');
      Torneo.dataJugadoresScore = _jugadores;
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          // child: AgregaJugaLaguneada(postTorneo: postTorneo,),
          child: AgregaJugaLaguna(postTorneo: postTorneo,),
        ),

      );
    }
  }

  void _verificaTees2() async {
    bool _isOk = true;
    String matriculas = '';
    List<String> _cTee = [];
    List<String> _cMat = [];

    _jugadores.forEach((juga) {
      //print(juga.pathTeeColor);
      if (juga.pathTeeColor == null || juga.pathTeeColor.length <= 5) {
        mToast.showToast('FALTA SELECCIONAR TEE DE: ' + juga.nombre_juga);
        print('*** NOTIFICAR ***:  FALTA SELECCIONAR TEE DE: ' +
            juga.nombre_juga);
        _isOk = false;
      }
      if (matriculas.length > 1) {
        matriculas = matriculas + ', ';
      }
      matriculas = matriculas + ' ' + juga.matricula.trim();
      _cTee.insert(0, juga.pathTeeColor);
      _cMat.insert(0, juga.matricula);
    });
    List<DataJugadorScore> dataJSCTrolTee = await DBApi.getTarjetasControlTee(
        matriculas,
        int.parse(postUser.idjuga_arg),
        int.parse(Torneo.postTorneoJuego.id_torneo));
    if (dataJSCTrolTee != null) {
      dataJSCTrolTee.forEach((dJSCTee) {
        for (int IdP = 0; IdP < _cMat.length; IdP++) {
          if (dJSCTee.matricula == _cMat[IdP]) {
            if (dJSCTee.pathTeeColor != _cTee[IdP]) {
              print('*** NOTIFICAR ***:  DIFERENCIA EN LOS TEE DE: ' +
                  dJSCTee.nombre_juga);

              mToast.showToastCancel(
                  'DIFERENCIA EN LOS TEE DE: ' + dJSCTee.nombre_juga);
              _isOk = false;
            }
          }
        }
      });
    }
    if (_isOk == true) {
      print('PASS CONTROL DE LOS TEES ');
      Torneo.dataJugadoresScore = _jugadores;
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          child: ScoreCardTeam(),
        ),

      );
    }
  }


  ///----------------------------------------------
  ///

  createAlertDialogRegEquipo(BuildContext context) {
    TextEditingController controllerMatricula = new TextEditingController();
    final TextEditingController controllerNombre = new TextEditingController(text: '');
    TextEditingController controllerHcp = new TextEditingController();
    TextEditingController controllerSexo = new TextEditingController();
    TextEditingController controllerCelular = new TextEditingController();
    TextEditingController controllerEmail = new TextEditingController();
    TextEditingController controllerPass = new TextEditingController();
    TextEditingController controllerPass2 = new TextEditingController();
    TextEditingController controllerLevelS = new TextEditingController();
    controllerLevelS.text = '0';
    bool _isValidMatricula = true;

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Container(
              decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(16)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 300,
                      alignment: Alignment.center,
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Agregar un Número para registrar su Equipo, este número será luego su Licencia',
                            style: TextStyle(fontSize: 14, color: Colors.black), textAlign: TextAlign.center,
                            textScaleFactor: 1,
                          ),
                          Container(
                            height: 5,
                          ),
                          Container(
                            height: 70,
                            child: TextFormField(
                              onChanged: (text) {
                                print("First text field: $text");
                                buscarMatriculaReg(text, controllerNombre,
                                    controllerHcp, controllerSexo, controllerCelular, controllerEmail, controllerPass, controllerPass2, controllerLevelS);
                              },
                              onEditingComplete: () {
                                print("onEditingComplete ");
                              },
                              keyboardType: TextInputType.number,
                              controller: controllerMatricula,
                              maxLength: 9,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.golf_course,
                                    color: Color(0xFF56bcbb)),
                                labelText: "Número Equipo",
                                labelStyle: TextStyle(
                                    fontSize: 20, color: Color(0xFF56bcbb)),
                              ),
                            ),
                          ),
                          Container(
                            height: 20,
                          ),
                          Text(
                            'Agregar un Nombre para su Equipo',
                            style: TextStyle(fontSize: 14, color: Colors.black), textAlign: TextAlign.center,
                            textScaleFactor: 1,
                          ),
                          Container(
                            height: 5,
                          ),
                          Container(
                            height: 70,
                            child: TextFormField(
                              // enabled: _isValidMatricula,
                              controller: controllerNombre,
                              keyboardType: TextInputType.text,
                              maxLength: 25,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person,
                                    color: Color(0xFF56bcbb)),
                                labelText: 'Nombre Equipo',
                                labelStyle: TextStyle(
                                    fontSize: 20, color: Color(0xFF56bcbb)),
                              ),
                              enabled: controllerNombre.text.isEmpty ? true : false,

                            ),
                          ),
                          // Container(
                          //   height: 70,
                          //   child: TextFormField(
                          //     enabled: _isValidMatricula,
                          //     controller: controllerHcp,
                          //     keyboardType: TextInputType.numberWithOptions(
                          //         decimal: true, signed: false),
                          //     maxLength: 4,
                          //     decoration: InputDecoration(
                          //       border: OutlineInputBorder(),
                          //       prefixIcon: Icon(Icons.create,
                          //           color: Color(0xFF56bcbb)),
                          //       labelText: 'Handicap Index',
                          //       labelStyle: TextStyle(
                          //           fontSize: 15, color: Color(0xFF56bcbb)),
                          //     ),
                          //   ),
                          // ),
                          // Container(
                          //   height: 70,
                          //   child: TextFormField(
                          //     textCapitalization: TextCapitalization.sentences,
                          //     enabled: _isValidMatricula,
                          //     keyboardType: TextInputType.text,
                          //     controller: controllerSexo,
                          //     maxLength: 1,
                          //     decoration: InputDecoration(
                          //       border: OutlineInputBorder(),
                          //       prefixIcon: Icon(Icons.settings_cell,
                          //           color: Color(0xFF56bcbb)),
                          //       labelText: "Sexo F o M",
                          //       labelStyle: TextStyle(
                          //           fontSize: 15, color: Color(0xFF56bcbb)),
                          //     ),
                          //   ),
                          // ),
                          // Container(
                          //   height: 70,
                          //   child: TextFormField(
                          //     enabled: _isValidMatricula,
                          //     keyboardType: TextInputType.number,
                          //     controller: controllerCelular,
                          //     maxLength: 15,
                          //     decoration: InputDecoration(
                          //       border: OutlineInputBorder(),
                          //       prefixIcon: Icon(Icons.settings_cell,
                          //           color: Color(0xFF56bcbb)),
                          //       labelText: "Celular",
                          //       labelStyle: TextStyle(
                          //           fontSize: 12, color: Color(0xFF56bcbb)),
                          //     ),
                          //   ),
                          // ),
                          // Container(
                          //   height: 70,
                          //   child: TextFormField(
                          //     enabled: _isValidMatricula,
                          //     controller: controllerEmail,
                          //     maxLength: 60,
                          //     keyboardType: TextInputType.emailAddress,
                          //     decoration: InputDecoration(
                          //       border: OutlineInputBorder(),
                          //       prefixIcon:
                          //       Icon(Icons.mail, color: Color(0xFF56bcbb)),
                          //       labelText: 'Email',
                          //       labelStyle: TextStyle(
                          //           fontSize: 12, color: Color(0xFF56bcbb)),
                          //     ),
                          //   ),
                          // ),
                          // Container(
                          //   height: 70,
                          //   child: TextFormField(
                          //     enabled: _isValidMatricula,
                          //     controller: controllerPass,
                          //     maxLength: 6,
                          //     decoration: InputDecoration(
                          //       border: OutlineInputBorder(),
                          //       prefixIcon: Icon(
                          //         Icons.lock,
                          //         color: Color(0xFF56bcbb),
                          //       ),
                          //       labelText: "Clave",
                          //       labelStyle: TextStyle(
                          //           fontSize: 12, color: Color(0xFF56bcbb)),
                          //     ),
                          //   ),
                          // ),
                          // Container(
                          //   height: 70,
                          //   child: TextFormField(
                          //     enabled: _isValidMatricula,
                          //     controller: controllerPass2,
                          //     maxLength: 6,
                          //     decoration: InputDecoration(
                          //       border: OutlineInputBorder(),
                          //       prefixIcon:
                          //       Icon(Icons.lock, color: Color(0xFF56bcbb)),
                          //       labelText: "Repetir Clave",
                          //       labelStyle: TextStyle(
                          //           fontSize: 12, color: Color(0xFF56bcbb)),
                          //     ),
                          //   ),
                          // ),
                          Container(
                            height: 20,
                          ),
                          Container(
                              height: 40,
                              alignment: Alignment.topCenter,
                              child: RaisedButton(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    new BorderRadius.circular(15.0)),
                                color: Color(0xFF1f2f50),
                                child: Text(
                                  'ENVIAR REGISTRO',
                                  textScaleFactor: 1.0,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15.0, color: Colors.white),
                                ),
                                onPressed: () {
                                  _grabarDatosRegis(
                                      context,
                                      controllerHcp,
                                      controllerSexo,
                                      controllerCelular,
                                      controllerEmail,
                                      controllerPass,
                                      controllerPass2,
                                      controllerLevelS,
                                      controllerMatricula.text,
                                      controllerNombre.text);
                                },
                              ),
                            ),
                          Expanded(
                            child: Container(
                              height: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  buscarMatriculaReg(
      String matricula,
      TextEditingController controllerNombre,
      TextEditingController controllerHcp,
      TextEditingController controllerSexo,
      TextEditingController controllerCelular,
      TextEditingController controllerEmail,
      TextEditingController controllerPass,
      TextEditingController controllerPass2,
      TextEditingController controllerLevelS) async {
    PostJuga postJugaBusca = await DBApi.getJugador(matricula);
    if (postJugaBusca != null) {
      controllerLevelS.text = postJugaBusca.level_security.toString();
      controllerNombre.text = postJugaBusca.nombre_juga;
      if (postJugaBusca.level_security <= 1) {
        controllerHcp.text = postJugaBusca.hcp;
      } else {
        controllerNombre.text = 'Usuario registrado';
        controllerHcp.text = 'Usuario registrado';
      }
    } else {
      controllerLevelS.text = '0';
      controllerNombre.text = '';
      controllerHcp.text = ' ';
      controllerSexo.text = 'T';
      controllerCelular.text = '000000000000';
      controllerEmail.text = 'actualizar@tumail.com';
      controllerPass.text = '123456';
      controllerPass2.text = '123456';
    }
  }

  Future<void> _grabarDatosRegis(
      BuildContext context,
      TextEditingController controllerHcp,
      TextEditingController controllerSexo,
      TextEditingController controllerCelular,
      TextEditingController controllerEmail,
      TextEditingController controllerPass,
      TextEditingController controllerPass2,
      TextEditingController controllerLevelS,
      String jugaMatricula,
      String jugaNombre) async {
    if (_isFirstClick == false) {
      return;
    }

    MessagesToast mToast = new MessagesToast(context: context);
    print(controllerLevelS.text);
    if (int.parse(controllerLevelS.text) > 1) {
      mToast.showToastCancel('Ya existe un Registro');
      return;
    }

    print('Grabando registro...');
    // Validaciones
    String controlErrores = '';
    String valHcp = controllerHcp.text;
    String valSexo = controllerSexo.text;
    String valCelular = controllerCelular.text;
    String valEmail = controllerEmail.text;
    String valClave = controllerPass.text;
    String valClave2 = controllerPass2.text;

    if (jugaNombre.length < 5) {
      controlErrores =
          controlErrores + '• Verifique la Matricula AAG                   ';
    }
    if (valEmail.length < 5) {
      controlErrores =
          controlErrores + '• Email incorrecto                            ';
    } else {
      final bool isValidMail = EmailValidator.validate(valEmail);
      if (isValidMail == false) {
        controlErrores =
            controlErrores + '• Email incorrecto                          ';
      }
    }
    if (valHcp.length < 1) {
      controlErrores =
          controlErrores + '• Handicap Incorrecto                       ';
    }
    if (valSexo.length < 1) {
      controlErrores =
          controlErrores + '• Verifique Sexo (F o M)                       ';
    }
    if (valCelular.length < 9) {
      controlErrores =
          controlErrores + '• Celular incorrecto                       ';
    }
    if (valClave.trim().length < 6) {
      controlErrores = controlErrores + '• La Clave debe tener 6 caracteres';
    } else {
      if (valClave.trim() != valClave2.trim()) {
        controlErrores = controlErrores + '• Las Claves deben ser iguales';
      }
    }
    if (controlErrores.length > 2) {
      mToast.showToastCancel(controlErrores);
    } else {
      _isFirstClick = false;
      mToast.showToast('AGUARDE UNOS SEGUNDOS, se están verificando sus datos');

      // TODO AQUI SPINNER.ON........
      await DBApi.registerUser(jugaMatricula, jugaNombre,
          controllerHcp.text, controllerSexo.text, controllerCelular.text, controllerEmail.text, controllerPass.text);
      // TODO AQUI SPINNER.OFF........
      _isFirstClick = true;

      Navigator.of(context).pop();

      // var _pasaDato = dialogoOk(
      //     context: context,
      //     title: 'Registro de Usuarios',
      //     message: 'Ingrese al mail para concluir con la Suscripción');
    }
  }



}

bool controlMatricula(List<DataJugadorScore> jugadores, String matricula) {
  bool dtaR = false;
  for (int idx = 0; idx < jugadores.length; idx++) {
    if (jugadores[idx].matricula == matricula) {
      return true;
    }
  }
  return dtaR;
}
