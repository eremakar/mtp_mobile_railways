import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:passflow_app/data/models/taskForm/form_task_field.dart';
import 'package:passflow_app/data/models/taskForm/put_task_form_model.dart';
import 'package:passflow_app/data/models/taskForm/task_form_model.dart';
import 'package:passflow_app/data/models/taskListType/task_model.dart';
import 'package:passflow_app/data/repositories/task_form_repository.dart';
import 'package:passflow_app/data/repositories/task_repository.dart';
import 'package:passflow_app/pages/task_form/bloc/task_form_bloc.dart';

class TaskFormRenderScreen extends StatelessWidget {
  final int typeId;
  const TaskFormRenderScreen({Key? key, required this.typeId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskFormBloc(
        repository: TaskFormRepository(),
        taskRepository: TaskRepository(),
        formTypeBox: Hive.box<TaskFormModel>('taskFormTypes'),
        answerBox: Hive.box<Map>('formAnswers'),
        listBox: Hive.box<TaskListTypeModel>('taskLists'),
      )..add(LoadTaskFormByTypeId(typeId)),
      child: const _TaskDisplayView(),
    );
  }
}

class _TaskDisplayView extends StatefulWidget {
  const _TaskDisplayView();

  @override
  State<_TaskDisplayView> createState() => _TaskDisplayViewState();
}

class _TaskDisplayViewState extends State<_TaskDisplayView> {
  late Box<Map> _answerBox;
  late int _typeId;

  @override
  void initState() {
    super.initState();
    _answerBox = Hive.box<Map>('formAnswers');
    _typeId =
        context.findAncestorWidgetOfExactType<TaskFormRenderScreen>()!.typeId;

    // восстановим сохранённые ответы, если есть
    final saved =
        _answerBox.get(Hive.box<PutTaskFormModel>('formId').get(_typeId)?.id);
    if (saved != null) {
      _formValues.addAll(saved.cast<String, dynamic>());
    }
  }

  final Map<String, dynamic> _formValues = {};
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Форма')),
        body: BlocListener<TaskFormBloc, TaskFormState>(
          listener: (context, state) {
            if (state is TaskFormBack) {
              Navigator.pop(context);
            }
          },
          child: BlocBuilder<TaskFormBloc, TaskFormState>(
            builder: (context, state) {
              if (state is TaskFormLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TaskFormError) {
                return Center(child: Text(state.message));
              } else if (state is TaskFormLoaded) {
                final config = state.form.configuration!;
                final tasks = config.tasks;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (config.instruction.isNotEmpty)
                        Text(
                          config.instruction,
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 20),
                      ...tasks.map(_buildTask),
                      const SizedBox(height: 20),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                            onPressed: _onSave,
                            label: const Text("Сохранить",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8370D8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                          )),
                    ],
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ));
  }

  void _onSave() {
    debugPrint("📝 Ответы: $_formValues");
    context.read<TaskFormBloc>().add(
        SubmitAnswersEvent(_typeId, Map<String, dynamic>.from(_formValues)));
  }

  Widget _buildTask(FormTaskField task) {
    final name = task.name;
    final label = task.label;
    final type = task.type;

    switch (type) {
      case 'text':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  _formValues[name]?.toString().trim().isNotEmpty == true
                      ? _formValues[name]
                      : (task.placeholder ?? ''),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        );

      case 'textfield':
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextFormField(
                maxLines: task.lines ?? 1,
                initialValue: _formValues[name],
                decoration: InputDecoration(
                  hintText: task.placeholder,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (val) => _formValues[name] = val,
              ),
            ],
          ),
        );

      case 'checkbox':
        return SwitchListTile(
          title: Text(label),
          value: _formValues[name] ?? false,
          onChanged: (val) => setState(() => _formValues[name] = val),
        );

      case 'select':
        final options = task.answerOptions ?? [];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<String>(
            value: _formValues[name],
            decoration: InputDecoration(
              labelText: label,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: options
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => _formValues[name] = val,
          ),
        );

      case 'radiobutton':
        final options = task.answerOptions ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ...options.map((option) => RadioListTile(
                  value: option,
                  groupValue: _formValues[name],
                  onChanged: (val) => setState(() => _formValues[name] = val),
                  title: Text(option),
                )),
          ],
        );

      case 'image':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final file =
                    await picker.pickImage(source: ImageSource.gallery);
                if (file != null) {
                  setState(() => _formValues[name] = File(file.path));
                }
              },
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  image: _formValues[name] != null
                      ? DecorationImage(
                          image: FileImage(_formValues[name]),
                          fit: BoxFit.cover)
                      : null,
                ),
                child: _formValues[name] == null
                    ? const Center(
                        child: Icon(Icons.add_a_photo,
                            size: 32, color: Colors.grey))
                    : null,
              ),
            ),
            if (_formValues[name] != null)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _formValues.remove(name)),
                ),
              ),
          ],
        );

      case 'select-multiple':
        final options = task.answerOptions ?? [];
        _formValues[name] ??= <String>[];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              // Создаем список чекбоксов для множественного выбора
              Column(
                children: options.map((option) {
                  return CheckboxListTile(
                    title: Text(option),
                    value: (_formValues[name] as List<String>).contains(option),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          (_formValues[name] as List<String>).add(option);
                        } else {
                          (_formValues[name] as List<String>).remove(option);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
