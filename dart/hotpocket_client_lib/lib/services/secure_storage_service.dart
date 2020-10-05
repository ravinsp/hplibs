import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//Added this class to make flutter secure storage singleton
class SecureStorageService {
  FlutterSecureStorage _flutterSecureStorage;

  SecureStorageService() {
    _flutterSecureStorage = FlutterSecureStorage();
  }

  FlutterSecureStorage getInstance() {
    return _flutterSecureStorage;
  }

  Future<dynamic> read(String key) async {
    final item = await _flutterSecureStorage
    .read(key: key);

    try {
      return jsonDecode(item);
    }
    catch (e){}
    
    return item;
  }

  Future write(String key, dynamic item) async {
    await _flutterSecureStorage
        .write(key: key, value: jsonEncode(item));
  }

  Future delete(String key) async {
    await _flutterSecureStorage
        .delete(key: key);
  }

  Future deleteAll() async {
    await _flutterSecureStorage
        .deleteAll();
  }

  Future<int> insertIdentityItem(String key, dynamic item) async {
    // If storage already has a object with a id then it'll be added along with the new item
    // If storage already has a object without id then it'll be marked as id=1 and added along with the new item
    // If storage already has a value which is not in json format the new item will override the exiting
    // If storage already has a list of objects with id the the new item will be added along with them
    // If storage already has a list of objects without id the ides will be set and the new item will be added along with them
    // If storage already has a list of value wich are not in json format the new item will override the exiting
    final dynamic items = await read(key);

    var existingItems = List<dynamic>();
    try {
      existingItems = items.toList();
    }
    catch(e1) {
      try {
        if (items['id'] == null || int.parse(items['id']) == 0) {
          items['id'] = 1;
        }
        existingItems.add(items);
      }
      catch(e2) {}
    }

    var id = 0;
    try {  
      id = existingItems.length > 0 ?
      existingItems.reduce((max, e) => max = e['id'] != null && e['id'] > max['id'] ? e : max)['id'] : 0;
      id = id != null ? id : 0;
      existingItems.where((e) => e['id'] == null || e['id'] == 0).forEach((e) { e['id'] = ++id; });
    }
    catch(e) {
      existingItems = List<dynamic>();
    }
    
    item.id = ++id;
    existingItems.add(item);
    await write(key, existingItems);

    return id;
  }
}
