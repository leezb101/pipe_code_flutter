import 'package:equatable/equatable.dart';

enum QmapStatus { initial, loading, success, failure }

class QmapEffect {
  final String? toastMessage; // one-shot UI effect
  final bool error;
  // Incremental marker ops for UI layer
  final List<Map<String, dynamic>>?
  storesToAdd; // new stores to add markers for
  final List<String>? storeIdsToRemove; // store ids to remove markers for

  const QmapEffect({
    this.toastMessage,
    this.error = false,
    this.storesToAdd,
    this.storeIdsToRemove,
  });
}

class QmapBlocState extends Equatable {
  final QmapStatus status;
  final List<Map<String, dynamic>> stores; // ready for _addStoreMarkers
  final String? errorMessage;
  final QmapEffect? effect; // transient side effect

  const QmapBlocState({
    this.status = QmapStatus.initial,
    this.stores = const [],
    this.errorMessage,
    this.effect,
  });

  QmapBlocState copyWith({
    QmapStatus? status,
    List<Map<String, dynamic>>? stores,
    String? errorMessage,
    QmapEffect? effect,
  }) {
    return QmapBlocState(
      status: status ?? this.status,
      stores: stores ?? this.stores,
      errorMessage: errorMessage,
      effect: effect,
    );
  }

  @override
  List<Object?> get props => [
    status,
    stores,
    errorMessage,
    // Effect equality (avoid deep compare of lists, rely on reference/identity for one-shot)
    effect?.toastMessage,
    effect?.error,
    effect?.storesToAdd?.length,
    effect?.storeIdsToRemove?.length,
  ];
}
