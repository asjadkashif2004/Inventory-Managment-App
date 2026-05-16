import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/models/item.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/item_service.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/app_svg_icons.dart';
import 'package:my_app/widgets/fade_slide_in.dart';
import 'package:my_app/widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.authService,
    required this.itemService,
  });

  final AuthService authService;
  final ItemService itemService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Item> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
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

  Future<void> _signOut() async {
    await widget.authService.signOut();
  }

  int get _totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  double get _totalValue => _items.fold(
        0.0,
        (sum, item) => sum + (item.quantity * item.price),
      );

  int get _lowStockCount =>
      _items.where((item) => item.quantity < 5).length;

  String? _validateItemCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter item ID';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter item name';
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter quantity';
    }
    final n = int.tryParse(value);
    if (n == null || n < 0) {
      return 'Enter a valid quantity (0 or more)';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter price';
    }
    final n = double.tryParse(value);
    if (n == null || n < 0) {
      return 'Enter a valid price (0 or more)';
    }
    return null;
  }

  Future<void> _showItemDialog({Item? existing}) async {
    final formKey = GlobalKey<FormState>();
    final itemCodeController =
        TextEditingController(text: existing?.itemCode ?? '');
    final nameController = TextEditingController(text: existing?.name ?? '');
    final quantityController = TextEditingController(
      text: existing?.quantity.toString() ?? '',
    );
    final priceController = TextEditingController(
      text: existing?.price.toString() ?? '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            AppSvgIcons.add(
              color: AppColors.accent,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(existing == null ? 'Add item' : 'Edit item'),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (existing != null) ...[
                  TextFormField(
                    initialValue: existing.id,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Record ID (auto)',
                      helperText: 'System UUID — cannot be changed',
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: itemCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Item ID',
                    hintText: 'e.g. SKU-001',
                  ),
                  validator: _validateItemCode,
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Item name'),
                  validator: _validateName,
                  autofocus: existing == null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _validateQuantity,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Unit price',
                    prefixText: '\$ ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _validatePrice,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    try {
      if (saved == true && mounted) {
        final quantity = int.parse(quantityController.text.trim());
        final price = double.parse(priceController.text.trim());

        if (existing == null) {
          await widget.itemService.create(
            itemCode: itemCodeController.text.trim(),
            name: nameController.text.trim(),
            quantity: quantity,
            price: price,
          );
        } else {
          await widget.itemService.update(
            id: existing.id,
            itemCode: itemCodeController.text.trim(),
            name: nameController.text.trim(),
            quantity: quantity,
            price: price,
          );
        }
        await _loadItems();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      itemCodeController.dispose();
      nameController.dispose();
      quantityController.dispose();
      priceController.dispose();
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

    if (confirmed != true) return;

    try {
      await widget.itemService.delete(item.id);
      await _loadItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  String _shortId(String id) {
    if (id.length <= 8) return id;
    return '${id.substring(0, 8)}…';
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.authService.currentUser?.email ?? 'User';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Row(
          children: [
            AppSvgIcons.dashboard(color: AppColors.primary, size: 26),
            const SizedBox(width: 10),
            const Text('Inventory Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadItems,
            icon: AppSvgIcons.refresh(color: AppColors.textSecondary),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: _signOut,
            icon: AppSvgIcons.logout(color: AppColors.textSecondary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadItems,
        color: AppColors.accent,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: FadeSlideIn(
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.08),
                          AppColors.accent.withValues(alpha: 0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            email.isNotEmpty
                                ? email[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                              Text(
                                email,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (!_loading && _error == null)
              SliverToBoxAdapter(child: _buildStatsGrid()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              sliver: SliverToBoxAdapter(child: _buildInventorySection()),
            ),
          ],
        ),
      ),
      floatingActionButton: FadeSlideIn(
        delay: const Duration(milliseconds: 600),
        offset: const Offset(0, 40),
        child: FloatingActionButton.extended(
          onPressed: _loading ? null : () => _showItemDialog(),
          icon: AppSvgIcons.add(color: Colors.white, size: 22),
          label: const Text('Add item'),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 700 ? 4 : 2;
          final stats = [
            (
              'Total items',
              '${_items.length}',
              AppSvgIcons.box(color: AppColors.accent, size: 22),
              AppColors.accent,
            ),
            (
              'Total quantity',
              '$_totalQuantity',
              AppSvgIcons.inventory(color: AppColors.primary, size: 22),
              AppColors.primary,
            ),
            (
              'Stock value',
              '\$${_totalValue.toStringAsFixed(2)}',
              AppSvgIcons.dollar(color: AppColors.success, size: 22),
              AppColors.success,
            ),
            (
              'Low stock',
              '$_lowStockCount',
              AppSvgIcons.warning(color: AppColors.warning, size: 22),
              AppColors.warning,
            ),
          ];

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: crossAxisCount == 4 ? 2.4 : 1.8,
            ),
            itemCount: stats.length,
            itemBuilder: (context, index) {
              final (label, value, icon, color) = stats[index];
              return FadeSlideIn(
                delay: Duration(milliseconds: 100 + index * 80),
                child: StatCard(
                  label: label,
                  value: value,
                  icon: icon,
                  accentColor: color,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInventorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeSlideIn(
          delay: const Duration(milliseconds: 350),
          child: Row(
            children: [
              AppSvgIcons.inventory(color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Inventory table',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: _buildTableContent(),
        ),
      ],
    );
  }

  Widget _buildTableContent() {
    if (_loading) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            AppSvgIcons.warning(color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Could not load items.\n\n'
              'Run supabase/setup.sql (new project) or '
              'supabase/migrate_items.sql (existing table) in Supabase.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadItems, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          children: [
            AppSvgIcons.box(color: AppColors.textSecondary, size: 56),
            const SizedBox(height: 16),
            Text(
              'No items yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap "Add item" to create your first inventory record.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
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
          final isLowStock = item.quantity < 5;

          return DataRow(
            color: WidgetStateProperty.resolveWith((states) {
              if (index.isEven) {
                return AppColors.surface.withValues(alpha: 0.5);
              }
              return null;
            }),
            cells: [
              DataCell(
                Text(
                  item.itemCode,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isLowStock ? AppColors.warning : null,
                  ),
                ),
              ),
              DataCell(Text(item.name)),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isLowStock
                        ? AppColors.warning.withValues(alpha: 0.12)
                        : AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.quantity}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isLowStock ? AppColors.warning : AppColors.accentDark,
                    ),
                  ),
                ),
              ),
              DataCell(Text('\$${item.price.toStringAsFixed(2)}')),
              DataCell(
                Text(
                  '\$${lineValue.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataCell(
                Text(
                  _shortId(item.id),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontFamily: 'monospace',
                      ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TableIconButton(
                      tooltip: 'Edit',
                      icon: AppSvgIcons.edit(color: AppColors.accentDark),
                      onPressed: () => _showItemDialog(existing: item),
                    ),
                    _TableIconButton(
                      tooltip: 'Delete',
                      icon: AppSvgIcons.delete(color: AppColors.error),
                      onPressed: () => _deleteItem(item),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _TableIconButton extends StatelessWidget {
  const _TableIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size(36, 36),
        padding: EdgeInsets.zero,
        backgroundColor: AppColors.surface,
      ),
      icon: icon,
    );
  }
}
