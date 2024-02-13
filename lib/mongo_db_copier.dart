// ignore_for_file: unused_element

import 'dart:async';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_db_copier/constants.dart';

class Copier {
  late Db _source;
  late Db _target;

  Future<void> connect() async {
    Constants constants = Constants();
    print('Connecting to Databases');
    _source = await _Connector(constants.sourceLink).connect();
    print('connected to source db');
    _target = await _Connector(constants.targetLink).connect();
    print('connected to target db');
  }

  Future<void> copy() async {
    var sourceCollections = await _source.getCollectionNames();
    for (var collection in sourceCollections) {
      if (collection == null) {
        print('Skipping collection {name=null}');
        continue;
      }
      print('Copying collection $collection');
      await _copyCollection(collection);
      print('collection $collection copied');
    }
    print('All collections copied successfully');
  }

  Future<void> _copyCollection(String name) async {
    var sourceCollection = _source.collection(name);
    // all items in the source collection
    var sourceItems = await _futureFind(sourceCollection);
    var targetCollection = _target.collection(name);
    await targetCollection.insertAll(sourceItems);
  }

  Future<List<Map<String, dynamic>>> _futureFind(
      DbCollection collection) async {
    Completer<List<Map<String, dynamic>>> completer =
        Completer<List<Map<String, dynamic>>>();

    List<Map<String, dynamic>> data = [];

    var stream = collection.find().listen((event) {
      data.add(event);
    });
    stream.onDone(() {
      completer.complete(data);
    });
    return completer.future;
  }
}

class _Connector {
  final String link;

  const _Connector(this.link);

  Future<Db> connect() async {
    Db db = await Db.create(link);
    await db.open();
    return db;
  }
}
