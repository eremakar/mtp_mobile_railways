import 'package:flutter/material.dart';
import 'package:passflow_app/data/models/services_model/vu8_remark_models.dart';
import 'package:passflow_app/data/repositories/vu8_repository.dart';
import 'package:passflow_app/widgets/custom_loader.dart';
import 'package:passflow_app/widgets/page/vu8/category_select_breakdown.dart';

class AddRemarkPage extends StatefulWidget {
  final Vu8Repository? repository;

  final int? wagonId;
  final int? routeId;
  final int? routeSheetId;

  final int? employeeId;
  final int? departmentId;

  const AddRemarkPage({
    super.key,
    this.repository,
    this.wagonId,
    this.routeId,
    this.routeSheetId,
    this.employeeId,
    this.departmentId,
  });

  @override
  State<AddRemarkPage> createState() => _AddRemarkPageState();
}

class _AddRemarkPageState extends State<AddRemarkPage> {
  int currentTab = 0;
  String? category;
  int? categoryTypeId;
  String? categoryOther;
  final textCtrl = TextEditingController();

  bool _loadingHistory = false;
  String? _historyError;
  List<Vu8Remark> _history = const [];

  late final Vu8Repository _repo = widget.repository ?? Vu8Repository();

  bool _loadingRoutes = false;
  String? _routesError;
  List<_RouteOption> _routes = const [];
  _RouteOption? _selectedRoute;

  bool _loadingWagons = false;
  String? _wagonsError;
  List<_WagonOption> _wagons = const [];
  _WagonOption? _selectedWagon;

  bool _submitting = false;
  String? _submitError;
  String? _imageUrl;

  bool get _isRouteAndWagonSelected {
    return _selectedRoute?.routeSheetId != null && _selectedWagon?.wagonId != null;
  }

  bool get _canSubmit {
    return !_submitting &&
        _isRouteAndWagonSelected &&
        widget.employeeId != null &&
        categoryTypeId != null &&
        textCtrl.text.trim().isNotEmpty;
  }

  String? _cannotSubmitReason() {
    if (_submitting) return 'Идет отправка…';

    if (_selectedRoute?.routeSheetId == null) return 'Сначала выберите маршрут';
    if (_selectedWagon?.wagonId == null) return 'Сначала выберите вагон';
    if (widget.employeeId == null) {
      return 'Не определен сотрудник (employeeId) — перелогиньтесь или проверьте авторизацию';
    }
    if (categoryTypeId == null) return 'Выберите категорию';
    if (textCtrl.text.trim().isEmpty) return 'Заполните текст замечания';

    return null;
  }

