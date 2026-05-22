import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/data/models/taskListType/task_form_model.dart';
import 'package:passflow_app/data/models/taskListType/task_model.dart';
import 'package:passflow_app/data/models/taskForm/task_form_model.dart';
import 'package:passflow_app/data/repositories/task_form_repository.dart';
import 'package:passflow_app/data/repositories/task_list_type_repository.dart';

// EVENTS
abstract class TaskListEvent {}

class LoadTaskListEvent extends TaskListEvent {
  final int typeId;
  LoadTaskListEvent(this.typeId);
}

class UpdateTaskStatusEvent extends TaskListEvent {
  final TaskItem task;
  final int newStatus;
  UpdateTaskStatusEvent(this.task, this.newStatus);
}

// STATES
abstract class TaskListState {}

class TaskListInitial extends TaskListState {}

class TaskListLoading extends TaskListState {}

class TaskListLoaded extends TaskListState {
  final TaskListTypeModel form;
  TaskListLoaded(this.form);
}

class TaskListError extends TaskListState {
  final String message;
  TaskListError(this.message);
}

// BLOC
class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final TaskListTypeRepository listRepository;
  final TaskFormRepository formRepository;
  final Box<TaskListTypeModel> listBox;
  final Box<TaskFormModel> formTypeBox;

  TaskListBloc({
    required this.listRepository,
    required this.formRepository,
    required this.listBox,
    required this.formTypeBox,
  }) : super(TaskListInitial()) {
    on<LoadTaskListEvent>(_onLoad);
    on<UpdateTaskStatusEvent>(_onStatusUpdate);
  }

  Future<void> _onLoad(
    LoadTaskListEvent event,
    Emitter<TaskListState> emit,
  ) async {
    emit(TaskListLoading());

    try {
      // Сначала пробуем онлайн-загрузку
      TaskListTypeModel? loaded = await listRepository.getById(event.typeId);

      if (loaded != null) {
        await listBox.put(loaded.id, loaded);

        // Загрузить и закешировать все TaskFormModel по каждому task.typeId
        for (final block in loaded.configuration.data) {
          for (final task in block.tasks) {
            if (task.typeId.isNotEmpty &&
                !formTypeBox.containsKey(task.typeId)) {
              final taskForm = await formRepository
                  .getFromTaskByTypeId(int.parse(task.typeId));
              if (taskForm != null) {
                await formTypeBox.put(task.typeId, taskForm);
              }
            }
          }
        }

        emit(TaskListLoaded(loaded));
        return;
      }

      // Пробуем из кэша
      final cached = listBox.get(event.typeId);
      if (cached != null) {
        emit(TaskListLoaded(cached));
      } else {
        emit(TaskListError("Нет данных ни в сети, ни в кэше"));
      }
    } catch (e) {
      final cached = listBox.get(event.typeId);
      if (cached != null) {
        emit(TaskListLoaded(cached));
      } else {
        emit(TaskListError("Ошибка загрузки: $e"));
      }
    }
  }

  Future<void> _onStatusUpdate(
    UpdateTaskStatusEvent event,
    Emitter<TaskListState> emit,
  ) async {
    if (state is! TaskListLoaded) return;

    final current = state as TaskListLoaded;

    event.task.currentStatus = event.newStatus;
    await current.form.save();

    emit(TaskListLoaded(current.form)); // Обновляем UI
  }
}
