import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shared_content.dart';

/// Handles creating, joining, and reading shared notes/flashcards/quizzes.
class ShareService {
  ShareService({FirebaseFirestore? firestore}) : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _items => _db.collection('shared_items');

  String _generateShareCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  /// Creates a new shared item and returns its share code.
  Future<String> shareContent({
    required SharedContentType type,
    required String title,
    required String ownerId,
    required String ownerName,
    required Map<String, dynamic> content,
    bool isPublic = false,
  }) async {
    String code = _generateShareCode();
    for (int attempt = 0; attempt < 5; attempt++) {
      final clash = await _items.where('shareCode', isEqualTo: code).limit(1).get();
      if (clash.docs.isEmpty) break;
      code = _generateShareCode();
    }

    final now = DateTime.now();
    final doc = SharedContent(
      id: '',
      type: type,
      title: title,
      ownerId: ownerId,
      ownerName: ownerName,
      shareCode: code,
      isPublic: isPublic,
      content: content,
      collaborators: const {},
      createdAt: now,
      updatedAt: now,
    );
    await _items.add(doc.toDoc());
    return code;
  }

  /// Looks up a share by its code. Returns null if not found.
  Future<SharedContent?> findByCode(String code) async {
    final res = await _items.where('shareCode', isEqualTo: code.toUpperCase()).limit(1).get();
    if (res.docs.isEmpty) return null;
    return SharedContent.fromDoc(res.docs.first);
  }

  /// Joins a shared item as a viewer (or editor).
  Future<SharedContent?> joinByCode(String code, String uid, {ShareRole role = ShareRole.viewer}) async {
    final res = await _items.where('shareCode', isEqualTo: code.toUpperCase()).limit(1).get();
    if (res.docs.isEmpty) return null;
    final docRef = res.docs.first.reference;
    await docRef.set({
      'collaborators': {uid: role.name}
    }, SetOptions(merge: true));
    final updated = await docRef.get();
    return SharedContent.fromDoc(updated);
  }

  /// Items I created.
  Stream<List<SharedContent>> myShares(String uid) {
    return _items
        .where('ownerId', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(SharedContent.fromDoc).toList());
  }

  /// Items someone else shared with me.
  Stream<List<SharedContent>> sharedWithMe(String uid) {
    return _items
        .where('collaborators.$uid', isNull: false)
        .snapshots()
        .map((s) => s.docs.map(SharedContent.fromDoc).toList());
  }

  Future<void> updateContent(String docId, Map<String, dynamic> content) {
    return _items.doc(docId).update({
      'content': content,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> revokeAccess(String docId, String uid) {
    return _items.doc(docId).update({'collaborators.$uid': FieldValue.delete()});
  }

  Future<void> deleteShare(String docId) => _items.doc(docId).delete();
}
