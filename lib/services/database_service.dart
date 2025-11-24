import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/user.dart';
import '../models/member.dart';
import '../models/billiard_table.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/invoice.dart';
import '../models/zone.dart';
import '../models/promotion.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('billiard_club.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Initialize FFI for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Create database schema and default admin user
  Future<void> _createDB(Database db, int version) async {
    await _createSchema(db);
    
    // Insert default admin user for login
    await db.insert('users', {
      'id': 'admin-001',
      'username': 'admin',
      'password': 'admin123', // In production, use hashed passwords
      'full_name': 'Administrator',
      'role': 'manager',
      'phone': '0123456789',
      'email': 'admin@billiardclub.com',
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Create all tables schema
  Future<void> _createSchema(Database db) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // Members table
    await db.execute('''
      CREATE TABLE members (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        address TEXT,
        registration_date TEXT NOT NULL,
        membership_type TEXT NOT NULL DEFAULT 'standard',
        discount_rate REAL NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        expiry_date TEXT
      )
    ''');

    // Billiard tables
    await db.execute('''
      CREATE TABLE billiard_tables (
        id TEXT PRIMARY KEY,
        table_name TEXT NOT NULL,
        table_type TEXT NOT NULL,
        zone TEXT NOT NULL DEFAULT 'Zone 1',
        price_per_hour REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'available',
        start_time TEXT,
        current_session_id TEXT,
        reserved_by TEXT,
        reservation_time TEXT
      )
    ''');

    // Products table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        stock_quantity INTEGER NOT NULL,
        unit TEXT,
        description TEXT,
        is_available INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        table_id TEXT NOT NULL,
        session_id TEXT,
        total_amount REAL NOT NULL,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        FOREIGN KEY (table_id) REFERENCES billiard_tables (id)
      )
    ''');

    // Order items table
    await db.execute('''
      CREATE TABLE order_items (
        id TEXT PRIMARY KEY,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Invoices table
    await db.execute('''
      CREATE TABLE invoices (
        id TEXT PRIMARY KEY,
        table_id TEXT NOT NULL,
        table_name TEXT NOT NULL,
        member_id TEXT,
        member_name TEXT,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        playing_hours REAL NOT NULL,
        table_charge REAL NOT NULL,
        order_total REAL NOT NULL,
        subtotal REAL NOT NULL,
        discount REAL NOT NULL DEFAULT 0,
        tax REAL NOT NULL DEFAULT 0,
        total_amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'paid',
        created_at TEXT NOT NULL,
        created_by TEXT NOT NULL,
        FOREIGN KEY (table_id) REFERENCES billiard_tables (id),
        FOREIGN KEY (member_id) REFERENCES members (id)
      )
    ''');

    // Zones table
    await db.execute('''
      CREATE TABLE zones (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        sort_order INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // Promotions table
    await db.execute('''
      CREATE TABLE promotions (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        value REAL NOT NULL,
        applicable_table_types TEXT,
        applicable_zones TEXT,
        applicable_membership_type TEXT,
        day_of_week TEXT,
        start_time TEXT,
        end_time TEXT,
        valid_from TEXT,
        valid_to TEXT,
        min_amount REAL,
        min_playing_hours REAL,
        is_active INTEGER NOT NULL DEFAULT 1,
        priority INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // User operations
  Future<User?> login(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ? AND is_active = 1',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users', orderBy: 'created_at DESC');
    return result.map((map) => User.fromMap(map)).toList();
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap());
  }

  Future<void> updateUser(User user) async {
    final db = await database;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(String id) async {
    final db = await database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Member operations
  Future<List<Member>> getAllMembers() async {
    final db = await database;
    final result = await db.query('members', orderBy: 'registration_date DESC');
    return result.map((map) => Member.fromMap(map)).toList();
  }

  Future<Member?> getMemberById(String id) async {
    final db = await database;
    final result = await db.query('members', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Member.fromMap(result.first);
    }
    return null;
  }

  Future<void> insertMember(Member member) async {
    final db = await database;
    await db.insert('members', member.toMap());
  }

  Future<void> updateMember(Member member) async {
    final db = await database;
    await db.update(
      'members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<void> deleteMember(String id) async {
    final db = await database;
    await db.delete('members', where: 'id = ?', whereArgs: [id]);
  }

  // Table operations
  Future<List<BilliardTable>> getAllTables() async {
    final db = await database;
    final result = await db.query('billiard_tables', orderBy: 'table_name');
    return result.map((map) => BilliardTable.fromMap(map)).toList();
  }

  Future<BilliardTable?> getTableById(String id) async {
    final db = await database;
    final result = await db.query('billiard_tables', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return BilliardTable.fromMap(result.first);
    }
    return null;
  }

  Future<void> insertTable(BilliardTable table) async {
    final db = await database;
    await db.insert('billiard_tables', table.toMap());
  }

  Future<void> updateTable(BilliardTable table) async {
    final db = await database;
    await db.update(
      'billiard_tables',
      table.toMap(),
      where: 'id = ?',
      whereArgs: [table.id],
    );
  }

  Future<void> deleteTable(String id) async {
    final db = await database;
    await db.delete('billiard_tables', where: 'id = ?', whereArgs: [id]);
  }

  // Product operations
  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final result = await db.query('products', orderBy: 'name');
    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<Product?> getProductById(String id) async {
    final db = await database;
    final result = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Product.fromMap(result.first);
    }
    return null;
  }

  Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert('products', product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Order operations
  Future<void> insertOrder(Order order) async {
    final db = await database;
    await db.insert('orders', order.toMap());

    for (var item in order.items) {
      await db.insert('order_items', item.toMap());
    }
  }

  Future<List<Order>> getOrdersByTableId(String tableId) async {
    final db = await database;
    final orderMaps = await db.query(
      'orders',
      where: 'table_id = ? AND status = ?',
      whereArgs: [tableId, 'pending'],
    );

    List<Order> orders = [];
    for (var orderMap in orderMaps) {
      final items = await _getOrderItems(orderMap['id'] as String);
      orders.add(Order.fromMap(orderMap, items));
    }

    return orders;
  }

  Future<List<OrderItem>> _getOrderItems(String orderId) async {
    final db = await database;
    final result = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    return result.map((map) => OrderItem.fromMap(map)).toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final db = await database;
    await db.update(
      'orders',
      {'status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  // Invoice operations
  Future<void> insertInvoice(Invoice invoice) async {
    final db = await database;
    await db.insert('invoices', invoice.toMap());
  }

  Future<List<Invoice>> getAllInvoices() async {
    final db = await database;
    final result = await db.query('invoices', orderBy: 'created_at DESC');
    return result.map((map) => Invoice.fromMap(map)).toList();
  }

  Future<List<Invoice>> getInvoicesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.query(
      'invoices',
      where: 'created_at BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Invoice.fromMap(map)).toList();
  }

  // Zone operations
  Future<List<Zone>> getAllZones() async {
    final db = await database;
    final result = await db.query('zones', orderBy: 'sort_order ASC');
    return result.map((map) => Zone.fromMap(map)).toList();
  }

  Future<List<Zone>> getActiveZones() async {
    final db = await database;
    final result = await db.query(
      'zones',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'sort_order ASC',
    );
    return result.map((map) => Zone.fromMap(map)).toList();
  }

  Future<Zone?> getZoneById(String id) async {
    final db = await database;
    final result = await db.query('zones', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Zone.fromMap(result.first);
    }
    return null;
  }

  Future<void> insertZone(Zone zone) async {
    final db = await database;
    await db.insert('zones', zone.toMap());
  }

  Future<void> updateZone(Zone zone) async {
    final db = await database;
    await db.update(
      'zones',
      zone.toMap(),
      where: 'id = ?',
      whereArgs: [zone.id],
    );
  }

  Future<void> deleteZone(String id) async {
    final db = await database;
    await db.delete('zones', where: 'id = ?', whereArgs: [id]);
  }

  // Promotion operations
  Future<List<Promotion>> getAllPromotions() async {
    final db = await database;
    final result = await db.query('promotions', orderBy: 'priority DESC, created_at DESC');
    return result.map((map) => Promotion.fromMap(map)).toList();
  }

  Future<List<Promotion>> getActivePromotions() async {
    final db = await database;
    final result = await db.query(
      'promotions',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'priority DESC, created_at DESC',
    );
    return result.map((map) => Promotion.fromMap(map)).toList();
  }

  Future<Promotion?> getPromotionById(String id) async {
    final db = await database;
    final result = await db.query('promotions', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Promotion.fromMap(result.first);
    }
    return null;
  }

  Future<void> insertPromotion(Promotion promotion) async {
    final db = await database;
    await db.insert('promotions', promotion.toMap());
  }

  Future<void> updatePromotion(Promotion promotion) async {
    final db = await database;
    await db.update(
      'promotions',
      promotion.toMap(),
      where: 'id = ?',
      whereArgs: [promotion.id],
    );
  }

  Future<void> deletePromotion(String id) async {
    final db = await database;
    await db.delete('promotions', where: 'id = ?', whereArgs: [id]);
  }

  // Reset database - delete and recreate with empty tables
  Future<void> resetDatabase() async {
    try {
      // Close current database connection
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Get database path
      final dbPath = await getApplicationDocumentsDirectory();
      final path = join(dbPath.path, 'billiard_club.db');

      // Delete database file
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }

      // Recreate database with empty tables (no default data)
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    } catch (e) {
      print('Error resetting database: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

