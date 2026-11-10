import 'package:flutter/material.dart';

void main() => runApp(const NovaVpnApp());

const _navy = Color(0xFF061226);
const _panel = Color(0xFF0D1D35);
const _panelLight = Color(0xFF122744);
const _blue = Color(0xFF168BFF);
const _cyan = Color(0xFF00D5E8);
const _purple = Color(0xFF764BFF);
const _muted = Color(0xFF91A5C3);

class NovaVpnApp extends StatefulWidget {
  const NovaVpnApp({super.key});

  @override
  State<NovaVpnApp> createState() => _NovaVpnAppState();
}

class _NovaVpnAppState extends State<NovaVpnApp> {
  bool _light = false;

  @override
  Widget build(BuildContext context) {
    final background = _light ? const Color(0xFFF2F6FC) : _navy;
    final foreground = _light ? const Color(0xFF10213A) : Colors.white;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NovaVPN',
      theme: ThemeData(
        brightness: _light ? Brightness.light : Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _blue,
          brightness: _light ? Brightness.light : Brightness.dark,
          surface: _light ? Colors.white : _panel,
        ),
        useMaterial3: true,
        textTheme: ThemeData(brightness: _light ? Brightness.light : Brightness.dark)
            .textTheme
            .apply(bodyColor: foreground, displayColor: foreground),
      ),
      home: NovaHome(
        lightMode: _light,
        onThemeChanged: (value) => setState(() => _light = value),
      ),
    );
  }
}

class VpnLocation {
  const VpnLocation(this.country, this.city, this.flag, this.ping);
  final String country;
  final String city;
  final String flag;
  final int ping;
}

const _locations = <VpnLocation>[
  VpnLocation('United Kingdom', 'London', '🇬🇧', 45),
  VpnLocation('Germany', 'Frankfurt', '🇩🇪', 52),
  VpnLocation('United States', 'New York', '🇺🇸', 68),
  VpnLocation('Canada', 'Toronto', '🇨🇦', 72),
  VpnLocation('France', 'Paris', '🇫🇷', 78),
  VpnLocation('Netherlands', 'Amsterdam', '🇳🇱', 81),
  VpnLocation('Australia', 'Sydney', '🇦🇺', 95),
  VpnLocation('Japan', 'Tokyo', '🇯🇵', 102),
  VpnLocation('Singapore', 'Singapore', '🇸🇬', 110),
  VpnLocation('Sweden', 'Stockholm', '🇸🇪', 118),
  VpnLocation('Switzerland', 'Zurich', '🇨🇭', 124),
  VpnLocation('Turkey', 'Istanbul', '🇹🇷', 132),
];

class NovaHome extends StatefulWidget {
  const NovaHome({super.key, required this.lightMode, required this.onThemeChanged});
  final bool lightMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<NovaHome> createState() => _NovaHomeState();
}

class _NovaHomeState extends State<NovaHome> {
  int _tab = 0;
  VpnLocation _selected = _locations.first;
  bool _connectedPreview = false;
  bool _autoConnect = false;
  bool _killSwitch = false;

