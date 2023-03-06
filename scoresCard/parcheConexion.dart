import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:golfguidescorecard/clubes/bochasColores.dart';
import 'package:golfguidescorecard/jugadores/jugador.dart';
import 'package:golfguidescorecard/main.dart';
import 'package:golfguidescorecard/mod_serv/model.dart';
import 'package:golfguidescorecard/models/postTorneo.dart';
import 'package:golfguidescorecard/scoresCard/agregarModalidad.dart';
import 'package:golfguidescorecard/scoresCard/scoreCard.dart';
import 'package:golfguidescorecard/scoresCard/torneo.dart';
import 'package:golfguidescorecard/services/db-api.dart';
import 'package:golfguidescorecard/utilities/global-data.dart';
import 'package:golfguidescorecard/utilities/messages-toast.dart';
import 'package:golfguidescorecard/utilities/user-funtions.dart';
import 'package:page_transition/page_transition.dart';

import '../mod_serv/servicesScore.dart';
import 'package:recase/recase.dart';

class ParcheConexion extends StatefulWidget {
  final PostTorneo postTorneo;
  ParcheConexion({@required this.postTorneo});
  @override
  ParcheConexionState createState() => ParcheConexionState(postTorneo: postTorneo);
}

class ParcheConexionState extends State<ParcheConexion> {
  //******************************************************************************
  var _limiteJugadores = 2;
  //******************************************************************************
  MessagesToast mToast;
  PostUser postUser = GlobalData.postUser;
  PostTorneo postTorneo;
  ParcheConexionState({@required this.postTorneo});
  PostClub postClub;
  List<DataJugadorScore> _jugadores;
  GlobalKey<ScaffoldState> _scaffoldKey;
  TextEditingController _matriculaController;
  PostJuga _selectedJugador;
  bool _isupdating;
  String _titleProgress;

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
                  height: 200,
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Image.network(postClub.imagen.trim() ?? '',
                            fit: BoxFit.fitWidth),
                        color: Colors.black,
                      ),
                      Container(
                        padding: EdgeInsets.all(2.0),
                        height: 130,
                        width: 130,
                        color: Colors.white.withOpacity(.5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(25.0),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('assets/clubes/logocolor.png'),
//                          image: AssetImage('assets/Logo02.png'),
                                    fit: BoxFit.fitHeight),
                              ),
                            ),
                            // Container(
                            //   child: SizedBox(
                            //     height: 10.0,
                            //   ),
                            // ),
                            // Container(
                            //   width: 110,
                            //   height: 55,
                            //   child: Image.network(postClub.logo.trim() ?? '',
                            //       fit: BoxFit.contain),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 20,
                    ),
//                     Container(
// //                    color: Colors.black12,
//                       width: 200,
//                       height: 40,
//                       child: TextField(
//                         textCapitalization: TextCapitalization.sentences,
//                         keyboardType: TextInputType.numberWithOptions(
//                             decimal: false, signed: true),
//                         textAlign: TextAlign.center,
//                         controller: _matriculaController,
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(),
//                           labelText: 'Agregar Licencia',
//                           labelStyle:
//                           TextStyle(fontSize: 12, color: Colors.black),
//                         ),
//                       ),
//                     ),
//                     Container(
//                         padding: EdgeInsets.all(10),
//                         height: 60,
//                         child: FloatingActionButton(
//                           backgroundColor: Color(0xFF1f2f50),
// //                        backgroundColor: Color(0xFFFF0030),
//                           onPressed: () {
//                             if (_jugadores.length < _limiteJugadores) {
//                               if (controlMatricula(
//                                   _jugadores, _matriculaController.text) ==
//                                   false) {
//                                 buscarMatricula();
//                                 _clearValues();
//                               } else {
//                                 print('YA EXISTE EL JUGADOR');
//                               }
//                             } else {
//                               // NOTA: Avisar que no se pueden agregar más...
//                               print('NO SE PUEDEN AGREGAR JUGADORES');
//                             }
//                           },
//                           child: Icon(Icons.add, color: Colors.white),
//                         )),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 50,
                  child: Column(
                    children: [
                      Text(
                        'VERIFIQUE SI SU CONEXION ESTA ACTIVA.',
                        style: TextStyle(
                            fontSize: 25, color: Colors.red, fontWeight: FontWeight.bold
                        ),
                        textAlign: TextAlign.center,
                        textScaleFactor: 1,
                      ),
                      Container (
                        height: 20,
                      ),
                      Text(
                        'Si su conexión falló en algún momento, haga click en el siguiente botón.',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                        textAlign: TextAlign.center,
                        textScaleFactor: 1,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 20,
                  child: SizedBox(),
                ),
                RaisedButton(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  color: Color(0xFF1f2f50),
                  child: Text('RECONECTAR',
                      textScaleFactor: 1.0,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 25.0, color: Colors.white)),
                  onPressed: () {
                    _verificaTees();
                  },
                ),
                RaisedButton(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  color: Colors.grey,
                  child: Text('Menú Principal',
                      textScaleFactor: 1.0,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18.0, color: Colors.black)),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          child:Publi(),
                        ),
                        ModalRoute.withName('/')
                    );
                  },
                  // onPressed: () {
                  //   Navigator.of(context).pop();
                  // },
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

  // Crear Alerta
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
                            'TO PLAY   X',
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

  void _verificaTees() async {
    bool _isOk = true;
    String matriculas = '';
    List<String> _cTee = [];
    List<String> _cMat = [];

    _jugadores.forEach((juga) {
      //print(juga.pathTeeColor);
      if (juga.pathTeeColor == null || juga.pathTeeColor.length <= 5) {
        mToast.showToast(' FALTA SELECCIONAR TEE DE: ' + juga.nombre_juga);
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
      Navigator.pop(context);
      Navigator.pop(context);
      // Navigator.push(
      //   context,
      //   PageTransition(
      //     type: PageTransitionType.fade,
      //     child: AgregaModalidad(
      //       postTorneo: postTorneo,
      //     ),
      //     // child: ScoreCard(),
      //   ),
      //
      // );
    }
  }

///----------------------------------------------
///

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
