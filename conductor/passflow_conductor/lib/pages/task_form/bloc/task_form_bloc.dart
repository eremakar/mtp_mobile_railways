import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:passflow_app/core/services/auto_submit_service.dart';
import 'package:passflow_app/data/models/taskForm/put_task_form_model.dart';
import 'package:passflow_app/data/models/taskForm/task_form_model.dart';
import 'package:passflow_app/data/models/taskListType/task_model.dart';
import 'package:passflow_app/data/repositories/task_form_repository.dart';
import 'package:passflow_app/data/repositories/task_repository.dart';

// -------- EVENTS --------
abstract class TaskFormEvent {}

class LoadTaskFormByTypeId extends TaskFormEvent {
  final int typeId;
  LoadTaskFormByTypeId(this.typeId);
}

class SubmitAnswersEvent extends TaskFormEvent {
  final int typeId;
  final Map<String, dynamic> answers;

  SubmitAnswersEvent(this.typeId, this.answers);
}

// -------- STATES --------
abstract class TaskFormState {}

class TaskFormInitial extends TaskFormState {}

class TaskFormLoading extends TaskFormState {}

class TaskFormBack extends TaskFormState {}

class TaskFormLoaded extends TaskFormState {
  final TaskFormModel form;
  TaskFormLoaded(this.form);
}

class TaskFormError extends TaskFormState {
  final String message;
  TaskFormError(this.message);
}

// -------- BLOC --------
class TaskFormBloc extends Bloc<TaskFormEvent, TaskFormState> {
  final TaskFormRepository repository;
  final TaskRepository taskRepository;
  final Box<TaskFormModel> formTypeBox;
  final Box<Map> answerBox;
  final Box<TaskListTypeModel> listBox;

  TaskFormBloc(
      {required this.repository,
      required this.taskRepository,
      required this.formTypeBox,
      required this.answerBox,
      required this.listBox})
      : super(TaskFormInitial()) {
    on<LoadTaskFormByTypeId>(_onLoad);
    on<SubmitAnswersEvent>(_onSubmit);
  }

  Future<void> _onLoad(
      LoadTaskFormByTypeId event, Emitter<TaskFormState> emit) async {
    emit(TaskFormLoading());

    try {
      final form = await repository.getFromTaskByTypeId(event.typeId);

      if (form != null) {
        await formTypeBox.put(event.typeId, form);
        emit(TaskFormLoaded(form));
      } else {
        final cached = formTypeBox.get(event.typeId);
        if (cached != null) {
          emit(TaskFormLoaded(cached));
        } else {
          emit(TaskFormError("Нет данных ни в сети, ни в кэше"));
        }
      }
    } catch (e) {
      final cached = formTypeBox.get(event.typeId);
      if (cached != null) {
        emit(TaskFormLoaded(cached));
      } else {
        emit(TaskFormError("Ошибка загрузки: $e"));
      }
    }
  }

  Future<void> _onSubmit(
    SubmitAnswersEvent event,
    Emitter<TaskFormState> emit,
  ) async {
    final form = Hive.box<PutTaskFormModel>('formId').get(event.typeId);

    if (form == null) {
      if (kDebugMode) {
        print("❌ formId для typeId=${event.typeId} не найден в Hive");
      }
      return;
    }

    await answerBox.put(form.id, event.answers);
    await AutoSubmitService.trySubmitCachedAnswers();
    emit(TaskFormBack());
  }
}
