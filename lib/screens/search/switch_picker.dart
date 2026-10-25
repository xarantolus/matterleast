import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/screens/search/quick_search.dart';
import 'package:matterleast/ui/tokens.dart';

/// A sheet to pick one of [items], narrowed by typing; null when dismissed.
Future<SwitchItem?> pickSwitchItem(
  BuildContext context, {
  required String title,
  required String hint,
  required List<SwitchItem> items,
}) => showModalBottomSheet<SwitchItem>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _SwitchPicker(title: title, hint: hint, items: items),
);

class _SwitchPicker extends StatefulWidget {
  const _SwitchPicker({
    required this.title,
    required this.hint,
    required this.items,
  });

  final String title;
  final String hint;
  final List<SwitchItem> items;

  @override
  State<_SwitchPicker> createState() => _SwitchPickerState();
}

class _SwitchPickerState extends State<_SwitchPicker> {
  var _term = '';

  @override
  Widget build(BuildContext context) {
    final shown = _term.trim().isEmpty
        ? ([...widget.items]..sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
          ))
        : rankSwitchItems(_term, widget.items, limit: 100);
    final insets = MediaQuery.viewInsetsOf(context).bottom;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: Padding(
        padding: EdgeInsets.only(bottom: insets),
        child: Column(
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: SearchBar(
                hintText: widget.hint,
                leading: const Icon(Icons.search),
                elevation: const WidgetStatePropertyAll(0),
                onChanged: (text) => setState(() => _term = text),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final item in shown)
                    SwitchTile(
                      item: item,
                      onTap: () => Navigator.of(context).pop(item),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
