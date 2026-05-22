import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:passflow_app/core/services/task_hive_service.dart';
import 'package:passflow_app/data/models/route_sheet_direction.dart';
import 'package:passflow_app/data/models/route_sheet_model.dart';
import 'package:passflow_app/data/models/user_model.dart';
import 'package:passflow_app/widgets/page/carriage_select.dart';
import 'package:passflow_app/widgets/page/select_wagon.dart';

String _wagonLabel(RouteSheetDirectionModel s) {
  final when = (s.startDate != null)
      ? DateFormat('dd.MM.yyyy HH:mm').format(s.startDate)
      : '';
  final name = s.trainDirection?.code ?? '';
  // пример: "(6829А Астана 1 - Кокшетау 1) - 12.08.2025 03:30"
  return '(${name}) - $when';
}

Future<void> openSelectTrainNumberModel(
    {required BuildContext context,
    required Box<RouteSheetModel> routeSheetBox,
    required UserModel? user,
    required Function() onTap}) async {
  final u = user;
  if (u == null) return;

  final routeSheet = routeSheetBox.get(u.routeSheetId);
  final numbers = routeSheet?.directions;
  if (numbers == null || numbers.isEmpty) return;

  final routes = numbers.map((x) => TrainRoute(_wagonLabel(x))).toList();

  // final routes = numbers
  //   ..sort((a, b) => _wagonLabel(a).compareTo(_wagonLabel(b)));

  final selected = await Navigator.push<String>(
    context,
    MaterialPageRoute(
      builder: (ctx) => SelectWagon(routes: routes),
    ),
  );

  if (selected == null) return;

  u.trainNumber = selected;
  await u.save();

  await _openSelectWagonNumberModel(
      context: context, routeSheetBox: routeSheetBox, user: u, onTap: onTap);
}

/// Открыть выбор номера вагона -> сохранить -> перейти на вкладку (если нужно).
Future<void> _openSelectWagonNumberModel(
    {required BuildContext context,
    required Box<RouteSheetModel> routeSheetBox,
    required UserModel? user,
    required Function() onTap}) async {
  final u = user;
  if (u == null) return;

  final routeSheet = routeSheetBox.get(u.routeSheetId);
  final wagons = routeSheet?.wagons;
  if (wagons == null || wagons.isEmpty) {
    if (kDebugMode) {
      u.wagonNumber = "Вагон не назначен";
      await u.save();
      HiveService.initAllHive();
      onTap.call();
    }
    return;
  }

  final wagonNumbers = wagons.map((x) => x.number).toList();

  final selectedWagon =
      await showWagonSelectionModal(context, wagonNumbers: wagonNumbers);

  if (selectedWagon == null) return;

  u.wagonNumber = selectedWagon;
  await u.save();
  HiveService.initAllHive();
  // Если у вас есть глобальные goToTab/_currentIndex — вызов останется рабочим.
  // Иначе замените на вашу навигацию.
  onTap.call();
}
