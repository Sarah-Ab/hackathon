import 'package:firebase_database/firebase_database.dart';
import 'package:hackathon/domain/artiste.dart';

import 'domain/edition.dart';

class Database {
  static final instance = Database._();

  final DatabaseReference _ref = FirebaseDatabase.instance.reference();


  Database._();

  Future<Artiste> artist(int id) async {
    return Artiste.fromJSON((await _ref.child("artists/$id").get()).value);
  }

  Future<Edition> edition(int annee) async {
    return ((await _ref.child("edition/$annee").get()).value);
  }





}
