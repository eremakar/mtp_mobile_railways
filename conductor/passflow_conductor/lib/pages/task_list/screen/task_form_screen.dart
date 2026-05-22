import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/core/services/auto_submit_service.dart';
import 'package:passflow_app/data/models/taskForm/put_task_form_model.dart';
import 'package:passflow_app/data/models/taskForm/task_form_model.dart';
import 'package:passflow_app/data/models/taskListType/block_model.dart';
import 'package:passflow_app/data/models/taskListType/task_form_model.dart';
import 'package:passflow_app/data/models/taskListType/task_model.dart';
import 'package:passflow_app/data/repositories/task_form_repository.dart';
import 'package:passflow_app/data/repositories/task_list_type_repository.dart';
import 'package:passflow_app/pages/task_form/screen/task_form_render_screen.dart';
import 'package:passflow_app/pages/task_list/bloc/task_list_bloc.dart';
import 'package:passflow_app/widgets/custom_loader.dart';

class TaskFormScreen extends StatelessWidget {
  final int id;
  const TaskFormScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    AutoSubmitService.trySubmitCachedAnswers();
    return BlocProvider(
      create: (_) => TaskListBloc(
        listRepository: TaskListTypeRepository(),
        formRepository: TaskFormRepository(),
        listBox: Hive.box<TaskListTypeModel>('taskLists'),
        formTypeBox: Hive.box<TaskFormModel>('taskFormTypes'),
      )..add(LoadTaskListEvent(id)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Задачи')),
        body: BlocBuilder<TaskListBloc, TaskListState>(
          builder: (context, state) {
            if (state is TaskListLoading) {
              return const Center(child: DotCircleLoader());
            } else if (state is TaskListError) {
              return Center(child: Text(state.message));
            } else if (state is TaskListLoaded) {
              final form = state.form;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: form.configuration.data.length,
                itemBuilder: (context, index) {
                  final block = form.configuration.data[index];
                  return _buildBlockWidget(context, block);
                },
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  Widget _buildBlockWidget(BuildContext context, TaskBlock block) {
    return Card(
        color: Colors.white,
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 0.5,
              children: [
                Text(
                  block.blockname,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...block.tasks
                    .map((task) => _buildTaskTile(context, task)),
              ],
            )));
  }

  Widget _buildTaskTile(BuildContext context, TaskItem task) {
    var form =
        Hive.box<PutTaskFormModel>('formId').get(int.tryParse(task.typeId));

    final currentStatusKey = (form != null && form.state < 2)
        ? form.state
        : (task.currentStatus ?? 0);
    final statusText =
        task.statusnames?[currentStatusKey] ?? 'Не синхронизировано';

    final statusColor = _getStatusColor(currentStatusKey);
    final statusIcon = _getStatusIcon(currentStatusKey);

    return GestureDetector(
      onTap: () {
        final bloc = context.read<TaskListBloc>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskFormRenderScreen(
              typeId: task.typeId.isEmpty ? 0 : int.parse(task.typeId),
            ),
          ),
        ).then((_) {
          bloc.add(LoadTaskListEvent(id));
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(218, 255, 255, 255),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Левая часть: текст
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D1D1F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha:0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Правая иконка
            statusIcon,
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(int? status) {
    switch (status) {
      case 1:
        return Colors.green;
      // case 0:
      //   return Colors.red;
      default:
        return Colors.red;
    }
  }

  Widget _getStatusIcon(int? status) {
    switch (status) {
      case 1:
        return const Icon(Icons.check_circle, color: Colors.green, size: 35);
      // case 0:
      //   return const Icon(Icons.error_outline, color: Colors.red, size: 28);
      default:
        return const Icon(Icons.chevron_right,
            size: 16, color: Color(0xFF3B3B5C));
    }
  }
}
