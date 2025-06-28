import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/list_item/list_item.dart';
import '../repositories/list_repository.dart';

class ListState extends Equatable {
  const ListState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.isRefreshing = false,
  });

  final List<ListItem> items;
  final bool isLoading;
  final String? error;
  final bool isRefreshing;

  ListState copyWith({
    List<ListItem>? items,
    bool? isLoading,
    String? error,
    bool? isRefreshing,
  }) {
    return ListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [items, isLoading, error, isRefreshing];
}

class ListCubit extends Cubit<ListState> {
  final ListRepository _listRepository;

  ListCubit({required ListRepository listRepository})
      : _listRepository = listRepository,
        super(const ListState());

  Future<void> loadItems() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final items = await _listRepository.getItems();
      emit(state.copyWith(
        items: items,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> refreshItems() async {
    emit(state.copyWith(isRefreshing: true, error: null));
    try {
      final items = await _listRepository.getItems();
      emit(state.copyWith(
        items: items,
        isRefreshing: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isRefreshing: false,
        error: e.toString(),
      ));
    }
  }
}