  void _selectLocation(VpnLocation location) {
    setState(() {
      _selected = location;
      _tab = 0;
      _connectedPreview = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homePage(),
      _locationsPage(),
      _settingsPage(),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _tab, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        backgroundColor: widget.lightMode ? Colors.white : const Color(0xFF08172B),
        indicatorColor: _blue.withValues(alpha: .18),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.shield_outlined), selectedIcon: Icon(Icons.shield), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.public), label: 'Locations'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _homePage() => LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 30),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _header(),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: _choiceButton(Icons.bolt, 'Auto', onTap: () => _selectLocation(_locations.first))),
                const SizedBox(width: 12),
                Expanded(child: _choiceButton(Icons.location_on, 'Select location', onTap: () => setState(() => _tab = 1))),
              ]),
              const SizedBox(height: 16),
              _locationCard(_selected, onTap: () => setState(() => _tab = 1)),
              const SizedBox(height: 18),
              SizedBox(
                height: 300,
                child: Stack(alignment: Alignment.center, children: [
                  const Positioned.fill(child: _NightLandscape()),
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    GestureDetector(
                      onTap: _toggleConnectionPreview,
                      child: Container(
                        width: 154,
                        height: 154,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: [_cyan, _blue, _purple]),
                          boxShadow: [
                            BoxShadow(color: _blue.withValues(alpha: .42), blurRadius: 38, spreadRadius: 7),
                            const BoxShadow(color: Colors.black54, blurRadius: 0, spreadRadius: 8),
                          ],
                          border: Border.all(color: const Color(0xFF06162B), width: 9),
                        ),
                        child: Icon(_connectedPreview ? Icons.check_rounded : Icons.power_settings_new,
                            size: 66, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(_connectedPreview ? 'Preview connected' : 'Tap to connect',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 5),
                    const Text('UI preview only — no VPN tunnel', style: TextStyle(color: _muted, fontSize: 11)),
                  ]),
                ]),
              ),
              const SizedBox(height: 14),
              _privacyCard(),
              const SizedBox(height: 14),
              _adPlaceholder(),
            ]),
          ),
        );
      });

  Widget _header() => Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(colors: [_cyan, _blue, _purple]),
          ),
          child: const Icon(Icons.shield, color: Colors.white, size: 25),
        ),
        const SizedBox(width: 10),
        const Text('Nova', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
        const Text('VPN', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: _cyan)),
        const Spacer(),
        IconButton(onPressed: () => setState(() => _tab = 2), icon: const Icon(Icons.settings_outlined)),
      ]);

  Widget _choiceButton(IconData icon, String label, {required VoidCallback onTap}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: _blue.withValues(alpha: .22))),
          child: Row(children: [Icon(icon, size: 19, color: _cyan), const SizedBox(width: 8), Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))), const Icon(Icons.keyboard_arrow_down, size: 18, color: _muted)]),
        ),
      );

  Widget _locationCard(VpnLocation location, {required VoidCallback onTap}) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(colors: [Color(0xFF102D55), _panel]),
            border: Border.all(color: _blue.withValues(alpha: .35)),
          ),
          child: Row(children: [
            Text(location.flag, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(location.country, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(location.city, style: const TextStyle(color: _muted, fontSize: 12))])),
            const Icon(Icons.signal_cellular_alt, color: Color(0xFF20DCA1)),
          ]),
        ),
      );

  Widget _privacyCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(20), border: Border.all(color: _cyan.withValues(alpha: .24))),
        child: const Row(children: [
          Icon(Icons.verified_user_outlined, color: _cyan, size: 28),
          SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Your privacy matters', style: TextStyle(fontWeight: FontWeight.w700)), SizedBox(height: 5), Text('Secure  •  Fast  •  Reliable', style: TextStyle(color: _muted, fontSize: 12))])),
        ]),
      );

  Widget _adPlaceholder() => Container(
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: _panel.withValues(alpha: .72), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
        child: const Text('Ad space • Advertisement will appear here', style: TextStyle(color: _muted, fontSize: 11)),
      );

  Widget _locationsPage() => Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 14), child: Row(children: [const Icon(Icons.arrow_back), const SizedBox(width: 16), const Text('Select Location', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700))])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: TextField(decoration: InputDecoration(hintText: 'Search country...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: _panel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)))),
        const SizedBox(height: 8),
        Expanded(child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
          itemCount: _locations.length,
          separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
          itemBuilder: (context, index) {
            final location = _locations[index];
            final selected = location == _selected;
            return ListTile(
              onTap: () => _selectLocation(location),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              leading: Text(location.flag, style: const TextStyle(fontSize: 27)),
              title: Text(location.country, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text(location.city, style: const TextStyle(color: _muted, fontSize: 12)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text('${location.ping} ms', style: const TextStyle(color: Color(0xFF20DCA1), fontSize: 12)), const SizedBox(width: 9), Icon(selected ? Icons.check_circle : Icons.chevron_right, color: selected ? _cyan : _muted, size: 20)]),
              tileColor: selected ? _blue.withValues(alpha: .12) : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            );
          },
        )),
      ]);

  Widget _settingsPage() => ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 24), children: [
        const Text('Settings', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
        const SizedBox(height: 22),
        const _SectionTitle('APP SETTINGS'),
        const SizedBox(height: 10),
        _settingsCard([
          _SettingsRow(icon: Icons.palette_outlined, color: _blue, title: 'Theme', subtitle: widget.lightMode ? 'Light mode' : 'Dark mode', trailing: Switch(value: widget.lightMode, onChanged: widget.onThemeChanged)),
          _SettingsRow(icon: Icons.bolt, color: const Color(0xFFFFBD3D), title: 'Auto-Connect', subtitle: 'Connect when you open the app', trailing: Switch(value: _autoConnect, onChanged: (value) => setState(() => _autoConnect = value)),
          _SettingsRow(icon: Icons.shield_outlined, color: const Color(0xFFFF5F8F), title: 'Kill Switch', subtitle: 'Keep traffic safe if disconnected', trailing: Switch(value: _killSwitch, onChanged: (value) => setState(() => _killSwitch = value)),
        ]),
        const SizedBox(height: 24),
        const _SectionTitle('ABOUT & SUPPORT'),
        const SizedBox(height: 10),
        _settingsCard([
          const _SettingsRow(icon: Icons.privacy_tip_outlined, color: _cyan, title: 'Privacy Policy', subtitle: 'Read our policy'),
          const _SettingsRow(icon: Icons.description_outlined, color: _purple, title: 'Terms of Service', subtitle: 'Read our terms'),
          const _SettingsRow(icon: Icons.help_outline, color: _blue, title: 'Support', subtitle: 'Get help'),
        ]),
        const SizedBox(height: 18),
        const _adPlaceholder(),
        const SizedBox(height: 18),
        const Center(child: Text('NovaVPN • UI prototype', style: TextStyle(color: _muted, fontSize: 12))),
      ]);

  Widget _settingsCard(List<Widget> children) => Container(
        decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
        child: Column(children: [for (var i = 0; i < children.length; i++) ...[children[i], if (i != children.length - 1) const Divider(height: 1, indent: 64, endIndent: 16, color: Colors.white10)]]),
      );

  void _toggleConnectionPreview() {
    setState(() => _connectedPreview = !_connectedPreview);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preview only: this build does not create a VPN connection.')));
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(title, style: const TextStyle(color: _muted, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w700));
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.icon, required this.color, required this.title, required this.subtitle, this.trailing});
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => ListTile(
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: .15), child: Icon(icon, color: color, size: 20)),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: _muted)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: _muted),
      );
}

