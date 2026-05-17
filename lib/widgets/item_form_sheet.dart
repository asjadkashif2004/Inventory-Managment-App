import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/models/item.dart';
import 'package:my_app/theme/app_theme.dart';
import 'package:my_app/widgets/app_svg_icons.dart';
import 'package:my_app/widgets/fade_slide_in.dart';

class ItemFormResult {
  const ItemFormResult({
    required this.itemCode,
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String itemCode;
  final String name;
  final int quantity;
  final double price;
}

abstract final class ItemFormSheet {
  static Future<ItemFormResult?> show(
    BuildContext context, {
    Item? existing,
  }) {
    return showGeneralDialog<ItemFormResult>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _ItemFormDialog(existing: existing);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curve),
            child: child,
          ),
        );
      },
    );
  }
}

class _ItemFormDialog extends StatefulWidget {
  const _ItemFormDialog({this.existing});

  final Item? existing;

  @override
  State<_ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<_ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final PageController _pageController;
  late final TextEditingController _itemCodeController;
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  int _step = 0;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _pageController = PageController();
    _itemCodeController = TextEditingController(text: e?.itemCode ?? '');
    _nameController = TextEditingController(text: e?.name ?? '');
    _quantityController = TextEditingController(text: e?.quantity.toString() ?? '');
    _priceController = TextEditingController(text: e?.price.toString() ?? '');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _itemCodeController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  bool _validateStep0() {
    return _itemCodeController.text.trim().isNotEmpty &&
        _nameController.text.trim().isNotEmpty;
  }

  bool _validateStep1() {
    final q = int.tryParse(_quantityController.text.trim());
    final p = double.tryParse(_priceController.text.trim());
    return q != null && q >= 0 && p != null && p >= 0;
  }

  void _nextStep() {
    if (_step == 0) {
      if (!_validateStep0()) {
        _formKey.currentState?.validate();
        return;
      }
      setState(() => _step = 1);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _prevStep() {
    if (_step == 1) {
      setState(() => _step = 0);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateStep1()) return;

    Navigator.of(context).pop(
      ItemFormResult(
        itemCode: _itemCodeController.text.trim(),
        name: _nameController.text.trim(),
        quantity: int.parse(_quantityController.text.trim()),
        price: double.parse(_priceController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = maxWidth > 600 ? 480.0 : maxWidth - 32;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: dialogWidth,
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: Container(
          width: dialogWidth,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              _buildStepIndicator(),
              Flexible(
                child: Form(
                  key: _formKey,
                  child: SizedBox(
                    height: _isEdit ? 340 : 300,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildStepDetails(),
                        _buildStepPricing(),
                      ],
                    ),
                  ),
                ),
              ),
              _buildActions(context),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppSvgIcons.add(color: Colors.white, size: 26),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEdit ? 'Edit inventory item' : 'Add inventory item',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  _step == 0 ? 'Step 1 — Item details' : 'Step 2 — Stock & pricing',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          _StepDot(active: _step >= 0, label: 'Details'),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: _step >= 1 ? AppColors.accent : AppColors.border,
            ),
          ),
          _StepDot(active: _step >= 1, label: 'Pricing'),
        ],
      ),
    );
  }

  Widget _buildStepDetails() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (_isEdit) ...[
          FadeSlideIn(
            child: TextFormField(
              initialValue: widget.existing!.id,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Record ID',
                helperText: 'Auto-generated — cannot be changed',
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        FadeSlideIn(
          delay: const Duration(milliseconds: 80),
          child: TextFormField(
            controller: _itemCodeController,
            decoration: InputDecoration(
              labelText: 'Item ID / SKU',
              hintText: 'e.g. SKU-001',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(14),
                child: AppSvgIcons.tag(color: AppColors.textSecondary),
              ),
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter item ID' : null,
          ),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          delay: const Duration(milliseconds: 160),
          child: TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Item name',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(14),
                child: AppSvgIcons.box(color: AppColors.textSecondary),
              ),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Enter item name' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStepPricing() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        FadeSlideIn(
          child: TextFormField(
            controller: _quantityController,
            decoration: InputDecoration(
              labelText: 'Quantity in stock',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(14),
                child: AppSvgIcons.inventory(color: AppColors.textSecondary),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) {
              final n = int.tryParse(v ?? '');
              if (n == null || n < 0) return 'Enter a valid quantity';
              return null;
            },
          ),
        ),
        const SizedBox(height: 14),
        FadeSlideIn(
          delay: const Duration(milliseconds: 100),
          child: TextFormField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: 'Unit price',
              prefixText: '\$ ',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 4),
                child: AppSvgIcons.dollar(color: AppColors.textSecondary, size: 20),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              final n = double.tryParse(v ?? '');
              if (n == null || n < 0) return 'Enter a valid price';
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),
        FadeSlideIn(
          delay: const Duration(milliseconds: 180),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                AppSvgIcons.dollar(color: AppColors.accentDark, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Line value is calculated as quantity × unit price on save.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        children: [
          if (_step > 0)
            TextButton(
              onPressed: _prevStep,
              child: const Text('Back'),
            )
          else
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          const Spacer(),
          if (_step == 0 && !_isEdit)
            FilledButton(
              onPressed: _nextStep,
              child: const Text('Continue'),
            )
          else if (_step == 0 && _isEdit)
            FilledButton(
              onPressed: _nextStep,
              child: const Text('Next'),
            )
          else
            FilledButton.icon(
              onPressed: _submit,
              icon: AppSvgIcons.add(color: Colors.white, size: 18),
              label: Text(_isEdit ? 'Save changes' : 'Add item'),
            ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.active, required this.label});

  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.accent : AppColors.border,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppColors.accentDark : AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}
