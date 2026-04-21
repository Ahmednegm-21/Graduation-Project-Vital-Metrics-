import 'package:flutter/material.dart';
import 'package:vital_metrics/core/themes/theme_context_extension.dart';

class AiMealSheet extends StatefulWidget {
  const AiMealSheet({super.key});

  @override
  State<AiMealSheet> createState() => _AiMealSheetState();
}

class _AiMealSheetState extends State<AiMealSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // ── Drag handle ────────────────────────────────────────────────────
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: context.colors.subText.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Title ──────────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.smart_toy_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Meal Assistant',
                      style: TextStyle(
                          color: context.colors.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text('Log your meal your way',
                      style: TextStyle(
                          color: context.colors.subText, fontSize: 12)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Search bar ─────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: context.colors.inputFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF4361EE).withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: TextStyle(color: context.colors.text, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search meals, ingredients...',
                hintStyle:
                    TextStyle(color: context.colors.subText, fontSize: 13),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFF4361EE), size: 20),
                suffixIcon: _query.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                        child: Icon(Icons.close,
                            color: context.colors.subText, size: 18),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Buttons ────────────────────────────────────────────────────────
          Row(
            children: [
              // ── Type meal description ──────────────────────────────────────
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showDescriptionDialog(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4361EE), Color(0xFF7B5EA7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4361EE).withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.edit_note_rounded,
                            color: Colors.white, size: 28),
                        SizedBox(height: 8),
                        Text('Describe\nMeal',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        SizedBox(height: 4),
                        Text('Type what you ate',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // ── Voice / AI search ──────────────────────────────────────────
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showVoiceDialog(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CC9F0), Color(0xFF4361EE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CC9F0).withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.mic_rounded,
                            color: Colors.white, size: 28),
                        SizedBox(height: 8),
                        Text('Voice\nSearch',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        SizedBox(height: 4),
                        Text('AI-powered search',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// ── Describe Meal Dialog ───────────────────────────────────────────────────────
void _showDescriptionDialog(BuildContext context) {
  final ctrl   = TextEditingController();
  final isDark = context.isDark;
  final dlgBg  = isDark ? const Color(0xFF16213E) : Colors.white;
  final txtColor = isDark ? Colors.white : const Color(0xFF2D3142);

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: dlgBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Row(
        children: [
          const Icon(Icons.edit_note_rounded, color: Color(0xFF4361EE)),
          const SizedBox(width: 8),
          Text('Describe Your Meal',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: txtColor,
                  fontSize: 15)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tell the AI what you ate and it will calculate the calories for you.',
            style: TextStyle(color: txtColor.withOpacity(0.65), fontSize: 12),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl,
            maxLines: 4,
            style: TextStyle(color: txtColor),
            decoration: InputDecoration(
              hintText:
                  'e.g. "I had 2 eggs, a toast and orange juice for breakfast"',
              hintStyle: TextStyle(
                  color: txtColor.withOpacity(0.4), fontSize: 12),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF1A1A2E)
                  : const Color(0xFFF6F8FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFF4361EE), width: 2),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey)),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4361EE),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.smart_toy_rounded,
              color: Colors.white, size: 16),
          label: const Text('Analyze',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () {
            // TODO: هنا بتبعت النص للـ AI API
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    ctrl.text.isNotEmpty
                        ? 'Analyzing: "${ctrl.text.substring(0, ctrl.text.length.clamp(0, 40))}..."'
                        : 'Please describe your meal'),
                backgroundColor: const Color(0xFF4361EE),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
        ),
      ],
    ),
  );
}

// ── Voice Dialog ──────────────────────────────────────────────────────────────
void _showVoiceDialog(BuildContext context) {
  final isDark   = context.isDark;
  final dlgBg    = isDark ? const Color(0xFF16213E) : Colors.white;
  final txtColor = isDark ? Colors.white : const Color(0xFF2D3142);

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: dlgBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Row(
        children: [
          const Icon(Icons.mic_rounded, color: Color(0xFF4CC9F0)),
          const SizedBox(width: 8),
          Text('Voice AI Search',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: txtColor,
                  fontSize: 15)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mic animation placeholder
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4361EE), Color(0xFF4CC9F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4361EE).withOpacity(0.4),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(Icons.mic_rounded,
                color: Colors.white, size: 44),
          ),
          const SizedBox(height: 16),
          Text('Tap & speak your meal',
              style: TextStyle(
                  color: txtColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 6),
          Text(
            'e.g. "Grilled chicken with rice and salad"',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: txtColor.withOpacity(0.5), fontSize: 11),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4361EE).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.smart_toy_rounded,
                    color: Color(0xFF4361EE), size: 14),
                SizedBox(width: 6),
                Text('AI-powered nutrition analysis',
                    style: TextStyle(
                        color: Color(0xFF4361EE),
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey)),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CC9F0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.mic_rounded,
              color: Colors.white, size: 16),
          label: const Text('Start',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () {
            // TODO: هنا بتفتح الـ speech recognition
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}