class _NightLandscape extends StatelessWidget {
  const _NightLandscape();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _LandscapePainter());
}

class _LandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x0008172E), Color(0xAA102D66), Color(0xFF07172D)]).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);
    final stars = Paint()..color = const Color(0xFF7CDFFF).withValues(alpha: .7);
    for (var i = 0; i < 36; i++) {
      final x = (i * 73.0 + 17) % size.width;
      final y = (i * 37.0 + 12) % (size.height * .58);
      canvas.drawCircle(Offset(x, y), i % 4 == 0 ? 1.3 : .7, stars);
    }
    final mountain = Paint()..shader = const LinearGradient(colors: [Color(0xFF314A9A), Color(0xFF091A39)], begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(Offset.zero & size);
    final path = Path()..moveTo(0, size.height * .66)..lineTo(size.width * .2, size.height * .36)..lineTo(size.width * .31, size.height * .55)..lineTo(size.width * .52, size.height * .25)..lineTo(size.width * .77, size.height * .62)..lineTo(size.width, size.height * .42)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(path, mountain);
    final lower = Path()..moveTo(0, size.height * .82)..lineTo(size.width * .22, size.height * .59)..lineTo(size.width * .44, size.height * .79)..lineTo(size.width * .68, size.height * .51)..lineTo(size.width, size.height * .8)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(lower, Paint()..color = const Color(0xFF08182F));
    canvas.drawRect(Rect.fromLTWH(0, size.height * .87, size.width, size.height * .13), Paint()..shader = const LinearGradient(colors: [Color(0x0013BDF5), Color(0x4425B8FF)]).createShader(Offset.zero & size));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
