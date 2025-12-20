import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._internal();
  static Database? _database;

  LocalDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'taka_dorkar.db');

    final db = await openDatabase(path, version: 1, onCreate: _createDatabase);

    await db.execute('''
      CREATE TABLE IF NOT EXISTS spam_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        message_text TEXT NOT NULL,
        threat_level TEXT NOT NULL,
        prediction TEXT NOT NULL,
        confidence REAL NOT NULL,
        detected_at TEXT NOT NULL,
        is_read INTEGER DEFAULT 0
      )
    ''');

    await _ensureSpamTableColumns(db);

    return db;
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT,
        balance REAL DEFAULT 0,
        currency TEXT DEFAULT 'BDT',
        parent_type TEXT,
        is_default INTEGER DEFAULT 0,
        include_in_savings INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        server_updated_at TEXT,
        is_deleted INTEGER DEFAULT 0,
        local_updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        needs_sync INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        account_id TEXT NOT NULL,
        category_id TEXT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        server_updated_at TEXT,
        is_deleted INTEGER DEFAULT 0,
        local_updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        needs_sync INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        category_id TEXT,
        amount REAL NOT NULL,
        period TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        created_at TEXT,
        updated_at TEXT,
        server_updated_at TEXT,
        is_deleted INTEGER DEFAULT 0,
        local_updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        needs_sync INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        last_sync_at TEXT,
        status TEXT
      )
    ''');

    await db.execute('''
      INSERT INTO sync_log (table_name, last_sync_at, status)
      VALUES 
        ('accounts', NULL, 'never_synced'),
        ('transactions', NULL, 'never_synced'),
        ('budgets', NULL, 'never_synced')
    ''');

    await db.execute('''
      CREATE TABLE spam_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        phone_number TEXT NOT NULL,
        message_text TEXT NOT NULL,
        threat_level TEXT NOT NULL,
        prediction TEXT NOT NULL,
        confidence REAL NOT NULL,
        detection_method TEXT,
        ai_confidence REAL,
        ml_confidence REAL,
        detected_at TEXT NOT NULL,
        is_read INTEGER DEFAULT 0,
        is_false_positive INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _ensureSpamTableColumns(Database db) async {
    final columnsInfo = await db.rawQuery('PRAGMA table_info(spam_messages)');
    final existingColumns = {
      for (var row in columnsInfo) row['name'] as String,
    };

    Future<void> addCol(String name, String type) async {
      if (!existingColumns.contains(name)) {
        await db.execute('ALTER TABLE spam_messages ADD COLUMN $name $type');
      }
    }

    await addCol('user_id', 'TEXT');
    await addCol('detection_method', 'TEXT');
    await addCol('ai_confidence', 'REAL');
    await addCol('ml_confidence', 'REAL');
    await addCol('is_false_positive', 'INTEGER DEFAULT 0');
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('accounts');
    await db.delete('transactions');
    await db.delete('budgets');
    await db.execute('''
      UPDATE sync_log SET last_sync_at = NULL, status = 'never_synced'
    ''');
  }

  Future<void> markForSync(String table, String id) async {
    final db = await database;
    await db.update(
      table,
      {'needs_sync': 1, 'local_updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getUnsyncedRecords(String table) async {
    final db = await database;
    return await db.query(table, where: 'needs_sync = ?', whereArgs: [1]);
  }

  Future<void> markAsSynced(String table, String id) async {
    final db = await database;
    await db.update(table, {'needs_sync': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateSyncLog(String table, String timestamp) async {
    final db = await database;
    await db.update(
      'sync_log',
      {'last_sync_at': timestamp, 'status': 'synced'},
      where: 'table_name = ?',
      whereArgs: [table],
    );
  }

  Future<String?> getLastSyncTime(String table) async {
    final db = await database;
    final result = await db.query(
      'sync_log',
      columns: ['last_sync_at'],
      where: 'table_name = ?',
      whereArgs: [table],
    );
    if (result.isEmpty) return null;
    return result.first['last_sync_at'] as String?;
  }

  Future<void> createDefaultAccounts(String userId) async {
    final db = await database;
    final uuid = Uuid();
    final now = DateTime.now().toIso8601String();

    final defaultAccounts = [
      {
        'id': uuid.v4(),
        'user_id': userId,
        'name': 'Wallet',
        'type': 'cash',
        'parent_type': 'cash',
        'balance': 0.0,
        'currency': 'BDT',
        'is_default': 1,
        'include_in_savings': 0,
        'created_at': now,
        'updated_at': now,
        'server_updated_at': null,
        'is_deleted': 0,
        'local_updated_at': now,
        'needs_sync': 1,
      },
      {
        'id': uuid.v4(),
        'user_id': userId,
        'name': 'BKash',
        'type': 'mobile_banking',
        'parent_type': 'mobile_banking',
        'balance': 0.0,
        'currency': 'BDT',
        'is_default': 1,
        'include_in_savings': 0,
        'created_at': now,
        'updated_at': now,
        'server_updated_at': null,
        'is_deleted': 0,
        'local_updated_at': now,
        'needs_sync': 1,
      },
      {
        'id': uuid.v4(),
        'user_id': userId,
        'name': 'Nagad',
        'type': 'mobile_banking',
        'parent_type': 'mobile_banking',
        'balance': 0.0,
        'currency': 'BDT',
        'is_default': 1,
        'include_in_savings': 0,
        'created_at': now,
        'updated_at': now,
        'server_updated_at': null,
        'is_deleted': 0,
        'local_updated_at': now,
        'needs_sync': 1,
      },
      {
        'id': uuid.v4(),
        'user_id': userId,
        'name': 'EBL',
        'type': 'bank',
        'parent_type': 'bank',
        'balance': 0.0,
        'currency': 'BDT',
        'is_default': 1,
        'include_in_savings': 0,
        'created_at': now,
        'updated_at': now,
        'server_updated_at': null,
        'is_deleted': 0,
        'local_updated_at': now,
        'needs_sync': 1,
      },
      {
        'id': uuid.v4(),
        'user_id': userId,
        'name': 'Personal Savings',
        'type': 'savings',
        'parent_type': 'savings',
        'balance': 1000.0,
        'currency': 'BDT',
        'is_default': 1,
        'include_in_savings': 1,
        'created_at': now,
        'updated_at': now,
        'server_updated_at': null,
        'is_deleted': 0,
        'local_updated_at': now,
        'needs_sync': 1,
      },
    ];

    for (var account in defaultAccounts) {
      await db.insert(
        'accounts',
        account,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<bool> hasDefaultAccounts(String userId) async {
    final db = await database;
    final result = await db.query(
      'accounts',
      where: 'user_id = ? AND is_default = ?',
      whereArgs: [userId, 1],
    );
    return result.isNotEmpty;
  }

  Future<int> insertSpamMessage(Map<String, dynamic> spamData) async {
    final db = await database;
    if (!spamData.containsKey('detected_at')) {
      spamData['detected_at'] = DateTime.now().toIso8601String();
    }
    spamData['user_id'] ??= 'local';
    spamData['detection_method'] ??= 'local';
    spamData['is_false_positive'] ??= 0;
    spamData['prediction'] ??= spamData['threat_level'] ?? 'unknown';
    final mlConf = spamData['ml_confidence'];
    final aiConf = spamData['ai_confidence'];
    spamData['confidence'] ??= (mlConf ?? aiConf ?? 0.8);
    return await db.insert(
      'spam_messages',
      spamData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getSpamMessages() async {
    final db = await database;
    return await db.query('spam_messages', orderBy: 'detected_at DESC');
  }

  Future<int> deleteSpamMessage(int id) async {
    final db = await database;
    return await db.delete('spam_messages', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> markSpamAsRead(int id) async {
    final db = await database;
    return await db.update(
      'spam_messages',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>> getLocalSecurityStats() async {
    final db = await database;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
    final weekStart = now.subtract(Duration(days: 7)).toIso8601String();

    final total =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM spam_messages'),
        ) ??
        0;
    final unread =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM spam_messages WHERE is_read = 0',
          ),
        ) ??
        0;
    final high =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM spam_messages WHERE threat_level = 'high'",
          ),
        ) ??
        0;
    final medium =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM spam_messages WHERE threat_level = 'medium'",
          ),
        ) ??
        0;
    final low =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM spam_messages WHERE threat_level = 'low'",
          ),
        ) ??
        0;
    final today =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM spam_messages WHERE detected_at >= ?',
            [todayStart],
          ),
        ) ??
        0;
    final week =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM spam_messages WHERE detected_at >= ?',
            [weekStart],
          ),
        ) ??
        0;

    return {
      'total': total,
      'unread': unread,
      'high_threat': high,
      'medium_threat': medium,
      'low_threat': low,
      'today': today,
      'this_week': week,
    };
  }
}
