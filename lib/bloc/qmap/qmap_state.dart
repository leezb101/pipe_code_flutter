import 'package:equatable/equatable.dart';

enum QmapStatus { initial, loading, success, failure }

class QmapEffect {
  final String? toastMessage; // one-shot UI effect
  final bool error;
  // Incremental marker ops for UI layer
  final List<Map<String, dynamic>>?
  storesToAdd; // new stores to add markers for
  final List<String>? storeIdsToRemove; // store ids to remove markers for
  final List<Map<String, dynamic>>?
  projectsToAdd; // new projects to add markers for
  final List<String>? projectIdsToRemove; // project ids to remove markers for

  const QmapEffect({
    this.toastMessage,
    this.error = false,
    this.storesToAdd,
    this.storeIdsToRemove,
    this.projectsToAdd,
    this.projectIdsToRemove,
  });
}

class QmapBlocState extends Equatable {
  final QmapStatus status;
  final List<Map<String, dynamic>> stores; // ready for _addStoreMarkers
  final List<Map<String, dynamic>> projects; // ready for _addProjectMarkers
  final String? errorMessage;
  final QmapEffect? effect; // transient side effect

  const QmapBlocState({
    this.status = QmapStatus.initial,
    this.stores = const [],
    this.projects = const [],
    this.errorMessage,
    this.effect,
  });

  QmapBlocState copyWith({
    QmapStatus? status,
    List<Map<String, dynamic>>? stores,
    List<Map<String, dynamic>>? projects,
    String? errorMessage,
    QmapEffect? effect,
  }) {
    return QmapBlocState(
      status: status ?? this.status,
      stores: stores ?? this.stores,
      projects: projects ?? this.projects,
      errorMessage: errorMessage,
      effect: effect,
    );
  }

  @override
  List<Object?> get props => [
    status,
    stores,
    projects,
    errorMessage,
    // Effect equality (avoid deep compare of lists, rely on reference/identity for one-shot)
    effect?.toastMessage,
    effect?.error,
    effect?.storesToAdd?.length,
    effect?.storeIdsToRemove?.length,
    effect?.projectsToAdd?.length,
    effect?.projectIdsToRemove?.length,
  ];
}
