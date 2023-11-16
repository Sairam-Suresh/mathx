import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mathx/logic/data_storage/database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'db_riverpod.g.dart';

@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) {
  return AppDatabase();
}
