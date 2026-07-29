import 'package:drift_flutter/drift_flutter.dart';

import 'app_database.dart';

AppDatabase createAppDatabase() => AppDatabase(driftDatabase(name: 'dianduji'));
