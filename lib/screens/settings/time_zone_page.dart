import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/data/time_zones.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/user_profile.dart';
import 'package:matterleast/screens/settings/settings_providers.dart';
import 'package:matterleast/screens/settings/settings_widgets.dart';
import 'package:matterleast/screens/you/profile_providers.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/tokens.dart';

/// The account's time zone on one server: the phone's, or one picked by
/// hand. Scheduled messages and other people's view of the user's local
/// time follow it.
class TimeZonePage extends ConsumerStatefulWidget {
  const TimeZonePage({required this.server, super.key});

  final ServerEntry server;

  @override
  ConsumerState<TimeZonePage> createState() => _TimeZonePageState();
}

class _TimeZonePageState extends ConsumerState<TimeZonePage> {
  final _zones = allTimeZones();
  final _query = TextEditingController();
  late List<String> _shown = _zones;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _query.addListener(
      () => setState(() => _shown = matchingZones(_zones, _query.text)),
    );
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _save({required bool automatic, String? manual}) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      final actions = await ref.read(
        profileActionsProvider(widget.server.url).future,
      );
      await actions.setTimeZone(automatic: automatic, manual: manual);
    } on Object catch (e) {
      showProblem(
        messenger,
        "Couldn't save. ${requestProblemText(e, widget.server.address)}",
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final setting = ref.watch(zoneSettingProvider(widget.server.url)).value;
    final automatic = setting?.automatic ?? true;
    final manual = setting?.manualZone;
    return ContentPage(
      title: const Text('Time zone'),
      progress: _saving,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SwitchListTile(
              title: const Text('Set automatically'),
              subtitle: Text(
                automatic && setting?.automaticZone != null
                    ? 'Last seen as ${zoneLabel(setting!.automaticZone!)}'
                    : 'Follow the time zone of your devices',
              ),
              value: automatic,
              onChanged: _saving || setting == null
                  ? null
                  : (on) => _save(
                      automatic: on,
                      manual: on
                          ? null
                          : manual ?? setting.automaticZone ?? 'UTC',
                    ),
            ),
          ),
          if (!automatic) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.sm,
                Spacing.lg,
                Spacing.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: SearchBar(
                  controller: _query,
                  hintText: 'Find a time zone',
                  leading: const Icon(Icons.search),
                  elevation: const WidgetStatePropertyAll(0),
                ),
              ),
            ),
            SliverList.builder(
              itemCount: _shown.length,
              itemBuilder: (context, i) {
                final zone = _shown[i];
                final selected = zone == manual;
                return ListTile(
                  enabled: !_saving,
                  title: Text(zoneLabel(zone)),
                  trailing: selected ? const Icon(Icons.check) : null,
                  selected: selected,
                  onTap: selected
                      ? null
                      : () => _save(automatic: false, manual: zone),
                );
              },
            ),
          ],
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ),
        ],
      ),
    );
  }
}
