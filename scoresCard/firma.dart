import 'dart:convert';
import 'dart:typed_data';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:golfguidescorecard/herramientas/myClipper.dart';
import 'package:golfguidescorecard/herramientas/bottonNavigator.dart';
import 'package:golfguidescorecard/models/postTorneo.dart';
import 'package:golfguidescorecard/scoresCard/leaderBoard.dart';
import 'package:golfguidescorecard/scoresCard/scoreCard.dart';
import 'package:golfguidescorecard/scoresCard/tablaResultados.dart';
import 'package:golfguidescorecard/services/db-admin.dart';
import 'package:golfguidescorecard/utilities/global-data.dart';
import 'package:hand_signature/signature.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';

HandSignatureControl control = new HandSignatureControl(
  threshold: 5.0,
  smoothRatio: 0.65,
  velocityRange: 2.0,
);

ValueNotifier<String> svg = ValueNotifier<String>(null);

ValueNotifier<ByteData> rawImage = ValueNotifier<ByteData>(null);

class Firma extends StatelessWidget {
  // This widget is the root of your application.
  List<DataJugadorScore> _dataJugadoresScore;
  int _indiceJuga=0;
  Firma({List<DataJugadorScore> dataJugadoresScore, int indiceJuga}) {
    control.clear();
    _dataJugadoresScore = dataJugadoresScore;
    _indiceJuga=indiceJuga;

  }

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: SingleChildScrollView(
    child: Container(
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: <Widget>[
                    Container(
//                      padding: EdgeInsets.all(70.0),
                    height: 120,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        image: DecorationImage(
                            image: NetworkImage(
                                'http://scoring.com.ar/app/images/clubes/112.jpg'
////                    GlobalData.postTorneo.postClub.imagen.trim() ?? '', /// TIRA POST CLUB NULL
                                ),
                            fit: BoxFit.cover),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(2.0),
                      height: 70,
                      width: 130,
                      color: Colors.white.withOpacity(.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 110,
                            height: 55,
                            child: Image.asset(
                                'assets/clubes/logocolor.png',
                                fit: BoxFit.contain),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),),
        ),
        backgroundColor: Colors.grey,
        body:
        // SingleChildScrollView(
          // child:
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Stack(
                children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      height: 20,
                    ),
                    Container(
                      height: 180,
                      color: Colors.white,
                          // .withOpacity(.6),
//                      width: 250,
                      width: 300,
                      alignment: Alignment.center,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Center(
                              child: AspectRatio(
                                aspectRatio: 1.3,
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      constraints: BoxConstraints.expand(),
//                                    color: Colors.black,
                                      child: HandSignaturePainterView(
                                        control: control,
                                        type: SignatureDrawType.shape,
                                      ),
                                    ),
                                    CustomPaint(
                                      painter: DebugSignaturePainterCP(
                                        control: control,
                                        cp: false,
                                        cpStart: false,
                                        cpEnd: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          color: Colors.black,
                          onPressed: control.clear,
                          child: Text('Borrar Firma',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.white)),
                        ),
                        Container(
                          width: 20,
                        ),
                        RaisedButton(
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          color: Colors.blue,
//                          color: Color(0xFFFF0030),
                          onPressed: () async {
                            print('_indiceJuga');
                            print(_indiceJuga);
                            await _grabaFirma(context);
                           // Navigator.popUntil(context, (route) => false);
                          },
                          child: Text('FIRMAR',
                              textScaleFactor: 1.0,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 22.0, color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        _buildImageView(),

                        /// Firma Jugador PNG
//                              SizedBox(
//                                width: 10,
//                              ),
//                              _buildImageView(), /// Firma Marcador Falta
//                      _buildSvgView(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      // ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.keyboard_arrow_left,
            size: 40,
          ),
          backgroundColor: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
            //Navigator.popUntil(context, (route) => false);
          },
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: 0,
          height: 60.0,
          items: <Widget>[
            Builder(builder: (context) {
              return IconButton(
                icon: Icon(Icons.golf_course, size: 30, color: Colors.white),
//              tooltip: 'GPS',
//              onPressed: () {
//                Scaffold.of(context).openDrawer();
//              },
              );
            }),
          ],
          color: Color(0xFF1f2f50),
//        color: Color(0xFFFF0030),
          buttonBackgroundColor: Color(0xFF1f2f50),
//        buttonBackgroundColor: Color(0xFFFF0030),
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 600),
        ),
      ),
    );
  }

  Future _grabaFirma(BuildContext context) async {
    rawImage.value = await control.toImage(
      color: Color(0xFF1f2f50),
    );
    print('_indiceJuga');
    print(_indiceJuga);
    String matricula = _dataJugadoresScore[_indiceJuga].matricula;
    String matriculas = '';

    Uint8List nFirma =
        rawImage.value.buffer.asUint8List();
    print(nFirma.length);

    /// SI ES EL JUGADOR TITULAR

    /// SI ES EL JUGADOR MARCADOR

    /// SI ES OTRO JUGADOR

    if (_indiceJuga==0 && GlobalData.postUser.matricula == matricula) {
      /// SI ES EL JUGADOR TITULAR
      /// firmar su tarjeta y firmar como marcador el resto de las tarjetas
      _dataJugadoresScore[0].firmaUserImage = nFirma;
      for (int iJ = 1; iJ < _dataJugadoresScore.length; iJ++) {
        _dataJugadoresScore[iJ].firmaMarcadorImage = nFirma;
        _dataJugadoresScore[iJ].firmaMarcadorMatricula = matricula;
        if (matriculas.length > 1) {
          matriculas = matriculas + ', ';
        }
        matriculas = matriculas +' ' + _dataJugadoresScore[iJ].matricula.trim();
      }


    }
    if (_indiceJuga==1 && GlobalData.postUser.matricula != matricula && _dataJugadoresScore.length>1  ) {
      /// SI ES EL JUGADOR MARCADOR
      /// firmar su tarjeta y firmar como marcador en el User (TITULAR)

      _dataJugadoresScore[1].firmaUserImage = nFirma;

      _dataJugadoresScore[0].firmaMarcadorImage = nFirma;
      _dataJugadoresScore[0].firmaMarcadorMatricula=matricula;
      matriculas=GlobalData.postUser.matricula;

    }

    if (_indiceJuga>1 && GlobalData.postUser.matricula != matricula && _dataJugadoresScore.length>2) {
      /// SI ES OTRO JUGADOR
      /// firmar su tarjeta unicamente

      _dataJugadoresScore[_indiceJuga].firmaUserImage = nFirma;

    }


    ///grabar en db
    DBAdmin.saveImageFirma(nFirma,_dataJugadoresScore[0].idTorneo,int.parse(GlobalData.postUser.idjuga_arg) ,matricula,matriculas);
    Navigator.of(context).pop(true);

  }

  Widget _buildImageView() => Container(
        width: 1.0,
        height: 1.0,
        // decoration: BoxDecoration(
        //   border: Border.all(),
        //   color: Colors.white30,
        // ),
        child: ValueListenableBuilder<ByteData>(
          valueListenable: rawImage,
          builder: (context, data, child) {
            if (_dataJugadoresScore[0].firmaUserImage.length < 10) {
              return Container(
                color: Colors.black12,
                child: Center(
                  child: Text(
                    'Falta Firma',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                    textAlign: TextAlign.center,
                    textScaleFactor: 1,
                  ),
                ),
              );
            } else {
              //_dataJugadoresScore[0].firmaUserImage=data.buffer.asUint8List();
              return Padding(
                padding: EdgeInsets.all(0.0),
                child: Image.memory(_dataJugadoresScore[0]
                    .firmaUserImage), //data.buffer.asUint8List()),
                //var encoded = base64.encode();
              );
            }
          },
        ),
      );

//  Widget _buildSvgView() => Container(
//        width: 125.0,
//        height: 125.0,
//        decoration: BoxDecoration(
//          border: Border.all(),
//          color: Colors.white30,
//        ),
//        child: ValueListenableBuilder<String>(
//          valueListenable: svg,
//          builder: (context, data, child) {
//            return HandSignatureView.svg(
//              data: data,
//              padding: EdgeInsets.all(8.0),
//              placeholder: Container(
//                color: Colors.red,
//                child: Center(
//                  child: Text(
//                    'No ha firmado (svg)',
//                    style: TextStyle(fontSize: 12, color: Colors.white),
//                    textAlign: TextAlign.center,
//                    textScaleFactor: 1,
//                  ),
//                ),
//              ),
//            );
//          },
//        ),
//      );
}
