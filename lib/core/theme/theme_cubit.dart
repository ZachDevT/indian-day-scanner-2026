import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/local/hive_service.dart';
import '../../core/di/injection.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final HiveService _hiveService;

  ThemeCubit()
      : _hiveService = sl<HiveService>(),
        super(sl<HiveService>().isDarkMode ? ThemeMode.dark : ThemeMode.light);

  void toggleTheme() {
    final isDark = state == ThemeMode.dark;
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    _hiveService.setDarkMode(!isDark);
    emit(newMode);
  }
}
