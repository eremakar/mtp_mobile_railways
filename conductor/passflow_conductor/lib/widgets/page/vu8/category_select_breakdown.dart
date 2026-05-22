import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passflow_app/data/models/services_model/vu8_remark_models.dart';
import 'package:passflow_app/data/repositories/vu8_repository.dart';
import 'package:passflow_app/widgets/custom_loader.dart';

class SelectCategoryPage extends StatefulWidget {
  const SelectCategoryPage({
    super.key,
    this.initial,
    this.repo,
  });

  final String? initial;
  final Vu8Repository? repo;

  @override
  State<SelectCategoryPage> createState() => _SelectCategoryPageState();
}

class _SelectCategoryPageState extends State<SelectCategoryPage> {
  Vu8Repository? _repo;

  bool _loading = true;
  String? _error;
  List<Vu8Type> _types = <Vu8Type>[];
  Vu8Type? _selectedType;

  final _otherCtrl = TextEditingController();

  bool get _needOtherText {
    final name = (_selectedType?.name ?? '').trim().toLowerCase();
    return name == 'другое' || name == 'other';
  }

  bool get _canSubmit {
    return _selectedType != null &&
        (!_needOtherText || _otherCtrl.text.trim().isNotEmpty);
  }

  @override
  void initState() {
    super.initState();
    _initRepoAndLoad();
  }

  @override
  void dispose() {
    _otherCtrl.dispose();
    super.dispose();
  }

  Future<void> _initRepoAndLoad() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    if (widget.repo != null) {
      _repo = widget.repo;
      await _loadTypes();
      return;
    }

    try {
      _repo = context.read<Vu8Repository>();
    } on ProviderNotFoundException catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error =
            'Vu8Repository не найден в дереве виджетов. Оберните экран в RepositoryProvider/Vu8Repository или передайте repo в SelectCategoryPage(repo: ...)';
      });
      return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
      return;
    }

    await _loadTypes();
  }

  Future<void> _loadTypes() async {
    try {
      final repo = _repo;
      if (repo == null) {
        throw StateError('Vu8Repository is null');
      }
      final types = await repo.getTypes();
      if (!mounted) return;

      Vu8Type? initial;
      final initialName = widget.initial?.trim();
      if (initialName != null && initialName.isNotEmpty) {
        initial = types.firstWhere(
          (t) => t.name.toLowerCase() == initialName.toLowerCase(),
          orElse: () =>
              types.isNotEmpty ? types.first : Vu8Type(id: 0, name: ''),
        );
        if (initial.name.isEmpty) initial = null;
      }

      setState(() {
        _types = types;
        _selectedType = initial ?? (types.isNotEmpty ? types.first : null);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: false,
        elevation: 0,
        title: Text(
          'Выберите категорию',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Builder(
                builder: (context) {
                  if (_loading) {
                    return const Center(child: DotCircleLoader());
                  }

                  if (_error != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Не удалось загрузить категории',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              style: TextStyle(color: scheme.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _initRepoAndLoad,
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (_types.isEmpty) {
                    return Center(
                      child: Text(
                        'Список категорий пуст',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    );
                  }

                  return RadioGroup<int>(
                    groupValue: _selectedType?.id,
                    onChanged: (value) {
                      if (value == null) return;
                      final next = _types.firstWhere(
                        (t) => t.id == value,
                        orElse: () => _selectedType ?? _types.first,
                      );
                      setState(() {
                        _selectedType = next;
                      });
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: _types.length + (_needOtherText ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 2),
                      itemBuilder: (context, index) {
                        if (_needOtherText && index == _types.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: TextField(
                                controller: _otherCtrl,
                                maxLines: 2,
                                onChanged: (_) => setState(() {}),
                                style: TextStyle(color: scheme.onSurface),
                                decoration: InputDecoration(
                                  hintText: 'Ваш текст',
                                  hintStyle:
                                      TextStyle(color: scheme.onSurfaceVariant),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          );
                        }

                        final type = _types[index];
                        final selected = _selectedType?.id == type.id;

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setState(() {
                            _selectedType = type;
                          }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    type.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? scheme.primary
                                          : scheme.onSurface,
                                    ),
                                  ),
                                ),
                                Radio<int>(
                                  value: type.id,
                                  activeColor: scheme.primary,
                                  fillColor: WidgetStateProperty.resolveWith(
                                    (states) {
                                      if (states
                                          .contains(WidgetState.selected)) {
                                        return scheme.primary;
                                      }
                                      return scheme.onSurfaceVariant;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canSubmit
                        ? () {
                            Navigator.pop<Map<String, String?>>(context, {
                              'typeId': _selectedType!.id.toString(),
                              'typeName': _selectedType!.name,
                              'category': _selectedType!.name,
                              'other':
                                  _needOtherText ? _otherCtrl.text.trim() : null,
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      disabledBackgroundColor: scheme.surfaceContainerHighest,
                      disabledForegroundColor: scheme.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      'Выбрать',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color:
                            _canSubmit ? scheme.onPrimary : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}