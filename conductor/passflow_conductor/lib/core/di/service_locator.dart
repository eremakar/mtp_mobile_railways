import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/data/models/notifications_model.dart';
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
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/data/repositories/auth_repository.dart';
import 'package:passflow_app/data/repositories/employ_repo.dart';
import 'package:passflow_app/data/repositories/employee_repository.dart';
import 'package:passflow_app/data/repositories/route_classes_repository.dart';
import 'package:passflow_app/data/repositories/route_sheet_employees_repository.dart';
import 'package:passflow_app/data/repositories/route_sheet_items_repository.dart';
import 'package:passflow_app/data/repositories/route_sheets_repository.dart';
import 'package:passflow_app/data/repositories/task_form_repository.dart';
import 'package:passflow_app/data/repositories/task_list_type_repository.dart';
import 'package:passflow_app/data/repositories/task_repository.dart';
import 'package:passflow_app/data/repositories/wagon_lu72_costs_repository.dart';
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
  Hive.registerAdapter(NotificationItemAdapter());
//repos
  sl.registerLazySingleton(() => AuthRepository());
  sl.registerLazySingleton(() => RouteSheetEmployeesRepository());
  sl.registerLazySingleton(() => TaskListTypeRepository());
  sl.registerLazySingleton(() => TaskFormRepository());
  sl.registerLazySingleton(() => TaskRepository());
  sl.registerLazySingleton(() => EmployeeStatisticsRepository());
  sl.registerLazySingleton(() => EmployeeRepository());  
  sl.registerLazySingleton(() => RouteSheetItemsRepository());  
  sl.registerLazySingleton(() => RouteClassesRepository());  
  sl.registerLazySingleton(() => WagonLu72CostsRepository());  
  sl.registerLazySingleton(() => RouteSheetsRepository());  
}
