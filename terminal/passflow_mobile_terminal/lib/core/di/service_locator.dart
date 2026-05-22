import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/data/models/class_station_model.dart';
import 'package:passflow_app/data/models/route_sheet_direction.dart';
import 'package:passflow_app/data/models/route_sheet_model.dart';
import 'package:passflow_app/data/models/task/answer_model.dart';
import 'package:passflow_app/data/models/task/task_model.dart';
import 'package:passflow_app/data/models/taskForm/form_configuration.dart';
import 'package:passflow_app/data/models/taskForm/form_task_field.dart';
import 'package:passflow_app/data/models/taskForm/put_task_form_model.dart';
import 'package:passflow_app/data/models/taskForm/task_form_model.dart';
import 'package:passflow_app/data/models/taskListType/block_model.dart';
import 'package:passflow_app/data/models/taskListType/task_configuration.dart';
import 'package:passflow_app/data/models/taskListType/task_form_model.dart';
import 'package:passflow_app/data/models/taskListType/task_model.dart';
import 'package:passflow_app/data/models/ticket_model.dart';
import 'package:passflow_app/data/models/tickets_search_entry_model.dart';
import 'package:passflow_app/data/models/train_direction_model.dart';
import 'package:passflow_app/data/models/train_directions_response.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/data/models/wagon_model.dart';
import 'package:passflow_app/data/repositories/auth_repository.dart';
import 'package:passflow_app/data/repositories/boardings_repo.dart';
import 'package:passflow_app/data/repositories/class_stations_repo.dart';
import 'package:passflow_app/data/repositories/route_sheet_employees_repository.dart';
import 'package:passflow_app/data/repositories/task_form_repository.dart';
import 'package:passflow_app/data/repositories/task_list_type_repository.dart';
import 'package:passflow_app/data/repositories/task_repository.dart';
import 'package:passflow_app/data/repositories/tickets_repository.dart';
import 'package:passflow_app/data/repositories/train_direction_repository.dart';
import 'package:path_provider/path_provider.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(RouteSheetModelAdapter());
  Hive.registerAdapter(TaskListTypeModelAdapter());
  Hive.registerAdapter(TaskConfigurationAdapter());
  Hive.registerAdapter(TaskBlockAdapter());
  Hive.registerAdapter(TaskItemAdapter());

  Hive.registerAdapter(TaskFormModelAdapter());
  Hive.registerAdapter(FormConfigurationAdapter());
  Hive.registerAdapter(FormTaskFieldAdapter());
  Hive.registerAdapter(PutTaskFormModelAdapter());
  Hive.registerAdapter(TaskModelAdapter());
  Hive.registerAdapter(AnswerModelAdapter());
  Hive.registerAdapter(WagonModelAdapter());
  Hive.registerAdapter(StationModelAdapter());
  Hive.registerAdapter(PassengerModelAdapter());
  Hive.registerAdapter(TicketModelAdapter());
  Hive.registerAdapter(TicketSearchEntryModelAdapter());
  Hive.registerAdapter(TrainDirectionModelAdapter());
  Hive.registerAdapter(RouteSheetDirectionModelAdapter());
  Hive.registerAdapter(TrainDirectionsResponseAdapter());
  Hive.registerAdapter(ClassStationModelAdapter());

//repos
  sl.registerLazySingleton(() => AuthRepository());
  sl.registerLazySingleton(() => RouteSheetEmployeesRepository());
  sl.registerLazySingleton(() => TaskListTypeRepository());
  sl.registerLazySingleton(() => TaskFormRepository());
  sl.registerLazySingleton(() => TaskRepository());
  sl.registerLazySingleton(() => BoardingsRepo());
  sl.registerLazySingleton(() => StationsRepo());
  sl.registerLazySingleton(() => TicketsRepository());
  sl.registerLazySingleton(() => TrainDirectionsRepository());
}
