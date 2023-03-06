
import 'package:golfguidescorecard/mod_serv/model.dart';
import 'package:golfguidescorecard/models/postTorneo.dart';
import 'package:golfguidescorecard/services/api-cfg.dart';
import 'package:golfguidescorecard/services/service.dart';
import 'package:golfguidescorecard/models/model.dart';
import 'package:golfguidescorecard/utilities/fecha.dart';

class Torneo{
  static List<DataJugadorScore> dataJugadoresScore;
  static PostTorneo postTorneoJuego;
  static List<PostTorneo> postUserTorneos;
  //static List<PostJuga> postJugadores;
  static Future<bool> getTorneo(String codigo_torneo) async {
    var pFilters = {
      "codigo_torneo": codigo_torneo,
    };
    TranferData tranferData = await fetchRBTorneo(ApiTorneosMethod.getTorneoByCodigo, pFilters, null, null, enableGlobalData:false, enableAlert:false) ;
    if (tranferData != null) {
      var resBody = tranferData.responseBody;
      if (resBody.length > 1) {
          postTorneoJuego = tranferData.postObject;
          return true;
      }
      return false;

    }
    return false;
  }

  static Future<PostTorneo> getTorneoId(int idTorneo) async {
    var pFilters = {
      "id_torneo": idTorneo,
    };
    TranferData tranferData = await fetchRBTorneo(ApiTorneosMethod.getTorneo, pFilters, null, null, enableGlobalData:false, enableAlert:false) ;
    if (tranferData != null) {
      var resBody = tranferData.responseBody;
      if (resBody.length > 1) {
        PostTorneo postTJ = tranferData.postObject;
        return postTJ;
      }
      return null;

    }
    return null;
  }

  static Future<List<PostTorneo>> getTorneosMios(String matricula) async {
    var pFilters = {
      "id_user": matricula,
    };

    TranferData tranferData = await fetchRBTorneos(ApiTorneosMethod.getTorneoAllExtend, pFilters, null, null, enableGlobalData:false, enableAlert:false) ;
    if (tranferData != null) {
      var resBody = tranferData.responseBody;
      if (resBody.length > 1) {
        List<PostTorneo> list = tranferData.postObject;
        return list.where((torneos) => torneos.id_user == matricula).toList();
      }
      return null;
    }
    return null;
  }
  static Future<List<PostTorneo>> getTorneos(String matricula, DateTime fecha) async {
    var pFilters = {
      "id_user": matricula,
      "start_date":Fecha.toAnsiSql(fecha),
    };
    TranferData tranferData = await fetchRBTorneos(ApiTorneosMethod.getTorneoAllExtend, pFilters, null, null, enableGlobalData:false, enableAlert:false) ;
    if (tranferData != null) {
      var resBody = tranferData.responseBody;
      if (resBody.length > 1) {
        List<PostTorneo> list = tranferData.postObject;
        return list;
      }
      return null; // List<PostTorneo>();
    }
    return null; // List<PostTorneo>();
  }

  static Future<List<PostTorneo>> getTorneosFecha(DateTime fecha) async {
    var pFilters = {
      "start_date":Fecha.toAnsiSql(fecha),
    };
    TranferData tranferData = await fetchRBTorneos(ApiTorneosMethod.getTorneoAllExtend, pFilters, null, null, enableGlobalData:false, enableAlert:false) ;
    if (tranferData != null) {
      var resBody = tranferData.responseBody;
      if (resBody.length > 1) {
        List<PostTorneo> list = tranferData.postObject;
        return list;
      }
      return null; // List<PostTorneo>();
    }
    return null; // List<PostTorneo>();
  }

  static Future<List<PostTorneo>> getTodosLosTorneos() async {
    TranferData tranferData = await fetchRBTorneos(ApiTorneosMethod.getTorneoAllExtend, null, null, null, enableGlobalData:false, enableAlert:false);
    if (tranferData != null) {
      var resBody = tranferData.responseBody;
      if (resBody.length > 1) {
        List<PostTorneo> list = tranferData.postObject;
        return list;
      }
      return null; // List<PostTorneo>();
    }
    return null; // List<PostTorneo>();
  }

  static Future<List<PostControlSC>> getControlSC(int id_torneo, int id_user, String matriculas,String operador) async {
    var pFilters = {
      "id_torneo": id_torneo.toString(),
      "id_user": id_user.toString(),
      "matriculas": matriculas,
      'operador' : operador,

    };
    TranferData tranferData = await fetchRBTarjetas(ApiTarjetasMethod.getControlScore , pFilters, null, null) ;
    if (tranferData != null) {
      var resBody = tranferData.responseBody;
      if (resBody.length > 1) {
        List<PostControlSC> list = tranferData.postObject;
        return list;
      }
      return null; // List<PostTorneo>();
    }
    return null; // List<PostTorneo>();
  }

  static  Future<List<PostLeaderboard>>  getLeaderboard(String id_torneo) async {
    var pFilters = {"id_torneo": id_torneo.toString()};
    TranferData tranferData = await fetchRBLeaderBoard(ApiTarjetasMethod.getLeaderboard , pFilters, null, null) ;
    if (tranferData != null) {
      var resBody = tranferData.responseBody;
      if (resBody.length > 1) {
        List<PostLeaderboard> list = tranferData.postObject;
        return list;
      }
      return null; // List<PostTorneo>();
    }
    return null; // List<PostTorneo>();

  }

}