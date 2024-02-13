import 'package:mongo_db_copier/mongo_db_copier.dart';

void main(List<String> args) async {
  Copier copier = Copier();
  await copier.connect();
  await copier.copy();
}