  void _showCannotSubmitSnack() {
    final msg = _cannotSubmitReason() ?? 'Не удалось отправить';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _lockUntilRouteAndWagonSelected({required Widget child}) {
    final enabled = _isRouteAndWagonSelected;
    return AbsorbPointer(
      absorbing: !enabled,
      child: Opacity(opacity: enabled ? 1.0 : 0.45, child: child),
    );
  }

  Widget _lockUntilRouteSelected({required Widget child}) {
    final enabled = _selectedRoute?.routeSheetId != null;
    return AbsorbPointer(
      absorbing: !enabled,
      child: Opacity(opacity: enabled ? 1.0 : 0.45, child: child),
    );
  }

  @override
  void initState() {
    super.initState();
    textCtrl.addListener(_onFormChanged);

    if (widget.routeSheetId != null) {
      _selectedRoute = _RouteOption(
        routeSheetId: widget.routeSheetId!,
        title: 'Маршрут',
        subtitle: null,
      );
    }
    if (widget.wagonId != null) {
      _selectedWagon = _WagonOption(
        wagonId: widget.wagonId!,
        title: 'Вагон',
      );
    }

    _loadRoutes();
    _loadWagonsForSelectedRoute();
    _loadHistory();
  }

  String _fmtDateTime(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    if (local.year <= 1900) return '—';

    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    final yyyy = local.year.toString();
    final hh = local.hour.toString().padLeft(2, '0');
    final mi = local.minute.toString().padLeft(2, '0');

    return '$dd.$mm.$yyyy $hh:$mi';
  }

  void _onFormChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadRoutes() async {
    final employeeId = widget.employeeId;
    if (employeeId == null) {
      if (!mounted) return;
      setState(() {
        _routes = const [];
        _routesError = 'Не указан employeeId';
        _loadingRoutes = false;
      });
      return;
    }

    setState(() {
      _loadingRoutes = true;
      _routesError = null;
    });

    try {
      final res = await _repo.getRouteSheetsForEmployee(
        employeeId: employeeId,
        state2IdMin: 0,
        state2IdMax: 4,
      );

      final dynamic raw = res;
      final List<dynamic> list = raw is List
          ? raw
          : (raw is Map<String, dynamic>
              ? (raw['result'] as List<dynamic>? ?? const [])
              : const []);

      final routes = <_RouteOption>[];
      for (final it in list) {
        final Map<String, dynamic> row =
            (it is Map<String, dynamic>) ? it : <String, dynamic>{};
        final Map<String, dynamic> rs =
            (row['routeSheet'] is Map<String, dynamic>)
                ? (row['routeSheet'] as Map<String, dynamic>)
                : row;

        final st = rs['state2Id'];
        final int? state2Id =
            st is int ? st : int.tryParse(st?.toString() ?? '');
        if (state2Id == null || state2Id <= 0 || state2Id >= 4) continue;

        final dynamic rsIdRaw = row['routeSheetId'] ?? rs['id'];
        final int? rsId = rsIdRaw is int
            ? rsIdRaw
            : int.tryParse(rsIdRaw?.toString() ?? '');
        if (rsId == null) continue;

        final cls = rs['class'];
        final className =
            (cls is Map<String, dynamic>) ? (cls['name']?.toString()) : null;
        final title = (className != null && className.trim().isNotEmpty)
            ? className
            : 'Маршрут';

        final start = rs['routeStartTime'];
        final subtitle = _fmtDateTimeKz5(start);

        routes.add(
          _RouteOption(
            routeSheetId: rsId,
            title: title,
            subtitle: subtitle,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _routes = routes;
      });

      if (_selectedRoute == null && routes.isNotEmpty) {
        setState(() => _selectedRoute = routes.first);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _routesError = 'Не удалось загрузить маршруты';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingRoutes = false;
        });
      }
    }
  }

