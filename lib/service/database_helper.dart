import 'package:hike_app/model/hike.dart';
import 'package:hike_app/model/observation.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static const String DATABASE_NAME = "hike_database.db";
  static const int DATABASE_VERSION = 1;

  Future<Database> get database async {
    final dbPath = await getDatabasesPath();
    print(dbPath);
    if (_database == null) {
      _database = await openDatabase(
        DATABASE_NAME,
        version: DATABASE_VERSION,
        onCreate: _createDatabase,
      );
    }
    return _database!;
  }

  // Hikes table
  static const String TABLE_HIKES = "hikes";
  static const String COLUMN_ID = "id";
  static const String COLUMN_HIKE_NAME = "hike_name";
  static const String COLUMN_DESCRIPTION = "description";
  static const String COLUMN_LOCATION_FROM = "location_from";
  static const String COLUMN_LOCATION_TO = "location_to";
  static const String COLUMN_DATE = "date";
  static const String COLUMN_LENGTH = "length";
  static const String COLUMN_DURATION = "duration";
  static const String COLUMN_LEVEL = "level";
  static const String COLUMN_IS_PARKING = "is_parking";

  // Observations table
  static const String TABLE_OBSERVATION = "observations";
  static const String COLUMN_OB_ID = "ob_id";
  static const String COLUMN_OB_HIKE_ID = "ob_hike_id";
  static const String COLUMN_OB_NAME = "ob_name";
  static const String COLUMN_OB_TIME = "ob_time";
  static const String COLUMN_OB_IMAGE = "ob_image";

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $TABLE_HIKES (
        $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        $COLUMN_HIKE_NAME TEXT,
        $COLUMN_DESCRIPTION TEXT,
        $COLUMN_LOCATION_FROM TEXT,
        $COLUMN_LOCATION_TO TEXT,
        $COLUMN_DATE TEXT,
        $COLUMN_LENGTH TEXT,
        $COLUMN_DURATION TEXT,
        $COLUMN_LEVEL TEXT,
        $COLUMN_IS_PARKING TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $TABLE_OBSERVATION (
        $COLUMN_OB_ID INTEGER PRIMARY KEY AUTOINCREMENT,
        $COLUMN_OB_HIKE_ID INTEGER,
        $COLUMN_OB_NAME TEXT,
        $COLUMN_OB_TIME TEXT,
        $COLUMN_OB_IMAGE TEXT,
        FOREIGN KEY ($COLUMN_OB_HIKE_ID) REFERENCES $TABLE_HIKES ($COLUMN_ID) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> planHike(
    String hikeName,
    String description,
    String locationFrom,
    String locationTo,
    String date,
    String length,
    String duration,
    String level,
    String isParking,
  ) async {
    final db = await database;
    final values = <String, dynamic>{
      COLUMN_HIKE_NAME: hikeName,
      COLUMN_DESCRIPTION: description,
      COLUMN_LOCATION_FROM: locationFrom,
      COLUMN_LOCATION_TO: locationTo,
      COLUMN_DATE: date,
      COLUMN_LENGTH: length,
      COLUMN_DURATION: duration,
      COLUMN_LEVEL: level,
      COLUMN_IS_PARKING: isParking,
    };

    final insertedId = await db.insert(TABLE_HIKES, values);
    return insertedId;
  }

  Future<Hike?> getHikeById(int hikeId) async {
    final db = await database; // Assuming you have a database instance

    final where = '$COLUMN_ID = ?';
    final whereArgs = [hikeId];

    final List<Map<String, dynamic>> result =
        await db.query(TABLE_HIKES, where: where, whereArgs: whereArgs);

    if (result.isNotEmpty) {
      final hikeData = result.first;
      return Hike(
        id: hikeData[DatabaseHelper.COLUMN_ID],
        hikeName: hikeData[DatabaseHelper.COLUMN_HIKE_NAME],
        description: hikeData[DatabaseHelper.COLUMN_DESCRIPTION],
        locationFrom: hikeData[DatabaseHelper.COLUMN_LOCATION_FROM],
        locationTo: hikeData[DatabaseHelper.COLUMN_LOCATION_TO],
        date: hikeData[DatabaseHelper.COLUMN_DATE],
        length: hikeData[DatabaseHelper.COLUMN_LENGTH],
        duration: hikeData[DatabaseHelper.COLUMN_DURATION],
        level: hikeData[DatabaseHelper.COLUMN_LEVEL],
        is_parking: hikeData[DatabaseHelper.COLUMN_IS_PARKING],
      );
    } else {
      return null;
    }
  }

  Future<void> updateHike(
    int hikeId,
    String hikeName,
    String description,
    String locationFrom,
    String locationTo,
    String date,
    String length,
    String duration,
    String level,
    String isParking,
  ) async {
    final db = await database;
    final values = <String, dynamic>{
      COLUMN_HIKE_NAME: hikeName,
      COLUMN_DESCRIPTION: description,
      COLUMN_LOCATION_FROM: locationFrom,
      COLUMN_LOCATION_TO: locationTo,
      COLUMN_DATE: date,
      COLUMN_LENGTH: length,
      COLUMN_DURATION: duration,
      COLUMN_LEVEL: level,
      COLUMN_IS_PARKING: isParking,
    };

    await db.update(
      TABLE_HIKES,
      values,
      where: '$COLUMN_ID = ?',
      whereArgs: [hikeId],
    );
  }

  Future<void> deleteHike(int hikeId) async {
    final db = await database;
    await db.delete(TABLE_OBSERVATION,
        where: '$COLUMN_OB_HIKE_ID = ?', whereArgs: [hikeId]);
    await db.delete(TABLE_HIKES, where: '$COLUMN_ID = ?', whereArgs: [hikeId]);
  }

  Future<List<Hike>> getAllHikes() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(TABLE_HIKES);

    return List.generate(maps.length, (index) {
      return Hike(
        id: maps[index][COLUMN_ID],
        hikeName: maps[index][COLUMN_HIKE_NAME],
        description: maps[index][COLUMN_DESCRIPTION],
        locationFrom: maps[index][COLUMN_LOCATION_FROM],
        locationTo: maps[index][COLUMN_LOCATION_TO],
        date: maps[index][COLUMN_DATE],
        length: maps[index][COLUMN_LENGTH],
        duration: maps[index][COLUMN_DURATION],
        level: maps[index][COLUMN_LEVEL],
        is_parking: maps[index][COLUMN_IS_PARKING],
      );
    });
  }

  Future<List<Observation>> getAllObservation() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(TABLE_OBSERVATION);

    return List.generate(maps.length, (index) {
      return Observation(
        obId: maps[index][COLUMN_OB_ID],
        obHikeId: maps[index][COLUMN_OB_HIKE_ID],
        obName: maps[index][COLUMN_OB_NAME],
        obTime: maps[index][COLUMN_OB_TIME],
        obImage: maps[index][COLUMN_OB_IMAGE],
      );
    });
  }

  Future<void> addObservation(
      String observationName, int hikeId, String time, String image) async {
    final db = await database;
    final obValues = <String, dynamic>{
      COLUMN_OB_NAME: observationName,
      COLUMN_OB_HIKE_ID: hikeId,
      COLUMN_OB_TIME: time,
      COLUMN_OB_IMAGE: image,
    };

    await db.insert(TABLE_OBSERVATION, obValues);
  }

  Future<List<Observation>> getAllObservationsByHikeId(int hikeId) async {
    final db = await database;
    final where = '$COLUMN_OB_HIKE_ID = ?';

    final List<Map<String, dynamic>> maps = await db.query(
      TABLE_OBSERVATION,
      where: where,
      whereArgs: [hikeId],
    );

    return List.generate(maps.length, (index) {
      return Observation(
        obId: maps[index][COLUMN_OB_ID],
        obHikeId: maps[index][COLUMN_OB_HIKE_ID],
        obName: maps[index][COLUMN_OB_NAME],
        obTime: maps[index][COLUMN_OB_TIME],
        obImage: maps[index][COLUMN_OB_IMAGE],
      );
    });
  }

  // Inside your DatabaseHelper class

