import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';
import '../../../data/repositories/sync_repository.dart';
import '../../../data/local/hive_service.dart';
import '../../../core/utils/connectivity_service.dart';

class HomeCubit extends Cubit<HomeState> {
  final SyncRepository _syncRepo;
  final HiveService _hive;
  final ConnectivityService _connectivity;
  StreamSubscription? _connectivitySub;

  HomeCubit(
    this._syncRepo,
    this._hive,
    this._connectivity,
  ) : super(const HomeInitial());

  Future<void> init() async {
    _connectivitySub = _connectivity.onlineStream.listen((online) {
      if (state is HomeLoaded) {
        final s = state as HomeLoaded;
        emit(s.copyWith(isOnline: online));
        if (online && s.pendingScanCount > 0) {
          _syncInBackground();
        }
      }
    });
    await _load();
  }

  Future<void> _load() async {
    emit(const HomeLoading());
    try {
      final isOnline = _connectivity.isOnline;

      emit(HomeLoaded(
        isOnline: isOnline,
        pendingScanCount: _hive.pendingScanCount,
        ticketCount: _hive.ticketCount,
        lastSync: _hive.getLastSync(),
      ));

      if (isOnline) syncData();
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> syncData() async {
    if (state is! HomeLoaded) return;
    final s = state as HomeLoaded;
    emit(s.copyWith(isSyncing: true));
    try {
      await _syncRepo.syncAll();
      if (state is HomeLoaded) {
        final updated = state as HomeLoaded;
        emit(updated.copyWith(
          isSyncing: false,
          pendingScanCount: _hive.pendingScanCount,
          ticketCount: _hive.ticketCount,
          lastSync: _hive.getLastSync(),
        ));
      }
    } catch (_) {
      if (state is HomeLoaded) {
        emit((state as HomeLoaded).copyWith(isSyncing: false));
      }
    }
  }

  void refreshCounts() {
    if (state is HomeLoaded) {
      final s = state as HomeLoaded;
      emit(s.copyWith(
        pendingScanCount: _hive.pendingScanCount,
        ticketCount: _hive.ticketCount,
      ));
    }
  }

  Future<void> _syncInBackground() async {
    try { await _syncRepo.syncAll(); } catch (_) {}
    refreshCounts();
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }
}