  Future<void> _loadWagonsForSelectedRoute() async {
    final rsId = _selectedRoute?.routeSheetId;
    if (rsId == null) return;

    setState(() {
      _loadingWagons = true;
      _wagonsError = null;
      _wagons = const [];
    });

    try {
      final routeSheet = await _repo.getRouteSheetRaw(rsId);

      final List<dynamic> items;
      if (routeSheet is Map) {
        final Map<String, dynamic> root = Map<String, dynamic>.from(routeSheet);
        final dynamic result = root['result'];
        final Map<String, dynamic> entity =
            (result is Map) ? Map<String, dynamic>.from(result) : root;
        final dynamic rawItems = entity['items'];
        items = rawItems is List ? rawItems : const [];
      } else {
        final dynamic rawItems = (routeSheet as dynamic)?.items;
        items = rawItems is List ? rawItems : const [];
      }

      final wagons = <_WagonOption>[];
      for (final it in items) {
        Map<String, dynamic>? asMap(dynamic v) =>
            v is Map ? Map<String, dynamic>.from(v) : null;

        final m = asMap(it);
        final rsItem = asMap(m?['routeSheetItem']);
        final wagon = asMap(m?['wagon']);

        final dynamic wagonIdRaw =
            (m?['wagonId'] ?? rsItem?['wagonId'] ?? wagon?['id']);
        final int? wagonId = wagonIdRaw is int
            ? wagonIdRaw
            : int.tryParse(wagonIdRaw?.toString() ?? '');
        if (wagonId == null) continue;

        final String number =
            (m?['number']?.toString() ?? wagon?['number']?.toString() ?? '')
                .trim();

        final dynamic wagonTypeRaw = m?['wagonType'] ?? rsItem?['wagonType'];
        final wagonTypeMap = asMap(wagonTypeRaw);
        final String wagonTypeName =
            (wagonTypeMap?['name']?.toString() ?? '').trim();

        final title = [
          if (number.isNotEmpty) number,
          if (wagonTypeName.isNotEmpty) wagonTypeName,
        ].join(' - ');

        wagons.add(
          _WagonOption(
            wagonId: wagonId,
            title: title.isEmpty ? 'Вагон $wagonId' : title,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _wagons = wagons;
      });

      final current = _selectedWagon;
      if (current != null) {
        final exists = wagons.any((w) => w.wagonId == current.wagonId);
        if (!exists && mounted) setState(() => _selectedWagon = null);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _wagonsError = 'Не удалось загрузить вагоны';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingWagons = false;
        });
      }
    }
  }

  String? _fmtDateTimeKz5(dynamic input) {
    try {
      if (input == null) return null;

      DateTime? dt;
      if (input is DateTime) {
        dt = input;
      } else {
        dt = DateTime.tryParse(input.toString());
      }
      if (dt == null) return null;

      final DateTime utc = dt.isUtc ? dt : dt.toUtc();
      final DateTime kz = utc.add(const Duration(hours: 5));

      if (kz.year <= 1900) return null;

      final yyyy = kz.year.toString().padLeft(4, '0');
      final mm = kz.month.toString().padLeft(2, '0');
      final dd = kz.day.toString().padLeft(2, '0');
      final hh = kz.hour.toString().padLeft(2, '0');
      final mi = kz.minute.toString().padLeft(2, '0');

      return '$yyyy-$mm-$dd $hh:$mi';
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickRoute() async {
    if (_loadingRoutes) return;

    if (_routesError != null) {
      await _loadRoutes();
    }

    if (!mounted) return;

    final selected = await showModalBottomSheet<_RouteOption>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;

        if (_loadingRoutes) {
          return const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: DotCircleLoader()),
            ),
          );
        }

        if (_routesError != null) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _routesError!,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await _loadRoutes();
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          );
        }

        if (_routes.isEmpty) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Маршрутов нет',
                style: TextStyle(color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            shrinkWrap: true,
            itemCount: _routes.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(ctx).dividerColor,
            ),
            itemBuilder: (_, i) {
              final r = _routes[i];
              final isSelected =
                  _selectedRoute?.routeSheetId == r.routeSheetId;
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                tileColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                title: Text(r.title),
                subtitle: (r.subtitle != null)
                    ? Text(r.subtitle!,
                        maxLines: 1, overflow: TextOverflow.ellipsis)
                    : null,
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(ctx).pop(r),
              );
            },
          ),
        );
      },
    );

    if (!mounted || selected == null) return;

    setState(() {
      _selectedRoute = selected;
    });
    await _loadWagonsForSelectedRoute();
    await _loadHistory();
  }

  Future<void> _pickWagon() async {
    if (_selectedRoute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала выберите маршрут')),
      );
      return;
    }

    if (_loadingWagons) return;

    if (_wagons.isEmpty && _wagonsError == null) {
      await _loadWagonsForSelectedRoute();
    }

    if (!mounted) return;

    final selected = await showModalBottomSheet<_WagonOption>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;

        if (_loadingWagons) {
          return const SafeArea(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: DotCircleLoader()),
            ),
          );
        }

        if (_wagonsError != null) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _wagonsError!,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await _loadWagonsForSelectedRoute();
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          );
        }

        if (_wagons.isEmpty) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Вагонов нет',
                style: TextStyle(color: scheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            shrinkWrap: true,
            itemCount: _wagons.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              thickness: 1,
              color: Theme.of(ctx).dividerColor,
            ),
            itemBuilder: (_, i) {
              final w = _wagons[i];
              final isSelected = _selectedWagon?.wagonId == w.wagonId;
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                tileColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                title: Text(w.title),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(ctx).pop(w),
              );
            },
          ),
        );
      },
    );

    if (!mounted || selected == null) return;

    setState(() {
      _selectedWagon = selected;
    });

    await _loadHistory();
  }

  Future<void> _submitRemark() async {
    final typeId = categoryTypeId;
    final text = textCtrl.text.trim();
    if (typeId == null || text.isEmpty) return;

    final wagonId = _selectedWagon?.wagonId ?? widget.wagonId;
    final employeeId = widget.employeeId;
    final routeId = widget.routeId;
    final routeSheetId = _selectedRoute?.routeSheetId ?? widget.routeSheetId;

    if (wagonId == null) {
      setState(() => _submitError = 'Не указан wagonId — сохранить нельзя.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить: не указан wagonId')),
      );
      return;
    }

    if (employeeId == null) {
      setState(() => _submitError = 'Не указан employeeId — сохранить нельзя.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить: не указан employeeId')),
      );
      return;
    }

    setState(() {
      _submitting = true;
      _submitError = null;
    });

    try {
      final ok = await _repo.createRemark(
        text: text,
        wagonId: wagonId,
        typeId: typeId,
        employeeId: employeeId,
        departmentId: widget.departmentId,
        state: 1,
        routeId: routeId,
        routeSheetId: routeSheetId,
        imageUrl: (_imageUrl != null && _imageUrl!.trim().isNotEmpty)
            ? _imageUrl
            : null,
      );

      if (!ok) {
        throw Exception('Не удалось сохранить замечание');
      }

      if (!mounted) return;

      setState(() {
        category = null;
        categoryTypeId = null;
        categoryOther = null;
        _imageUrl = null;
      });
      textCtrl.clear();

      setState(() => currentTab = 1);
      await _loadHistory();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Замечание сохранено')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitError = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить замечание')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _loadHistory() async {
    final wagonId = _selectedWagon?.wagonId ?? widget.wagonId;
    if (wagonId == null) return;

    setState(() {
      _loadingHistory = true;
      _historyError = null;
    });

    try {
      final res = await _repo.searchByWagon(wagonId: wagonId);
      setState(() {
        _history = res?.result ?? const [];
      });
    } catch (_) {
      setState(() {
        _historyError = 'Не удалось загрузить историю';
      });
    } finally {
      if (mounted) {
        setState(() => _loadingHistory = false);
      }
    }
  }

  @override
  void dispose() {
    textCtrl.removeListener(_onFormChanged);
    textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18);
    final scheme = Theme.of(context).colorScheme;
    final int? historyWagonId = _selectedWagon?.wagonId ?? widget.wagonId;

    final blue = scheme.primary;
    final pillGrey = scheme.surfaceContainerHighest;
    final fieldGrey = scheme.surfaceContainerHighest;
    final lightBlue = scheme.primaryContainer;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'ВУ-8',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: scheme.onSurface),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  _pill(
                    context: context,
                    label: 'Добавить замечание',
                    selected: currentTab == 0,
                    onTap: () => setState(() => currentTab = 0),
                    selectedColor: blue,
                    unselectedBg: pillGrey,
                    selectedFg: scheme.onPrimary,
                  ),
                  const SizedBox(width: 10),
                  _pill(
                    context: context,
                    label: 'История записей (${_history.length})',
                    selected: currentTab == 1,
                    onTap: () => setState(() => currentTab = 1),
                    selectedColor: blue,
                    unselectedBg: pillGrey,
                    selectedFg: scheme.onPrimary,
                  ),
                ],
              ),
            ),
            if (currentTab == 0)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Выберите категорию замечания и\nопишите подробнее причину',
                        style: TextStyle(
                          fontSize: 20,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: _pickRoute,
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: fieldGrey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedRoute?.title ?? 'Выбрать маршрут',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: _selectedRoute == null
                                            ? scheme.onSurfaceVariant
                                            : scheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (_selectedRoute?.subtitle != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          _selectedRoute!.subtitle!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: scheme.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (_loadingRoutes)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: DotCircleLoader(),
                                )
                              else
                                Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _lockUntilRouteSelected(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _pickWagon,
                          child: Container(
                            height: 64,
                            decoration: BoxDecoration(
                              color: fieldGrey,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedWagon?.title ?? 'Выбрать вагон',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: (_selectedWagon == null)
                                          ? scheme.onSurfaceVariant
                                          : scheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_loadingWagons)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: DotCircleLoader(),
                                  )
                                else
                                  Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _lockUntilRouteAndWagonSelected(
                        child: Column(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () async {
                                final res = await Navigator.of(context)
                                    .push<Map<String, String?>>(
                                  MaterialPageRoute(
                                    builder: (_) => SelectCategoryPage(
                                      repo: _repo,
                                      initial: category,
                                    ),
                                  ),
                                );

                                if (!mounted || res == null) return;

                                final other = (res['other'] ?? '').trim();
                                final typeName = (res['typeName'] ?? '').trim();
                                final dynamic rawTypeId = res['typeId'] ?? res['id'];
                                final int? parsedTypeId = rawTypeId is int
                                    ? rawTypeId
                                    : int.tryParse(rawTypeId?.toString() ?? '');

                                setState(() {
                                  categoryTypeId = parsedTypeId;
                                  categoryOther = other.isNotEmpty ? other : null;
                                  category = other.isNotEmpty ? other : typeName;
                                });
                              },
                              child: Container(
                                height: 64,
                                decoration: BoxDecoration(
                                  color: fieldGrey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        category ?? 'Категория',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: category == null
                                              ? scheme.onSurfaceVariant
                                              : scheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: fieldGrey,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: TextField(
                                controller: textCtrl,
                                enabled: _isRouteAndWagonSelected,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Ваш текст',
                                  hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Добавление фото пока не реализовано')),
                                );
                              },
                              child: Container(
                                height: 64,
                                decoration: BoxDecoration(
                                  color: lightBlue,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo_camera_outlined, color: scheme.onPrimaryContainer),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Добавить фото',
                                      style: TextStyle(
                                        color: scheme.onPrimaryContainer,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            InkWell(
                              borderRadius: borderRadius,
                              onTap: _canSubmit ? _submitRemark : _showCannotSubmitSnack,
                              child: Container(
                                height: 64,
                                decoration: BoxDecoration(
                                  color: _canSubmit ? blue : scheme.surfaceContainerHighest,
                                  borderRadius: borderRadius,
                                ),
                                alignment: Alignment.center,
                                child: _submitting
                                    ? SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: DotCircleLoader(),
                                      )
                                    : Text(
                                        'Сохранить',
                                        style: TextStyle(
                                          color: _canSubmit
                                              ? scheme.onPrimary
                                              : scheme.onSurfaceVariant,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            if (_submitError != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                _submitError!,
                                style: TextStyle(color: scheme.error, fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        borderRadius: borderRadius,
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: borderRadius,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Отменить',
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadHistory,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                          children: [
                            if (historyWagonId == null)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
                                child: Center(
                                  child: Text(
                                    'Не выбран вагон',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                            else if (_loadingHistory)
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 40, 16, 0),
                                child: Center(child: DotCircleLoader()),
                              )
                            else if (_historyError != null)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
                                child: Center(
                                  child: Text(
                                    _historyError!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                            else if (_history.isEmpty)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
                                child: Center(
                                  child: Text(
                                    'Пока нет замечаний',
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ..._history.expand((item) {
                                final isDone =
                                    (item.completedText ?? '').trim().isNotEmpty;

                                final statusText = isDone ? 'Исправлено' : 'Создано';
                                final statusColor =
                                    isDone ? scheme.tertiary : scheme.primary;

                                final title = item.type?.name ?? 'Без категории';
                                final author = item.employee?.shortName ?? '—';
                                final date = _fmtDateTime(item.createdTime);

                                const attachments = <_Attach>[];

                                return [
                                  _RemarkHistoryItem(
                                    title: title,
                                    text: item.text,
                                    statusText: statusText,
                                    statusColor: statusColor,
                                    rightAvatar: _Avatar(
                                      url: null,
                                      initials: (item.employee?.initials.isNotEmpty ?? false)
                                          ? item.employee!.initials
                                          : 'A',
                                    ),
                                    author: author,
                                    date: date,
                                    borderColor: statusColor,
                                    attachments: attachments,
                                    onEdit: () {},
                                  ),
                                  const SizedBox(height: 14),
                                ];
                              }),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 26, 20),
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blue,
                              foregroundColor: scheme.onPrimary,
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                            onPressed: () => setState(() => currentTab = 0),
                            child: Text(
                              'Добавить замечание',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: scheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _pill({
    required BuildContext context,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required Color selectedColor,
    required Color unselectedBg,
    required Color selectedFg,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? selectedColor : unselectedBg,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? selectedFg : scheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final String text;
  final String statusText;
  final Color statusColor;
  final String author;
  final String date;
  final Color borderColor;
  final List<_Attach> attachments;

  const _HistoryCard({
    required this.title,
    required this.text,
    required this.statusText,
    required this.statusColor,
    required this.author,
    required this.date,
    required this.borderColor,
    this.attachments = const [],
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    const cardRadius = 18.0;
    const stripeWidth = 4.0;
    const statusFontSize = 16.0;
    const titleFontSize = 18.0;
    const textFontSize = 15.0;

    const double topPad = 12;
    final double bottomPad = attachments.isEmpty ? 12 : 10;
    const double sidePad = 16;

    final borderRadius = BorderRadius.circular(cardRadius);

    return ClipRRect(
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Container(color: scheme.surface),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 12),
                padding: EdgeInsets.fromLTRB(sidePad, topPad, sidePad, bottomPad),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(cardRadius - 6),
                    bottomLeft: Radius.circular(cardRadius - 6),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: textFontSize,
                        color: scheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                      overflow: TextOverflow.visible,
                      softWrap: true,
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: statusFontSize, color: scheme.onSurface),
                        children: [
                          const TextSpan(
                            text: 'Статус: ',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: statusText,
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (attachments.isNotEmpty) ...[
                Divider(height: 0.1, thickness: 0.1, color: Theme.of(context).dividerColor),
                Padding(
                  padding: const EdgeInsets.fromLTRB(sidePad, 10, sidePad, 12),
                  child: Row(
                    children: [
                      Icon(Icons.attach_file, size: 22, color: scheme.primary),
                      const SizedBox(width: 12),
                      ...attachments.map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              a.thumbUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 56,
                                  height: 56,
                                  alignment: Alignment.center,
                                  color: scheme.surfaceContainerHighest.withValues(alpha:0.6),
                                  child: const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: DotCircleLoader(),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 56,
                                  height: 56,
                                  color: scheme.surfaceContainerHighest.withValues(alpha:0.6),
                                  alignment: Alignment.center,
                                  child: Icon(Icons.broken_image, size: 18, color: scheme.onSurfaceVariant),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: Container(width: stripeWidth, color: borderColor),
          ),
        ],
      ),
    );
  }
}

class _AvatarContainer extends StatelessWidget {
  final Widget child;
  const _AvatarContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String initials;
  const _Avatar({this.url, required this.initials});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: 15,
      backgroundColor: Colors.transparent,
      backgroundImage: url != null ? NetworkImage(url!) : null,
      child: url == null
          ? Text(
              initials,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: scheme.onPrimary,
              ),
            )
          : null,
    );
  }
}

class _Attach {
  final String thumbUrl;
  const _Attach.thumb(this.thumbUrl);
}

class _RemarkHistoryItem extends StatelessWidget {
  final String title;
  final String text;
  final String statusText;
  final Color statusColor;
  final String author;
  final String date;
  final Color borderColor;
  final _Avatar? rightAvatar;
  final List<_Attach> attachments;
  final VoidCallback onEdit;

  const _RemarkHistoryItem({
    required this.title,
    required this.text,
    required this.statusText,
    required this.statusColor,
    required this.author,
    required this.date,
    required this.borderColor,
    this.rightAvatar,
    this.attachments = const [],
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final double avatarReserve = rightAvatar != null ? (48 + 12).toDouble() : 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16 + avatarReserve / 2, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(right: avatarReserve),
            child: _HistoryCard(
              title: title,
              text: text,
              statusText: statusText,
              statusColor: statusColor,
              author: author,
              date: date,
              borderColor: borderColor,
              attachments: attachments,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '$author - $date',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                if (rightAvatar != null) ...[
                  const SizedBox(width: 8),
                  Transform.translate(
                    offset: const Offset(0, -6),
                    child: _AvatarContainer(child: rightAvatar!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteOption {
  final int routeSheetId;
  final String title;
  final String? subtitle;
  const _RouteOption({
    required this.routeSheetId,
    required this.title,
    this.subtitle,
  });
}

class _WagonOption {
  final int wagonId;
  final String title;
  const _WagonOption({
    required this.wagonId,
    required this.title,
  });
}