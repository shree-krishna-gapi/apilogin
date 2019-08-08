

import 'dart:async';
import 'dart:convert';

import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/subjects.dart';
import 'package:alertd/models/user.dart';

class ConnectedProgramsModel extends Model{

  User _authenticatedUser;
  bool _isLoading = false;
}

class UserModel extends ConnectedProgramsModel{
  User _authenticatedUser;
  PublishSubject<bool> _userSubject = PublishSubject();
  User get user {
    return _authenticatedUser;
  }
  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(String username, String password) async{
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'user_login': username,
      'password': password,
    };
    http.Response response;
    response = await http.post(
      'https://foodyorder.com/api/api/front/Users/authenticate',
//      'http://imloyal-co-uk.stackstaging.com/wp-json/loyal_rest/v1/user_login',
      body: authData,
      headers: {
        'x-api-key': 'SRHCnJE44WVe3sLzdD6'},
    );
    final Map<String, dynamic> responseData = json.decode(response.body);
    _isLoading = false;
    notifyListeners();
    print(responseData['status']);
    print(responseData['data']);


    if(responseData['status'] == '200'){
      final List<dynamic> data = responseData['data'];
      print(data[0]['token']);
      print(data[0]['user_email']);
      print(data[0]['user_id']);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token',  data[0]['token'] );
      prefs.setString('userEmail',  data[0]['user_email'] );
      prefs.setInt('userId', data[0]['user_id']);

      _authenticatedUser = User(
          id:  data[0]['user_id'],
          email: data[0]['user_email'],
          token: data[0]['token']);
      _userSubject.add(true);
    }

    return responseData;

  }

  //  Future<Map<String, dynamic>> register(String fullname,String email,String dob, String password) async{
  //   _isLoading = true;
  //   notifyListeners();
  //     final Map<String, dynamic> registerData = {
  //     'full_name': fullname,
  //     'email': email,
  //     'dob': dob,
  //     'password': password,
  //     };
  //      http.Response response;
  //       response = await http.post(
  //       'http://imloyal-co-uk.stackstaging.com/wp-json/loyal_rest/v1/user_register',
  //       body: registerData,
  //       headers: {
  //        'x-api-key': 'SRHCnJE44WVe3sLzdD6'},
  //     );
  //     final Map<String, dynamic> responseData = json.decode(response.body);
  //       _isLoading = false;
  //       notifyListeners();
  //       print(responseData['status']);
  //       print(responseData['data']);


  //       if(responseData['status'] == '200'){
  //         final List<dynamic> data = responseData['data'];
  //      print(data[0]['token']);
  //      print(data[0]['user_email']);
  //      print(data[0]['user_id']);
  //      final SharedPreferences prefs = await SharedPreferences.getInstance();
  //     prefs.setString('token',  data[0]['token'] );
  //     prefs.setString('userEmail',  data[0]['user_email'] );
  //     prefs.setInt('userId', data[0]['user_id']);

  //     _authenticatedUser = User(
  //         id:  data[0]['user_id'],
  //         email: data[0]['user_email'],
  //         token: data[0]['token']);
  //         _userSubject.add(true);
  //       }

  //     return responseData;

  // }


  void autoAuthenticate() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    if(token != null){
      final String userEmail = prefs.getString('userEmail');
      final int userId = prefs.getInt('userId');
      _authenticatedUser = User(id: userId, email: userEmail, token: token);
      _userSubject.add(true);
      notifyListeners();
    }

  }

  void logout() async{

    _authenticatedUser = null;
    _userSubject.add(false);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
    prefs.remove('userEmail');
    prefs.remove('token');
  }


}


class UtilityModel extends ConnectedProgramsModel {
  bool get isLoading {
    return _isLoading;
  }
}

