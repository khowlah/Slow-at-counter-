import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// يدير هوية المستخدم (بدون تسجيل دخول)، عدّاده الشخصي، ومزامنته
/// مع Cloud Firestore لحساب الإجمالي عبر كل المستخدمين.
///
/// البنية في Firestore:
///   users/{deviceId}   -> { count: int, updatedAt: Timestamp }
///   stats/global       -> { total: int }
///
/// التحديث يتم داخل Transaction واحدة حتى يبقى total متزامنًا دائمًا
/// مع مجموع كل مستندات users (مقاومة لتضارب الكتابة المتزامن).
class SalawatService {
  SalawatService._internal();
  static final SalawatService instance = SalawatService._internal();

  static const _prefsDeviceIdKey = 'device_id';
  static const _prefsLocalCountKey = 'local_count';

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final SharedPreferences _prefs;
  late final String deviceId;

  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    _prefs = await SharedPreferences.getInstance();

    var id = _prefs.getString(_prefsDeviceIdKey);
    if (id == null) {
      id = const Uuid().v4();
      await _prefs.setString(_prefsDeviceIdKey, id);
    }
    deviceId = id;
    _ready = true;
  }

  /// آخر عدد شخصي محفوظ محليًا (يُستخدم كقيمة أولية قبل وصول ستريم Firestore).
  int get cachedLocalCount => _prefs.getInt(_prefsLocalCountKey) ?? 0;

  /// ستريم مباشر لعدد المستخدم الشخصي كما هو مخزّن في Firestore.
  Stream<int> personalCountStream() {
    return _db.collection('users').doc(deviceId).snapshots().map((doc) {
      final count = (doc.data()?['count'] as num?)?.toInt() ?? 0;
      _prefs.setInt(_prefsLocalCountKey, count);
      return count;
    });
  }

  /// ستريم مباشر لإجمالي الصلوات لكل المستخدمين.
  Stream<int> globalTotalStream() {
    return _db.collection('stats').doc('global').snapshots().map((doc) {
      return (doc.data()?['total'] as num?)?.toInt() ?? 0;
    });
  }

  /// يزيد عدّاد المستخدم الحالي بمقدار [amount] ويحدّث الإجمالي العام
  /// بشكل ذرّي (atomic) داخل معاملة واحدة.
  Future<void> incrementSalawat({int amount = 1}) async {
    final userRef = _db.collection('users').doc(deviceId);
    final statsRef = _db.collection('stats').doc('global');

    await _db.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      final statsSnap = await tx.get(statsRef);

      final currentUserCount =
          (userSnap.data()?['count'] as num?)?.toInt() ?? 0;
      final currentTotal = (statsSnap.data()?['total'] as num?)?.toInt() ?? 0;

      tx.set(
        userRef,
        {
          'count': currentUserCount + amount,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      tx.set(
        statsRef,
        {'total': currentTotal + amount},
        SetOptions(merge: true),
      );
    });
  }
}
