import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:golfguidescorecard/clubes/bochasColores.dart';
import 'package:golfguidescorecard/jugadores/buscaJugaGralAgrega.dart';
import 'package:golfguidescorecard/jugadores/jugador.dart';
import 'package:golfguidescorecard/mod_serv/model.dart';
import 'package:golfguidescorecard/models/postTorneo.dart';
import 'package:golfguidescorecard/scoresCard/scoreCard.dart';
import 'package:golfguidescorecard/scoresCard/scoreCardPlumas.dart';
import 'package:golfguidescorecard/scoresCard/scoreCardStb.dart';
import 'package:golfguidescorecard/scoresCard/scoreCardFB.dart';
import 'package:golfguidescorecard/scoresCard/scoreCardStb2.dart';
import 'package:golfguidescorecard/scoresCard/torneo.dart';
import 'package:golfguidescorecard/services/db-api.dart';
import 'package:golfguidescorecard/utilities/display-functions.dart';
import 'package:golfguidescorecard/utilities/global-data.dart';
import 'package:golfguidescorecard/utilities/messages-toast.dart';
import 'package:golfguidescorecard/utilities/user-funtions.dart';
import 'package:page_transition/page_transition.dart';

import '../mod_serv/servicesScore.dart';
import 'package:recase/recase.dart';

class AgregaJugaStb extends StatefulWidget {
  final PostTorneo postTorneo;
  AgregaJugaStb({@required this.postTorneo});
  @override
  AgregaJugaState createState() => AgregaJugaState(postTorneo: postTorneo);
}

class AgregaJugaState extends State<AgregaJugaStb> {
  bool useScoreCardStb2 = false; // Agrega esta variable booleana

