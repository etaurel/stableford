import 'package:flutter/foundation.dart';

class PostApiError {
  final String errorCode;
  final String errorMessage;

  PostApiError({this.errorCode, this.errorMessage});

  factory PostApiError.fromJson(Map<String, dynamic> json) {
    return PostApiError(
        errorCode: json['errorCode'] as String,
        errorMessage: json['errorMessage'] as String);
  }
}

class TranferData {
  final String responseBody;
  final PostApiError postApiError;
  final Object postObject;

  //TranferData(String resBody, PostApiError apiError, PostUser postUser);
  TranferData(this.responseBody, this.postApiError, this.postObject);
}

//class PostTorneo {
//  /// No faltaria Nombre de Club?
//  final String idjuga_arg;
//  final String matricula;
//  final String nombre_juga;
//  final String hcp;
//  final String hcp3;
//  final String celular;
//  final String email;
//  final String idclub;
//  final String sexo;
//  final String images;
//  final String pais_juga;
//  final String start_date;
//
//  PostTorneo({
//    @required this.idjuga_arg,
//    @required this.matricula,
//    @required this.nombre_juga,
//    @required this.hcp,
//    @required this.hcp3,
//    @required this.celular,
//    @required this.email,
//    @required this.idclub,
//    @required this.sexo,
//    @required this.images,
//    @required this.pais_juga,
//    @required this.start_date,
//  });
//
//  factory PostTorneo.fromJson(Map<String, dynamic> json) {
//    return PostTorneo(
//      idjuga_arg: json['id_user'] as String,
//      matricula: json['matricula'] as String,
//      nombre_juga: json['nombre'] as String,
//      hcp: json['hcp'] as String,
//      hcp3: json['hcp_3'] as String,
//      celular: json['celular'] as String,
//      email: json['email'] as String,
//      idclub: json['club'] as String,
//      sexo: json['sexo'] as String,
//      images: json['imagen'] as String,
//      pais_juga: json['id_pais'] as String,
//      start_date: json['start_date'] as String,
//    );
//  }
//}


// import 'package:flutter/foundation.dart';
//
// class PostApiError {
//   final String errorCode;
//   final String errorMessage;
//
//   PostApiError({this.errorCode, this.errorMessage});
//
//   factory PostApiError.fromJson(Map<String, dynamic> json) {
//     return PostApiError(
//         errorCode: json['errorCode'] as String,
//         errorMessage: json['errorMessage'] as String);
//   }
// }
//
// class TranferData {
//   final String responseBody;
//   final PostApiError postApiError;
//   final Object postObject;
//
//   //TranferData(String resBody, PostApiError apiError, PostUser postUser);
//   TranferData(this.responseBody, this.postApiError, this.postObject);
// }
//
// //class PostTorneo {
// //  /// No faltaria Nombre de Club?
// //  final String idjuga_arg;
// //  final String matricula;
// //  final String nombre_juga;
// //  final String hcp;
// //  final String hcp3;
// //  final String celular;
// //  final String email;
// //  final String idclub;
// //  final String sexo;
// //  final String images;
// //  final String pais_juga;
// //  final String start_date;
// //
// //  PostTorneo({
// //    @required this.idjuga_arg,
// //    @required this.matricula,
// //    @required this.nombre_juga,
// //    @required this.hcp,
// //    @required this.hcp3,
// //    @required this.celular,
// //    @required this.email,
// //    @required this.idclub,
// //    @required this.sexo,
// //    @required this.images,
// //    @required this.pais_juga,
// //    @required this.start_date,
// //  });
// //
// //  factory PostTorneo.fromJson(Map<String, dynamic> json) {
// //    return PostTorneo(
// //      idjuga_arg: json['id_user'] as String,
// //      matricula: json['matricula'] as String,
// //      nombre_juga: json['nombre'] as String,
// //      hcp: json['hcp'] as String,
// //      hcp3: json['hcp_3'] as String,
// //      celular: json['celular'] as String,
// //      email: json['email'] as String,
// //      idclub: json['club'] as String,
// //      sexo: json['sexo'] as String,
// //      images: json['imagen'] as String,
// //      pais_juga: json['id_pais'] as String,
// //      start_date: json['start_date'] as String,
// //    );
// //  }
// //}
