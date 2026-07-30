import 'package:equatable/equatable.dart';

class PendingProductChatIntent extends Equatable {
  const PendingProductChatIntent({
    required this.receiverId,
    required this.receiverName,
    required this.initialDraft,
    required this.createdAt,
  });

  final String receiverId;
  final String receiverName;
  final String initialDraft;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    receiverId,
    receiverName,
    initialDraft,
    createdAt,
  ];
}

abstract class PendingProductChatStorage {
  static const Duration maximumAge = Duration(hours: 24);

  Future<PendingProductChatIntent?> getPending();

  Future<void> save(PendingProductChatIntent intent);

  Future<void> clear();
}