  //******************************************************************************
  var _limiteJugadores = 4;
  //******************************************************************************
  MessagesToast mToast;
  PostUser postUser = GlobalData.postUser;
  PostTorneo postTorneo;
  AgregaJugaState({@required this.postTorneo});
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
      mToast.showToastCancel('NO SE PUEDE BORRAR SU USUARIO');

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
                      Container(
                        padding: EdgeInsets.all(2.0),
                        height: 70,
                        width: 200,
                        color: Colors.white.withOpacity(.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
//                            Container(
//                              width: 90,
//                              height: 55,
//                              decoration: BoxDecoration(
//                                image: DecorationImage(
//                                    image: AssetImage('assets/ScoreCard2.png'),
////                          image: AssetImage('assets/Logo02.png'),
//                                    fit: BoxFit.contain),
//                              ),
//                            ),
//                            Container(
//                              child: SizedBox(
//                                height: 10.0,
//                              ),
//                            ),
                            Container(
                              width: 80,
                              height: 55,
                              child: Image.network(postClub.logo.trim() ?? '',
                                  fit: BoxFit.contain),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 110),
                        child: SizedBox(
                          width: 200,
                          child:
                          RaisedButton(
                            color: Color(0xFFCF0707),
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                            child: Text('CREAR JUGADOR',
                                textScaleFactor: 1.0,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.fade,
                                  // child: RegistroEquipo(),
                                  child: createAlertDialogRegEquipo(context),
                                ),
                              );
                            },
                          ),
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
                    Container(
//                    color: Colors.black12,
                      width: 200,
                      height: 40,
                      child: TextField(
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.numberWithOptions(
                            decimal: false, signed: true),
                        textAlign: TextAlign.center,
                        controller: _matriculaController,
                        maxLength: 9,
                        decoration: InputDecoration(
                          counterText: "",
                          border: OutlineInputBorder(),
                          labelText: 'Agregar Licencia',
                          labelStyle:
                              TextStyle(fontSize: 15, color: Colors.black),
                        ),
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.all(10),
                        height: 60,
                        child: FloatingActionButton(
                          backgroundColor: Color(0xFF1f2f50),
//                        backgroundColor: Color(0xFFFF0030),
                          onPressed: () {
                            if (_jugadores.length < _limiteJugadores) {
                              if (controlMatricula(
                                      _jugadores, _matriculaController.text) ==
                                  false) {
                                buscarMatricula();
                                _clearValues();
                              } else {
                                print('YA EXISTE EL JUGADOR');
                                mToast.showToastCancel('YA EXISTE EL JUGADOR');

                              }
                            } else {
                              // NOTA: Avisar que no se pueden agregar más...
                              print('NO SE PUEDEN AGREGAR JUGADORES');
                              mToast.showToastCancel('NO SE PUEDE AGREGAR MAS JUGADORES');
                            }
                          },
                          child: Icon(Icons.add, color: Colors.white),
                        )
                    ),
                    Container(
                      // padding: EdgeInsets.all(10),
                      height: 40,
                      width: 40,
                      child: RaisedButton(
                        padding: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        color: Color(0xFFFFFFFF),
                        child: Icon(Icons.search_outlined, color: Color(0xFF1f2f50)),
                        // Text('BUSCAR MATRICULA',
                        //     textScaleFactor: 1.0,
                        //     textAlign: TextAlign.center,
                        //     style: TextStyle(fontSize: 12.0, color: Color(0xFF5b45cc))),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.fade,
                              child: BuscaJugadoresAgrega(),
                            ),
                          );
                        },
                        // child: Icon(Icons.search_rounded, color: Color(0xFF1f2f50)),
                      ),
                    ),

                  ],
                ),
                Text(
                  'Agregar Licencia de Compañero',
                  style: TextStyle(
                    fontSize: 18, color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  textScaleFactor: 1,
                ),
                Text(
                  '(Sólo 1 Jugador más)',
                  style: TextStyle(
                    fontSize: 16, color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                  textScaleFactor: 1,
                ),
                Container(
                  height: 10,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      /// Datos Matricula
                      DataTable(
                        columnSpacing: 0,
                        horizontalMargin: 10,
                        headingRowHeight: 10,
                        dataRowHeight: 80,
                        columns: [
                          DataColumn(
                            label: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Container(
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(''),
                          ),
                          // Lets add one more column to show a delete button
                        ],
                        rows: _jugadores
                            .map(
                              (jugadorItem) => DataRow(cells: [
                                DataCell(
                                  Container(
                                      height: 70,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          GestureDetector(
                                            child: CircleAvatar(
                                              backgroundImage: AssetImage(
                                                  _estableceTeeImage(
                                                      jugadorItem.pathTeeColor,
                                                      'assets/tees/error.jpg')),
                                              child: Icon(
                                                Icons.golf_course,
                                                color: Colors.white,
                                              ),
                                              radius: 20,
                                            ),
                                            onTap: () {
                                              //print(jugadorItem.pathTeeColor);
                                              var selectTee = _selectTee(
                                                  context: context,
                                                  jugador: jugadorItem);
                                            },
                                          ),
                                          Container(
                                            width: 10,
                                          ),
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundImage: NetworkImage(
                                                jugadorItem.images.trim() ??
                                                    ''),
                                            backgroundColor: Colors.black,
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only(left: 10),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 120,
                                                  height: 15,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    jugadorItem.nombre_juga
                                                            .trim()
                                                            .toLowerCase()
                                                            .titleCase ??
                                                        '',
                                                    textScaleFactor: 1,
                                                    overflow: TextOverflow.clip,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontFamily:
                                                            'DIN Condensed',
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                Container(
                                                  width: 120,
                                                  height: 30,
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    //"${(jugadorItem.matricula.trim() ?? '')} | ${(jugadorItem.hcpTorneo.toString().trim() ?? '00')}",
                                                    "${(jugadorItem.matricula.trim() ?? '')} | ${(UserFunctions.miifObject(jugadorItem.hcpTorneo == 0, jugadorItem.hcpIndex.toString().trim(), jugadorItem.hcpTorneo.toString().trim()) ?? '00')}",
                                                    //${(jugadorItem.hcpTorneo.trim() ?? jugadorItem.hcp.trim())}",
                                                    textScaleFactor: 1,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'DIN Condensed',
                                                        fontSize: 23,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                                DataCell(IconButton(
                                  icon: Icon(Icons.delete, color: Colors.grey, size: 30,),
                                  onPressed: () {
                                    _deleteJugador(jugadorItem);
                                  },
                                ))
                              ]),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 5,
                  child: SizedBox(),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: Icon(Icons.arrow_upward_rounded, size: 35, color: Colors.redAccent),
                    ),
                    Text(
                      'Antes de Jugar, seleccionar',
                      style: TextStyle(fontSize: 18, color: Colors.redAccent, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                      textScaleFactor: 1,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ' TEEs de Salida de cada Jugador ',
                      style: TextStyle(fontSize: 18, color: Colors.redAccent, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                      textScaleFactor: 1,
                    ),
                  ],
                ),


                Container(
                  height: 10,
                  child: SizedBox(),
                ),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       height: 50,
//                       width: MediaQuery.of(context).size.width - 70,
//                       child: RaisedButton(
//                         elevation: 5.0,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: new BorderRadius.circular(20.0)),
//                         color: Color(0xFF1f2f50),
// //                color: Color(0xFFFF0030),
//                         child: Text('JUGAR MEDAL PLAY',
//                             textScaleFactor: 1.0,
//                             textAlign: TextAlign.center,
//                             style: TextStyle(fontSize: 22.0, color: Colors.white)),
//                         onPressed: () {
//                           if (_jugadores.length == _limiteJugadores) {
//                             if (controlMatricula(
//                                 _jugadores, _matriculaController.text) ==
//                                 false) {
//                               _verificaTees();
//
//                             } else {
//                               print('YA EXISTE EL JUGADOR');
//                             }
//                           } else {
//                             // NOTA: Avisar que no se pueden agregar más...
//                             print('FALTAN JUGADORES AGREGAR');
//                             mToast.showToastCancel('DEBE HABER 2 JUGADORES');
//
//                           }
//
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 Container(
//                   height: 5,
//                 ),
//
//                 Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text('9 hoyos >  ',
//                           textScaleFactor: 1.0,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.bold)),
//                       SizedBox(
//                   height: 30,
//                   width: 95,
//                   child: RaisedButton(
//                     elevation: 5.0,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: new BorderRadius.circular(15.0)),
//                     color: Color(0xFF3b299b),
// //                color: Color(0xFFFF0030),
//                     child: Text('Ida',
//                         textScaleFactor: 1.0,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(fontSize: 18.0, color: Colors.white)),
//                     onPressed: () {
//                       if (_jugadores.length == _limiteJugadores) {
//                         if (controlMatricula(
//                             _jugadores, _matriculaController.text) ==
//                             false) {
//                           _verificaTees();
//
//                         } else {
//                           print('YA EXISTE EL JUGADOR');
//                         }
//                       } else {
//                         // NOTA: Avisar que no se pueden agregar más...
//                         print('FALTAN JUGADORES AGREGAR');
//                         mToast.showToastCancel('DEBE HABER 2 JUGADORES');
//
//                       }
//
//                     },
//                   ),
//                 ),
//                       Container(
//                         width: 5,
//                       ),
//                       SizedBox(
//                         height: 30,
//                         width: 95,
//                         child: RaisedButton(
//                           elevation: 5.0,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: new BorderRadius.circular(15.0)),
//                           color: Color(0xFF3b299b),
// //                color: Color(0xFFFF0030),
//                           child: Text('Vuelta',
//                               textScaleFactor: 1.0,
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontSize: 18.0, color: Colors.white)),
//                           onPressed: () {
//                             if (_jugadores.length == _limiteJugadores) {
//                               if (controlMatricula(
//                                   _jugadores, _matriculaController.text) ==
//                                   false) {
//                                 _verificaTees();
//
//                               } else {
//                                 print('YA EXISTE EL JUGADOR');
//                               }
//                             } else {
//                               // NOTA: Avisar que no se pueden agregar más...
//                               print('FALTAN JUGADORES AGREGAR');
//                               mToast.showToastCancel('DEBE HABER 2 JUGADORES');
//
//                             }
//
//                           },
//                         ),
//                       ),
//                     ],
//                 ),
//
//                 Container(
//                   height: 10,
//                 ),
                Text(':: JUGAR ::',
                    textScaleFactor: 1.0,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15.0,
                        fontWeight: FontWeight.bold, color: Colors.black)
                ),
                Container(
                  height: 5,
                  child: SizedBox(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width - 70,
                      child: RaisedButton(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        color: Color(0xFF1f2f50),
                        child: Text('STABLEFORD 85%',
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 22.0, color: Colors.white)),
                        onPressed: () {
                          setState(() {
                            useScoreCardStb2 = !useScoreCardStb2; // Cambia el valor de useScoreCardStb2
                          });
                              _verificaTeesStb();
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 5,
                  child: SizedBox(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width - 70,
                      child: RaisedButton(
                        elevation: 5.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20.0)),
                        color: Color(0xFF1f2f50),
                        child: Text('STABLEFORD 100%',
                            textScaleFactor: 1.0,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 22.0, color: Colors.white)),
                        onPressed: () {
                          setState(() {
                            useScoreCardStb2 = !useScoreCardStb2; // Cambia el valor de useScoreCardStb2
                          });
                          _verificaTeesStb2();
                        },
                      ),
                    ),

                  ],
                ),
                Container(
                  height: 10,
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

  void _verificaTees() async {
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
          child: ScoreCard(),
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

  void _verificaTeesStb() async {
    setState(() {
      useScoreCardStb2 = useScoreCardStb2;
      print(useScoreCardStb2);
    });

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
          child: ScoreCardStb(),
        ),

      );
    }
  }

  void _verificaTeesStb2() async {
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
          child: ScoreCardStb2(),
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
                      height: 550,
                      alignment: Alignment.center,
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Agregar un Número para registrarse, este número será luego su Licencia. (Ej. 7771234)',
                            style: TextStyle(fontSize: 18, color: Colors.black), textAlign: TextAlign.center,
                            textScaleFactor: 1,
                          ),
                          Container(
                            height: 15,
                          ),
                          Container(
                            height: 85,
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
                                labelText: "Número Licencia",
                                labelStyle: TextStyle(
                                    fontSize: 20, color: Color(0xFF56bcbb)),
                              ),
                            ),
                          ),
                          Container(
                            height: 5,
                          ),
                          // Text(
                          //   'Agregar Apellido y Nombre',
                          //   style: TextStyle(fontSize: 18, color: Colors.black), textAlign: TextAlign.center,
                          //   textScaleFactor: 1,
                          // ),
                          // Container(
                          //   height: 5,
                          // ),
                          Container(
                            height: 85,
                            child: TextFormField(
                              // enabled: _isValidMatricula,
                              controller: controllerNombre,
                              textCapitalization: TextCapitalization.sentences,
                              keyboardType: TextInputType.text,
                              maxLength: 25,
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person,
                                    color: Color(0xFF56bcbb)),
                                labelText: 'Apellido y Nombre',
                                labelStyle: TextStyle(
                                    fontSize: 20, color: Color(0xFF56bcbb)),
                              ),
                              enabled: controllerNombre.text.isEmpty ? true : false,

                            ),
                          ),
                          Container(
                            height: 5,
                          ),

                          Container(
                            height: 85,
                            child: TextFormField(
                              enabled: _isValidMatricula,
                              controller: controllerHcp,
                              keyboardType: TextInputType.datetime,
                              maxLength: 4,
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.create,
                                    color: Color(0xFF56bcbb)),
                                labelText: 'Handicap Index',
                                labelStyle: TextStyle(
                                    fontSize: 20, color: Color(0xFF56bcbb)),
                              ),
                            ),
                          ),
                          Container(
                            height: 5,
                          ),

                          Container(
                            height: 85,
                            child: TextFormField(
                              textCapitalization: TextCapitalization.sentences,
                              enabled: _isValidMatricula,
                              keyboardType: TextInputType.text,
                              controller: controllerSexo,
                              maxLength: 1,
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.settings_cell,
                                    color: Color(0xFF56bcbb)),
                                labelText: "Sexo F o M",
                                labelStyle: TextStyle(
                                    fontSize: 20, color: Color(0xFF56bcbb)),
                              ),
                            ),
                          ),
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
                                if (_jugadores.length < _limiteJugadores) {
                                  if (controlMatricula(
                                      _jugadores, _matriculaController.text) ==
                                      false) {
                                    // buscarMatricula();
                                    _clearValues();
                                  } else {
                                    print('YA EXISTE EL JUGADOR');
                                    mToast.showToastCancel('YA EXISTE EL JUGADOR');
                                  }
                                } else {
                                  // NOTA: Avisar que no se pueden agregar más...
                                  print('NO SE PUEDEN AGREGAR JUGADORES');
                                  mToast.showToastCancel('NO SE PUEDE AGREGAR MAS JUGADORES');
                                }

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
      controllerHcp.text = '';
      controllerSexo.text = '';
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
          controlErrores + '• Verifique su Nombre                   ';
    }
    if (valEmail.length < 5) {
      controlErrores =
          controlErrores + '';
    } else {
      final bool isValidMail = EmailValidator.validate(valEmail);
      if (isValidMail == false) {
        controlErrores =
            controlErrores + '';
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
          controlErrores + '';
    }
    if (valClave.trim().length < 6) {
      controlErrores = controlErrores + '';
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
