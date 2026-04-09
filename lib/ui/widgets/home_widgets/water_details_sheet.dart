import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vital_metrics/logic/home/water_cubit.dart';

class WaterDetailsSheet extends StatefulWidget {
  const WaterDetailsSheet({super.key});

  @override
  State<WaterDetailsSheet> createState() => _WaterDetailsSheetState();
}

class _WaterDetailsSheetState extends State<WaterDetailsSheet> {
  int _selectedTab = 0; // 0=goal, 1=drink amount, 2=unit

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WaterCubit, WaterState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 16,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Water Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 16),
              // Tab selector
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildTab(0, 'Daily Goal'),
                    _buildTab(1, 'Drink Size'),
                    _buildTab(2, 'Unit'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildTabContent(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4361EE) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, WaterState state) {
    switch (_selectedTab) {
      case 0:
        return _GoalEditor(key: const ValueKey(0), state: state);
      case 1:
        return _DrinkAmountEditor(key: const ValueKey(1), state: state);
      case 2:
        return _UnitSelector(key: const ValueKey(2), state: state);
      default:
        return const SizedBox();
    }
  }
}

class _GoalEditor extends StatefulWidget {
  final WaterState state;
  const _GoalEditor({super.key, required this.state});

  @override
  State<_GoalEditor> createState() => _GoalEditorState();
}

class _GoalEditorState extends State<_GoalEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.state.goalInUnit.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey(0),
      children: [
        Text(
          'Set your daily water goal (${widget.state.unit})',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: widget.state.unit,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4361EE)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4361EE), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Quick select chips
        Wrap(
          spacing: 8,
          children: (widget.state.unit == 'ml'
                  ? [1500, 2000, 2500, 3000, 3500]
                  : [50, 68, 84, 100, 118])
              .map((v) => GestureDetector(
                    onTap: () =>
                        _controller.text = v.toString(),
                    child: Chip(
                      label: Text('$v ${widget.state.unit}'),
                      backgroundColor: const Color(0xFFF1F3FF),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        _SaveButton(onSave: () {
          final val = double.tryParse(_controller.text);
          if (val != null) {
            context.read<WaterCubit>().updateDailyGoal(val);
            Navigator.pop(context);
          }
        }),
      ],
    );
  }
}

class _DrinkAmountEditor extends StatefulWidget {
  final WaterState state;
  const _DrinkAmountEditor({super.key, required this.state});

  @override
  State<_DrinkAmountEditor> createState() => _DrinkAmountEditorState();
}

class _DrinkAmountEditorState extends State<_DrinkAmountEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.state.drinkAmountInUnit.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey(1),
      children: [
        Text(
          'Amount added each time you drink (${widget.state.unit})',
          style: const TextStyle(color: Colors.grey, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: widget.state.unit,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4361EE), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: (widget.state.unit == 'ml'
                  ? [150, 200, 250, 300, 500]
                  : [5, 7, 8, 10, 17])
              .map((v) => GestureDetector(
                    onTap: () =>
                        _controller.text = v.toString(),
                    child: Chip(
                      label: Text('$v ${widget.state.unit}'),
                      backgroundColor: const Color(0xFFF1F3FF),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        _SaveButton(onSave: () {
          final val = double.tryParse(_controller.text);
          if (val != null) {
            context.read<WaterCubit>().updateDrinkAmount(val);
            Navigator.pop(context);
          }
        }),
      ],
    );
  }
}

class _UnitSelector extends StatelessWidget {
  final WaterState state;
  const _UnitSelector({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey(2),
      children: [
        const Text(
          'Choose measurement unit',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _UnitOption(
              label: 'Milliliters',
              sub: 'ml',
              icon: Icons.water_drop,
              selected: state.unit == 'ml',
              onTap: () {
                context.read<WaterCubit>().updateUnit('ml');
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 12),
            _UnitOption(
              label: 'Fluid Ounces',
              sub: 'oz',
              icon: Icons.local_drink,
              selected: state.unit == 'oz',
              onTap: () {
                context.read<WaterCubit>().updateUnit('oz');
                Navigator.pop(context);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _UnitOption extends StatelessWidget {
  final String label;
  final String sub;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _UnitOption({
    required this.label,
    required this.sub,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF4361EE)
                : const Color(0xFFF1F3FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? const Color(0xFF4361EE)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : const Color(0xFF4361EE),
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : const Color(0xFF2D3142),
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                sub,
                style: TextStyle(
                  color: selected
                      ? Colors.white70
                      : Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onSave;
  const _SaveButton({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4361EE),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Save',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}