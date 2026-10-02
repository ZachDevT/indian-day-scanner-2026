import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override List<Object?> get props => [];
}

class HomeInitial extends HomeState { const HomeInitial(); }
class HomeLoading extends HomeState { const HomeLoading(); }

class HomeLoaded extends HomeState {
  final bool isOnline;
  final int pendingScanCount;
  final int ticketCount;
  final DateTime? lastSync;
  final bool isSyncing;

  const HomeLoaded({
    required this.isOnline,
    required this.pendingScanCount,
    required this.ticketCount,
    this.lastSync,
    this.isSyncing = false,
  });

  HomeLoaded copyWith({
    bool? isOnline,
    int? pendingScanCount,
    int? ticketCount,
    DateTime? lastSync,
    bool? isSyncing,
  }) => HomeLoaded(
    isOnline: isOnline ?? this.isOnline,
    pendingScanCount: pendingScanCount ?? this.pendingScanCount,
    ticketCount: ticketCount ?? this.ticketCount,
    lastSync: lastSync ?? this.lastSync,
    isSyncing: isSyncing ?? this.isSyncing,
  );

  @override
  List<Object?> get props => [isOnline, pendingScanCount, ticketCount, lastSync, isSyncing];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override List<Object?> get props => [message];
}
