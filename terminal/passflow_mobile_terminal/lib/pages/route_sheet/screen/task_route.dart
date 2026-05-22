import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:passflow_app/core/services/language_service.dart';
import 'package:passflow_app/data/models/route_sheet_model.dart';
import 'package:passflow_app/data/models/taskListType/task_model.dart';

import 'package:passflow_app/data/repositories/boardings_repo.dart';
import 'package:passflow_app/data/repositories/class_stations_repo.dart';
import 'package:passflow_app/data/repositories/route_sheet_employees_repository.dart';
import 'package:passflow_app/data/repositories/task_list_type_repository.dart';
import 'package:passflow_app/l10n/app_localizations.dart';
import 'package:passflow_app/pages/boardings/boardings_screen.dart';
import 'package:passflow_app/pages/image_constant.dart';
import 'package:passflow_app/pages/route_sheet/bloc/route_sheet_bloc.dart';
import 'package:passflow_app/pages/task_list/screen/task_form_screen.dart';
import 'package:passflow_app/widgets/custom_app_bar_text.dart';
import 'package:passflow_app/widgets/page/carriage_select.dart';
import 'package:provider/provider.dart';

class TaskRouteScreen extends StatelessWidget {
  final Function(int) onPressed;
  TaskRouteScreen({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RouteSheetBloc>(
      create: (_) => RouteSheetBloc(
        repository: RouteSheetEmployeesRepository(),
        hiveBox: Hive.box<RouteSheetModel>('routeSheets'),
        taskRepo: TaskListTypeRepository(),
        taskBox: Hive.box<TaskListTypeModel>('taskLists'),
        stationsRepo: StationsRepo(),
        boardingsRepo: BoardingsRepo(),
      )..add(LoadRouteSheets()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(234, 255, 255, 255),
              elevation: 0,
              centerTitle: true,
              surfaceTintColor: Colors.white,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              title: Text(
                AppLocalizations.of(context)!.taskRouteAppBarTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.language, color: Colors.black),
                    onSelected: (lang) {
                      final languageService =
                          Provider.of<LanguageService>(context, listen: false);
                      languageService.setLanguage(lang);
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem<String>(
                        value: 'ru',
                        child: Text('Русский'),
                      ),
                      PopupMenuItem<String>(
                        value: 'kk',
                        child: Text('Қазақша'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: SafeArea(
              top: false,
              bottom: true,
              child: BlocBuilder<RouteSheetBloc, RouteSheetState>(
                builder: (context, state) {
                  if (state is RouteSheetLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is RouteSheetLoaded) {
                    final activeRoutes = state.routeSheets
                        .where((x) => x.routeSheetState != "Approved")
                        .toList();
                    final historyRoutes = state.routeSheets
                        .where((x) => x.routeSheetState == "Approved")
                        .toList();

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.selectRouteTitle,
                              style: _sectionTitleStyle),
                          const SizedBox(height: 12),
                          const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFECECEC)),
                          ..._buildRouteList(context, activeRoutes),
                          const SizedBox(height: 24),
                          // Container(
                          //   margin: const EdgeInsets.only(top: 16),
                          //   child: Text(
                          //     "История",
                          //     style: _sectionTitleStyle,
                          //   ),
                          // ),
                          const SizedBox(height: 12),
                          ..._buildRouteList(context, historyRoutes),
                        ],
                      ),
                    );
                  } else if (state is RouteSheetError) {
                    return Center(child: Text(state.message));
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  static const _sectionTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  List<Widget> _buildRouteList(
      BuildContext context, List<RouteSheetModel> items) {
    if (items.isEmpty) return [];
    return List.generate(items.length * 2 - 1, (index) {
      if (index.isOdd) {
        return const Divider(
          height: 1,
          thickness: 1,
          color: Color.fromARGB(64, 223, 223, 223),
        );
      } else {
        final item = items[index ~/ 2];
        final realIndex = index ~/ 2;
        return _buildRouteItem(context, item, realIndex);
      }
    });
  }

  Widget _buildRouteItem(
      BuildContext context, RouteSheetModel item, int index) {
    final parsed =
        DateTime.tryParse(item.routeSheetDate.toString()) ?? DateTime.now();
    final dateString = DateFormat('dd.MM.yy').format(parsed);
    final timeString = DateFormat('HH:mm').format(parsed);

    return InkWell(
      onTap: () => this.onPressed(item.id),
      // async {
      //   final selectedWagon = await showWagonSelectionModal(context);
      //   if (selectedWagon != null) {
      //     this.onPressed(item.id);
      //   }
      // },
      //  () {
      //   showWagonSelectionModal(context, (selectedWagon) {
      //     if (selectedWagon != null) {
      //       if (tabIndex == 1) {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (_) => TaskFormScreen(id: item.id)),
      //         );
      //       } else if (tabIndex == 0) {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //               builder: (_) => BoardingScreen(routeSheetId: item.id)),
      //         );
      //       }
      //     }
      //   });
      // },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF0062DE),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/svg_icons/rail.svg',
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.routeSheetName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.routeSheetName ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context)!
                        .routeDateTimeFormat(dateString, timeString),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusWidget(BuildContext context, String status) {
    late final Color bgColor;
    late final Color textColor;
    String label = status;

    switch (status) {
      case 'Not Approved':
        bgColor = Colors.red.shade50;
        textColor = Colors.red;
        label = AppLocalizations.of(context)!.routeStatusNotApproved;
        break;
      case 'Current':
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue;
        label = AppLocalizations.of(context)!.routeStatusCurrent;
        break;
      case 'Approved':
        bgColor = Colors.green.shade50;
        textColor = Colors.green;
        label = AppLocalizations.of(context)!.routeStatusApproved;
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.orange;
    }

    return FractionallySizedBox(
        widthFactor: 0.7,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ));
  }
}
