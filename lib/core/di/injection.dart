import 'package:get_it/get_it.dart';
import '../../data/local/hive_service.dart';
import '../../data/remote/api_client.dart';
import '../../data/repositories/scan_repository.dart';
import '../../data/repositories/sync_repository.dart';
import '../utils/connectivity_service.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  // Services
  final hive = HiveService();
  await hive.init();
  sl.registerSingleton<HiveService>(hive);

  final connectivity = ConnectivityService();
  await connectivity.init();
  sl.registerSingleton<ConnectivityService>(connectivity);

  // Remote
  sl.registerSingleton<ApiClient>(ApiClient());

  // Repositories
  sl.registerSingleton<ScanRepository>(
    ScanRepository(sl<ApiClient>(), sl<HiveService>()),
  );
  sl.registerSingleton<SyncRepository>(
    SyncRepository(sl<ApiClient>(), sl<HiveService>()),
  );
}
