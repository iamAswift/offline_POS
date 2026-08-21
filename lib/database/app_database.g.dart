// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _loginIdMeta = const VerificationMeta(
    'loginId',
  );
  @override
  late final GeneratedColumn<String> loginId = GeneratedColumn<String>(
    'login_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _passwordMeta = const VerificationMeta(
    'password',
  );
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
    'password',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('staff'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    loginId,
    email,
    password,
    isActive,
    role,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('login_id')) {
      context.handle(
        _loginIdMeta,
        loginId.isAcceptableOrUnknown(data['login_id']!, _loginIdMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('password')) {
      context.handle(
        _passwordMeta,
        password.isAcceptableOrUnknown(data['password']!, _passwordMeta),
      );
    } else if (isInserting) {
      context.missing(_passwordMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      loginId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}login_id'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      password: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String name;
  final String? loginId;
  final String email;
  final String password;
  final bool isActive;
  final String role;
  const User({
    required this.id,
    required this.name,
    this.loginId,
    required this.email,
    required this.password,
    required this.isActive,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || loginId != null) {
      map['login_id'] = Variable<String>(loginId);
    }
    map['email'] = Variable<String>(email);
    map['password'] = Variable<String>(password);
    map['is_active'] = Variable<bool>(isActive);
    map['role'] = Variable<String>(role);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      loginId: loginId == null && nullToAbsent
          ? const Value.absent()
          : Value(loginId),
      email: Value(email),
      password: Value(password),
      isActive: Value(isActive),
      role: Value(role),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      loginId: serializer.fromJson<String?>(json['loginId']),
      email: serializer.fromJson<String>(json['email']),
      password: serializer.fromJson<String>(json['password']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'loginId': serializer.toJson<String?>(loginId),
      'email': serializer.toJson<String>(email),
      'password': serializer.toJson<String>(password),
      'isActive': serializer.toJson<bool>(isActive),
      'role': serializer.toJson<String>(role),
    };
  }

  User copyWith({
    int? id,
    String? name,
    Value<String?> loginId = const Value.absent(),
    String? email,
    String? password,
    bool? isActive,
    String? role,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    loginId: loginId.present ? loginId.value : this.loginId,
    email: email ?? this.email,
    password: password ?? this.password,
    isActive: isActive ?? this.isActive,
    role: role ?? this.role,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      loginId: data.loginId.present ? data.loginId.value : this.loginId,
      email: data.email.present ? data.email.value : this.email,
      password: data.password.present ? data.password.value : this.password,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('loginId: $loginId, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('isActive: $isActive, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, loginId, email, password, isActive, role);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.name == this.name &&
          other.loginId == this.loginId &&
          other.email == this.email &&
          other.password == this.password &&
          other.isActive == this.isActive &&
          other.role == this.role);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> loginId;
  final Value<String> email;
  final Value<String> password;
  final Value<bool> isActive;
  final Value<String> role;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.loginId = const Value.absent(),
    this.email = const Value.absent(),
    this.password = const Value.absent(),
    this.isActive = const Value.absent(),
    this.role = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.loginId = const Value.absent(),
    required String email,
    required String password,
    this.isActive = const Value.absent(),
    this.role = const Value.absent(),
  }) : name = Value(name),
       email = Value(email),
       password = Value(password);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? loginId,
    Expression<String>? email,
    Expression<String>? password,
    Expression<bool>? isActive,
    Expression<String>? role,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (loginId != null) 'login_id': loginId,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (isActive != null) 'is_active': isActive,
      if (role != null) 'role': role,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? loginId,
    Value<String>? email,
    Value<String>? password,
    Value<bool>? isActive,
    Value<String>? role,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      loginId: loginId ?? this.loginId,
      email: email ?? this.email,
      password: password ?? this.password,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (loginId.present) {
      map['login_id'] = Variable<String>(loginId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('loginId: $loginId, ')
          ..write('email: $email, ')
          ..write('password: $password, ')
          ..write('isActive: $isActive, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, imagePath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String name;
  final String? imagePath;
  const Category({required this.id, required this.name, this.imagePath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'imagePath': serializer.toJson<String?>(imagePath),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    Value<String?> imagePath = const Value.absent(),
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imagePath: $imagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, imagePath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.imagePath == this.imagePath);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> imagePath;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.imagePath = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.imagePath = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? imagePath,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (imagePath != null) 'image_path': imagePath,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? imagePath,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imagePath: $imagePath')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costPriceMeta = const VerificationMeta(
    'costPrice',
  );
  @override
  late final GeneratedColumn<double> costPrice = GeneratedColumn<double>(
    'cost_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sellingPriceMeta = const VerificationMeta(
    'sellingPrice',
  );
  @override
  late final GeneratedColumn<double> sellingPrice = GeneratedColumn<double>(
    'selling_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    barcode,
    name,
    brand,
    categoryId,
    unit,
    costPrice,
    sellingPrice,
    stock,
    imagePath,
    expiryDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<Product> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('cost_price')) {
      context.handle(
        _costPriceMeta,
        costPrice.isAcceptableOrUnknown(data['cost_price']!, _costPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_costPriceMeta);
    }
    if (data.containsKey('selling_price')) {
      context.handle(
        _sellingPriceMeta,
        sellingPrice.isAcceptableOrUnknown(
          data['selling_price']!,
          _sellingPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sellingPriceMeta);
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      costPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_price'],
      )!,
      sellingPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}selling_price'],
      )!,
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      ),
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final int id;
  final String? barcode;
  final String name;
  final String? brand;
  final int categoryId;
  final String unit;
  final double costPrice;
  final double sellingPrice;

  ///  stock quantity
  final int stock;
  final String? imagePath;
  final DateTime? expiryDate;
  const Product({
    required this.id,
    this.barcode,
    required this.name,
    this.brand,
    required this.categoryId,
    required this.unit,
    required this.costPrice,
    required this.sellingPrice,
    required this.stock,
    this.imagePath,
    this.expiryDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    map['category_id'] = Variable<int>(categoryId);
    map['unit'] = Variable<String>(unit);
    map['cost_price'] = Variable<double>(costPrice);
    map['selling_price'] = Variable<double>(sellingPrice);
    map['stock'] = Variable<int>(stock);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<DateTime>(expiryDate);
    }
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      categoryId: Value(categoryId),
      unit: Value(unit),
      costPrice: Value(costPrice),
      sellingPrice: Value(sellingPrice),
      stock: Value(stock),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
    );
  }

  factory Product.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<int>(json['id']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      unit: serializer.fromJson<String>(json['unit']),
      costPrice: serializer.fromJson<double>(json['costPrice']),
      sellingPrice: serializer.fromJson<double>(json['sellingPrice']),
      stock: serializer.fromJson<int>(json['stock']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'barcode': serializer.toJson<String?>(barcode),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'categoryId': serializer.toJson<int>(categoryId),
      'unit': serializer.toJson<String>(unit),
      'costPrice': serializer.toJson<double>(costPrice),
      'sellingPrice': serializer.toJson<double>(sellingPrice),
      'stock': serializer.toJson<int>(stock),
      'imagePath': serializer.toJson<String?>(imagePath),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
    };
  }

  Product copyWith({
    int? id,
    Value<String?> barcode = const Value.absent(),
    String? name,
    Value<String?> brand = const Value.absent(),
    int? categoryId,
    String? unit,
    double? costPrice,
    double? sellingPrice,
    int? stock,
    Value<String?> imagePath = const Value.absent(),
    Value<DateTime?> expiryDate = const Value.absent(),
  }) => Product(
    id: id ?? this.id,
    barcode: barcode.present ? barcode.value : this.barcode,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    categoryId: categoryId ?? this.categoryId,
    unit: unit ?? this.unit,
    costPrice: costPrice ?? this.costPrice,
    sellingPrice: sellingPrice ?? this.sellingPrice,
    stock: stock ?? this.stock,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
  );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      unit: data.unit.present ? data.unit.value : this.unit,
      costPrice: data.costPrice.present ? data.costPrice.value : this.costPrice,
      sellingPrice: data.sellingPrice.present
          ? data.sellingPrice.value
          : this.sellingPrice,
      stock: data.stock.present ? data.stock.value : this.stock,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('categoryId: $categoryId, ')
          ..write('unit: $unit, ')
          ..write('costPrice: $costPrice, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('stock: $stock, ')
          ..write('imagePath: $imagePath, ')
          ..write('expiryDate: $expiryDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    barcode,
    name,
    brand,
    categoryId,
    unit,
    costPrice,
    sellingPrice,
    stock,
    imagePath,
    expiryDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.barcode == this.barcode &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.categoryId == this.categoryId &&
          other.unit == this.unit &&
          other.costPrice == this.costPrice &&
          other.sellingPrice == this.sellingPrice &&
          other.stock == this.stock &&
          other.imagePath == this.imagePath &&
          other.expiryDate == this.expiryDate);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<int> id;
  final Value<String?> barcode;
  final Value<String> name;
  final Value<String?> brand;
  final Value<int> categoryId;
  final Value<String> unit;
  final Value<double> costPrice;
  final Value<double> sellingPrice;
  final Value<int> stock;
  final Value<String?> imagePath;
  final Value<DateTime?> expiryDate;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.barcode = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.unit = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.sellingPrice = const Value.absent(),
    this.stock = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.expiryDate = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    this.barcode = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    required int categoryId,
    required String unit,
    required double costPrice,
    required double sellingPrice,
    this.stock = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.expiryDate = const Value.absent(),
  }) : name = Value(name),
       categoryId = Value(categoryId),
       unit = Value(unit),
       costPrice = Value(costPrice),
       sellingPrice = Value(sellingPrice);
  static Insertable<Product> custom({
    Expression<int>? id,
    Expression<String>? barcode,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<int>? categoryId,
    Expression<String>? unit,
    Expression<double>? costPrice,
    Expression<double>? sellingPrice,
    Expression<int>? stock,
    Expression<String>? imagePath,
    Expression<DateTime>? expiryDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (barcode != null) 'barcode': barcode,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (categoryId != null) 'category_id': categoryId,
      if (unit != null) 'unit': unit,
      if (costPrice != null) 'cost_price': costPrice,
      if (sellingPrice != null) 'selling_price': sellingPrice,
      if (stock != null) 'stock': stock,
      if (imagePath != null) 'image_path': imagePath,
      if (expiryDate != null) 'expiry_date': expiryDate,
    });
  }

  ProductsCompanion copyWith({
    Value<int>? id,
    Value<String?>? barcode,
    Value<String>? name,
    Value<String?>? brand,
    Value<int>? categoryId,
    Value<String>? unit,
    Value<double>? costPrice,
    Value<double>? sellingPrice,
    Value<int>? stock,
    Value<String?>? imagePath,
    Value<DateTime?>? expiryDate,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      categoryId: categoryId ?? this.categoryId,
      unit: unit ?? this.unit,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stock: stock ?? this.stock,
      imagePath: imagePath ?? this.imagePath,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (costPrice.present) {
      map['cost_price'] = Variable<double>(costPrice.value);
    }
    if (sellingPrice.present) {
      map['selling_price'] = Variable<double>(sellingPrice.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('categoryId: $categoryId, ')
          ..write('unit: $unit, ')
          ..write('costPrice: $costPrice, ')
          ..write('sellingPrice: $sellingPrice, ')
          ..write('stock: $stock, ')
          ..write('imagePath: $imagePath, ')
          ..write('expiryDate: $expiryDate')
          ..write(')'))
        .toString();
  }
}

class $SuppliersTable extends Suppliers
    with TableInfo<$SuppliersTable, Supplier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactMeta = const VerificationMeta(
    'contact',
  );
  @override
  late final GeneratedColumn<String> contact = GeneratedColumn<String>(
    'contact',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, contact, address, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Supplier> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('contact')) {
      context.handle(
        _contactMeta,
        contact.isAcceptableOrUnknown(data['contact']!, _contactMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Supplier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Supplier(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }
}

class Supplier extends DataClass implements Insertable<Supplier> {
  final int id;
  final String name;
  final String? contact;
  final String? address;
  final String? notes;
  const Supplier({
    required this.id,
    required this.name,
    this.contact,
    this.address,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || contact != null) {
      map['contact'] = Variable<String>(contact);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
      id: Value(id),
      name: Value(name),
      contact: contact == null && nullToAbsent
          ? const Value.absent()
          : Value(contact),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Supplier.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Supplier(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      contact: serializer.fromJson<String?>(json['contact']),
      address: serializer.fromJson<String?>(json['address']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'contact': serializer.toJson<String?>(contact),
      'address': serializer.toJson<String?>(address),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Supplier copyWith({
    int? id,
    String? name,
    Value<String?> contact = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => Supplier(
    id: id ?? this.id,
    name: name ?? this.name,
    contact: contact.present ? contact.value : this.contact,
    address: address.present ? address.value : this.address,
    notes: notes.present ? notes.value : this.notes,
  );
  Supplier copyWithCompanion(SuppliersCompanion data) {
    return Supplier(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      contact: data.contact.present ? data.contact.value : this.contact,
      address: data.address.present ? data.address.value : this.address,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Supplier(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contact: $contact, ')
          ..write('address: $address, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, contact, address, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Supplier &&
          other.id == this.id &&
          other.name == this.name &&
          other.contact == this.contact &&
          other.address == this.address &&
          other.notes == this.notes);
}

class SuppliersCompanion extends UpdateCompanion<Supplier> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> contact;
  final Value<String?> address;
  final Value<String?> notes;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.contact = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
  });
  SuppliersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.contact = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Supplier> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? contact,
    Expression<String>? address,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (contact != null) 'contact': contact,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
    });
  }

  SuppliersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? contact,
    Value<String?>? address,
    Value<String?>? notes,
  }) {
    return SuppliersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      address: address ?? this.address,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contact.present) {
      map['contact'] = Variable<String>(contact.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contact: $contact, ')
          ..write('address: $address, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $SupplierDeliveriesTable extends SupplierDeliveries
    with TableInfo<$SupplierDeliveriesTable, SupplierDelivery> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierDeliveriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<int> supplierId = GeneratedColumn<int>(
    'supplier_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES suppliers (id)',
    ),
  );
  static const VerificationMeta _deliveryDateMeta = const VerificationMeta(
    'deliveryDate',
  );
  @override
  late final GeneratedColumn<DateTime> deliveryDate = GeneratedColumn<DateTime>(
    'delivery_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _invoiceNumberMeta = const VerificationMeta(
    'invoiceNumber',
  );
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
    'invoice_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    supplierId,
    deliveryDate,
    invoiceNumber,
    totalAmount,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_deliveries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierDelivery> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('delivery_date')) {
      context.handle(
        _deliveryDateMeta,
        deliveryDate.isAcceptableOrUnknown(
          data['delivery_date']!,
          _deliveryDateMeta,
        ),
      );
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
        _invoiceNumberMeta,
        invoiceNumber.isAcceptableOrUnknown(
          data['invoice_number']!,
          _invoiceNumberMeta,
        ),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierDelivery map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierDelivery(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}supplier_id'],
      )!,
      deliveryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}delivery_date'],
      )!,
      invoiceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_number'],
      ),
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $SupplierDeliveriesTable createAlias(String alias) {
    return $SupplierDeliveriesTable(attachedDatabase, alias);
  }
}

class SupplierDelivery extends DataClass
    implements Insertable<SupplierDelivery> {
  final int id;

  /// Supplier who made this delivery.
  final int supplierId;

  /// Date the goods were received.
  final DateTime deliveryDate;

  /// Supplier invoice / delivery note number.
  final String? invoiceNumber;

  /// Total value of this delivery.
  ///
  /// This is the supplier's purchase value, NOT the selling value.
  final double totalAmount;

  /// Optional notes about the delivery.
  final String? notes;
  const SupplierDelivery({
    required this.id,
    required this.supplierId,
    required this.deliveryDate,
    this.invoiceNumber,
    required this.totalAmount,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['supplier_id'] = Variable<int>(supplierId);
    map['delivery_date'] = Variable<DateTime>(deliveryDate);
    if (!nullToAbsent || invoiceNumber != null) {
      map['invoice_number'] = Variable<String>(invoiceNumber);
    }
    map['total_amount'] = Variable<double>(totalAmount);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  SupplierDeliveriesCompanion toCompanion(bool nullToAbsent) {
    return SupplierDeliveriesCompanion(
      id: Value(id),
      supplierId: Value(supplierId),
      deliveryDate: Value(deliveryDate),
      invoiceNumber: invoiceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceNumber),
      totalAmount: Value(totalAmount),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory SupplierDelivery.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierDelivery(
      id: serializer.fromJson<int>(json['id']),
      supplierId: serializer.fromJson<int>(json['supplierId']),
      deliveryDate: serializer.fromJson<DateTime>(json['deliveryDate']),
      invoiceNumber: serializer.fromJson<String?>(json['invoiceNumber']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'supplierId': serializer.toJson<int>(supplierId),
      'deliveryDate': serializer.toJson<DateTime>(deliveryDate),
      'invoiceNumber': serializer.toJson<String?>(invoiceNumber),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  SupplierDelivery copyWith({
    int? id,
    int? supplierId,
    DateTime? deliveryDate,
    Value<String?> invoiceNumber = const Value.absent(),
    double? totalAmount,
    Value<String?> notes = const Value.absent(),
  }) => SupplierDelivery(
    id: id ?? this.id,
    supplierId: supplierId ?? this.supplierId,
    deliveryDate: deliveryDate ?? this.deliveryDate,
    invoiceNumber: invoiceNumber.present
        ? invoiceNumber.value
        : this.invoiceNumber,
    totalAmount: totalAmount ?? this.totalAmount,
    notes: notes.present ? notes.value : this.notes,
  );
  SupplierDelivery copyWithCompanion(SupplierDeliveriesCompanion data) {
    return SupplierDelivery(
      id: data.id.present ? data.id.value : this.id,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      deliveryDate: data.deliveryDate.present
          ? data.deliveryDate.value
          : this.deliveryDate,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierDelivery(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('deliveryDate: $deliveryDate, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    supplierId,
    deliveryDate,
    invoiceNumber,
    totalAmount,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierDelivery &&
          other.id == this.id &&
          other.supplierId == this.supplierId &&
          other.deliveryDate == this.deliveryDate &&
          other.invoiceNumber == this.invoiceNumber &&
          other.totalAmount == this.totalAmount &&
          other.notes == this.notes);
}

class SupplierDeliveriesCompanion extends UpdateCompanion<SupplierDelivery> {
  final Value<int> id;
  final Value<int> supplierId;
  final Value<DateTime> deliveryDate;
  final Value<String?> invoiceNumber;
  final Value<double> totalAmount;
  final Value<String?> notes;
  const SupplierDeliveriesCompanion({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.deliveryDate = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.notes = const Value.absent(),
  });
  SupplierDeliveriesCompanion.insert({
    this.id = const Value.absent(),
    required int supplierId,
    this.deliveryDate = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    required double totalAmount,
    this.notes = const Value.absent(),
  }) : supplierId = Value(supplierId),
       totalAmount = Value(totalAmount);
  static Insertable<SupplierDelivery> custom({
    Expression<int>? id,
    Expression<int>? supplierId,
    Expression<DateTime>? deliveryDate,
    Expression<String>? invoiceNumber,
    Expression<double>? totalAmount,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplierId != null) 'supplier_id': supplierId,
      if (deliveryDate != null) 'delivery_date': deliveryDate,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (notes != null) 'notes': notes,
    });
  }

  SupplierDeliveriesCompanion copyWith({
    Value<int>? id,
    Value<int>? supplierId,
    Value<DateTime>? deliveryDate,
    Value<String?>? invoiceNumber,
    Value<double>? totalAmount,
    Value<String?>? notes,
  }) {
    return SupplierDeliveriesCompanion(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<int>(supplierId.value);
    }
    if (deliveryDate.present) {
      map['delivery_date'] = Variable<DateTime>(deliveryDate.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierDeliveriesCompanion(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('deliveryDate: $deliveryDate, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<int> supplierId = GeneratedColumn<int>(
    'supplier_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES suppliers (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deliveryIdMeta = const VerificationMeta(
    'deliveryId',
  );
  @override
  late final GeneratedColumn<int> deliveryId = GeneratedColumn<int>(
    'delivery_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES supplier_deliveries (id)',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    supplierId,
    type,
    deliveryId,
    quantity,
    unitPrice,
    date,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('delivery_id')) {
      context.handle(
        _deliveryIdMeta,
        deliveryId.isAcceptableOrUnknown(data['delivery_id']!, _deliveryIdMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}supplier_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      deliveryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivery_id'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovement extends DataClass implements Insertable<StockMovement> {
  final int id;
  final int productId;
  final int? supplierId;
  final String type;
  final int? deliveryId;
  final int quantity;
  final double unitPrice;
  final DateTime date;
  const StockMovement({
    required this.id,
    required this.productId,
    this.supplierId,
    required this.type,
    this.deliveryId,
    required this.quantity,
    required this.unitPrice,
    required this.date,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<int>(productId);
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<int>(supplierId);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || deliveryId != null) {
      map['delivery_id'] = Variable<int>(deliveryId);
    }
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      productId: Value(productId),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      type: Value(type),
      deliveryId: deliveryId == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryId),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      date: Value(date),
    );
  }

  factory StockMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovement(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<int>(json['productId']),
      supplierId: serializer.fromJson<int?>(json['supplierId']),
      type: serializer.fromJson<String>(json['type']),
      deliveryId: serializer.fromJson<int?>(json['deliveryId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<int>(productId),
      'supplierId': serializer.toJson<int?>(supplierId),
      'type': serializer.toJson<String>(type),
      'deliveryId': serializer.toJson<int?>(deliveryId),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  StockMovement copyWith({
    int? id,
    int? productId,
    Value<int?> supplierId = const Value.absent(),
    String? type,
    Value<int?> deliveryId = const Value.absent(),
    int? quantity,
    double? unitPrice,
    DateTime? date,
  }) => StockMovement(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    supplierId: supplierId.present ? supplierId.value : this.supplierId,
    type: type ?? this.type,
    deliveryId: deliveryId.present ? deliveryId.value : this.deliveryId,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    date: date ?? this.date,
  );
  StockMovement copyWithCompanion(StockMovementsCompanion data) {
    return StockMovement(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      type: data.type.present ? data.type.value : this.type,
      deliveryId: data.deliveryId.present
          ? data.deliveryId.value
          : this.deliveryId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovement(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('supplierId: $supplierId, ')
          ..write('type: $type, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    supplierId,
    type,
    deliveryId,
    quantity,
    unitPrice,
    date,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovement &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.supplierId == this.supplierId &&
          other.type == this.type &&
          other.deliveryId == this.deliveryId &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.date == this.date);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovement> {
  final Value<int> id;
  final Value<int> productId;
  final Value<int?> supplierId;
  final Value<String> type;
  final Value<int?> deliveryId;
  final Value<int> quantity;
  final Value<double> unitPrice;
  final Value<DateTime> date;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.type = const Value.absent(),
    this.deliveryId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.date = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    this.id = const Value.absent(),
    required int productId,
    this.supplierId = const Value.absent(),
    required String type,
    this.deliveryId = const Value.absent(),
    required int quantity,
    required double unitPrice,
    this.date = const Value.absent(),
  }) : productId = Value(productId),
       type = Value(type),
       quantity = Value(quantity),
       unitPrice = Value(unitPrice);
  static Insertable<StockMovement> custom({
    Expression<int>? id,
    Expression<int>? productId,
    Expression<int>? supplierId,
    Expression<String>? type,
    Expression<int>? deliveryId,
    Expression<int>? quantity,
    Expression<double>? unitPrice,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (supplierId != null) 'supplier_id': supplierId,
      if (type != null) 'type': type,
      if (deliveryId != null) 'delivery_id': deliveryId,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (date != null) 'date': date,
    });
  }

  StockMovementsCompanion copyWith({
    Value<int>? id,
    Value<int>? productId,
    Value<int?>? supplierId,
    Value<String>? type,
    Value<int?>? deliveryId,
    Value<int>? quantity,
    Value<double>? unitPrice,
    Value<DateTime>? date,
  }) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      supplierId: supplierId ?? this.supplierId,
      type: type ?? this.type,
      deliveryId: deliveryId ?? this.deliveryId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<int>(supplierId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (deliveryId.present) {
      map['delivery_id'] = Variable<int>(deliveryId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('supplierId: $supplierId, ')
          ..write('type: $type, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, Sale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<int> unitPrice = GeneratedColumn<int>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costPriceAtSaleMeta = const VerificationMeta(
    'costPriceAtSale',
  );
  @override
  late final GeneratedColumn<double> costPriceAtSale = GeneratedColumn<double>(
    'cost_price_at_sale',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalPriceMeta = const VerificationMeta(
    'totalPrice',
  );
  @override
  late final GeneratedColumn<int> totalPrice = GeneratedColumn<int>(
    'total_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cashAmountMeta = const VerificationMeta(
    'cashAmount',
  );
  @override
  late final GeneratedColumn<double> cashAmount = GeneratedColumn<double>(
    'cash_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _posAmountMeta = const VerificationMeta(
    'posAmount',
  );
  @override
  late final GeneratedColumn<double> posAmount = GeneratedColumn<double>(
    'pos_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transferAmountMeta = const VerificationMeta(
    'transferAmount',
  );
  @override
  late final GeneratedColumn<double> transferAmount = GeneratedColumn<double>(
    'transfer_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant("pending"),
  );
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<int> staffId = GeneratedColumn<int>(
    'staff_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    quantity,
    unitPrice,
    costPriceAtSale,
    totalPrice,
    paymentMethod,
    cashAmount,
    posAmount,
    transferAmount,
    status,
    staffId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('cost_price_at_sale')) {
      context.handle(
        _costPriceAtSaleMeta,
        costPriceAtSale.isAcceptableOrUnknown(
          data['cost_price_at_sale']!,
          _costPriceAtSaleMeta,
        ),
      );
    }
    if (data.containsKey('total_price')) {
      context.handle(
        _totalPriceMeta,
        totalPrice.isAcceptableOrUnknown(data['total_price']!, _totalPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_totalPriceMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('cash_amount')) {
      context.handle(
        _cashAmountMeta,
        cashAmount.isAcceptableOrUnknown(data['cash_amount']!, _cashAmountMeta),
      );
    }
    if (data.containsKey('pos_amount')) {
      context.handle(
        _posAmountMeta,
        posAmount.isAcceptableOrUnknown(data['pos_amount']!, _posAmountMeta),
      );
    }
    if (data.containsKey('transfer_amount')) {
      context.handle(
        _transferAmountMeta,
        transferAmount.isAcceptableOrUnknown(
          data['transfer_amount']!,
          _transferAmountMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    } else if (isInserting) {
      context.missing(_staffIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price'],
      )!,
      costPriceAtSale: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_price_at_sale'],
      )!,
      totalPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_price'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      cashAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cash_amount'],
      ),
      posAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pos_amount'],
      ),
      transferAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}transfer_amount'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}staff_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class Sale extends DataClass implements Insertable<Sale> {
  final int id;
  final int productId;
  final int quantity;
  final int unitPrice;
  final double costPriceAtSale;
  final int totalPrice;
  final String paymentMethod;
  final double? cashAmount;
  final double? posAmount;
  final double? transferAmount;
  final String status;
  final int staffId;
  final DateTime createdAt;
  const Sale({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.costPriceAtSale,
    required this.totalPrice,
    required this.paymentMethod,
    this.cashAmount,
    this.posAmount,
    this.transferAmount,
    required this.status,
    required this.staffId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<int>(productId);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<int>(unitPrice);
    map['cost_price_at_sale'] = Variable<double>(costPriceAtSale);
    map['total_price'] = Variable<int>(totalPrice);
    map['payment_method'] = Variable<String>(paymentMethod);
    if (!nullToAbsent || cashAmount != null) {
      map['cash_amount'] = Variable<double>(cashAmount);
    }
    if (!nullToAbsent || posAmount != null) {
      map['pos_amount'] = Variable<double>(posAmount);
    }
    if (!nullToAbsent || transferAmount != null) {
      map['transfer_amount'] = Variable<double>(transferAmount);
    }
    map['status'] = Variable<String>(status);
    map['staff_id'] = Variable<int>(staffId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      productId: Value(productId),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      costPriceAtSale: Value(costPriceAtSale),
      totalPrice: Value(totalPrice),
      paymentMethod: Value(paymentMethod),
      cashAmount: cashAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(cashAmount),
      posAmount: posAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(posAmount),
      transferAmount: transferAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(transferAmount),
      status: Value(status),
      staffId: Value(staffId),
      createdAt: Value(createdAt),
    );
  }

  factory Sale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sale(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<int>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<int>(json['unitPrice']),
      costPriceAtSale: serializer.fromJson<double>(json['costPriceAtSale']),
      totalPrice: serializer.fromJson<int>(json['totalPrice']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      cashAmount: serializer.fromJson<double?>(json['cashAmount']),
      posAmount: serializer.fromJson<double?>(json['posAmount']),
      transferAmount: serializer.fromJson<double?>(json['transferAmount']),
      status: serializer.fromJson<String>(json['status']),
      staffId: serializer.fromJson<int>(json['staffId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<int>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<int>(unitPrice),
      'costPriceAtSale': serializer.toJson<double>(costPriceAtSale),
      'totalPrice': serializer.toJson<int>(totalPrice),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'cashAmount': serializer.toJson<double?>(cashAmount),
      'posAmount': serializer.toJson<double?>(posAmount),
      'transferAmount': serializer.toJson<double?>(transferAmount),
      'status': serializer.toJson<String>(status),
      'staffId': serializer.toJson<int>(staffId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Sale copyWith({
    int? id,
    int? productId,
    int? quantity,
    int? unitPrice,
    double? costPriceAtSale,
    int? totalPrice,
    String? paymentMethod,
    Value<double?> cashAmount = const Value.absent(),
    Value<double?> posAmount = const Value.absent(),
    Value<double?> transferAmount = const Value.absent(),
    String? status,
    int? staffId,
    DateTime? createdAt,
  }) => Sale(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    costPriceAtSale: costPriceAtSale ?? this.costPriceAtSale,
    totalPrice: totalPrice ?? this.totalPrice,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    cashAmount: cashAmount.present ? cashAmount.value : this.cashAmount,
    posAmount: posAmount.present ? posAmount.value : this.posAmount,
    transferAmount: transferAmount.present
        ? transferAmount.value
        : this.transferAmount,
    status: status ?? this.status,
    staffId: staffId ?? this.staffId,
    createdAt: createdAt ?? this.createdAt,
  );
  Sale copyWithCompanion(SalesCompanion data) {
    return Sale(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      costPriceAtSale: data.costPriceAtSale.present
          ? data.costPriceAtSale.value
          : this.costPriceAtSale,
      totalPrice: data.totalPrice.present
          ? data.totalPrice.value
          : this.totalPrice,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      cashAmount: data.cashAmount.present
          ? data.cashAmount.value
          : this.cashAmount,
      posAmount: data.posAmount.present ? data.posAmount.value : this.posAmount,
      transferAmount: data.transferAmount.present
          ? data.transferAmount.value
          : this.transferAmount,
      status: data.status.present ? data.status.value : this.status,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sale(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('costPriceAtSale: $costPriceAtSale, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('cashAmount: $cashAmount, ')
          ..write('posAmount: $posAmount, ')
          ..write('transferAmount: $transferAmount, ')
          ..write('status: $status, ')
          ..write('staffId: $staffId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    quantity,
    unitPrice,
    costPriceAtSale,
    totalPrice,
    paymentMethod,
    cashAmount,
    posAmount,
    transferAmount,
    status,
    staffId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sale &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.costPriceAtSale == this.costPriceAtSale &&
          other.totalPrice == this.totalPrice &&
          other.paymentMethod == this.paymentMethod &&
          other.cashAmount == this.cashAmount &&
          other.posAmount == this.posAmount &&
          other.transferAmount == this.transferAmount &&
          other.status == this.status &&
          other.staffId == this.staffId &&
          other.createdAt == this.createdAt);
}

class SalesCompanion extends UpdateCompanion<Sale> {
  final Value<int> id;
  final Value<int> productId;
  final Value<int> quantity;
  final Value<int> unitPrice;
  final Value<double> costPriceAtSale;
  final Value<int> totalPrice;
  final Value<String> paymentMethod;
  final Value<double?> cashAmount;
  final Value<double?> posAmount;
  final Value<double?> transferAmount;
  final Value<String> status;
  final Value<int> staffId;
  final Value<DateTime> createdAt;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.costPriceAtSale = const Value.absent(),
    this.totalPrice = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.cashAmount = const Value.absent(),
    this.posAmount = const Value.absent(),
    this.transferAmount = const Value.absent(),
    this.status = const Value.absent(),
    this.staffId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SalesCompanion.insert({
    this.id = const Value.absent(),
    required int productId,
    required int quantity,
    required int unitPrice,
    this.costPriceAtSale = const Value.absent(),
    required int totalPrice,
    required String paymentMethod,
    this.cashAmount = const Value.absent(),
    this.posAmount = const Value.absent(),
    this.transferAmount = const Value.absent(),
    this.status = const Value.absent(),
    required int staffId,
    this.createdAt = const Value.absent(),
  }) : productId = Value(productId),
       quantity = Value(quantity),
       unitPrice = Value(unitPrice),
       totalPrice = Value(totalPrice),
       paymentMethod = Value(paymentMethod),
       staffId = Value(staffId);
  static Insertable<Sale> custom({
    Expression<int>? id,
    Expression<int>? productId,
    Expression<int>? quantity,
    Expression<int>? unitPrice,
    Expression<double>? costPriceAtSale,
    Expression<int>? totalPrice,
    Expression<String>? paymentMethod,
    Expression<double>? cashAmount,
    Expression<double>? posAmount,
    Expression<double>? transferAmount,
    Expression<String>? status,
    Expression<int>? staffId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (costPriceAtSale != null) 'cost_price_at_sale': costPriceAtSale,
      if (totalPrice != null) 'total_price': totalPrice,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (cashAmount != null) 'cash_amount': cashAmount,
      if (posAmount != null) 'pos_amount': posAmount,
      if (transferAmount != null) 'transfer_amount': transferAmount,
      if (status != null) 'status': status,
      if (staffId != null) 'staff_id': staffId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SalesCompanion copyWith({
    Value<int>? id,
    Value<int>? productId,
    Value<int>? quantity,
    Value<int>? unitPrice,
    Value<double>? costPriceAtSale,
    Value<int>? totalPrice,
    Value<String>? paymentMethod,
    Value<double?>? cashAmount,
    Value<double?>? posAmount,
    Value<double?>? transferAmount,
    Value<String>? status,
    Value<int>? staffId,
    Value<DateTime>? createdAt,
  }) {
    return SalesCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      costPriceAtSale: costPriceAtSale ?? this.costPriceAtSale,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cashAmount: cashAmount ?? this.cashAmount,
      posAmount: posAmount ?? this.posAmount,
      transferAmount: transferAmount ?? this.transferAmount,
      status: status ?? this.status,
      staffId: staffId ?? this.staffId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<int>(unitPrice.value);
    }
    if (costPriceAtSale.present) {
      map['cost_price_at_sale'] = Variable<double>(costPriceAtSale.value);
    }
    if (totalPrice.present) {
      map['total_price'] = Variable<int>(totalPrice.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (cashAmount.present) {
      map['cash_amount'] = Variable<double>(cashAmount.value);
    }
    if (posAmount.present) {
      map['pos_amount'] = Variable<double>(posAmount.value);
    }
    if (transferAmount.present) {
      map['transfer_amount'] = Variable<double>(transferAmount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (staffId.present) {
      map['staff_id'] = Variable<int>(staffId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('costPriceAtSale: $costPriceAtSale, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('cashAmount: $cashAmount, ')
          ..write('posAmount: $posAmount, ')
          ..write('transferAmount: $transferAmount, ')
          ..write('status: $status, ')
          ..write('staffId: $staffId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final String key;
  final String value;
  const Setting({required this.id, required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      key: Value(key),
      value: Value(value),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({int? id, String? key, String? value}) => Setting(
    id: id ?? this.id,
    key: key ?? this.key,
    value: value ?? this.value,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<String> key;
  final Value<String> value;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    required String key,
    required String value,
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<String>? key,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? key,
    Value<String>? value,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _ninMeta = const VerificationMeta('nin');
  @override
  late final GeneratedColumn<String> nin = GeneratedColumn<String>(
    'nin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _guarantorNameMeta = const VerificationMeta(
    'guarantorName',
  );
  @override
  late final GeneratedColumn<String> guarantorName = GeneratedColumn<String>(
    'guarantor_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _guarantorPhoneMeta = const VerificationMeta(
    'guarantorPhone',
  );
  @override
  late final GeneratedColumn<String> guarantorPhone = GeneratedColumn<String>(
    'guarantor_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _salaryMeta = const VerificationMeta('salary');
  @override
  late final GeneratedColumn<double> salary = GeneratedColumn<double>(
    'salary',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _amountOwedMeta = const VerificationMeta(
    'amountOwed',
  );
  @override
  late final GeneratedColumn<double> amountOwed = GeneratedColumn<double>(
    'amount_owed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _canReceiveStockMeta = const VerificationMeta(
    'canReceiveStock',
  );
  @override
  late final GeneratedColumn<bool> canReceiveStock = GeneratedColumn<bool>(
    'can_receive_stock',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_receive_stock" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _canCountStockMeta = const VerificationMeta(
    'canCountStock',
  );
  @override
  late final GeneratedColumn<bool> canCountStock = GeneratedColumn<bool>(
    'can_count_stock',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_count_stock" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    nin,
    phone,
    guarantorName,
    guarantorPhone,
    salary,
    amountOwed,
    canReceiveStock,
    canCountStock,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('nin')) {
      context.handle(
        _ninMeta,
        nin.isAcceptableOrUnknown(data['nin']!, _ninMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('guarantor_name')) {
      context.handle(
        _guarantorNameMeta,
        guarantorName.isAcceptableOrUnknown(
          data['guarantor_name']!,
          _guarantorNameMeta,
        ),
      );
    }
    if (data.containsKey('guarantor_phone')) {
      context.handle(
        _guarantorPhoneMeta,
        guarantorPhone.isAcceptableOrUnknown(
          data['guarantor_phone']!,
          _guarantorPhoneMeta,
        ),
      );
    }
    if (data.containsKey('salary')) {
      context.handle(
        _salaryMeta,
        salary.isAcceptableOrUnknown(data['salary']!, _salaryMeta),
      );
    }
    if (data.containsKey('amount_owed')) {
      context.handle(
        _amountOwedMeta,
        amountOwed.isAcceptableOrUnknown(data['amount_owed']!, _amountOwedMeta),
      );
    }
    if (data.containsKey('can_receive_stock')) {
      context.handle(
        _canReceiveStockMeta,
        canReceiveStock.isAcceptableOrUnknown(
          data['can_receive_stock']!,
          _canReceiveStockMeta,
        ),
      );
    }
    if (data.containsKey('can_count_stock')) {
      context.handle(
        _canCountStockMeta,
        canCountStock.isAcceptableOrUnknown(
          data['can_count_stock']!,
          _canCountStockMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      nin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nin'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      guarantorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guarantor_name'],
      ),
      guarantorPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guarantor_phone'],
      ),
      salary: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}salary'],
      )!,
      amountOwed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_owed'],
      )!,
      canReceiveStock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_receive_stock'],
      )!,
      canCountStock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_count_stock'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final int id;
  final int userId;
  final String? nin;
  final String? phone;
  final String? guarantorName;
  final String? guarantorPhone;
  final double salary;
  final double amountOwed;
  final bool canReceiveStock;
  final bool canCountStock;
  const UserProfile({
    required this.id,
    required this.userId,
    this.nin,
    this.phone,
    this.guarantorName,
    this.guarantorPhone,
    required this.salary,
    required this.amountOwed,
    required this.canReceiveStock,
    required this.canCountStock,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    if (!nullToAbsent || nin != null) {
      map['nin'] = Variable<String>(nin);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || guarantorName != null) {
      map['guarantor_name'] = Variable<String>(guarantorName);
    }
    if (!nullToAbsent || guarantorPhone != null) {
      map['guarantor_phone'] = Variable<String>(guarantorPhone);
    }
    map['salary'] = Variable<double>(salary);
    map['amount_owed'] = Variable<double>(amountOwed);
    map['can_receive_stock'] = Variable<bool>(canReceiveStock);
    map['can_count_stock'] = Variable<bool>(canCountStock);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      userId: Value(userId),
      nin: nin == null && nullToAbsent ? const Value.absent() : Value(nin),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      guarantorName: guarantorName == null && nullToAbsent
          ? const Value.absent()
          : Value(guarantorName),
      guarantorPhone: guarantorPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(guarantorPhone),
      salary: Value(salary),
      amountOwed: Value(amountOwed),
      canReceiveStock: Value(canReceiveStock),
      canCountStock: Value(canCountStock),
    );
  }

  factory UserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      nin: serializer.fromJson<String?>(json['nin']),
      phone: serializer.fromJson<String?>(json['phone']),
      guarantorName: serializer.fromJson<String?>(json['guarantorName']),
      guarantorPhone: serializer.fromJson<String?>(json['guarantorPhone']),
      salary: serializer.fromJson<double>(json['salary']),
      amountOwed: serializer.fromJson<double>(json['amountOwed']),
      canReceiveStock: serializer.fromJson<bool>(json['canReceiveStock']),
      canCountStock: serializer.fromJson<bool>(json['canCountStock']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'nin': serializer.toJson<String?>(nin),
      'phone': serializer.toJson<String?>(phone),
      'guarantorName': serializer.toJson<String?>(guarantorName),
      'guarantorPhone': serializer.toJson<String?>(guarantorPhone),
      'salary': serializer.toJson<double>(salary),
      'amountOwed': serializer.toJson<double>(amountOwed),
      'canReceiveStock': serializer.toJson<bool>(canReceiveStock),
      'canCountStock': serializer.toJson<bool>(canCountStock),
    };
  }

  UserProfile copyWith({
    int? id,
    int? userId,
    Value<String?> nin = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> guarantorName = const Value.absent(),
    Value<String?> guarantorPhone = const Value.absent(),
    double? salary,
    double? amountOwed,
    bool? canReceiveStock,
    bool? canCountStock,
  }) => UserProfile(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    nin: nin.present ? nin.value : this.nin,
    phone: phone.present ? phone.value : this.phone,
    guarantorName: guarantorName.present
        ? guarantorName.value
        : this.guarantorName,
    guarantorPhone: guarantorPhone.present
        ? guarantorPhone.value
        : this.guarantorPhone,
    salary: salary ?? this.salary,
    amountOwed: amountOwed ?? this.amountOwed,
    canReceiveStock: canReceiveStock ?? this.canReceiveStock,
    canCountStock: canCountStock ?? this.canCountStock,
  );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      nin: data.nin.present ? data.nin.value : this.nin,
      phone: data.phone.present ? data.phone.value : this.phone,
      guarantorName: data.guarantorName.present
          ? data.guarantorName.value
          : this.guarantorName,
      guarantorPhone: data.guarantorPhone.present
          ? data.guarantorPhone.value
          : this.guarantorPhone,
      salary: data.salary.present ? data.salary.value : this.salary,
      amountOwed: data.amountOwed.present
          ? data.amountOwed.value
          : this.amountOwed,
      canReceiveStock: data.canReceiveStock.present
          ? data.canReceiveStock.value
          : this.canReceiveStock,
      canCountStock: data.canCountStock.present
          ? data.canCountStock.value
          : this.canCountStock,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('nin: $nin, ')
          ..write('phone: $phone, ')
          ..write('guarantorName: $guarantorName, ')
          ..write('guarantorPhone: $guarantorPhone, ')
          ..write('salary: $salary, ')
          ..write('amountOwed: $amountOwed, ')
          ..write('canReceiveStock: $canReceiveStock, ')
          ..write('canCountStock: $canCountStock')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    nin,
    phone,
    guarantorName,
    guarantorPhone,
    salary,
    amountOwed,
    canReceiveStock,
    canCountStock,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.nin == this.nin &&
          other.phone == this.phone &&
          other.guarantorName == this.guarantorName &&
          other.guarantorPhone == this.guarantorPhone &&
          other.salary == this.salary &&
          other.amountOwed == this.amountOwed &&
          other.canReceiveStock == this.canReceiveStock &&
          other.canCountStock == this.canCountStock);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String?> nin;
  final Value<String?> phone;
  final Value<String?> guarantorName;
  final Value<String?> guarantorPhone;
  final Value<double> salary;
  final Value<double> amountOwed;
  final Value<bool> canReceiveStock;
  final Value<bool> canCountStock;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.nin = const Value.absent(),
    this.phone = const Value.absent(),
    this.guarantorName = const Value.absent(),
    this.guarantorPhone = const Value.absent(),
    this.salary = const Value.absent(),
    this.amountOwed = const Value.absent(),
    this.canReceiveStock = const Value.absent(),
    this.canCountStock = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    this.nin = const Value.absent(),
    this.phone = const Value.absent(),
    this.guarantorName = const Value.absent(),
    this.guarantorPhone = const Value.absent(),
    this.salary = const Value.absent(),
    this.amountOwed = const Value.absent(),
    this.canReceiveStock = const Value.absent(),
    this.canCountStock = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<UserProfile> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? nin,
    Expression<String>? phone,
    Expression<String>? guarantorName,
    Expression<String>? guarantorPhone,
    Expression<double>? salary,
    Expression<double>? amountOwed,
    Expression<bool>? canReceiveStock,
    Expression<bool>? canCountStock,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (nin != null) 'nin': nin,
      if (phone != null) 'phone': phone,
      if (guarantorName != null) 'guarantor_name': guarantorName,
      if (guarantorPhone != null) 'guarantor_phone': guarantorPhone,
      if (salary != null) 'salary': salary,
      if (amountOwed != null) 'amount_owed': amountOwed,
      if (canReceiveStock != null) 'can_receive_stock': canReceiveStock,
      if (canCountStock != null) 'can_count_stock': canCountStock,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<String?>? nin,
    Value<String?>? phone,
    Value<String?>? guarantorName,
    Value<String?>? guarantorPhone,
    Value<double>? salary,
    Value<double>? amountOwed,
    Value<bool>? canReceiveStock,
    Value<bool>? canCountStock,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nin: nin ?? this.nin,
      phone: phone ?? this.phone,
      guarantorName: guarantorName ?? this.guarantorName,
      guarantorPhone: guarantorPhone ?? this.guarantorPhone,
      salary: salary ?? this.salary,
      amountOwed: amountOwed ?? this.amountOwed,
      canReceiveStock: canReceiveStock ?? this.canReceiveStock,
      canCountStock: canCountStock ?? this.canCountStock,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (nin.present) {
      map['nin'] = Variable<String>(nin.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (guarantorName.present) {
      map['guarantor_name'] = Variable<String>(guarantorName.value);
    }
    if (guarantorPhone.present) {
      map['guarantor_phone'] = Variable<String>(guarantorPhone.value);
    }
    if (salary.present) {
      map['salary'] = Variable<double>(salary.value);
    }
    if (amountOwed.present) {
      map['amount_owed'] = Variable<double>(amountOwed.value);
    }
    if (canReceiveStock.present) {
      map['can_receive_stock'] = Variable<bool>(canReceiveStock.value);
    }
    if (canCountStock.present) {
      map['can_count_stock'] = Variable<bool>(canCountStock.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('nin: $nin, ')
          ..write('phone: $phone, ')
          ..write('guarantorName: $guarantorName, ')
          ..write('guarantorPhone: $guarantorPhone, ')
          ..write('salary: $salary, ')
          ..write('amountOwed: $amountOwed, ')
          ..write('canReceiveStock: $canReceiveStock, ')
          ..write('canCountStock: $canCountStock')
          ..write(')'))
        .toString();
  }
}

class $AttendanceTable extends Attendance
    with TableInfo<$AttendanceTable, AttendanceData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendanceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clockInMeta = const VerificationMeta(
    'clockIn',
  );
  @override
  late final GeneratedColumn<DateTime> clockIn = GeneratedColumn<DateTime>(
    'clock_in',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clockOutMeta = const VerificationMeta(
    'clockOut',
  );
  @override
  late final GeneratedColumn<DateTime> clockOut = GeneratedColumn<DateTime>(
    'clock_out',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _correctedByUserIdMeta = const VerificationMeta(
    'correctedByUserId',
  );
  @override
  late final GeneratedColumn<int> correctedByUserId = GeneratedColumn<int>(
    'corrected_by_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correctedAtMeta = const VerificationMeta(
    'correctedAt',
  );
  @override
  late final GeneratedColumn<DateTime> correctedAt = GeneratedColumn<DateTime>(
    'corrected_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correctionNoteMeta = const VerificationMeta(
    'correctionNote',
  );
  @override
  late final GeneratedColumn<String> correctionNote = GeneratedColumn<String>(
    'correction_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    clockIn,
    clockOut,
    notes,
    createdAt,
    correctedByUserId,
    correctedAt,
    correctionNote,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendance';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttendanceData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('clock_in')) {
      context.handle(
        _clockInMeta,
        clockIn.isAcceptableOrUnknown(data['clock_in']!, _clockInMeta),
      );
    } else if (isInserting) {
      context.missing(_clockInMeta);
    }
    if (data.containsKey('clock_out')) {
      context.handle(
        _clockOutMeta,
        clockOut.isAcceptableOrUnknown(data['clock_out']!, _clockOutMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('corrected_by_user_id')) {
      context.handle(
        _correctedByUserIdMeta,
        correctedByUserId.isAcceptableOrUnknown(
          data['corrected_by_user_id']!,
          _correctedByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('corrected_at')) {
      context.handle(
        _correctedAtMeta,
        correctedAt.isAcceptableOrUnknown(
          data['corrected_at']!,
          _correctedAtMeta,
        ),
      );
    }
    if (data.containsKey('correction_note')) {
      context.handle(
        _correctionNoteMeta,
        correctionNote.isAcceptableOrUnknown(
          data['correction_note']!,
          _correctionNoteMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttendanceData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttendanceData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      clockIn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}clock_in'],
      )!,
      clockOut: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}clock_out'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      correctedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}corrected_by_user_id'],
      ),
      correctedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}corrected_at'],
      ),
      correctionNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}correction_note'],
      ),
    );
  }

  @override
  $AttendanceTable createAlias(String alias) {
    return $AttendanceTable(attachedDatabase, alias);
  }
}

class AttendanceData extends DataClass implements Insertable<AttendanceData> {
  final int id;
  final int userId;
  final DateTime clockIn;
  final DateTime? clockOut;
  final String? notes;
  final DateTime createdAt;
  final int? correctedByUserId;
  final DateTime? correctedAt;
  final String? correctionNote;
  const AttendanceData({
    required this.id,
    required this.userId,
    required this.clockIn,
    this.clockOut,
    this.notes,
    required this.createdAt,
    this.correctedByUserId,
    this.correctedAt,
    this.correctionNote,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['clock_in'] = Variable<DateTime>(clockIn);
    if (!nullToAbsent || clockOut != null) {
      map['clock_out'] = Variable<DateTime>(clockOut);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || correctedByUserId != null) {
      map['corrected_by_user_id'] = Variable<int>(correctedByUserId);
    }
    if (!nullToAbsent || correctedAt != null) {
      map['corrected_at'] = Variable<DateTime>(correctedAt);
    }
    if (!nullToAbsent || correctionNote != null) {
      map['correction_note'] = Variable<String>(correctionNote);
    }
    return map;
  }

  AttendanceCompanion toCompanion(bool nullToAbsent) {
    return AttendanceCompanion(
      id: Value(id),
      userId: Value(userId),
      clockIn: Value(clockIn),
      clockOut: clockOut == null && nullToAbsent
          ? const Value.absent()
          : Value(clockOut),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      correctedByUserId: correctedByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(correctedByUserId),
      correctedAt: correctedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(correctedAt),
      correctionNote: correctionNote == null && nullToAbsent
          ? const Value.absent()
          : Value(correctionNote),
    );
  }

  factory AttendanceData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttendanceData(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      clockIn: serializer.fromJson<DateTime>(json['clockIn']),
      clockOut: serializer.fromJson<DateTime?>(json['clockOut']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      correctedByUserId: serializer.fromJson<int?>(json['correctedByUserId']),
      correctedAt: serializer.fromJson<DateTime?>(json['correctedAt']),
      correctionNote: serializer.fromJson<String?>(json['correctionNote']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'clockIn': serializer.toJson<DateTime>(clockIn),
      'clockOut': serializer.toJson<DateTime?>(clockOut),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'correctedByUserId': serializer.toJson<int?>(correctedByUserId),
      'correctedAt': serializer.toJson<DateTime?>(correctedAt),
      'correctionNote': serializer.toJson<String?>(correctionNote),
    };
  }

  AttendanceData copyWith({
    int? id,
    int? userId,
    DateTime? clockIn,
    Value<DateTime?> clockOut = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    Value<int?> correctedByUserId = const Value.absent(),
    Value<DateTime?> correctedAt = const Value.absent(),
    Value<String?> correctionNote = const Value.absent(),
  }) => AttendanceData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    clockIn: clockIn ?? this.clockIn,
    clockOut: clockOut.present ? clockOut.value : this.clockOut,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    correctedByUserId: correctedByUserId.present
        ? correctedByUserId.value
        : this.correctedByUserId,
    correctedAt: correctedAt.present ? correctedAt.value : this.correctedAt,
    correctionNote: correctionNote.present
        ? correctionNote.value
        : this.correctionNote,
  );
  AttendanceData copyWithCompanion(AttendanceCompanion data) {
    return AttendanceData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      clockIn: data.clockIn.present ? data.clockIn.value : this.clockIn,
      clockOut: data.clockOut.present ? data.clockOut.value : this.clockOut,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      correctedByUserId: data.correctedByUserId.present
          ? data.correctedByUserId.value
          : this.correctedByUserId,
      correctedAt: data.correctedAt.present
          ? data.correctedAt.value
          : this.correctedAt,
      correctionNote: data.correctionNote.present
          ? data.correctionNote.value
          : this.correctionNote,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('clockIn: $clockIn, ')
          ..write('clockOut: $clockOut, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('correctedByUserId: $correctedByUserId, ')
          ..write('correctedAt: $correctedAt, ')
          ..write('correctionNote: $correctionNote')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    clockIn,
    clockOut,
    notes,
    createdAt,
    correctedByUserId,
    correctedAt,
    correctionNote,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttendanceData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.clockIn == this.clockIn &&
          other.clockOut == this.clockOut &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.correctedByUserId == this.correctedByUserId &&
          other.correctedAt == this.correctedAt &&
          other.correctionNote == this.correctionNote);
}

class AttendanceCompanion extends UpdateCompanion<AttendanceData> {
  final Value<int> id;
  final Value<int> userId;
  final Value<DateTime> clockIn;
  final Value<DateTime?> clockOut;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int?> correctedByUserId;
  final Value<DateTime?> correctedAt;
  final Value<String?> correctionNote;
  const AttendanceCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.clockIn = const Value.absent(),
    this.clockOut = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.correctedByUserId = const Value.absent(),
    this.correctedAt = const Value.absent(),
    this.correctionNote = const Value.absent(),
  });
  AttendanceCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required DateTime clockIn,
    this.clockOut = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.correctedByUserId = const Value.absent(),
    this.correctedAt = const Value.absent(),
    this.correctionNote = const Value.absent(),
  }) : userId = Value(userId),
       clockIn = Value(clockIn);
  static Insertable<AttendanceData> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<DateTime>? clockIn,
    Expression<DateTime>? clockOut,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? correctedByUserId,
    Expression<DateTime>? correctedAt,
    Expression<String>? correctionNote,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (clockIn != null) 'clock_in': clockIn,
      if (clockOut != null) 'clock_out': clockOut,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (correctedByUserId != null) 'corrected_by_user_id': correctedByUserId,
      if (correctedAt != null) 'corrected_at': correctedAt,
      if (correctionNote != null) 'correction_note': correctionNote,
    });
  }

  AttendanceCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<DateTime>? clockIn,
    Value<DateTime?>? clockOut,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int?>? correctedByUserId,
    Value<DateTime?>? correctedAt,
    Value<String?>? correctionNote,
  }) {
    return AttendanceCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clockIn: clockIn ?? this.clockIn,
      clockOut: clockOut ?? this.clockOut,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      correctedByUserId: correctedByUserId ?? this.correctedByUserId,
      correctedAt: correctedAt ?? this.correctedAt,
      correctionNote: correctionNote ?? this.correctionNote,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (clockIn.present) {
      map['clock_in'] = Variable<DateTime>(clockIn.value);
    }
    if (clockOut.present) {
      map['clock_out'] = Variable<DateTime>(clockOut.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (correctedByUserId.present) {
      map['corrected_by_user_id'] = Variable<int>(correctedByUserId.value);
    }
    if (correctedAt.present) {
      map['corrected_at'] = Variable<DateTime>(correctedAt.value);
    }
    if (correctionNote.present) {
      map['correction_note'] = Variable<String>(correctionNote.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendanceCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('clockIn: $clockIn, ')
          ..write('clockOut: $clockOut, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('correctedByUserId: $correctedByUserId, ')
          ..write('correctedAt: $correctedAt, ')
          ..write('correctionNote: $correctionNote')
          ..write(')'))
        .toString();
  }
}

class $StaffPurchasesTable extends StaffPurchases
    with TableInfo<$StaffPurchasesTable, StaffPurchase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffPurchasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<int> staffId = GeneratedColumn<int>(
    'staff_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentTypeMeta = const VerificationMeta(
    'paymentType',
  );
  @override
  late final GeneratedColumn<String> paymentType = GeneratedColumn<String>(
    'payment_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaidMeta = const VerificationMeta(
    'amountPaid',
  );
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
    'amount_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _debtAmountMeta = const VerificationMeta(
    'debtAmount',
  );
  @override
  late final GeneratedColumn<double> debtAmount = GeneratedColumn<double>(
    'debt_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<int> saleId = GeneratedColumn<int>(
    'sale_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales (id)',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    staffId,
    productId,
    quantity,
    unitPrice,
    totalAmount,
    paymentType,
    amountPaid,
    debtAmount,
    saleId,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staff_purchases';
  @override
  VerificationContext validateIntegrity(
    Insertable<StaffPurchase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    } else if (isInserting) {
      context.missing(_staffIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('payment_type')) {
      context.handle(
        _paymentTypeMeta,
        paymentType.isAcceptableOrUnknown(
          data['payment_type']!,
          _paymentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentTypeMeta);
    }
    if (data.containsKey('amount_paid')) {
      context.handle(
        _amountPaidMeta,
        amountPaid.isAcceptableOrUnknown(data['amount_paid']!, _amountPaidMeta),
      );
    }
    if (data.containsKey('debt_amount')) {
      context.handle(
        _debtAmountMeta,
        debtAmount.isAcceptableOrUnknown(data['debt_amount']!, _debtAmountMeta),
      );
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StaffPurchase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaffPurchase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}staff_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      paymentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_type'],
      )!,
      amountPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_paid'],
      )!,
      debtAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}debt_amount'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sale_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StaffPurchasesTable createAlias(String alias) {
    return $StaffPurchasesTable(attachedDatabase, alias);
  }
}

class StaffPurchase extends DataClass implements Insertable<StaffPurchase> {
  final int id;
  final int staffId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String paymentType;
  final double amountPaid;
  final double debtAmount;
  final int? saleId;
  final String? note;
  final DateTime createdAt;
  const StaffPurchase({
    required this.id,
    required this.staffId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.paymentType,
    required this.amountPaid,
    required this.debtAmount,
    this.saleId,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['staff_id'] = Variable<int>(staffId);
    map['product_id'] = Variable<int>(productId);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['total_amount'] = Variable<double>(totalAmount);
    map['payment_type'] = Variable<String>(paymentType);
    map['amount_paid'] = Variable<double>(amountPaid);
    map['debt_amount'] = Variable<double>(debtAmount);
    if (!nullToAbsent || saleId != null) {
      map['sale_id'] = Variable<int>(saleId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StaffPurchasesCompanion toCompanion(bool nullToAbsent) {
    return StaffPurchasesCompanion(
      id: Value(id),
      staffId: Value(staffId),
      productId: Value(productId),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      totalAmount: Value(totalAmount),
      paymentType: Value(paymentType),
      amountPaid: Value(amountPaid),
      debtAmount: Value(debtAmount),
      saleId: saleId == null && nullToAbsent
          ? const Value.absent()
          : Value(saleId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory StaffPurchase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaffPurchase(
      id: serializer.fromJson<int>(json['id']),
      staffId: serializer.fromJson<int>(json['staffId']),
      productId: serializer.fromJson<int>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      paymentType: serializer.fromJson<String>(json['paymentType']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      debtAmount: serializer.fromJson<double>(json['debtAmount']),
      saleId: serializer.fromJson<int?>(json['saleId']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'staffId': serializer.toJson<int>(staffId),
      'productId': serializer.toJson<int>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'paymentType': serializer.toJson<String>(paymentType),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'debtAmount': serializer.toJson<double>(debtAmount),
      'saleId': serializer.toJson<int?>(saleId),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StaffPurchase copyWith({
    int? id,
    int? staffId,
    int? productId,
    int? quantity,
    double? unitPrice,
    double? totalAmount,
    String? paymentType,
    double? amountPaid,
    double? debtAmount,
    Value<int?> saleId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => StaffPurchase(
    id: id ?? this.id,
    staffId: staffId ?? this.staffId,
    productId: productId ?? this.productId,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    totalAmount: totalAmount ?? this.totalAmount,
    paymentType: paymentType ?? this.paymentType,
    amountPaid: amountPaid ?? this.amountPaid,
    debtAmount: debtAmount ?? this.debtAmount,
    saleId: saleId.present ? saleId.value : this.saleId,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  StaffPurchase copyWithCompanion(StaffPurchasesCompanion data) {
    return StaffPurchase(
      id: data.id.present ? data.id.value : this.id,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      paymentType: data.paymentType.present
          ? data.paymentType.value
          : this.paymentType,
      amountPaid: data.amountPaid.present
          ? data.amountPaid.value
          : this.amountPaid,
      debtAmount: data.debtAmount.present
          ? data.debtAmount.value
          : this.debtAmount,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaffPurchase(')
          ..write('id: $id, ')
          ..write('staffId: $staffId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentType: $paymentType, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('debtAmount: $debtAmount, ')
          ..write('saleId: $saleId, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    staffId,
    productId,
    quantity,
    unitPrice,
    totalAmount,
    paymentType,
    amountPaid,
    debtAmount,
    saleId,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaffPurchase &&
          other.id == this.id &&
          other.staffId == this.staffId &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.totalAmount == this.totalAmount &&
          other.paymentType == this.paymentType &&
          other.amountPaid == this.amountPaid &&
          other.debtAmount == this.debtAmount &&
          other.saleId == this.saleId &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class StaffPurchasesCompanion extends UpdateCompanion<StaffPurchase> {
  final Value<int> id;
  final Value<int> staffId;
  final Value<int> productId;
  final Value<int> quantity;
  final Value<double> unitPrice;
  final Value<double> totalAmount;
  final Value<String> paymentType;
  final Value<double> amountPaid;
  final Value<double> debtAmount;
  final Value<int?> saleId;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const StaffPurchasesCompanion({
    this.id = const Value.absent(),
    this.staffId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.debtAmount = const Value.absent(),
    this.saleId = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  StaffPurchasesCompanion.insert({
    this.id = const Value.absent(),
    required int staffId,
    required int productId,
    required int quantity,
    required double unitPrice,
    required double totalAmount,
    required String paymentType,
    this.amountPaid = const Value.absent(),
    this.debtAmount = const Value.absent(),
    this.saleId = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : staffId = Value(staffId),
       productId = Value(productId),
       quantity = Value(quantity),
       unitPrice = Value(unitPrice),
       totalAmount = Value(totalAmount),
       paymentType = Value(paymentType);
  static Insertable<StaffPurchase> custom({
    Expression<int>? id,
    Expression<int>? staffId,
    Expression<int>? productId,
    Expression<int>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? totalAmount,
    Expression<String>? paymentType,
    Expression<double>? amountPaid,
    Expression<double>? debtAmount,
    Expression<int>? saleId,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (staffId != null) 'staff_id': staffId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (paymentType != null) 'payment_type': paymentType,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (debtAmount != null) 'debt_amount': debtAmount,
      if (saleId != null) 'sale_id': saleId,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  StaffPurchasesCompanion copyWith({
    Value<int>? id,
    Value<int>? staffId,
    Value<int>? productId,
    Value<int>? quantity,
    Value<double>? unitPrice,
    Value<double>? totalAmount,
    Value<String>? paymentType,
    Value<double>? amountPaid,
    Value<double>? debtAmount,
    Value<int?>? saleId,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return StaffPurchasesCompanion(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentType: paymentType ?? this.paymentType,
      amountPaid: amountPaid ?? this.amountPaid,
      debtAmount: debtAmount ?? this.debtAmount,
      saleId: saleId ?? this.saleId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (staffId.present) {
      map['staff_id'] = Variable<int>(staffId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (paymentType.present) {
      map['payment_type'] = Variable<String>(paymentType.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (debtAmount.present) {
      map['debt_amount'] = Variable<double>(debtAmount.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<int>(saleId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaffPurchasesCompanion(')
          ..write('id: $id, ')
          ..write('staffId: $staffId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentType: $paymentType, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('debtAmount: $debtAmount, ')
          ..write('saleId: $saleId, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $StaffDebtPaymentsTable extends StaffDebtPayments
    with TableInfo<$StaffDebtPaymentsTable, StaffDebtPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffDebtPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _staffIdMeta = const VerificationMeta(
    'staffId',
  );
  @override
  late final GeneratedColumn<int> staffId = GeneratedColumn<int>(
    'staff_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedByMeta = const VerificationMeta(
    'recordedBy',
  );
  @override
  late final GeneratedColumn<int> recordedBy = GeneratedColumn<int>(
    'recorded_by',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    staffId,
    amount,
    paymentMethod,
    note,
    recordedBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staff_debt_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<StaffDebtPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('staff_id')) {
      context.handle(
        _staffIdMeta,
        staffId.isAcceptableOrUnknown(data['staff_id']!, _staffIdMeta),
      );
    } else if (isInserting) {
      context.missing(_staffIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('recorded_by')) {
      context.handle(
        _recordedByMeta,
        recordedBy.isAcceptableOrUnknown(data['recorded_by']!, _recordedByMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StaffDebtPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaffDebtPayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      staffId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}staff_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      recordedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorded_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StaffDebtPaymentsTable createAlias(String alias) {
    return $StaffDebtPaymentsTable(attachedDatabase, alias);
  }
}

class StaffDebtPayment extends DataClass
    implements Insertable<StaffDebtPayment> {
  final int id;
  final int staffId;
  final double amount;
  final String paymentMethod;
  final String? note;
  final int recordedBy;
  final DateTime createdAt;
  const StaffDebtPayment({
    required this.id,
    required this.staffId,
    required this.amount,
    required this.paymentMethod,
    this.note,
    required this.recordedBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['staff_id'] = Variable<int>(staffId);
    map['amount'] = Variable<double>(amount);
    map['payment_method'] = Variable<String>(paymentMethod);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['recorded_by'] = Variable<int>(recordedBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StaffDebtPaymentsCompanion toCompanion(bool nullToAbsent) {
    return StaffDebtPaymentsCompanion(
      id: Value(id),
      staffId: Value(staffId),
      amount: Value(amount),
      paymentMethod: Value(paymentMethod),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      recordedBy: Value(recordedBy),
      createdAt: Value(createdAt),
    );
  }

  factory StaffDebtPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaffDebtPayment(
      id: serializer.fromJson<int>(json['id']),
      staffId: serializer.fromJson<int>(json['staffId']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      note: serializer.fromJson<String?>(json['note']),
      recordedBy: serializer.fromJson<int>(json['recordedBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'staffId': serializer.toJson<int>(staffId),
      'amount': serializer.toJson<double>(amount),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'note': serializer.toJson<String?>(note),
      'recordedBy': serializer.toJson<int>(recordedBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StaffDebtPayment copyWith({
    int? id,
    int? staffId,
    double? amount,
    String? paymentMethod,
    Value<String?> note = const Value.absent(),
    int? recordedBy,
    DateTime? createdAt,
  }) => StaffDebtPayment(
    id: id ?? this.id,
    staffId: staffId ?? this.staffId,
    amount: amount ?? this.amount,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    note: note.present ? note.value : this.note,
    recordedBy: recordedBy ?? this.recordedBy,
    createdAt: createdAt ?? this.createdAt,
  );
  StaffDebtPayment copyWithCompanion(StaffDebtPaymentsCompanion data) {
    return StaffDebtPayment(
      id: data.id.present ? data.id.value : this.id,
      staffId: data.staffId.present ? data.staffId.value : this.staffId,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      note: data.note.present ? data.note.value : this.note,
      recordedBy: data.recordedBy.present
          ? data.recordedBy.value
          : this.recordedBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaffDebtPayment(')
          ..write('id: $id, ')
          ..write('staffId: $staffId, ')
          ..write('amount: $amount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('note: $note, ')
          ..write('recordedBy: $recordedBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    staffId,
    amount,
    paymentMethod,
    note,
    recordedBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaffDebtPayment &&
          other.id == this.id &&
          other.staffId == this.staffId &&
          other.amount == this.amount &&
          other.paymentMethod == this.paymentMethod &&
          other.note == this.note &&
          other.recordedBy == this.recordedBy &&
          other.createdAt == this.createdAt);
}

class StaffDebtPaymentsCompanion extends UpdateCompanion<StaffDebtPayment> {
  final Value<int> id;
  final Value<int> staffId;
  final Value<double> amount;
  final Value<String> paymentMethod;
  final Value<String?> note;
  final Value<int> recordedBy;
  final Value<DateTime> createdAt;
  const StaffDebtPaymentsCompanion({
    this.id = const Value.absent(),
    this.staffId = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.note = const Value.absent(),
    this.recordedBy = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  StaffDebtPaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int staffId,
    required double amount,
    required String paymentMethod,
    this.note = const Value.absent(),
    required int recordedBy,
    this.createdAt = const Value.absent(),
  }) : staffId = Value(staffId),
       amount = Value(amount),
       paymentMethod = Value(paymentMethod),
       recordedBy = Value(recordedBy);
  static Insertable<StaffDebtPayment> custom({
    Expression<int>? id,
    Expression<int>? staffId,
    Expression<double>? amount,
    Expression<String>? paymentMethod,
    Expression<String>? note,
    Expression<int>? recordedBy,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (staffId != null) 'staff_id': staffId,
      if (amount != null) 'amount': amount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (note != null) 'note': note,
      if (recordedBy != null) 'recorded_by': recordedBy,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  StaffDebtPaymentsCompanion copyWith({
    Value<int>? id,
    Value<int>? staffId,
    Value<double>? amount,
    Value<String>? paymentMethod,
    Value<String?>? note,
    Value<int>? recordedBy,
    Value<DateTime>? createdAt,
  }) {
    return StaffDebtPaymentsCompanion(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      note: note ?? this.note,
      recordedBy: recordedBy ?? this.recordedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (staffId.present) {
      map['staff_id'] = Variable<int>(staffId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (recordedBy.present) {
      map['recorded_by'] = Variable<int>(recordedBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaffDebtPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('staffId: $staffId, ')
          ..write('amount: $amount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('note: $note, ')
          ..write('recordedBy: $recordedBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SupplierDeliveryItemsTable extends SupplierDeliveryItems
    with TableInfo<$SupplierDeliveryItemsTable, SupplierDeliveryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierDeliveryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deliveryIdMeta = const VerificationMeta(
    'deliveryId',
  );
  @override
  late final GeneratedColumn<int> deliveryId = GeneratedColumn<int>(
    'delivery_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES supplier_deliveries (id)',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostMeta = const VerificationMeta(
    'unitCost',
  );
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
    'unit_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCostMeta = const VerificationMeta(
    'totalCost',
  );
  @override
  late final GeneratedColumn<double> totalCost = GeneratedColumn<double>(
    'total_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deliveryId,
    productId,
    quantity,
    unitCost,
    totalCost,
    expiryDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_delivery_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierDeliveryItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('delivery_id')) {
      context.handle(
        _deliveryIdMeta,
        deliveryId.isAcceptableOrUnknown(data['delivery_id']!, _deliveryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deliveryIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(
        _unitCostMeta,
        unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta),
      );
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('total_cost')) {
      context.handle(
        _totalCostMeta,
        totalCost.isAcceptableOrUnknown(data['total_cost']!, _totalCostMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCostMeta);
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierDeliveryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierDeliveryItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deliveryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivery_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_cost'],
      )!,
      totalCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_cost'],
      )!,
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      ),
    );
  }

  @override
  $SupplierDeliveryItemsTable createAlias(String alias) {
    return $SupplierDeliveryItemsTable(attachedDatabase, alias);
  }
}

class SupplierDeliveryItem extends DataClass
    implements Insertable<SupplierDeliveryItem> {
  final int id;

  /// The supplier delivery this item belongs to.
  final int deliveryId;

  /// Existing product being received.
  final int productId;

  /// Quantity received.
  final int quantity;

  /// Actual supplier purchase price at the time of delivery.
  ///
  /// Preserved historically even if the product's current
  /// costPrice changes later.
  final double unitCost;

  /// quantity × unitCost
  final double totalCost;

  /// Optional expiry date for this specific received batch.
  final DateTime? expiryDate;
  const SupplierDeliveryItem({
    required this.id,
    required this.deliveryId,
    required this.productId,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
    this.expiryDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['delivery_id'] = Variable<int>(deliveryId);
    map['product_id'] = Variable<int>(productId);
    map['quantity'] = Variable<int>(quantity);
    map['unit_cost'] = Variable<double>(unitCost);
    map['total_cost'] = Variable<double>(totalCost);
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<DateTime>(expiryDate);
    }
    return map;
  }

  SupplierDeliveryItemsCompanion toCompanion(bool nullToAbsent) {
    return SupplierDeliveryItemsCompanion(
      id: Value(id),
      deliveryId: Value(deliveryId),
      productId: Value(productId),
      quantity: Value(quantity),
      unitCost: Value(unitCost),
      totalCost: Value(totalCost),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
    );
  }

  factory SupplierDeliveryItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierDeliveryItem(
      id: serializer.fromJson<int>(json['id']),
      deliveryId: serializer.fromJson<int>(json['deliveryId']),
      productId: serializer.fromJson<int>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitCost: serializer.fromJson<double>(json['unitCost']),
      totalCost: serializer.fromJson<double>(json['totalCost']),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deliveryId': serializer.toJson<int>(deliveryId),
      'productId': serializer.toJson<int>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'unitCost': serializer.toJson<double>(unitCost),
      'totalCost': serializer.toJson<double>(totalCost),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
    };
  }

  SupplierDeliveryItem copyWith({
    int? id,
    int? deliveryId,
    int? productId,
    int? quantity,
    double? unitCost,
    double? totalCost,
    Value<DateTime?> expiryDate = const Value.absent(),
  }) => SupplierDeliveryItem(
    id: id ?? this.id,
    deliveryId: deliveryId ?? this.deliveryId,
    productId: productId ?? this.productId,
    quantity: quantity ?? this.quantity,
    unitCost: unitCost ?? this.unitCost,
    totalCost: totalCost ?? this.totalCost,
    expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
  );
  SupplierDeliveryItem copyWithCompanion(SupplierDeliveryItemsCompanion data) {
    return SupplierDeliveryItem(
      id: data.id.present ? data.id.value : this.id,
      deliveryId: data.deliveryId.present
          ? data.deliveryId.value
          : this.deliveryId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      totalCost: data.totalCost.present ? data.totalCost.value : this.totalCost,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierDeliveryItem(')
          ..write('id: $id, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('totalCost: $totalCost, ')
          ..write('expiryDate: $expiryDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deliveryId,
    productId,
    quantity,
    unitCost,
    totalCost,
    expiryDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierDeliveryItem &&
          other.id == this.id &&
          other.deliveryId == this.deliveryId &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.unitCost == this.unitCost &&
          other.totalCost == this.totalCost &&
          other.expiryDate == this.expiryDate);
}

class SupplierDeliveryItemsCompanion
    extends UpdateCompanion<SupplierDeliveryItem> {
  final Value<int> id;
  final Value<int> deliveryId;
  final Value<int> productId;
  final Value<int> quantity;
  final Value<double> unitCost;
  final Value<double> totalCost;
  final Value<DateTime?> expiryDate;
  const SupplierDeliveryItemsCompanion({
    this.id = const Value.absent(),
    this.deliveryId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.totalCost = const Value.absent(),
    this.expiryDate = const Value.absent(),
  });
  SupplierDeliveryItemsCompanion.insert({
    this.id = const Value.absent(),
    required int deliveryId,
    required int productId,
    required int quantity,
    required double unitCost,
    required double totalCost,
    this.expiryDate = const Value.absent(),
  }) : deliveryId = Value(deliveryId),
       productId = Value(productId),
       quantity = Value(quantity),
       unitCost = Value(unitCost),
       totalCost = Value(totalCost);
  static Insertable<SupplierDeliveryItem> custom({
    Expression<int>? id,
    Expression<int>? deliveryId,
    Expression<int>? productId,
    Expression<int>? quantity,
    Expression<double>? unitCost,
    Expression<double>? totalCost,
    Expression<DateTime>? expiryDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deliveryId != null) 'delivery_id': deliveryId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (unitCost != null) 'unit_cost': unitCost,
      if (totalCost != null) 'total_cost': totalCost,
      if (expiryDate != null) 'expiry_date': expiryDate,
    });
  }

  SupplierDeliveryItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? deliveryId,
    Value<int>? productId,
    Value<int>? quantity,
    Value<double>? unitCost,
    Value<double>? totalCost,
    Value<DateTime?>? expiryDate,
  }) {
    return SupplierDeliveryItemsCompanion(
      id: id ?? this.id,
      deliveryId: deliveryId ?? this.deliveryId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      totalCost: totalCost ?? this.totalCost,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deliveryId.present) {
      map['delivery_id'] = Variable<int>(deliveryId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (totalCost.present) {
      map['total_cost'] = Variable<double>(totalCost.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierDeliveryItemsCompanion(')
          ..write('id: $id, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('totalCost: $totalCost, ')
          ..write('expiryDate: $expiryDate')
          ..write(')'))
        .toString();
  }
}

class $SupplierPaymentsTable extends SupplierPayments
    with TableInfo<$SupplierPaymentsTable, SupplierPayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<int> supplierId = GeneratedColumn<int>(
    'supplier_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES suppliers (id)',
    ),
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'payment_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('cash'),
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    supplierId,
    paymentDate,
    amount,
    paymentMethod,
    reference,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierPayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierPayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierPayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}supplier_id'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_date'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $SupplierPaymentsTable createAlias(String alias) {
    return $SupplierPaymentsTable(attachedDatabase, alias);
  }
}

class SupplierPayment extends DataClass implements Insertable<SupplierPayment> {
  final int id;

  /// Supplier receiving the payment.
  final int supplierId;

  /// Date the payment was made.
  final DateTime paymentDate;

  /// Amount actually paid.
  final double amount;

  /// cash / pos / transfer / etc.
  final String paymentMethod;

  /// Bank transfer / POS reference where applicable.
  final String? reference;

  /// Optional payment notes.
  final String? notes;
  const SupplierPayment({
    required this.id,
    required this.supplierId,
    required this.paymentDate,
    required this.amount,
    required this.paymentMethod,
    this.reference,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['supplier_id'] = Variable<int>(supplierId);
    map['payment_date'] = Variable<DateTime>(paymentDate);
    map['amount'] = Variable<double>(amount);
    map['payment_method'] = Variable<String>(paymentMethod);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  SupplierPaymentsCompanion toCompanion(bool nullToAbsent) {
    return SupplierPaymentsCompanion(
      id: Value(id),
      supplierId: Value(supplierId),
      paymentDate: Value(paymentDate),
      amount: Value(amount),
      paymentMethod: Value(paymentMethod),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory SupplierPayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierPayment(
      id: serializer.fromJson<int>(json['id']),
      supplierId: serializer.fromJson<int>(json['supplierId']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      reference: serializer.fromJson<String?>(json['reference']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'supplierId': serializer.toJson<int>(supplierId),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'amount': serializer.toJson<double>(amount),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'reference': serializer.toJson<String?>(reference),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  SupplierPayment copyWith({
    int? id,
    int? supplierId,
    DateTime? paymentDate,
    double? amount,
    String? paymentMethod,
    Value<String?> reference = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => SupplierPayment(
    id: id ?? this.id,
    supplierId: supplierId ?? this.supplierId,
    paymentDate: paymentDate ?? this.paymentDate,
    amount: amount ?? this.amount,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    reference: reference.present ? reference.value : this.reference,
    notes: notes.present ? notes.value : this.notes,
  );
  SupplierPayment copyWithCompanion(SupplierPaymentsCompanion data) {
    return SupplierPayment(
      id: data.id.present ? data.id.value : this.id,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      reference: data.reference.present ? data.reference.value : this.reference,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierPayment(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('amount: $amount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    supplierId,
    paymentDate,
    amount,
    paymentMethod,
    reference,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierPayment &&
          other.id == this.id &&
          other.supplierId == this.supplierId &&
          other.paymentDate == this.paymentDate &&
          other.amount == this.amount &&
          other.paymentMethod == this.paymentMethod &&
          other.reference == this.reference &&
          other.notes == this.notes);
}

class SupplierPaymentsCompanion extends UpdateCompanion<SupplierPayment> {
  final Value<int> id;
  final Value<int> supplierId;
  final Value<DateTime> paymentDate;
  final Value<double> amount;
  final Value<String> paymentMethod;
  final Value<String?> reference;
  final Value<String?> notes;
  const SupplierPaymentsCompanion({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
  });
  SupplierPaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int supplierId,
    this.paymentDate = const Value.absent(),
    required double amount,
    this.paymentMethod = const Value.absent(),
    this.reference = const Value.absent(),
    this.notes = const Value.absent(),
  }) : supplierId = Value(supplierId),
       amount = Value(amount);
  static Insertable<SupplierPayment> custom({
    Expression<int>? id,
    Expression<int>? supplierId,
    Expression<DateTime>? paymentDate,
    Expression<double>? amount,
    Expression<String>? paymentMethod,
    Expression<String>? reference,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplierId != null) 'supplier_id': supplierId,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (amount != null) 'amount': amount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (reference != null) 'reference': reference,
      if (notes != null) 'notes': notes,
    });
  }

  SupplierPaymentsCompanion copyWith({
    Value<int>? id,
    Value<int>? supplierId,
    Value<DateTime>? paymentDate,
    Value<double>? amount,
    Value<String>? paymentMethod,
    Value<String?>? reference,
    Value<String?>? notes,
  }) {
    return SupplierPaymentsCompanion(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      paymentDate: paymentDate ?? this.paymentDate,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<int>(supplierId.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('amount: $amount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('reference: $reference, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $SupplierPaymentAllocationsTable extends SupplierPaymentAllocations
    with
        TableInfo<$SupplierPaymentAllocationsTable, SupplierPaymentAllocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierPaymentAllocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _paymentIdMeta = const VerificationMeta(
    'paymentId',
  );
  @override
  late final GeneratedColumn<int> paymentId = GeneratedColumn<int>(
    'payment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES supplier_payments (id)',
    ),
  );
  static const VerificationMeta _deliveryIdMeta = const VerificationMeta(
    'deliveryId',
  );
  @override
  late final GeneratedColumn<int> deliveryId = GeneratedColumn<int>(
    'delivery_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES supplier_deliveries (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, paymentId, deliveryId, amount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_payment_allocations';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierPaymentAllocation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('payment_id')) {
      context.handle(
        _paymentIdMeta,
        paymentId.isAcceptableOrUnknown(data['payment_id']!, _paymentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_paymentIdMeta);
    }
    if (data.containsKey('delivery_id')) {
      context.handle(
        _deliveryIdMeta,
        deliveryId.isAcceptableOrUnknown(data['delivery_id']!, _deliveryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deliveryIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierPaymentAllocation map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierPaymentAllocation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      paymentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_id'],
      )!,
      deliveryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivery_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $SupplierPaymentAllocationsTable createAlias(String alias) {
    return $SupplierPaymentAllocationsTable(attachedDatabase, alias);
  }
}

class SupplierPaymentAllocation extends DataClass
    implements Insertable<SupplierPaymentAllocation> {
  final int id;

  /// Payment being allocated.
  final int paymentId;

  /// Delivery/invoice receiving this payment.
  final int deliveryId;

  /// Amount of the payment applied to this delivery.
  final double amount;
  const SupplierPaymentAllocation({
    required this.id,
    required this.paymentId,
    required this.deliveryId,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['payment_id'] = Variable<int>(paymentId);
    map['delivery_id'] = Variable<int>(deliveryId);
    map['amount'] = Variable<double>(amount);
    return map;
  }

  SupplierPaymentAllocationsCompanion toCompanion(bool nullToAbsent) {
    return SupplierPaymentAllocationsCompanion(
      id: Value(id),
      paymentId: Value(paymentId),
      deliveryId: Value(deliveryId),
      amount: Value(amount),
    );
  }

  factory SupplierPaymentAllocation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierPaymentAllocation(
      id: serializer.fromJson<int>(json['id']),
      paymentId: serializer.fromJson<int>(json['paymentId']),
      deliveryId: serializer.fromJson<int>(json['deliveryId']),
      amount: serializer.fromJson<double>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'paymentId': serializer.toJson<int>(paymentId),
      'deliveryId': serializer.toJson<int>(deliveryId),
      'amount': serializer.toJson<double>(amount),
    };
  }

  SupplierPaymentAllocation copyWith({
    int? id,
    int? paymentId,
    int? deliveryId,
    double? amount,
  }) => SupplierPaymentAllocation(
    id: id ?? this.id,
    paymentId: paymentId ?? this.paymentId,
    deliveryId: deliveryId ?? this.deliveryId,
    amount: amount ?? this.amount,
  );
  SupplierPaymentAllocation copyWithCompanion(
    SupplierPaymentAllocationsCompanion data,
  ) {
    return SupplierPaymentAllocation(
      id: data.id.present ? data.id.value : this.id,
      paymentId: data.paymentId.present ? data.paymentId.value : this.paymentId,
      deliveryId: data.deliveryId.present
          ? data.deliveryId.value
          : this.deliveryId,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierPaymentAllocation(')
          ..write('id: $id, ')
          ..write('paymentId: $paymentId, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, paymentId, deliveryId, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierPaymentAllocation &&
          other.id == this.id &&
          other.paymentId == this.paymentId &&
          other.deliveryId == this.deliveryId &&
          other.amount == this.amount);
}

class SupplierPaymentAllocationsCompanion
    extends UpdateCompanion<SupplierPaymentAllocation> {
  final Value<int> id;
  final Value<int> paymentId;
  final Value<int> deliveryId;
  final Value<double> amount;
  const SupplierPaymentAllocationsCompanion({
    this.id = const Value.absent(),
    this.paymentId = const Value.absent(),
    this.deliveryId = const Value.absent(),
    this.amount = const Value.absent(),
  });
  SupplierPaymentAllocationsCompanion.insert({
    this.id = const Value.absent(),
    required int paymentId,
    required int deliveryId,
    required double amount,
  }) : paymentId = Value(paymentId),
       deliveryId = Value(deliveryId),
       amount = Value(amount);
  static Insertable<SupplierPaymentAllocation> custom({
    Expression<int>? id,
    Expression<int>? paymentId,
    Expression<int>? deliveryId,
    Expression<double>? amount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (paymentId != null) 'payment_id': paymentId,
      if (deliveryId != null) 'delivery_id': deliveryId,
      if (amount != null) 'amount': amount,
    });
  }

  SupplierPaymentAllocationsCompanion copyWith({
    Value<int>? id,
    Value<int>? paymentId,
    Value<int>? deliveryId,
    Value<double>? amount,
  }) {
    return SupplierPaymentAllocationsCompanion(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      deliveryId: deliveryId ?? this.deliveryId,
      amount: amount ?? this.amount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (paymentId.present) {
      map['payment_id'] = Variable<int>(paymentId.value);
    }
    if (deliveryId.present) {
      map['delivery_id'] = Variable<int>(deliveryId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplierPaymentAllocationsCompanion(')
          ..write('id: $id, ')
          ..write('paymentId: $paymentId, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $SupplierDeliveriesTable supplierDeliveries =
      $SupplierDeliveriesTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $AttendanceTable attendance = $AttendanceTable(this);
  late final $StaffPurchasesTable staffPurchases = $StaffPurchasesTable(this);
  late final $StaffDebtPaymentsTable staffDebtPayments =
      $StaffDebtPaymentsTable(this);
  late final $SupplierDeliveryItemsTable supplierDeliveryItems =
      $SupplierDeliveryItemsTable(this);
  late final $SupplierPaymentsTable supplierPayments = $SupplierPaymentsTable(
    this,
  );
  late final $SupplierPaymentAllocationsTable supplierPaymentAllocations =
      $SupplierPaymentAllocationsTable(this);
  late final UserDao userDao = UserDao(this as AppDatabase);
  late final ProductDao productDao = ProductDao(this as AppDatabase);
  late final StockMovementDao stockMovementDao = StockMovementDao(
    this as AppDatabase,
  );
  late final SupplierDao supplierDao = SupplierDao(this as AppDatabase);
  late final SalesDao salesDao = SalesDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final CategoryDao categoryDao = CategoryDao(this as AppDatabase);
  late final UserProfileDao userProfileDao = UserProfileDao(
    this as AppDatabase,
  );
  late final AttendanceDao attendanceDao = AttendanceDao(this as AppDatabase);
  late final StaffPurchaseDao staffPurchaseDao = StaffPurchaseDao(
    this as AppDatabase,
  );
  late final StaffDebtPaymentDao staffDebtPaymentDao = StaffDebtPaymentDao(
    this as AppDatabase,
  );
  late final SupplierDeliveryDao supplierDeliveryDao = SupplierDeliveryDao(
    this as AppDatabase,
  );
  late final SupplierDeliveryItemDao supplierDeliveryItemDao =
      SupplierDeliveryItemDao(this as AppDatabase);
  late final SupplierPaymentDao supplierPaymentDao = SupplierPaymentDao(
    this as AppDatabase,
  );
  late final SupplierPaymentAllocationDao supplierPaymentAllocationDao =
      SupplierPaymentAllocationDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    categories,
    products,
    suppliers,
    supplierDeliveries,
    stockMovements,
    sales,
    settings,
    userProfiles,
    attendance,
    staffPurchases,
    staffDebtPayments,
    supplierDeliveryItems,
    supplierPayments,
    supplierPaymentAllocations,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> loginId,
      required String email,
      required String password,
      Value<bool> isActive,
      Value<String> role,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> loginId,
      Value<String> email,
      Value<String> password,
      Value<bool> isActive,
      Value<String> role,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SalesTable, List<Sale>> _salesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sales,
    aliasName: 'users__id__sales__staff_id',
  );

  $$SalesTableProcessedTableManager get salesRefs {
    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.staffId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_salesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UserProfilesTable, List<UserProfile>>
  _userProfilesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userProfiles,
    aliasName: 'users__id__user_profiles__user_id',
  );

  $$UserProfilesTableProcessedTableManager get userProfilesRefs {
    final manager = $$UserProfilesTableTableManager(
      $_db,
      $_db.userProfiles,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_userProfilesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StaffPurchasesTable, List<StaffPurchase>>
  _staffPurchasesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.staffPurchases,
    aliasName: 'users__id__staff_purchases__staff_id',
  );

  $$StaffPurchasesTableProcessedTableManager get staffPurchasesRefs {
    final manager = $$StaffPurchasesTableTableManager(
      $_db,
      $_db.staffPurchases,
    ).filter((f) => f.staffId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_staffPurchasesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get loginId => $composableBuilder(
    column: $table.loginId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> salesRefs(
    Expression<bool> Function($$SalesTableFilterComposer f) f,
  ) {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.staffId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userProfilesRefs(
    Expression<bool> Function($$UserProfilesTableFilterComposer f) f,
  ) {
    final $$UserProfilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableFilterComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> staffPurchasesRefs(
    Expression<bool> Function($$StaffPurchasesTableFilterComposer f) f,
  ) {
    final $$StaffPurchasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.staffPurchases,
      getReferencedColumn: (t) => t.staffId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StaffPurchasesTableFilterComposer(
            $db: $db,
            $table: $db.staffPurchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get loginId => $composableBuilder(
    column: $table.loginId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get password => $composableBuilder(
    column: $table.password,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get loginId =>
      $composableBuilder(column: $table.loginId, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  Expression<T> salesRefs<T extends Object>(
    Expression<T> Function($$SalesTableAnnotationComposer a) f,
  ) {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.staffId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userProfilesRefs<T extends Object>(
    Expression<T> Function($$UserProfilesTableAnnotationComposer a) f,
  ) {
    final $$UserProfilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userProfiles,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserProfilesTableAnnotationComposer(
            $db: $db,
            $table: $db.userProfiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> staffPurchasesRefs<T extends Object>(
    Expression<T> Function($$StaffPurchasesTableAnnotationComposer a) f,
  ) {
    final $$StaffPurchasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.staffPurchases,
      getReferencedColumn: (t) => t.staffId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StaffPurchasesTableAnnotationComposer(
            $db: $db,
            $table: $db.staffPurchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({
            bool salesRefs,
            bool userProfilesRefs,
            bool staffPurchasesRefs,
          })
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> loginId = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> password = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> role = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                name: name,
                loginId: loginId,
                email: email,
                password: password,
                isActive: isActive,
                role: role,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> loginId = const Value.absent(),
                required String email,
                required String password,
                Value<bool> isActive = const Value.absent(),
                Value<String> role = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                name: name,
                loginId: loginId,
                email: email,
                password: password,
                isActive: isActive,
                role: role,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$UsersTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                salesRefs = false,
                userProfilesRefs = false,
                staffPurchasesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (salesRefs) db.sales,
                    if (userProfilesRefs) db.userProfiles,
                    if (staffPurchasesRefs) db.staffPurchases,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (salesRefs)
                        await $_getPrefetchedData<User, $UsersTable, Sale>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._salesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(db, table, p0).salesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.staffId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userProfilesRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          UserProfile
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._userProfilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).userProfilesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (staffPurchasesRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          StaffPurchase
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._staffPurchasesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).staffPurchasesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.staffId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({
        bool salesRefs,
        bool userProfilesRefs,
        bool staffPurchasesRefs,
      })
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> imagePath,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> imagePath,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductsTable, List<Product>> _productsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.products,
    aliasName: 'categories__id__products__category_id',
  );

  $$ProductsTableProcessedTableManager get productsRefs {
    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_productsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> productsRefs(
    Expression<bool> Function($$ProductsTableFilterComposer f) f,
  ) {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  Expression<T> productsRefs<T extends Object>(
    Expression<T> Function($$ProductsTableAnnotationComposer a) f,
  ) {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool productsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
              }) =>
                  CategoriesCompanion(id: id, name: name, imagePath: imagePath),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> imagePath = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                imagePath: imagePath,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (productsRefs) db.products],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productsRefs)
                    await $_getPrefetchedData<
                      Category,
                      $CategoriesTable,
                      Product
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._productsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).productsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool productsRefs})
    >;
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      Value<int> id,
      Value<String?> barcode,
      required String name,
      Value<String?> brand,
      required int categoryId,
      required String unit,
      required double costPrice,
      required double sellingPrice,
      Value<int> stock,
      Value<String?> imagePath,
      Value<DateTime?> expiryDate,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<int> id,
      Value<String?> barcode,
      Value<String> name,
      Value<String?> brand,
      Value<int> categoryId,
      Value<String> unit,
      Value<double> costPrice,
      Value<double> sellingPrice,
      Value<int> stock,
      Value<String?> imagePath,
      Value<DateTime?> expiryDate,
    });

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, Product> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('products__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StockMovementsTable, List<StockMovement>>
  _stockMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockMovements,
    aliasName: 'products__id__stock_movements__product_id',
  );

  $$StockMovementsTableProcessedTableManager get stockMovementsRefs {
    final manager = $$StockMovementsTableTableManager(
      $_db,
      $_db.stockMovements,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SalesTable, List<Sale>> _salesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sales,
    aliasName: 'products__id__sales__product_id',
  );

  $$SalesTableProcessedTableManager get salesRefs {
    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_salesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StaffPurchasesTable, List<StaffPurchase>>
  _staffPurchasesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.staffPurchases,
    aliasName: 'products__id__staff_purchases__product_id',
  );

  $$StaffPurchasesTableProcessedTableManager get staffPurchasesRefs {
    final manager = $$StaffPurchasesTableTableManager(
      $_db,
      $_db.staffPurchases,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_staffPurchasesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SupplierDeliveryItemsTable,
    List<SupplierDeliveryItem>
  >
  _supplierDeliveryItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.supplierDeliveryItems,
        aliasName: 'products__id__supplier_delivery_items__product_id',
      );

  $$SupplierDeliveryItemsTableProcessedTableManager
  get supplierDeliveryItemsRefs {
    final manager = $$SupplierDeliveryItemsTableTableManager(
      $_db,
      $_db.supplierDeliveryItems,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierDeliveryItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> stockMovementsRefs(
    Expression<bool> Function($$StockMovementsTableFilterComposer f) f,
  ) {
    final $$StockMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableFilterComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> salesRefs(
    Expression<bool> Function($$SalesTableFilterComposer f) f,
  ) {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> staffPurchasesRefs(
    Expression<bool> Function($$StaffPurchasesTableFilterComposer f) f,
  ) {
    final $$StaffPurchasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.staffPurchases,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StaffPurchasesTableFilterComposer(
            $db: $db,
            $table: $db.staffPurchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supplierDeliveryItemsRefs(
    Expression<bool> Function($$SupplierDeliveryItemsTableFilterComposer f) f,
  ) {
    final $$SupplierDeliveryItemsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supplierDeliveryItems,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierDeliveryItemsTableFilterComposer(
                $db: $db,
                $table: $db.supplierDeliveryItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get costPrice =>
      $composableBuilder(column: $table.costPrice, builder: (column) => column);

  GeneratedColumn<double> get sellingPrice => $composableBuilder(
    column: $table.sellingPrice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> stockMovementsRefs<T extends Object>(
    Expression<T> Function($$StockMovementsTableAnnotationComposer a) f,
  ) {
    final $$StockMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> salesRefs<T extends Object>(
    Expression<T> Function($$SalesTableAnnotationComposer a) f,
  ) {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> staffPurchasesRefs<T extends Object>(
    Expression<T> Function($$StaffPurchasesTableAnnotationComposer a) f,
  ) {
    final $$StaffPurchasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.staffPurchases,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StaffPurchasesTableAnnotationComposer(
            $db: $db,
            $table: $db.staffPurchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supplierDeliveryItemsRefs<T extends Object>(
    Expression<T> Function($$SupplierDeliveryItemsTableAnnotationComposer a) f,
  ) {
    final $$SupplierDeliveryItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supplierDeliveryItems,
          getReferencedColumn: (t) => t.productId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierDeliveryItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.supplierDeliveryItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          Product,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (Product, $$ProductsTableReferences),
          Product,
          PrefetchHooks Function({
            bool categoryId,
            bool stockMovementsRefs,
            bool salesRefs,
            bool staffPurchasesRefs,
            bool supplierDeliveryItemsRefs,
          })
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> costPrice = const Value.absent(),
                Value<double> sellingPrice = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                barcode: barcode,
                name: name,
                brand: brand,
                categoryId: categoryId,
                unit: unit,
                costPrice: costPrice,
                sellingPrice: sellingPrice,
                stock: stock,
                imagePath: imagePath,
                expiryDate: expiryDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                required String name,
                Value<String?> brand = const Value.absent(),
                required int categoryId,
                required String unit,
                required double costPrice,
                required double sellingPrice,
                Value<int> stock = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                barcode: barcode,
                name: name,
                brand: brand,
                categoryId: categoryId,
                unit: unit,
                costPrice: costPrice,
                sellingPrice: sellingPrice,
                stock: stock,
                imagePath: imagePath,
                expiryDate: expiryDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                stockMovementsRefs = false,
                salesRefs = false,
                staffPurchasesRefs = false,
                supplierDeliveryItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (stockMovementsRefs) db.stockMovements,
                    if (salesRefs) db.sales,
                    if (staffPurchasesRefs) db.staffPurchases,
                    if (supplierDeliveryItemsRefs) db.supplierDeliveryItems,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable: $$ProductsTableReferences
                                        ._categoryIdTable(db),
                                    referencedColumn: $$ProductsTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stockMovementsRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          StockMovement
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._stockMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (salesRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          Sale
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._salesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).salesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (staffPurchasesRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          StaffPurchase
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._staffPurchasesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).staffPurchasesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supplierDeliveryItemsRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          SupplierDeliveryItem
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._supplierDeliveryItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierDeliveryItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      Product,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (Product, $$ProductsTableReferences),
      Product,
      PrefetchHooks Function({
        bool categoryId,
        bool stockMovementsRefs,
        bool salesRefs,
        bool staffPurchasesRefs,
        bool supplierDeliveryItemsRefs,
      })
    >;
typedef $$SuppliersTableCreateCompanionBuilder =
    SuppliersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> contact,
      Value<String?> address,
      Value<String?> notes,
    });
typedef $$SuppliersTableUpdateCompanionBuilder =
    SuppliersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> contact,
      Value<String?> address,
      Value<String?> notes,
    });

final class $$SuppliersTableReferences
    extends BaseReferences<_$AppDatabase, $SuppliersTable, Supplier> {
  $$SuppliersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SupplierDeliveriesTable, List<SupplierDelivery>>
  _supplierDeliveriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.supplierDeliveries,
        aliasName: 'suppliers__id__supplier_deliveries__supplier_id',
      );

  $$SupplierDeliveriesTableProcessedTableManager get supplierDeliveriesRefs {
    final manager = $$SupplierDeliveriesTableTableManager(
      $_db,
      $_db.supplierDeliveries,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierDeliveriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StockMovementsTable, List<StockMovement>>
  _stockMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockMovements,
    aliasName: 'suppliers__id__stock_movements__supplier_id',
  );

  $$StockMovementsTableProcessedTableManager get stockMovementsRefs {
    final manager = $$StockMovementsTableTableManager(
      $_db,
      $_db.stockMovements,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SupplierPaymentsTable, List<SupplierPayment>>
  _supplierPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.supplierPayments,
    aliasName: 'suppliers__id__supplier_payments__supplier_id',
  );

  $$SupplierPaymentsTableProcessedTableManager get supplierPaymentsRefs {
    final manager = $$SupplierPaymentsTableTableManager(
      $_db,
      $_db.supplierPayments,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierPaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SuppliersTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contact => $composableBuilder(
    column: $table.contact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> supplierDeliveriesRefs(
    Expression<bool> Function($$SupplierDeliveriesTableFilterComposer f) f,
  ) {
    final $$SupplierDeliveriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierDeliveries,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierDeliveriesTableFilterComposer(
            $db: $db,
            $table: $db.supplierDeliveries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stockMovementsRefs(
    Expression<bool> Function($$StockMovementsTableFilterComposer f) f,
  ) {
    final $$StockMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableFilterComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supplierPaymentsRefs(
    Expression<bool> Function($$SupplierPaymentsTableFilterComposer f) f,
  ) {
    final $$SupplierPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierPayments,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.supplierPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SuppliersTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contact => $composableBuilder(
    column: $table.contact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuppliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contact =>
      $composableBuilder(column: $table.contact, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> supplierDeliveriesRefs<T extends Object>(
    Expression<T> Function($$SupplierDeliveriesTableAnnotationComposer a) f,
  ) {
    final $$SupplierDeliveriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supplierDeliveries,
          getReferencedColumn: (t) => t.supplierId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierDeliveriesTableAnnotationComposer(
                $db: $db,
                $table: $db.supplierDeliveries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> stockMovementsRefs<T extends Object>(
    Expression<T> Function($$StockMovementsTableAnnotationComposer a) f,
  ) {
    final $$StockMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supplierPaymentsRefs<T extends Object>(
    Expression<T> Function($$SupplierPaymentsTableAnnotationComposer a) f,
  ) {
    final $$SupplierPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.supplierPayments,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SuppliersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuppliersTable,
          Supplier,
          $$SuppliersTableFilterComposer,
          $$SuppliersTableOrderingComposer,
          $$SuppliersTableAnnotationComposer,
          $$SuppliersTableCreateCompanionBuilder,
          $$SuppliersTableUpdateCompanionBuilder,
          (Supplier, $$SuppliersTableReferences),
          Supplier,
          PrefetchHooks Function({
            bool supplierDeliveriesRefs,
            bool stockMovementsRefs,
            bool supplierPaymentsRefs,
          })
        > {
  $$SuppliersTableTableManager(_$AppDatabase db, $SuppliersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> contact = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SuppliersCompanion(
                id: id,
                name: name,
                contact: contact,
                address: address,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> contact = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SuppliersCompanion.insert(
                id: id,
                name: name,
                contact: contact,
                address: address,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SuppliersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                supplierDeliveriesRefs = false,
                stockMovementsRefs = false,
                supplierPaymentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (supplierDeliveriesRefs) db.supplierDeliveries,
                    if (stockMovementsRefs) db.stockMovements,
                    if (supplierPaymentsRefs) db.supplierPayments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (supplierDeliveriesRefs)
                        await $_getPrefetchedData<
                          Supplier,
                          $SuppliersTable,
                          SupplierDelivery
                        >(
                          currentTable: table,
                          referencedTable: $$SuppliersTableReferences
                              ._supplierDeliveriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SuppliersTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierDeliveriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.supplierId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (stockMovementsRefs)
                        await $_getPrefetchedData<
                          Supplier,
                          $SuppliersTable,
                          StockMovement
                        >(
                          currentTable: table,
                          referencedTable: $$SuppliersTableReferences
                              ._stockMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SuppliersTableReferences(
                                db,
                                table,
                                p0,
                              ).stockMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.supplierId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supplierPaymentsRefs)
                        await $_getPrefetchedData<
                          Supplier,
                          $SuppliersTable,
                          SupplierPayment
                        >(
                          currentTable: table,
                          referencedTable: $$SuppliersTableReferences
                              ._supplierPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SuppliersTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierPaymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.supplierId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SuppliersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuppliersTable,
      Supplier,
      $$SuppliersTableFilterComposer,
      $$SuppliersTableOrderingComposer,
      $$SuppliersTableAnnotationComposer,
      $$SuppliersTableCreateCompanionBuilder,
      $$SuppliersTableUpdateCompanionBuilder,
      (Supplier, $$SuppliersTableReferences),
      Supplier,
      PrefetchHooks Function({
        bool supplierDeliveriesRefs,
        bool stockMovementsRefs,
        bool supplierPaymentsRefs,
      })
    >;
typedef $$SupplierDeliveriesTableCreateCompanionBuilder =
    SupplierDeliveriesCompanion Function({
      Value<int> id,
      required int supplierId,
      Value<DateTime> deliveryDate,
      Value<String?> invoiceNumber,
      required double totalAmount,
      Value<String?> notes,
    });
typedef $$SupplierDeliveriesTableUpdateCompanionBuilder =
    SupplierDeliveriesCompanion Function({
      Value<int> id,
      Value<int> supplierId,
      Value<DateTime> deliveryDate,
      Value<String?> invoiceNumber,
      Value<double> totalAmount,
      Value<String?> notes,
    });

final class $$SupplierDeliveriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SupplierDeliveriesTable,
          SupplierDelivery
        > {
  $$SupplierDeliveriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SuppliersTable _supplierIdTable(_$AppDatabase db) => db.suppliers
      .createAlias('supplier_deliveries__supplier_id__suppliers__id');

  $$SuppliersTableProcessedTableManager get supplierId {
    final $_column = $_itemColumn<int>('supplier_id')!;

    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StockMovementsTable, List<StockMovement>>
  _stockMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockMovements,
    aliasName: 'supplier_deliveries__id__stock_movements__delivery_id',
  );

  $$StockMovementsTableProcessedTableManager get stockMovementsRefs {
    final manager = $$StockMovementsTableTableManager(
      $_db,
      $_db.stockMovements,
    ).filter((f) => f.deliveryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SupplierDeliveryItemsTable,
    List<SupplierDeliveryItem>
  >
  _supplierDeliveryItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.supplierDeliveryItems,
        aliasName:
            'supplier_deliveries__id__supplier_delivery_items__delivery_id',
      );

  $$SupplierDeliveryItemsTableProcessedTableManager
  get supplierDeliveryItemsRefs {
    final manager = $$SupplierDeliveryItemsTableTableManager(
      $_db,
      $_db.supplierDeliveryItems,
    ).filter((f) => f.deliveryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierDeliveryItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $SupplierPaymentAllocationsTable,
    List<SupplierPaymentAllocation>
  >
  _supplierPaymentAllocationsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.supplierPaymentAllocations,
    aliasName:
        'supplier_deliveries__id__supplier_payment_allocations__delivery_id',
  );

  $$SupplierPaymentAllocationsTableProcessedTableManager
  get supplierPaymentAllocationsRefs {
    final manager = $$SupplierPaymentAllocationsTableTableManager(
      $_db,
      $_db.supplierPaymentAllocations,
    ).filter((f) => f.deliveryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierPaymentAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SupplierDeliveriesTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierDeliveriesTable> {
  $$SupplierDeliveriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> stockMovementsRefs(
    Expression<bool> Function($$StockMovementsTableFilterComposer f) f,
  ) {
    final $$StockMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.deliveryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableFilterComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> supplierDeliveryItemsRefs(
    Expression<bool> Function($$SupplierDeliveryItemsTableFilterComposer f) f,
  ) {
    final $$SupplierDeliveryItemsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supplierDeliveryItems,
          getReferencedColumn: (t) => t.deliveryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierDeliveryItemsTableFilterComposer(
                $db: $db,
                $table: $db.supplierDeliveryItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> supplierPaymentAllocationsRefs(
    Expression<bool> Function($$SupplierPaymentAllocationsTableFilterComposer f)
    f,
  ) {
    final $$SupplierPaymentAllocationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supplierPaymentAllocations,
          getReferencedColumn: (t) => t.deliveryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierPaymentAllocationsTableFilterComposer(
                $db: $db,
                $table: $db.supplierPaymentAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SupplierDeliveriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierDeliveriesTable> {
  $$SupplierDeliveriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableOrderingComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierDeliveriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierDeliveriesTable> {
  $$SupplierDeliveriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> stockMovementsRefs<T extends Object>(
    Expression<T> Function($$StockMovementsTableAnnotationComposer a) f,
  ) {
    final $$StockMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.deliveryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> supplierDeliveryItemsRefs<T extends Object>(
    Expression<T> Function($$SupplierDeliveryItemsTableAnnotationComposer a) f,
  ) {
    final $$SupplierDeliveryItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supplierDeliveryItems,
          getReferencedColumn: (t) => t.deliveryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierDeliveryItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.supplierDeliveryItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> supplierPaymentAllocationsRefs<T extends Object>(
    Expression<T> Function(
      $$SupplierPaymentAllocationsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$SupplierPaymentAllocationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supplierPaymentAllocations,
          getReferencedColumn: (t) => t.deliveryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierPaymentAllocationsTableAnnotationComposer(
                $db: $db,
                $table: $db.supplierPaymentAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SupplierDeliveriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplierDeliveriesTable,
          SupplierDelivery,
          $$SupplierDeliveriesTableFilterComposer,
          $$SupplierDeliveriesTableOrderingComposer,
          $$SupplierDeliveriesTableAnnotationComposer,
          $$SupplierDeliveriesTableCreateCompanionBuilder,
          $$SupplierDeliveriesTableUpdateCompanionBuilder,
          (SupplierDelivery, $$SupplierDeliveriesTableReferences),
          SupplierDelivery,
          PrefetchHooks Function({
            bool supplierId,
            bool stockMovementsRefs,
            bool supplierDeliveryItemsRefs,
            bool supplierPaymentAllocationsRefs,
          })
        > {
  $$SupplierDeliveriesTableTableManager(
    _$AppDatabase db,
    $SupplierDeliveriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierDeliveriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierDeliveriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplierDeliveriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> supplierId = const Value.absent(),
                Value<DateTime> deliveryDate = const Value.absent(),
                Value<String?> invoiceNumber = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SupplierDeliveriesCompanion(
                id: id,
                supplierId: supplierId,
                deliveryDate: deliveryDate,
                invoiceNumber: invoiceNumber,
                totalAmount: totalAmount,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int supplierId,
                Value<DateTime> deliveryDate = const Value.absent(),
                Value<String?> invoiceNumber = const Value.absent(),
                required double totalAmount,
                Value<String?> notes = const Value.absent(),
              }) => SupplierDeliveriesCompanion.insert(
                id: id,
                supplierId: supplierId,
                deliveryDate: deliveryDate,
                invoiceNumber: invoiceNumber,
                totalAmount: totalAmount,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SupplierDeliveriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                supplierId = false,
                stockMovementsRefs = false,
                supplierDeliveryItemsRefs = false,
                supplierPaymentAllocationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (stockMovementsRefs) db.stockMovements,
                    if (supplierDeliveryItemsRefs) db.supplierDeliveryItems,
                    if (supplierPaymentAllocationsRefs)
                      db.supplierPaymentAllocations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (supplierId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.supplierId,
                                    referencedTable:
                                        $$SupplierDeliveriesTableReferences
                                            ._supplierIdTable(db),
                                    referencedColumn:
                                        $$SupplierDeliveriesTableReferences
                                            ._supplierIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stockMovementsRefs)
                        await $_getPrefetchedData<
                          SupplierDelivery,
                          $SupplierDeliveriesTable,
                          StockMovement
                        >(
                          currentTable: table,
                          referencedTable: $$SupplierDeliveriesTableReferences
                              ._stockMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SupplierDeliveriesTableReferences(
                                db,
                                table,
                                p0,
                              ).stockMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.deliveryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supplierDeliveryItemsRefs)
                        await $_getPrefetchedData<
                          SupplierDelivery,
                          $SupplierDeliveriesTable,
                          SupplierDeliveryItem
                        >(
                          currentTable: table,
                          referencedTable: $$SupplierDeliveriesTableReferences
                              ._supplierDeliveryItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SupplierDeliveriesTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierDeliveryItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.deliveryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (supplierPaymentAllocationsRefs)
                        await $_getPrefetchedData<
                          SupplierDelivery,
                          $SupplierDeliveriesTable,
                          SupplierPaymentAllocation
                        >(
                          currentTable: table,
                          referencedTable: $$SupplierDeliveriesTableReferences
                              ._supplierPaymentAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SupplierDeliveriesTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierPaymentAllocationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.deliveryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SupplierDeliveriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplierDeliveriesTable,
      SupplierDelivery,
      $$SupplierDeliveriesTableFilterComposer,
      $$SupplierDeliveriesTableOrderingComposer,
      $$SupplierDeliveriesTableAnnotationComposer,
      $$SupplierDeliveriesTableCreateCompanionBuilder,
      $$SupplierDeliveriesTableUpdateCompanionBuilder,
      (SupplierDelivery, $$SupplierDeliveriesTableReferences),
      SupplierDelivery,
      PrefetchHooks Function({
        bool supplierId,
        bool stockMovementsRefs,
        bool supplierDeliveryItemsRefs,
        bool supplierPaymentAllocationsRefs,
      })
    >;
typedef $$StockMovementsTableCreateCompanionBuilder =
    StockMovementsCompanion Function({
      Value<int> id,
      required int productId,
      Value<int?> supplierId,
      required String type,
      Value<int?> deliveryId,
      required int quantity,
      required double unitPrice,
      Value<DateTime> date,
    });
typedef $$StockMovementsTableUpdateCompanionBuilder =
    StockMovementsCompanion Function({
      Value<int> id,
      Value<int> productId,
      Value<int?> supplierId,
      Value<String> type,
      Value<int?> deliveryId,
      Value<int> quantity,
      Value<double> unitPrice,
      Value<DateTime> date,
    });

final class $$StockMovementsTableReferences
    extends BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement> {
  $$StockMovementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('stock_movements__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<int>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SuppliersTable _supplierIdTable(_$AppDatabase db) =>
      db.suppliers.createAlias('stock_movements__supplier_id__suppliers__id');

  $$SuppliersTableProcessedTableManager? get supplierId {
    final $_column = $_itemColumn<int>('supplier_id');
    if ($_column == null) return null;
    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SupplierDeliveriesTable _deliveryIdTable(_$AppDatabase db) => db
      .supplierDeliveries
      .createAlias('stock_movements__delivery_id__supplier_deliveries__id');

  $$SupplierDeliveriesTableProcessedTableManager? get deliveryId {
    final $_column = $_itemColumn<int>('delivery_id');
    if ($_column == null) return null;
    final manager = $$SupplierDeliveriesTableTableManager(
      $_db,
      $_db.supplierDeliveries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deliveryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierDeliveriesTableFilterComposer get deliveryId {
    final $$SupplierDeliveriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deliveryId,
      referencedTable: $db.supplierDeliveries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierDeliveriesTableFilterComposer(
            $db: $db,
            $table: $db.supplierDeliveries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableOrderingComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierDeliveriesTableOrderingComposer get deliveryId {
    final $$SupplierDeliveriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deliveryId,
      referencedTable: $db.supplierDeliveries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierDeliveriesTableOrderingComposer(
            $db: $db,
            $table: $db.supplierDeliveries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierDeliveriesTableAnnotationComposer get deliveryId {
    final $$SupplierDeliveriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.deliveryId,
          referencedTable: $db.supplierDeliveries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierDeliveriesTableAnnotationComposer(
                $db: $db,
                $table: $db.supplierDeliveries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$StockMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockMovementsTable,
          StockMovement,
          $$StockMovementsTableFilterComposer,
          $$StockMovementsTableOrderingComposer,
          $$StockMovementsTableAnnotationComposer,
          $$StockMovementsTableCreateCompanionBuilder,
          $$StockMovementsTableUpdateCompanionBuilder,
          (StockMovement, $$StockMovementsTableReferences),
          StockMovement,
          PrefetchHooks Function({
            bool productId,
            bool supplierId,
            bool deliveryId,
          })
        > {
  $$StockMovementsTableTableManager(
    _$AppDatabase db,
    $StockMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<int?> supplierId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> deliveryId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
              }) => StockMovementsCompanion(
                id: id,
                productId: productId,
                supplierId: supplierId,
                type: type,
                deliveryId: deliveryId,
                quantity: quantity,
                unitPrice: unitPrice,
                date: date,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int productId,
                Value<int?> supplierId = const Value.absent(),
                required String type,
                Value<int?> deliveryId = const Value.absent(),
                required int quantity,
                required double unitPrice,
                Value<DateTime> date = const Value.absent(),
              }) => StockMovementsCompanion.insert(
                id: id,
                productId: productId,
                supplierId: supplierId,
                type: type,
                deliveryId: deliveryId,
                quantity: quantity,
                unitPrice: unitPrice,
                date: date,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockMovementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({productId = false, supplierId = false, deliveryId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (productId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.productId,
                                    referencedTable:
                                        $$StockMovementsTableReferences
                                            ._productIdTable(db),
                                    referencedColumn:
                                        $$StockMovementsTableReferences
                                            ._productIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (supplierId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.supplierId,
                                    referencedTable:
                                        $$StockMovementsTableReferences
                                            ._supplierIdTable(db),
                                    referencedColumn:
                                        $$StockMovementsTableReferences
                                            ._supplierIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (deliveryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.deliveryId,
                                    referencedTable:
                                        $$StockMovementsTableReferences
                                            ._deliveryIdTable(db),
                                    referencedColumn:
                                        $$StockMovementsTableReferences
                                            ._deliveryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$StockMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockMovementsTable,
      StockMovement,
      $$StockMovementsTableFilterComposer,
      $$StockMovementsTableOrderingComposer,
      $$StockMovementsTableAnnotationComposer,
      $$StockMovementsTableCreateCompanionBuilder,
      $$StockMovementsTableUpdateCompanionBuilder,
      (StockMovement, $$StockMovementsTableReferences),
      StockMovement,
      PrefetchHooks Function({bool productId, bool supplierId, bool deliveryId})
    >;
typedef $$SalesTableCreateCompanionBuilder =
    SalesCompanion Function({
      Value<int> id,
      required int productId,
      required int quantity,
      required int unitPrice,
      Value<double> costPriceAtSale,
      required int totalPrice,
      required String paymentMethod,
      Value<double?> cashAmount,
      Value<double?> posAmount,
      Value<double?> transferAmount,
      Value<String> status,
      required int staffId,
      Value<DateTime> createdAt,
    });
typedef $$SalesTableUpdateCompanionBuilder =
    SalesCompanion Function({
      Value<int> id,
      Value<int> productId,
      Value<int> quantity,
      Value<int> unitPrice,
      Value<double> costPriceAtSale,
      Value<int> totalPrice,
      Value<String> paymentMethod,
      Value<double?> cashAmount,
      Value<double?> posAmount,
      Value<double?> transferAmount,
      Value<String> status,
      Value<int> staffId,
      Value<DateTime> createdAt,
    });

final class $$SalesTableReferences
    extends BaseReferences<_$AppDatabase, $SalesTable, Sale> {
  $$SalesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('sales__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<int>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _staffIdTable(_$AppDatabase db) =>
      db.users.createAlias('sales__staff_id__users__id');

  $$UsersTableProcessedTableManager get staffId {
    final $_column = $_itemColumn<int>('staff_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_staffIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StaffPurchasesTable, List<StaffPurchase>>
  _staffPurchasesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.staffPurchases,
    aliasName: 'sales__id__staff_purchases__sale_id',
  );

  $$StaffPurchasesTableProcessedTableManager get staffPurchasesRefs {
    final manager = $$StaffPurchasesTableTableManager(
      $_db,
      $_db.staffPurchases,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_staffPurchasesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPriceAtSale => $composableBuilder(
    column: $table.costPriceAtSale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cashAmount => $composableBuilder(
    column: $table.cashAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get posAmount => $composableBuilder(
    column: $table.posAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get transferAmount => $composableBuilder(
    column: $table.transferAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get staffId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.staffId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> staffPurchasesRefs(
    Expression<bool> Function($$StaffPurchasesTableFilterComposer f) f,
  ) {
    final $$StaffPurchasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.staffPurchases,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StaffPurchasesTableFilterComposer(
            $db: $db,
            $table: $db.staffPurchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPriceAtSale => $composableBuilder(
    column: $table.costPriceAtSale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cashAmount => $composableBuilder(
    column: $table.cashAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get posAmount => $composableBuilder(
    column: $table.posAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get transferAmount => $composableBuilder(
    column: $table.transferAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get staffId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.staffId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get costPriceAtSale => $composableBuilder(
    column: $table.costPriceAtSale,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cashAmount => $composableBuilder(
    column: $table.cashAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get posAmount =>
      $composableBuilder(column: $table.posAmount, builder: (column) => column);

  GeneratedColumn<double> get transferAmount => $composableBuilder(
    column: $table.transferAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get staffId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.staffId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> staffPurchasesRefs<T extends Object>(
    Expression<T> Function($$StaffPurchasesTableAnnotationComposer a) f,
  ) {
    final $$StaffPurchasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.staffPurchases,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StaffPurchasesTableAnnotationComposer(
            $db: $db,
            $table: $db.staffPurchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTable,
          Sale,
          $$SalesTableFilterComposer,
          $$SalesTableOrderingComposer,
          $$SalesTableAnnotationComposer,
          $$SalesTableCreateCompanionBuilder,
          $$SalesTableUpdateCompanionBuilder,
          (Sale, $$SalesTableReferences),
          Sale,
          PrefetchHooks Function({
            bool productId,
            bool staffId,
            bool staffPurchasesRefs,
          })
        > {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> unitPrice = const Value.absent(),
                Value<double> costPriceAtSale = const Value.absent(),
                Value<int> totalPrice = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<double?> cashAmount = const Value.absent(),
                Value<double?> posAmount = const Value.absent(),
                Value<double?> transferAmount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> staffId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SalesCompanion(
                id: id,
                productId: productId,
                quantity: quantity,
                unitPrice: unitPrice,
                costPriceAtSale: costPriceAtSale,
                totalPrice: totalPrice,
                paymentMethod: paymentMethod,
                cashAmount: cashAmount,
                posAmount: posAmount,
                transferAmount: transferAmount,
                status: status,
                staffId: staffId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int productId,
                required int quantity,
                required int unitPrice,
                Value<double> costPriceAtSale = const Value.absent(),
                required int totalPrice,
                required String paymentMethod,
                Value<double?> cashAmount = const Value.absent(),
                Value<double?> posAmount = const Value.absent(),
                Value<double?> transferAmount = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int staffId,
                Value<DateTime> createdAt = const Value.absent(),
              }) => SalesCompanion.insert(
                id: id,
                productId: productId,
                quantity: quantity,
                unitPrice: unitPrice,
                costPriceAtSale: costPriceAtSale,
                totalPrice: totalPrice,
                paymentMethod: paymentMethod,
                cashAmount: cashAmount,
                posAmount: posAmount,
                transferAmount: transferAmount,
                status: status,
                staffId: staffId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$SalesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                productId = false,
                staffId = false,
                staffPurchasesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (staffPurchasesRefs) db.staffPurchases,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (productId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.productId,
                                    referencedTable: $$SalesTableReferences
                                        ._productIdTable(db),
                                    referencedColumn: $$SalesTableReferences
                                        ._productIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (staffId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.staffId,
                                    referencedTable: $$SalesTableReferences
                                        ._staffIdTable(db),
                                    referencedColumn: $$SalesTableReferences
                                        ._staffIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (staffPurchasesRefs)
                        await $_getPrefetchedData<
                          Sale,
                          $SalesTable,
                          StaffPurchase
                        >(
                          currentTable: table,
                          referencedTable: $$SalesTableReferences
                              ._staffPurchasesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SalesTableReferences(
                                db,
                                table,
                                p0,
                              ).staffPurchasesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.saleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTable,
      Sale,
      $$SalesTableFilterComposer,
      $$SalesTableOrderingComposer,
      $$SalesTableAnnotationComposer,
      $$SalesTableCreateCompanionBuilder,
      $$SalesTableUpdateCompanionBuilder,
      (Sale, $$SalesTableReferences),
      Sale,
      PrefetchHooks Function({
        bool productId,
        bool staffId,
        bool staffPurchasesRefs,
      })
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      required String key,
      required String value,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      Value<String> key,
      Value<String> value,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
              }) => SettingsCompanion(id: id, key: key, value: value),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String key,
                required String value,
              }) => SettingsCompanion.insert(id: id, key: key, value: value),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      required int userId,
      Value<String?> nin,
      Value<String?> phone,
      Value<String?> guarantorName,
      Value<String?> guarantorPhone,
      Value<double> salary,
      Value<double> amountOwed,
      Value<bool> canReceiveStock,
      Value<bool> canCountStock,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<String?> nin,
      Value<String?> phone,
      Value<String?> guarantorName,
      Value<String?> guarantorPhone,
      Value<double> salary,
      Value<double> amountOwed,
      Value<bool> canReceiveStock,
      Value<bool> canCountStock,
    });

final class $$UserProfilesTableReferences
    extends BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile> {
  $$UserProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('user_profiles__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nin => $composableBuilder(
    column: $table.nin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guarantorName => $composableBuilder(
    column: $table.guarantorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guarantorPhone => $composableBuilder(
    column: $table.guarantorPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get salary => $composableBuilder(
    column: $table.salary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountOwed => $composableBuilder(
    column: $table.amountOwed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canReceiveStock => $composableBuilder(
    column: $table.canReceiveStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canCountStock => $composableBuilder(
    column: $table.canCountStock,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nin => $composableBuilder(
    column: $table.nin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guarantorName => $composableBuilder(
    column: $table.guarantorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guarantorPhone => $composableBuilder(
    column: $table.guarantorPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get salary => $composableBuilder(
    column: $table.salary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountOwed => $composableBuilder(
    column: $table.amountOwed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canReceiveStock => $composableBuilder(
    column: $table.canReceiveStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canCountStock => $composableBuilder(
    column: $table.canCountStock,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nin =>
      $composableBuilder(column: $table.nin, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get guarantorName => $composableBuilder(
    column: $table.guarantorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get guarantorPhone => $composableBuilder(
    column: $table.guarantorPhone,
    builder: (column) => column,
  );

  GeneratedColumn<double> get salary =>
      $composableBuilder(column: $table.salary, builder: (column) => column);

  GeneratedColumn<double> get amountOwed => $composableBuilder(
    column: $table.amountOwed,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canReceiveStock => $composableBuilder(
    column: $table.canReceiveStock,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get canCountStock => $composableBuilder(
    column: $table.canCountStock,
    builder: (column) => column,
  );

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfilesTable,
          UserProfile,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (UserProfile, $$UserProfilesTableReferences),
          UserProfile,
          PrefetchHooks Function({bool userId})
        > {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String?> nin = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> guarantorName = const Value.absent(),
                Value<String?> guarantorPhone = const Value.absent(),
                Value<double> salary = const Value.absent(),
                Value<double> amountOwed = const Value.absent(),
                Value<bool> canReceiveStock = const Value.absent(),
                Value<bool> canCountStock = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                userId: userId,
                nin: nin,
                phone: phone,
                guarantorName: guarantorName,
                guarantorPhone: guarantorPhone,
                salary: salary,
                amountOwed: amountOwed,
                canReceiveStock: canReceiveStock,
                canCountStock: canCountStock,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                Value<String?> nin = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> guarantorName = const Value.absent(),
                Value<String?> guarantorPhone = const Value.absent(),
                Value<double> salary = const Value.absent(),
                Value<double> amountOwed = const Value.absent(),
                Value<bool> canReceiveStock = const Value.absent(),
                Value<bool> canCountStock = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                userId: userId,
                nin: nin,
                phone: phone,
                guarantorName: guarantorName,
                guarantorPhone: guarantorPhone,
                salary: salary,
                amountOwed: amountOwed,
                canReceiveStock: canReceiveStock,
                canCountStock: canCountStock,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserProfilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.userId,
                                referencedTable: $$UserProfilesTableReferences
                                    ._userIdTable(db),
                                referencedColumn: $$UserProfilesTableReferences
                                    ._userIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfilesTable,
      UserProfile,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (UserProfile, $$UserProfilesTableReferences),
      UserProfile,
      PrefetchHooks Function({bool userId})
    >;
typedef $$AttendanceTableCreateCompanionBuilder =
    AttendanceCompanion Function({
      Value<int> id,
      required int userId,
      required DateTime clockIn,
      Value<DateTime?> clockOut,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int?> correctedByUserId,
      Value<DateTime?> correctedAt,
      Value<String?> correctionNote,
    });
typedef $$AttendanceTableUpdateCompanionBuilder =
    AttendanceCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<DateTime> clockIn,
      Value<DateTime?> clockOut,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int?> correctedByUserId,
      Value<DateTime?> correctedAt,
      Value<String?> correctionNote,
    });

class $$AttendanceTableFilterComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clockIn => $composableBuilder(
    column: $table.clockIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clockOut => $composableBuilder(
    column: $table.clockOut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctedByUserId => $composableBuilder(
    column: $table.correctedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get correctedAt => $composableBuilder(
    column: $table.correctedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctionNote => $composableBuilder(
    column: $table.correctionNote,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttendanceTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clockIn => $composableBuilder(
    column: $table.clockIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clockOut => $composableBuilder(
    column: $table.clockOut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctedByUserId => $composableBuilder(
    column: $table.correctedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get correctedAt => $composableBuilder(
    column: $table.correctedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctionNote => $composableBuilder(
    column: $table.correctionNote,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttendanceTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendanceTable> {
  $$AttendanceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get clockIn =>
      $composableBuilder(column: $table.clockIn, builder: (column) => column);

  GeneratedColumn<DateTime> get clockOut =>
      $composableBuilder(column: $table.clockOut, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get correctedByUserId => $composableBuilder(
    column: $table.correctedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get correctedAt => $composableBuilder(
    column: $table.correctedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get correctionNote => $composableBuilder(
    column: $table.correctionNote,
    builder: (column) => column,
  );
}

class $$AttendanceTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendanceTable,
          AttendanceData,
          $$AttendanceTableFilterComposer,
          $$AttendanceTableOrderingComposer,
          $$AttendanceTableAnnotationComposer,
          $$AttendanceTableCreateCompanionBuilder,
          $$AttendanceTableUpdateCompanionBuilder,
          (
            AttendanceData,
            BaseReferences<_$AppDatabase, $AttendanceTable, AttendanceData>,
          ),
          AttendanceData,
          PrefetchHooks Function()
        > {
  $$AttendanceTableTableManager(_$AppDatabase db, $AttendanceTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendanceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendanceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendanceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<DateTime> clockIn = const Value.absent(),
                Value<DateTime?> clockOut = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> correctedByUserId = const Value.absent(),
                Value<DateTime?> correctedAt = const Value.absent(),
                Value<String?> correctionNote = const Value.absent(),
              }) => AttendanceCompanion(
                id: id,
                userId: userId,
                clockIn: clockIn,
                clockOut: clockOut,
                notes: notes,
                createdAt: createdAt,
                correctedByUserId: correctedByUserId,
                correctedAt: correctedAt,
                correctionNote: correctionNote,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required DateTime clockIn,
                Value<DateTime?> clockOut = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> correctedByUserId = const Value.absent(),
                Value<DateTime?> correctedAt = const Value.absent(),
                Value<String?> correctionNote = const Value.absent(),
              }) => AttendanceCompanion.insert(
                id: id,
                userId: userId,
                clockIn: clockIn,
                clockOut: clockOut,
                notes: notes,
                createdAt: createdAt,
                correctedByUserId: correctedByUserId,
                correctedAt: correctedAt,
                correctionNote: correctionNote,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttendanceTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendanceTable,
      AttendanceData,
      $$AttendanceTableFilterComposer,
      $$AttendanceTableOrderingComposer,
      $$AttendanceTableAnnotationComposer,
      $$AttendanceTableCreateCompanionBuilder,
      $$AttendanceTableUpdateCompanionBuilder,
      (
        AttendanceData,
        BaseReferences<_$AppDatabase, $AttendanceTable, AttendanceData>,
      ),
      AttendanceData,
      PrefetchHooks Function()
    >;
typedef $$StaffPurchasesTableCreateCompanionBuilder =
    StaffPurchasesCompanion Function({
      Value<int> id,
      required int staffId,
      required int productId,
      required int quantity,
      required double unitPrice,
      required double totalAmount,
      required String paymentType,
      Value<double> amountPaid,
      Value<double> debtAmount,
      Value<int?> saleId,
      Value<String?> note,
      Value<DateTime> createdAt,
    });
typedef $$StaffPurchasesTableUpdateCompanionBuilder =
    StaffPurchasesCompanion Function({
      Value<int> id,
      Value<int> staffId,
      Value<int> productId,
      Value<int> quantity,
      Value<double> unitPrice,
      Value<double> totalAmount,
      Value<String> paymentType,
      Value<double> amountPaid,
      Value<double> debtAmount,
      Value<int?> saleId,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

final class $$StaffPurchasesTableReferences
    extends BaseReferences<_$AppDatabase, $StaffPurchasesTable, StaffPurchase> {
  $$StaffPurchasesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _staffIdTable(_$AppDatabase db) =>
      db.users.createAlias('staff_purchases__staff_id__users__id');

  $$UsersTableProcessedTableManager get staffId {
    final $_column = $_itemColumn<int>('staff_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_staffIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('staff_purchases__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<int>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SalesTable _saleIdTable(_$AppDatabase db) =>
      db.sales.createAlias('staff_purchases__sale_id__sales__id');

  $$SalesTableProcessedTableManager? get saleId {
    final $_column = $_itemColumn<int>('sale_id');
    if ($_column == null) return null;
    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StaffPurchasesTableFilterComposer
    extends Composer<_$AppDatabase, $StaffPurchasesTable> {
  $$StaffPurchasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get debtAmount => $composableBuilder(
    column: $table.debtAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get staffId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.staffId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SalesTableFilterComposer get saleId {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StaffPurchasesTableOrderingComposer
    extends Composer<_$AppDatabase, $StaffPurchasesTable> {
  $$StaffPurchasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get debtAmount => $composableBuilder(
    column: $table.debtAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get staffId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.staffId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SalesTableOrderingComposer get saleId {
    final $$SalesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableOrderingComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StaffPurchasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaffPurchasesTable> {
  $$StaffPurchasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<double> get debtAmount => $composableBuilder(
    column: $table.debtAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get staffId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.staffId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SalesTableAnnotationComposer get saleId {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StaffPurchasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StaffPurchasesTable,
          StaffPurchase,
          $$StaffPurchasesTableFilterComposer,
          $$StaffPurchasesTableOrderingComposer,
          $$StaffPurchasesTableAnnotationComposer,
          $$StaffPurchasesTableCreateCompanionBuilder,
          $$StaffPurchasesTableUpdateCompanionBuilder,
          (StaffPurchase, $$StaffPurchasesTableReferences),
          StaffPurchase,
          PrefetchHooks Function({bool staffId, bool productId, bool saleId})
        > {
  $$StaffPurchasesTableTableManager(
    _$AppDatabase db,
    $StaffPurchasesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffPurchasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffPurchasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaffPurchasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> staffId = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<String> paymentType = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<double> debtAmount = const Value.absent(),
                Value<int?> saleId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => StaffPurchasesCompanion(
                id: id,
                staffId: staffId,
                productId: productId,
                quantity: quantity,
                unitPrice: unitPrice,
                totalAmount: totalAmount,
                paymentType: paymentType,
                amountPaid: amountPaid,
                debtAmount: debtAmount,
                saleId: saleId,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int staffId,
                required int productId,
                required int quantity,
                required double unitPrice,
                required double totalAmount,
                required String paymentType,
                Value<double> amountPaid = const Value.absent(),
                Value<double> debtAmount = const Value.absent(),
                Value<int?> saleId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => StaffPurchasesCompanion.insert(
                id: id,
                staffId: staffId,
                productId: productId,
                quantity: quantity,
                unitPrice: unitPrice,
                totalAmount: totalAmount,
                paymentType: paymentType,
                amountPaid: amountPaid,
                debtAmount: debtAmount,
                saleId: saleId,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StaffPurchasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({staffId = false, productId = false, saleId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (staffId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.staffId,
                                    referencedTable:
                                        $$StaffPurchasesTableReferences
                                            ._staffIdTable(db),
                                    referencedColumn:
                                        $$StaffPurchasesTableReferences
                                            ._staffIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (productId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.productId,
                                    referencedTable:
                                        $$StaffPurchasesTableReferences
                                            ._productIdTable(db),
                                    referencedColumn:
                                        $$StaffPurchasesTableReferences
                                            ._productIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (saleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.saleId,
                                    referencedTable:
                                        $$StaffPurchasesTableReferences
                                            ._saleIdTable(db),
                                    referencedColumn:
                                        $$StaffPurchasesTableReferences
                                            ._saleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$StaffPurchasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StaffPurchasesTable,
      StaffPurchase,
      $$StaffPurchasesTableFilterComposer,
      $$StaffPurchasesTableOrderingComposer,
      $$StaffPurchasesTableAnnotationComposer,
      $$StaffPurchasesTableCreateCompanionBuilder,
      $$StaffPurchasesTableUpdateCompanionBuilder,
      (StaffPurchase, $$StaffPurchasesTableReferences),
      StaffPurchase,
      PrefetchHooks Function({bool staffId, bool productId, bool saleId})
    >;
typedef $$StaffDebtPaymentsTableCreateCompanionBuilder =
    StaffDebtPaymentsCompanion Function({
      Value<int> id,
      required int staffId,
      required double amount,
      required String paymentMethod,
      Value<String?> note,
      required int recordedBy,
      Value<DateTime> createdAt,
    });
typedef $$StaffDebtPaymentsTableUpdateCompanionBuilder =
    StaffDebtPaymentsCompanion Function({
      Value<int> id,
      Value<int> staffId,
      Value<double> amount,
      Value<String> paymentMethod,
      Value<String?> note,
      Value<int> recordedBy,
      Value<DateTime> createdAt,
    });

final class $$StaffDebtPaymentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $StaffDebtPaymentsTable,
          StaffDebtPayment
        > {
  $$StaffDebtPaymentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _staffIdTable(_$AppDatabase db) =>
      db.users.createAlias('staff_debt_payments__staff_id__users__id');

  $$UsersTableProcessedTableManager get staffId {
    final $_column = $_itemColumn<int>('staff_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_staffIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $UsersTable _recordedByTable(_$AppDatabase db) =>
      db.users.createAlias('staff_debt_payments__recorded_by__users__id');

  $$UsersTableProcessedTableManager get recordedBy {
    final $_column = $_itemColumn<int>('recorded_by')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recordedByTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StaffDebtPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $StaffDebtPaymentsTable> {
  $$StaffDebtPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get staffId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.staffId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableFilterComposer get recordedBy {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordedBy,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StaffDebtPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StaffDebtPaymentsTable> {
  $$StaffDebtPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get staffId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.staffId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableOrderingComposer get recordedBy {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordedBy,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StaffDebtPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaffDebtPaymentsTable> {
  $$StaffDebtPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$UsersTableAnnotationComposer get staffId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.staffId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$UsersTableAnnotationComposer get recordedBy {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordedBy,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StaffDebtPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StaffDebtPaymentsTable,
          StaffDebtPayment,
          $$StaffDebtPaymentsTableFilterComposer,
          $$StaffDebtPaymentsTableOrderingComposer,
          $$StaffDebtPaymentsTableAnnotationComposer,
          $$StaffDebtPaymentsTableCreateCompanionBuilder,
          $$StaffDebtPaymentsTableUpdateCompanionBuilder,
          (StaffDebtPayment, $$StaffDebtPaymentsTableReferences),
          StaffDebtPayment,
          PrefetchHooks Function({bool staffId, bool recordedBy})
        > {
  $$StaffDebtPaymentsTableTableManager(
    _$AppDatabase db,
    $StaffDebtPaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffDebtPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffDebtPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaffDebtPaymentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> staffId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> recordedBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => StaffDebtPaymentsCompanion(
                id: id,
                staffId: staffId,
                amount: amount,
                paymentMethod: paymentMethod,
                note: note,
                recordedBy: recordedBy,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int staffId,
                required double amount,
                required String paymentMethod,
                Value<String?> note = const Value.absent(),
                required int recordedBy,
                Value<DateTime> createdAt = const Value.absent(),
              }) => StaffDebtPaymentsCompanion.insert(
                id: id,
                staffId: staffId,
                amount: amount,
                paymentMethod: paymentMethod,
                note: note,
                recordedBy: recordedBy,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StaffDebtPaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({staffId = false, recordedBy = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (staffId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.staffId,
                                referencedTable:
                                    $$StaffDebtPaymentsTableReferences
                                        ._staffIdTable(db),
                                referencedColumn:
                                    $$StaffDebtPaymentsTableReferences
                                        ._staffIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (recordedBy) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.recordedBy,
                                referencedTable:
                                    $$StaffDebtPaymentsTableReferences
                                        ._recordedByTable(db),
                                referencedColumn:
                                    $$StaffDebtPaymentsTableReferences
                                        ._recordedByTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StaffDebtPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StaffDebtPaymentsTable,
      StaffDebtPayment,
      $$StaffDebtPaymentsTableFilterComposer,
      $$StaffDebtPaymentsTableOrderingComposer,
      $$StaffDebtPaymentsTableAnnotationComposer,
      $$StaffDebtPaymentsTableCreateCompanionBuilder,
      $$StaffDebtPaymentsTableUpdateCompanionBuilder,
      (StaffDebtPayment, $$StaffDebtPaymentsTableReferences),
      StaffDebtPayment,
      PrefetchHooks Function({bool staffId, bool recordedBy})
    >;
typedef $$SupplierDeliveryItemsTableCreateCompanionBuilder =
    SupplierDeliveryItemsCompanion Function({
      Value<int> id,
      required int deliveryId,
      required int productId,
      required int quantity,
      required double unitCost,
      required double totalCost,
      Value<DateTime?> expiryDate,
    });
typedef $$SupplierDeliveryItemsTableUpdateCompanionBuilder =
    SupplierDeliveryItemsCompanion Function({
      Value<int> id,
      Value<int> deliveryId,
      Value<int> productId,
      Value<int> quantity,
      Value<double> unitCost,
      Value<double> totalCost,
      Value<DateTime?> expiryDate,
    });

final class $$SupplierDeliveryItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SupplierDeliveryItemsTable,
          SupplierDeliveryItem
        > {
  $$SupplierDeliveryItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SupplierDeliveriesTable _deliveryIdTable(_$AppDatabase db) =>
      db.supplierDeliveries.createAlias(
        'supplier_delivery_items__delivery_id__supplier_deliveries__id',
      );

  $$SupplierDeliveriesTableProcessedTableManager get deliveryId {
    final $_column = $_itemColumn<int>('delivery_id')!;

    final manager = $$SupplierDeliveriesTableTableManager(
      $_db,
      $_db.supplierDeliveries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deliveryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) => db.products
      .createAlias('supplier_delivery_items__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<int>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SupplierDeliveryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierDeliveryItemsTable> {
  $$SupplierDeliveryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  $$SupplierDeliveriesTableFilterComposer get deliveryId {
    final $$SupplierDeliveriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deliveryId,
      referencedTable: $db.supplierDeliveries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierDeliveriesTableFilterComposer(
            $db: $db,
            $table: $db.supplierDeliveries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierDeliveryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierDeliveryItemsTable> {
  $$SupplierDeliveryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$SupplierDeliveriesTableOrderingComposer get deliveryId {
    final $$SupplierDeliveriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deliveryId,
      referencedTable: $db.supplierDeliveries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierDeliveriesTableOrderingComposer(
            $db: $db,
            $table: $db.supplierDeliveries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierDeliveryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierDeliveryItemsTable> {
  $$SupplierDeliveryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<double> get totalCost =>
      $composableBuilder(column: $table.totalCost, builder: (column) => column);

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  $$SupplierDeliveriesTableAnnotationComposer get deliveryId {
    final $$SupplierDeliveriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.deliveryId,
          referencedTable: $db.supplierDeliveries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierDeliveriesTableAnnotationComposer(
                $db: $db,
                $table: $db.supplierDeliveries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierDeliveryItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplierDeliveryItemsTable,
          SupplierDeliveryItem,
          $$SupplierDeliveryItemsTableFilterComposer,
          $$SupplierDeliveryItemsTableOrderingComposer,
          $$SupplierDeliveryItemsTableAnnotationComposer,
          $$SupplierDeliveryItemsTableCreateCompanionBuilder,
          $$SupplierDeliveryItemsTableUpdateCompanionBuilder,
          (SupplierDeliveryItem, $$SupplierDeliveryItemsTableReferences),
          SupplierDeliveryItem,
          PrefetchHooks Function({bool deliveryId, bool productId})
        > {
  $$SupplierDeliveryItemsTableTableManager(
    _$AppDatabase db,
    $SupplierDeliveryItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierDeliveryItemsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SupplierDeliveryItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SupplierDeliveryItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> deliveryId = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> unitCost = const Value.absent(),
                Value<double> totalCost = const Value.absent(),
                Value<DateTime?> expiryDate = const Value.absent(),
              }) => SupplierDeliveryItemsCompanion(
                id: id,
                deliveryId: deliveryId,
                productId: productId,
                quantity: quantity,
                unitCost: unitCost,
                totalCost: totalCost,
                expiryDate: expiryDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int deliveryId,
                required int productId,
                required int quantity,
                required double unitCost,
                required double totalCost,
                Value<DateTime?> expiryDate = const Value.absent(),
              }) => SupplierDeliveryItemsCompanion.insert(
                id: id,
                deliveryId: deliveryId,
                productId: productId,
                quantity: quantity,
                unitCost: unitCost,
                totalCost: totalCost,
                expiryDate: expiryDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SupplierDeliveryItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deliveryId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deliveryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deliveryId,
                                referencedTable:
                                    $$SupplierDeliveryItemsTableReferences
                                        ._deliveryIdTable(db),
                                referencedColumn:
                                    $$SupplierDeliveryItemsTableReferences
                                        ._deliveryIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable:
                                    $$SupplierDeliveryItemsTableReferences
                                        ._productIdTable(db),
                                referencedColumn:
                                    $$SupplierDeliveryItemsTableReferences
                                        ._productIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SupplierDeliveryItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplierDeliveryItemsTable,
      SupplierDeliveryItem,
      $$SupplierDeliveryItemsTableFilterComposer,
      $$SupplierDeliveryItemsTableOrderingComposer,
      $$SupplierDeliveryItemsTableAnnotationComposer,
      $$SupplierDeliveryItemsTableCreateCompanionBuilder,
      $$SupplierDeliveryItemsTableUpdateCompanionBuilder,
      (SupplierDeliveryItem, $$SupplierDeliveryItemsTableReferences),
      SupplierDeliveryItem,
      PrefetchHooks Function({bool deliveryId, bool productId})
    >;
typedef $$SupplierPaymentsTableCreateCompanionBuilder =
    SupplierPaymentsCompanion Function({
      Value<int> id,
      required int supplierId,
      Value<DateTime> paymentDate,
      required double amount,
      Value<String> paymentMethod,
      Value<String?> reference,
      Value<String?> notes,
    });
typedef $$SupplierPaymentsTableUpdateCompanionBuilder =
    SupplierPaymentsCompanion Function({
      Value<int> id,
      Value<int> supplierId,
      Value<DateTime> paymentDate,
      Value<double> amount,
      Value<String> paymentMethod,
      Value<String?> reference,
      Value<String?> notes,
    });

final class $$SupplierPaymentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SupplierPaymentsTable, SupplierPayment> {
  $$SupplierPaymentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SuppliersTable _supplierIdTable(_$AppDatabase db) =>
      db.suppliers.createAlias('supplier_payments__supplier_id__suppliers__id');

  $$SuppliersTableProcessedTableManager get supplierId {
    final $_column = $_itemColumn<int>('supplier_id')!;

    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $SupplierPaymentAllocationsTable,
    List<SupplierPaymentAllocation>
  >
  _supplierPaymentAllocationsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.supplierPaymentAllocations,
        aliasName:
            'supplier_payments__id__supplier_payment_allocations__payment_id',
      );

  $$SupplierPaymentAllocationsTableProcessedTableManager
  get supplierPaymentAllocationsRefs {
    final manager = $$SupplierPaymentAllocationsTableTableManager(
      $_db,
      $_db.supplierPaymentAllocations,
    ).filter((f) => f.paymentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _supplierPaymentAllocationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SupplierPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierPaymentsTable> {
  $$SupplierPaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> supplierPaymentAllocationsRefs(
    Expression<bool> Function($$SupplierPaymentAllocationsTableFilterComposer f)
    f,
  ) {
    final $$SupplierPaymentAllocationsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supplierPaymentAllocations,
          getReferencedColumn: (t) => t.paymentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierPaymentAllocationsTableFilterComposer(
                $db: $db,
                $table: $db.supplierPaymentAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SupplierPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierPaymentsTable> {
  $$SupplierPaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableOrderingComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierPaymentsTable> {
  $$SupplierPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> supplierPaymentAllocationsRefs<T extends Object>(
    Expression<T> Function(
      $$SupplierPaymentAllocationsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$SupplierPaymentAllocationsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.supplierPaymentAllocations,
          getReferencedColumn: (t) => t.paymentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierPaymentAllocationsTableAnnotationComposer(
                $db: $db,
                $table: $db.supplierPaymentAllocations,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SupplierPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplierPaymentsTable,
          SupplierPayment,
          $$SupplierPaymentsTableFilterComposer,
          $$SupplierPaymentsTableOrderingComposer,
          $$SupplierPaymentsTableAnnotationComposer,
          $$SupplierPaymentsTableCreateCompanionBuilder,
          $$SupplierPaymentsTableUpdateCompanionBuilder,
          (SupplierPayment, $$SupplierPaymentsTableReferences),
          SupplierPayment,
          PrefetchHooks Function({
            bool supplierId,
            bool supplierPaymentAllocationsRefs,
          })
        > {
  $$SupplierPaymentsTableTableManager(
    _$AppDatabase db,
    $SupplierPaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplierPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> supplierId = const Value.absent(),
                Value<DateTime> paymentDate = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SupplierPaymentsCompanion(
                id: id,
                supplierId: supplierId,
                paymentDate: paymentDate,
                amount: amount,
                paymentMethod: paymentMethod,
                reference: reference,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int supplierId,
                Value<DateTime> paymentDate = const Value.absent(),
                required double amount,
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SupplierPaymentsCompanion.insert(
                id: id,
                supplierId: supplierId,
                paymentDate: paymentDate,
                amount: amount,
                paymentMethod: paymentMethod,
                reference: reference,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SupplierPaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({supplierId = false, supplierPaymentAllocationsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (supplierPaymentAllocationsRefs)
                      db.supplierPaymentAllocations,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (supplierId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.supplierId,
                                    referencedTable:
                                        $$SupplierPaymentsTableReferences
                                            ._supplierIdTable(db),
                                    referencedColumn:
                                        $$SupplierPaymentsTableReferences
                                            ._supplierIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (supplierPaymentAllocationsRefs)
                        await $_getPrefetchedData<
                          SupplierPayment,
                          $SupplierPaymentsTable,
                          SupplierPaymentAllocation
                        >(
                          currentTable: table,
                          referencedTable: $$SupplierPaymentsTableReferences
                              ._supplierPaymentAllocationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SupplierPaymentsTableReferences(
                                db,
                                table,
                                p0,
                              ).supplierPaymentAllocationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.paymentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SupplierPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplierPaymentsTable,
      SupplierPayment,
      $$SupplierPaymentsTableFilterComposer,
      $$SupplierPaymentsTableOrderingComposer,
      $$SupplierPaymentsTableAnnotationComposer,
      $$SupplierPaymentsTableCreateCompanionBuilder,
      $$SupplierPaymentsTableUpdateCompanionBuilder,
      (SupplierPayment, $$SupplierPaymentsTableReferences),
      SupplierPayment,
      PrefetchHooks Function({
        bool supplierId,
        bool supplierPaymentAllocationsRefs,
      })
    >;
typedef $$SupplierPaymentAllocationsTableCreateCompanionBuilder =
    SupplierPaymentAllocationsCompanion Function({
      Value<int> id,
      required int paymentId,
      required int deliveryId,
      required double amount,
    });
typedef $$SupplierPaymentAllocationsTableUpdateCompanionBuilder =
    SupplierPaymentAllocationsCompanion Function({
      Value<int> id,
      Value<int> paymentId,
      Value<int> deliveryId,
      Value<double> amount,
    });

final class $$SupplierPaymentAllocationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SupplierPaymentAllocationsTable,
          SupplierPaymentAllocation
        > {
  $$SupplierPaymentAllocationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SupplierPaymentsTable _paymentIdTable(_$AppDatabase db) =>
      db.supplierPayments.createAlias(
        'supplier_payment_allocations__payment_id__supplier_payments__id',
      );

  $$SupplierPaymentsTableProcessedTableManager get paymentId {
    final $_column = $_itemColumn<int>('payment_id')!;

    final manager = $$SupplierPaymentsTableTableManager(
      $_db,
      $_db.supplierPayments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SupplierDeliveriesTable _deliveryIdTable(_$AppDatabase db) =>
      db.supplierDeliveries.createAlias(
        'supplier_payment_allocations__delivery_id__supplier_deliveries__id',
      );

  $$SupplierDeliveriesTableProcessedTableManager get deliveryId {
    final $_column = $_itemColumn<int>('delivery_id')!;

    final manager = $$SupplierDeliveriesTableTableManager(
      $_db,
      $_db.supplierDeliveries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deliveryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SupplierPaymentAllocationsTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierPaymentAllocationsTable> {
  $$SupplierPaymentAllocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  $$SupplierPaymentsTableFilterComposer get paymentId {
    final $$SupplierPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.supplierPayments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.supplierPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierDeliveriesTableFilterComposer get deliveryId {
    final $$SupplierDeliveriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deliveryId,
      referencedTable: $db.supplierDeliveries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierDeliveriesTableFilterComposer(
            $db: $db,
            $table: $db.supplierDeliveries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierPaymentAllocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierPaymentAllocationsTable> {
  $$SupplierPaymentAllocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  $$SupplierPaymentsTableOrderingComposer get paymentId {
    final $$SupplierPaymentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.supplierPayments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierPaymentsTableOrderingComposer(
            $db: $db,
            $table: $db.supplierPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierDeliveriesTableOrderingComposer get deliveryId {
    final $$SupplierDeliveriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deliveryId,
      referencedTable: $db.supplierDeliveries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierDeliveriesTableOrderingComposer(
            $db: $db,
            $table: $db.supplierDeliveries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SupplierPaymentAllocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierPaymentAllocationsTable> {
  $$SupplierPaymentAllocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  $$SupplierPaymentsTableAnnotationComposer get paymentId {
    final $$SupplierPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentId,
      referencedTable: $db.supplierPayments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SupplierPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.supplierPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SupplierDeliveriesTableAnnotationComposer get deliveryId {
    final $$SupplierDeliveriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.deliveryId,
          referencedTable: $db.supplierDeliveries,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SupplierDeliveriesTableAnnotationComposer(
                $db: $db,
                $table: $db.supplierDeliveries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$SupplierPaymentAllocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplierPaymentAllocationsTable,
          SupplierPaymentAllocation,
          $$SupplierPaymentAllocationsTableFilterComposer,
          $$SupplierPaymentAllocationsTableOrderingComposer,
          $$SupplierPaymentAllocationsTableAnnotationComposer,
          $$SupplierPaymentAllocationsTableCreateCompanionBuilder,
          $$SupplierPaymentAllocationsTableUpdateCompanionBuilder,
          (
            SupplierPaymentAllocation,
            $$SupplierPaymentAllocationsTableReferences,
          ),
          SupplierPaymentAllocation,
          PrefetchHooks Function({bool paymentId, bool deliveryId})
        > {
  $$SupplierPaymentAllocationsTableTableManager(
    _$AppDatabase db,
    $SupplierPaymentAllocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierPaymentAllocationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SupplierPaymentAllocationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SupplierPaymentAllocationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> paymentId = const Value.absent(),
                Value<int> deliveryId = const Value.absent(),
                Value<double> amount = const Value.absent(),
              }) => SupplierPaymentAllocationsCompanion(
                id: id,
                paymentId: paymentId,
                deliveryId: deliveryId,
                amount: amount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int paymentId,
                required int deliveryId,
                required double amount,
              }) => SupplierPaymentAllocationsCompanion.insert(
                id: id,
                paymentId: paymentId,
                deliveryId: deliveryId,
                amount: amount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SupplierPaymentAllocationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({paymentId = false, deliveryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (paymentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.paymentId,
                                referencedTable:
                                    $$SupplierPaymentAllocationsTableReferences
                                        ._paymentIdTable(db),
                                referencedColumn:
                                    $$SupplierPaymentAllocationsTableReferences
                                        ._paymentIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (deliveryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deliveryId,
                                referencedTable:
                                    $$SupplierPaymentAllocationsTableReferences
                                        ._deliveryIdTable(db),
                                referencedColumn:
                                    $$SupplierPaymentAllocationsTableReferences
                                        ._deliveryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SupplierPaymentAllocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplierPaymentAllocationsTable,
      SupplierPaymentAllocation,
      $$SupplierPaymentAllocationsTableFilterComposer,
      $$SupplierPaymentAllocationsTableOrderingComposer,
      $$SupplierPaymentAllocationsTableAnnotationComposer,
      $$SupplierPaymentAllocationsTableCreateCompanionBuilder,
      $$SupplierPaymentAllocationsTableUpdateCompanionBuilder,
      (SupplierPaymentAllocation, $$SupplierPaymentAllocationsTableReferences),
      SupplierPaymentAllocation,
      PrefetchHooks Function({bool paymentId, bool deliveryId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db, _db.suppliers);
  $$SupplierDeliveriesTableTableManager get supplierDeliveries =>
      $$SupplierDeliveriesTableTableManager(_db, _db.supplierDeliveries);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$AttendanceTableTableManager get attendance =>
      $$AttendanceTableTableManager(_db, _db.attendance);
  $$StaffPurchasesTableTableManager get staffPurchases =>
      $$StaffPurchasesTableTableManager(_db, _db.staffPurchases);
  $$StaffDebtPaymentsTableTableManager get staffDebtPayments =>
      $$StaffDebtPaymentsTableTableManager(_db, _db.staffDebtPayments);
  $$SupplierDeliveryItemsTableTableManager get supplierDeliveryItems =>
      $$SupplierDeliveryItemsTableTableManager(_db, _db.supplierDeliveryItems);
  $$SupplierPaymentsTableTableManager get supplierPayments =>
      $$SupplierPaymentsTableTableManager(_db, _db.supplierPayments);
  $$SupplierPaymentAllocationsTableTableManager
  get supplierPaymentAllocations =>
      $$SupplierPaymentAllocationsTableTableManager(
        _db,
        _db.supplierPaymentAllocations,
      );
}
