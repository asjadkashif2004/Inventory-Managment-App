import 'package:flutter/material.dart';
import 'package:my_app/core/app_breakpoints.dart';
import 'package:my_app/models/item.dart';
import 'package:my_app/models/user_profile.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/item_service.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/app_snackbar.dart';
import 'package:my_app/widgets/app_svg_icons.dart';
import 'package:my_app/widgets/fade_slide_in.dart';
import 'package:my_app/widgets/item_form_sheet.dart';
import 'package:my_app/widgets/stat_card.dart';
import 'package:my_app/widgets/user_avatar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.authService,
    required this.itemService,
    required this.profile,
  });

  final AuthService authService;
  final ItemService itemService;
  final UserProfile profile;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Item> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await widget.itemService.fetchAll();
      if (mounted) {
        setState(() {
          _items = items;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  int get _totalQuantity => _items.fold(0, (s, i) => s + i.quantity);

  double get _totalValue =>
      _items.fold(0.0, (s, i) => s + i.quantity * i.price);

  int get _lowStockCount => _items.where((i) => i.quantity < 5).length;

  Future<void> _openItemForm({Item? existing}) async {
    final result = await ItemFormSheet.show(context, existing: existing);
    if (result == null || !mounted) return;

    try {
      if (existing == null) {
        await widget.itemService.create(
          itemCode: result.itemCode,
          name: result.name,
          quantity: result.quantity,
          price: result.price,
        );
        if (!mounted) return;
        showAppSnackBar(context, message: 'Item added successfully');
      } else {
        await widget.itemService.update(
          id: existing.id,
          itemCode: result.itemCode,
          name: result.name,
          quantity: result.quantity,
          price: result.price,
        );
        if (!mounted) return;
        showAppSnackBar(context, message: 'Item updated successfully');
      }
      await _loadItems();
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e);
    }
  }

  Future<void> _deleteItem(Item item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('Remove "${item.name}" (${item.itemCode})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await widget.itemService.delete(item.id);
      if (!mounted) return;
      showAppSnackBar(context, message: 'Item deleted');
      await _loadItems();
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e);
    }
  }

  String _shortId(String id) =>
      id.length <= 8 ? id : '${id.substring(0, 8)}…';

  double _horizontalPadding(double width) {
    if (AppBreakpoints.isDesktop(width)) return 32;
    if (AppBreakpoints.isTablet(width)) return 24;
    return 16;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final padding = _horizontalPadding(width);
    final showTopBar = !AppBreakpoints.isMobile(width);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadItems,
          color: AppColors.accent,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (showTopBar)
                SliverToBoxAdapter(child: _buildTopBar(context, padding)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(padding, showTopBar ? 8 : 16, padding, 0),
                  child: _buildWelcomeCard(context),
                ),
              ),
              if (!_loading && _error == null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(padding, 20, padding, 0),
                    child: _buildStatsGrid(width),
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(padding, 20, padding, 100),
                sliver: SliverToBoxAdapter(child: _buildInventorySection(context, width)),
              ),
            ],
          ),
        ),
        Positioned(
          right: padding,
          bottom: 24,
          child: FadeSlideIn(
            delay: const Duration(milliseconds: 400),
            offset: const Offset(0, 30),
            child: FloatingActionButton.extended(
              onPressed: _loading ? null : () => _openItemForm(),
              icon: AppSvgIcons.add(color: Colors.white, size: 22),
              label: const Text('Add item'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, double padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 20, padding, 0),
      child: Row(
        children: [
          AppSvgIcons.dashboard(color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadItems,
            icon: AppSvgIcons.refresh(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return FadeSlideIn(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.accent.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            UserAvatar(profile: widget.profile, radius: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${widget.profile.displayName}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    widget.profile.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(double width) {
    final crossAxisCount = width >= 1100 ? 4 : 2;
    final stats = [
      ('Total items', '${_items.length}', AppSvgIcons.box, AppColors.accent),
      ('Total quantity', '$_totalQuantity', AppSvgIcons.inventory, AppColors.primary),
      ('Stock value', '\$${_totalValue.toStringAsFixed(2)}', AppSvgIcons.dollar, AppColors.success),
      ('Low stock', '$_lowStockCount', AppSvgIcons.warning, AppColors.warning),
    ];

    // Taller cells on mobile — horizontal stat rows overflow at ratio 1.75.
    final aspectRatio = width >= 1100
        ? 2.5
        : width >= AppBreakpoints.mobile
            ? 1.85
            : 0.95;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: aspectRatio,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final (label, value, iconBuilder, color) = stats[index];
        return FadeSlideIn(
          delay: Duration(milliseconds: 80 * index),
          child: StatCard(
            label: label,
            value: value,
            icon: iconBuilder(color: color, size: 22),
            accentColor: color,
          ),
        );
      },
    );
  }

  Widget _buildInventorySection(BuildContext context, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppSvgIcons.inventory(color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Inventory',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: _buildTableContent(context, width),
        ),
      ],
    );
  }

  Widget _buildTableContent(BuildContext context, double width) {
    if (_loading) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            AppSvgIcons.warning(color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Could not load inventory. Run supabase/setup.sql in your Supabase project.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _loadItems, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            AppSvgIcons.box(color: AppColors.textSecondary, size: 56),
            const SizedBox(height: 12),
            const Text('No items yet'),
            const SizedBox(height: 8),
            Text(
              'Tap Add item to get started',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    if (width < 700) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) => _MobileItemTile(
          item: _items[index],
          onEdit: () => _openItemForm(existing: _items[index]),
          onDelete: () => _deleteItem(_items[index]),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        columns: const [
          DataColumn(label: Text('ITEM ID')),
          DataColumn(label: Text('NAME')),
          DataColumn(label: Text('QTY'), numeric: true),
          DataColumn(label: Text('PRICE'), numeric: true),
          DataColumn(label: Text('VALUE'), numeric: true),
          DataColumn(label: Text('RECORD')),
          DataColumn(label: Text('ACTIONS')),
        ],
        rows: List.generate(_items.length, (index) {
          final item = _items[index];
          final lineValue = item.quantity * item.price;
          final isLow = item.quantity < 5;

          return DataRow(
            color: WidgetStateProperty.resolveWith((_) {
              return index.isEven
                  ? AppColors.surface.withValues(alpha: 0.5)
                  : null;
            }),
            cells: [
              DataCell(Text(item.itemCode,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isLow ? AppColors.warning : null,
                  ))),
              DataCell(Text(item.name)),
              DataCell(Text('${item.quantity}')),
              DataCell(Text('\$${item.price.toStringAsFixed(2)}')),
              DataCell(Text('\$${lineValue.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(_shortId(item.id),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ))),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: () => _openItemForm(existing: item),
                    icon: AppSvgIcons.edit(color: AppColors.accentDark),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: () => _deleteItem(item),
                    icon: AppSvgIcons.delete(color: AppColors.error),
                  ),
                ],
              )),
            ],
          );
        }),
      ),
    );
  }
}

class _MobileItemTile extends StatelessWidget {
  const _MobileItemTile({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final Item item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${item.itemCode} · Qty ${item.quantity} · \$${item.price.toStringAsFixed(2)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onEdit,
            icon: AppSvgIcons.edit(color: AppColors.accentDark, size: 20),
          ),
          IconButton(
            onPressed: onDelete,
            icon: AppSvgIcons.delete(color: AppColors.error, size: 20),
          ),
        ],
      ),
    );
  }
}
