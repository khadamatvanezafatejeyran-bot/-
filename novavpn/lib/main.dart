import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const NovaVpnApp());

const _navy = Color(0xFF061226);
const _panel = Color(0xFF0D1D35);
const _blue = Color(0xFF168BFF);
const _cyan = Color(0xFF00D5E8);
const _purple = Color(0xFF764BFF);
const _muted = Color(0xFF91A5C3);
const _wireGuard = MethodChannel('com.novavpn/wireguard');

class NovaVpnApp extends StatelessWidget {
  const NovaVpnApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'NovaVPN',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: _navy,
          colorScheme: ColorScheme.fromSeed(seedColor: _blue, brightness: Brightness.dark, surface: _panel),
          useMaterial3: true,
        ),
        home: const NovaHome(),
      );
}

class NovaHome extends StatefulWidget {
  const NovaHome({super.key});

  @override
  State<NovaHome> createState() => _NovaHomeState();
}

class _NovaHomeState extends State<NovaHome> {
  final _configController = TextEditingController();
  bool _connecting = false;
  bool _connected = false;
  String? _error;
  String _server = 'WireGuard server';

  @override
  void dispose() {
    _configController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (_connected) {
      await _disconnect();
      return;
    }
    if (_configController.text.trim().isEmpty) {
      await _editConfig();
      return;
    }
    setState(() {
      _connecting = true;
      _error = null;
    });
    try {
      await _wireGuard.invokeMethod<void>('connect', {'config': _configController.text});
      if (!mounted) return;
      setState(() {
        _connected = true;
        _connecting = false;
        _error = null;
      });
      _configController.clear();
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _connecting = false;
        _error = error.message ?? 'WireGuard connection failed.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _connecting = false;
        _error = 'Unable to start the VPN. Check the configuration and try again.';
      });
    }
  }

  Future<void> _disconnect() async {
    setState(() {
      _connecting = true;
      _error = null;
    });
    try {
      await _wireGuard.invokeMethod<void>('disconnect');
      if (!mounted) return;
      setState(() {
        _connected = false;
        _connecting = false;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _connecting = false;
        _error = error.message ?? 'Unable to disconnect cleanly.';
      });
    }
  }

  Future<void> _editConfig() async {
    final controller = TextEditingController(text: _configController.text);
    var obscure = true;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('WireGuard configuration'),
          content: SizedBox(
            width: 520,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('Paste the complete [Interface] and [Peer] config. It stays in app memory only and is not saved or logged. Never paste it into chat or GitHub.', style: TextStyle(color: _muted, fontSize: 12)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                minLines: 5,
                maxLines: 9,
                autocorrect: false,
                enableSuggestions: false,
                obscureText: obscure,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                decoration: InputDecoration(
                  hintText: '[Interface]\nPrivateKey = …\nAddress = …\nDNS = …\n\n[Peer]\nPublicKey = …\nEndpoint = …\nAllowedIPs = …',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    tooltip: obscure ? 'Show config' : 'Hide config',
                    icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setDialogState(() => obscure = !obscure),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text('For full traffic routing, confirm IPv4 and IPv6 forwarding with your VPN provider.', style: TextStyle(color: _muted, fontSize: 11)),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                _configController.text = controller.text.trim();
                final endpoint = RegExp(r'^Endpoint\s*=\s*(.+)$', multiLine: true).firstMatch(controller.text)?.group(1)?.trim();
                if (endpoint != null) _server = endpoint;
                Navigator.pop(dialogContext);
                setState(() => _error = null);
              },
              child: const Text('Use config'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [_cyan, _blue, _purple])),
                  child: const Icon(Icons.shield_rounded, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Text('Nova', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const Text('VPN', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _cyan)),
                const Spacer(),
                IconButton(onPressed: _editConfig, icon: const Icon(Icons.tune_rounded), tooltip: 'Configure WireGuard'),
              ]),
              const SizedBox(height: 24),
              _serverCard(),
              const SizedBox(height: 18),
              SizedBox(
                height: 350,
                child: Stack(alignment: Alignment.center, children: [
                  const Positioned.fill(child: _NightLandscape()),
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Semantics(
                      button: true,
                      label: _connected ? 'Disconnect VPN' : 'Connect VPN',
                      child: GestureDetector(
                        onTap: _connecting ? null : _connect,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 164,
                          height: 164,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: _connected ? [const Color(0xFF20DCA1), _blue, _purple] : [_cyan, _blue, _purple]),
                            border: Border.all(color: const Color(0xFF07162A), width: 10),
                            boxShadow: [BoxShadow(color: (_connected ? const Color(0xFF20DCA1) : _blue).withValues(alpha: .42), blurRadius: 38, spreadRadius: 7)],
                          ),
                          child: Center(child: _connecting ? const CircularProgressIndicator(color: Colors.white) : Icon(_connected ? Icons.check_rounded : Icons.power_settings_new_rounded, color: Colors.white, size: 70)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(_connecting ? 'Connecting…' : _connected ? 'Connected' : 'Tap to connect', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(_connected ? 'WireGuard tunnel active' : 'WireGuard • device VPN', style: const TextStyle(color: _muted, fontSize: 12)),
                  ]),
                ]),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFF4A1725), borderRadius: BorderRadius.circular(14)),
                  child: Text(_error!, style: const TextStyle(color: Color(0xFFFFB8C2), fontSize: 13)),
                ),
              ],
              const SizedBox(height: 14),
              _infoCard(Icons.verified_user_outlined, 'Private configuration', 'VPN config is not bundled with the app or written to Git.'),
              const SizedBox(height: 12),
              _infoCard(Icons.route_outlined, 'Full tunnel routes', 'WireGuard uses the AllowedIPs supplied in your configuration.'),
              const SizedBox(height: 16),
              Container(
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
                child: const Text('Advertisement space • not configured', style: TextStyle(color: _muted, fontSize: 12)),
              ),
              const SizedBox(height: 14),
              const Text('Use only with a VPN server you are authorized to access. Check the server supports all configured routes before relying on the tunnel.', textAlign: TextAlign.center, style: TextStyle(color: _muted, fontSize: 11)),
            ],
          ),
        ),
      );

  Widget _serverCard() => InkWell(
        onTap: _connected ? null : _editConfig,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: _blue.withValues(alpha: .35))),
          child: Row(children: [
            const Icon(Icons.public, color: _cyan, size: 27),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('WireGuard endpoint', style: TextStyle(color: _muted, fontSize: 11)), const SizedBox(height: 4), Text(_server, style: const TextStyle(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)])),
            Icon(_connected ? Icons.lock_rounded : Icons.edit_outlined, color: _connected ? const Color(0xFF20DCA1) : _muted, size: 20),
          ]),
        ),
      );

  Widget _infoCard(IconData icon, String title, String subtitle) => Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
        child: Row(children: [Icon(icon, color: _cyan, size: 26), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12))]))]),
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
    final bounds = Offset.zero & size;
    canvas.drawRect(bounds, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF091A34), Color(0xFF163B70), Color(0xFF07172D)]).createShader(bounds));
    final starPaint = Paint()..color = const Color(0xFF8EEAFF).withValues(alpha: .7);
    for (var index = 0; index < 32; index++) {
      canvas.drawCircle(Offset((index * 71.0 + 13) % size.width, (index * 43.0 + 11) % (size.height * .55)), index % 4 == 0 ? 1.2 : .7, starPaint);
    }
    final distant = Path()..moveTo(0, size.height * .70)..lineTo(size.width * .20, size.height * .39)..lineTo(size.width * .34, size.height * .62)..lineTo(size.width * .55, size.height * .28)..lineTo(size.width * .80, size.height * .65)..lineTo(size.width, size.height * .43)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(distant, Paint()..color = const Color(0xFF1B376C));
    final foreground = Path()..moveTo(0, size.height * .82)..lineTo(size.width * .20, size.height * .61)..lineTo(size.width * .40, size.height * .78)..lineTo(size.width * .70, size.height * .56)..lineTo(size.width, size.height * .78)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(foreground, Paint()..color = const Color(0xFF08182F));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
