import 'package:cloud_firestore/cloud_firestore.dart';

enum SharedContentType { note, flashcardSet, quiz }

enum ShareRole { viewer, editor }

SharedContentType typeFromString(String s) =>
    SharedContentType.values.firstWhere((e) => e.name == s, orElse: () => SharedContentType.note);

/// A single piece of content (note / flashcard set / quiz) shared through Firestore.
class SharedContent {
  final String id;
  final SharedContentType type;
  final String title;
  final String ownerId;
  final String ownerName;
  final String shareCode;
  final bool isPublic;
  final Map<String, dynamic> content;
  final Map<String, String> collaborators;
  final DateTime createdAt;
  final DateTime updatedAt;

  SharedContent({
    required this.id,
    required this.type,
    required this.title,
    required this.ownerId,
    required this.ownerName,
    required this.shareCode,
    required this.isPublic,
    required this.content,
    required this.collaborators,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SharedContent.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return SharedContent(
      id: doc.id,
      type: typeFromString(d['type'] as String? ?? 'note'),
      title: d['title'] as String? ?? 'Shared Content',
      ownerId: d['ownerId'] as String? ?? '',
      ownerName: d['ownerName'] as String? ?? 'Unknown',
      shareCode: d['shareCode'] as String? ?? '',
      isPublic: d['isPublic'] as bool? ?? false,
      content: Map<String, dynamic>.from(d['content'] as Map? ?? {}),
      collaborators: Map<String, String>.from(d['collaborators'] as Map? ?? {}),
      createdAt: d['createdAt'] != null ? (d['createdAt'] as Timestamp).toDate() : DateTime.now(),
      updatedAt: d['updatedAt'] != null ? (d['updatedAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toDoc() => {
        'type': type.name,
        'title': title,
        'ownerId': ownerId,
        'ownerName': ownerName,
        'shareCode': shareCode,
        'isPublic': isPublic,
        'content': content,
        'collaborators': collaborators,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  ShareRole? roleFor(String uid) {
    if (ownerId == uid) return ShareRole.editor;
    final r = collaborators[uid];
    if (r == null) return null;
    return ShareRole.values.firstWhere((e) => e.name == r, orElse: () => ShareRole.viewer);
  }
}