Future<void> updateObservation(
  int obId,
  String observationName,
  String time,
  String image,
) async {
  final db = await database;
  final values = <String, dynamic>{
    COLUMN_OB_NAME: observationName,
    COLUMN_OB_TIME: time,
    COLUMN_OB_IMAGE: image,
  };

  await db.update(
    TABLE_OBSERVATION,
    values,
    where: '$COLUMN_OB_ID = ?',
    whereArgs: [obId],
  );
}


  Future<Observation?> getObservationById(int obId) async {
    final db = await database;

    final where = '$COLUMN_OB_ID = ?';
    final whereArgs = [obId];

    final List<Map<String, dynamic>> result =
        await db.query(TABLE_OBSERVATION, where: where, whereArgs: whereArgs);

    if (result.isNotEmpty) {
      final observationData = result.first;
      return Observation(
        obId: observationData[DatabaseHelper.COLUMN_OB_ID],
        obHikeId: observationData[DatabaseHelper.COLUMN_OB_HIKE_ID],
        obName: observationData[DatabaseHelper.COLUMN_OB_NAME],
        obTime: observationData[DatabaseHelper.COLUMN_OB_TIME],
        obImage: observationData[DatabaseHelper.COLUMN_OB_IMAGE],
      );
    } else {
      return null;
    }
  }

  Future<Observation?> getLatestObservationByHikeId(int hikeId) async {
    final db = await database;

    final orderBy = '$COLUMN_OB_IMAGE ASC';
    final where = '$COLUMN_OB_HIKE_ID = ?';
    final whereArgs = [hikeId];

    final List<Map<String, dynamic>> result = await db.query(
      TABLE_OBSERVATION,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: 1,
    );

    if (result.isNotEmpty) {
      final observationData = result.first;
      return Observation(
        obId: observationData[DatabaseHelper.COLUMN_OB_ID],
        obHikeId: observationData[DatabaseHelper.COLUMN_OB_HIKE_ID],
        obName: observationData[DatabaseHelper.COLUMN_OB_NAME],
        obTime: observationData[DatabaseHelper.COLUMN_OB_TIME],
        obImage: observationData[DatabaseHelper.COLUMN_OB_IMAGE],
      );
    } else {
      return null;
    }
  }

  Future<void> deleteObservation(int obId) async {
    final db = await database;
    await db.delete(TABLE_OBSERVATION,
        where: '$COLUMN_OB_ID = ?', whereArgs: [obId]);
  }

  Future<void> deleteAllObservations() async {
    final db = await database;

    await db.delete(TABLE_OBSERVATION);
  }

  Future<void> deleteAllHikesAndObservations() async {
    final db = await database;

    await db.delete(TABLE_OBSERVATION);
    await db.delete(TABLE_HIKES);
  }

  Future<int> getHikeCount() async {
    final db = await database;
    final result = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $TABLE_HIKES'));
    return result ?? 0;
  }

  Future<int> getObservationCount() async {
    final db = await database;
    final result = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $TABLE_OBSERVATION'));
    return result ?? 0;
  }

  Future<double> getTotalHikingDistance() async {
    final db = await database;
    final result = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT SUM(CAST($COLUMN_LENGTH AS INTEGER)) FROM $TABLE_HIKES',
    ));
    return result?.toDouble() ?? 0.0;
  }

  Future<double> getTotalHikingDuration() async {
    final db = await database;
    final result = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT SUM(CAST($COLUMN_DURATION AS INTEGER)) FROM $TABLE_HIKES',
    ));
    return result?.toDouble() ?? 0.0;
  }
}
