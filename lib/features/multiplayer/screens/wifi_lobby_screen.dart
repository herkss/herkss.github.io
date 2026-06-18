import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/level_data.dart';
import '../../../core/services/audio_service.dart';
import '../providers/wifi_game_provider.dart';
import '../services/network_service.dart';
import 'wifi_game_screen.dart';

class WifiLobbyScreen extends StatefulWidget {
  const WifiLobbyScreen({super.key});

  @override
  State<WifiLobbyScreen> createState() => _WifiLobbyScreenState();
}

class _WifiLobbyScreenState extends State<WifiLobbyScreen> {
  bool _isHost = true;

  // 공통
  NetworkService? _network;
  WifiGameProvider? _provider;

  // Host 상태
  String _localIp = '';
  bool _serverReady = false;
  bool _guestConnected = false;
  int _selectedLevel = 1;

  // Guest 상태
  final _ipCtrl = TextEditingController();
  bool _connecting = false;
  String? _connectError;
  bool _guestReady = false;

  @override
  void initState() {
    super.initState();
    _startHost();
  }

  @override
  void dispose() {
    _provider?.removeListener(_onProviderChange);
    _ipCtrl.dispose();
    // 게임으로 전환되지 않은 경우에만 dispose
    if (_provider == null || _provider!.state != WifiGameState.playing) {
      _network?.dispose();
    }
    super.dispose();
  }

  // ─── Host 흐름 ──────────────────────────────────────────────────────────────

  Future<void> _startHost() async {
    await _cleanup();
    _network = NetworkService();
    try {
      final ip = await _network!.startHost();
      if (!mounted) return;
      setState(() {
        _localIp = ip;
        _serverReady = true;
        _guestConnected = false;
      });
      // 백그라운드에서 게스트 대기
      _network!.waitForGuest().then((_) {
        if (mounted) setState(() => _guestConnected = true);
      });
    } catch (e) {
      if (mounted) setState(() => _serverReady = false);
    }
  }

  void _onStartGame() {
    if (!_guestConnected || _provider != null) return;
    AudioService.instance.playUIClick();
    _provider = WifiGameProvider(_network!);
    _provider!.addListener(_onProviderChange);
    _provider!.hostStartGame(_selectedLevel, 1);
  }

  // ─── Guest 흐름 ─────────────────────────────────────────────────────────────

  Future<void> _connectAsGuest() async {
    final ip = _ipCtrl.text.trim();
    if (ip.isEmpty) return;
    AudioService.instance.playUIClick();

    await _cleanup();
    setState(() { _connecting = true; _connectError = null; });
    _network = NetworkService();

    try {
      await _network!.connectToHost(ip);
      if (!mounted) return;
      _provider = WifiGameProvider(_network!);
      _provider!.addListener(_onProviderChange);
      setState(() { _connecting = false; _guestReady = true; });
    } catch (e) {
      if (!mounted) return;
      await _network!.dispose();
      _network = null;
      setState(() { _connecting = false; _connectError = '연결 실패: 호스트 IP를 확인해주세요'; });
    }
  }

  // ─── 공통 ───────────────────────────────────────────────────────────────────

  Future<void> _cleanup() async {
    _provider?.removeListener(_onProviderChange);
    _provider = null;
    await _network?.dispose();
    _network = null;
    if (mounted) {
      setState(() {
        _serverReady = false;
        _guestConnected = false;
        _connecting = false;
        _connectError = null;
        _guestReady = false;
      });
    }
  }

  void _onProviderChange() {
    if (!mounted) return;
    final p = _provider;
    if (p == null) return;

    if (p.state == WifiGameState.playing) {
      _provider!.removeListener(_onProviderChange);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, a, __) => WifiGameScreen(provider: _provider!),
              transitionsBuilder: (_, a, __, child) =>
                  FadeTransition(opacity: a, child: child),
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        }
      });
    }

    if (p.state == WifiGameState.disconnected && mounted) {
      setState(() {});
    }
  }

  void _switchMode(bool toHost) {
    if (_isHost == toHost) return;
    _cleanup().then((_) {
      if (!mounted) return;
      setState(() => _isHost = toHost);
      if (toHost) _startHost();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(),
              const SizedBox(height: 20),
              _ModeToggle(isHost: _isHost, onChanged: _switchMode),
              const SizedBox(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _isHost ? _buildHostContent() : _buildGuestContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Host UI ────────────────────────────────────────────────────────────────

  Widget _buildHostContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IpCard(
          ip: _localIp,
          port: NetworkService.port,
          ready: _serverReady,
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 24),
        if (_serverReady) ...[
          _StatusRow(
            connected: _guestConnected,
            waitingLabel: '게스트 접속 대기 중...',
            connectedLabel: '게스트 연결됨! 게임을 시작하세요',
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 28),
          if (_guestConnected) ...[
            _SectionLabel('레벨 선택'),
            const SizedBox(height: 12),
            _LevelPicker(
              selected: _selectedLevel,
              onChanged: (l) => setState(() => _selectedLevel = l),
            ).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: 32),
            _StartButton(
              enabled: _guestConnected,
              onTap: _onStartGame,
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0),
          ],
        ],
      ],
    );
  }

  // ─── Guest UI ───────────────────────────────────────────────────────────────

  Widget _buildGuestContent() {
    if (_guestReady) {
      return _WaitingForHost()
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.2, end: 0);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('호스트 IP 주소 입력'),
        const SizedBox(height: 12),
        _IpInput(
          controller: _ipCtrl,
          enabled: !_connecting,
        ),
        if (_connectError != null) ...[
          const SizedBox(height: 8),
          Text(
            _connectError!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
          ),
        ],
        const SizedBox(height: 28),
        _ConnectButton(
          connecting: _connecting,
          onTap: _connectAsGuest,
        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0),
        const SizedBox(height: 20),
        const _HintText('호스트 기기의 IP 주소를 입력하세요.\n같은 와이파이 네트워크에 연결되어 있어야 합니다.'),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─── 공통 위젯 ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          ),
          const Text(
            '📶 와이파이 멀티플레이',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool isHost;
  final ValueChanged<bool> onChanged;
  const _ModeToggle({required this.isHost, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _Tab(label: '🏠 방 만들기', selected: isHost, onTap: () => onChanged(true)),
            _Tab(label: '🚪 방 참가', selected: !isHost, onTap: () => onChanged(false)),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13, fontWeight: FontWeight.w700,
        color: AppColors.textSecondary, letterSpacing: 1.2,
      ),
    );
  }
}

class _IpCard extends StatelessWidget {
  final String ip;
  final int port;
  final bool ready;
  const _IpCard({required this.ip, required this.port, required this.ready});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ready ? AppColors.primary.withValues(alpha: 0.5) : Colors.white12,
          width: 1.5,
        ),
        boxShadow: ready ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 16)] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wifi, color: ready ? AppColors.primary : Colors.white30, size: 18),
              const SizedBox(width: 8),
              Text(
                ready ? '서버 준비 완료' : '서버 시작 중...',
                style: TextStyle(
                  fontSize: 13,
                  color: ready ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('IP 주소', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Row(
            children: [
              ShaderMask(
                shaderCallback: (b) => AppColors.goldGradient.createShader(b),
                child: Text(
                  ready ? ip : '...',
                  style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2,
                  ),
                ),
              ),
              const Spacer(),
              if (ready)
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: ip));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('IP 주소가 복사되었습니다'),
                        backgroundColor: AppColors.surface,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, color: AppColors.textSecondary, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '포트: $port',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final bool connected;
  final String waitingLabel;
  final String connectedLabel;
  const _StatusRow({required this.connected, required this.waitingLabel, required this.connectedLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 10, height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: connected ? AppColors.gold : Colors.orange,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          connected ? connectedLabel : waitingLabel,
          style: TextStyle(
            fontSize: 14,
            color: connected ? AppColors.gold : AppColors.textSecondary,
            fontWeight: connected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        if (!connected) ...[
          const SizedBox(width: 8),
          const SizedBox(
            width: 14, height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
          ),
        ],
      ],
    );
  }
}

class _LevelPicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _LevelPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1,
      ),
      itemCount: 10,
      itemBuilder: (_, i) {
        final lv = i + 1;
        final sel = lv == selected;
        return GestureDetector(
          onTap: () => onChanged(lv),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: sel ? AppColors.goldGradient : null,
              color: sel ? null : AppColors.surface,
              border: Border.all(color: sel ? Colors.transparent : AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$lv', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900,
                    color: sel ? Colors.white : AppColors.textPrimary)),
                Text('${LevelData.levels[i].gridCols}×${LevelData.levels[i].gridRows}',
                    style: TextStyle(fontSize: 9, color: sel ? Colors.white70 : AppColors.textSecondary)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StartButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _StartButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: enabled ? AppColors.primaryGradient : null,
          color: enabled ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: enabled ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.45), blurRadius: 20, offset: const Offset(0, 8))] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎮', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text(
              '게임 시작!',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1,
                color: enabled ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IpInput extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  const _IpInput({required this.controller, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.url,
        style: const TextStyle(
          color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 2,
        ),
        decoration: const InputDecoration(
          hintText: '192.168.x.x',
          hintStyle: TextStyle(color: Colors.white24, fontSize: 20, letterSpacing: 1),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: Icon(Icons.router_outlined, color: AppColors.textSecondary),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
        ],
      ),
    );
  }
}

class _ConnectButton extends StatelessWidget {
  final bool connecting;
  final VoidCallback onTap;
  const _ConnectButton({required this.connecting, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: connecting ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: connecting ? null : AppColors.primaryGradient,
          color: connecting ? AppColors.surface : null,
          borderRadius: BorderRadius.circular(18),
          boxShadow: connecting ? [] : [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (connecting)
              const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            else
              const Text('🔌', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text(
              connecting ? '연결 중...' : '연결하기',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaitingForHost extends StatelessWidget {
  const _WaitingForHost();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        const SizedBox(
          width: 56, height: 56,
          child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.gold),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (b) => AppColors.goldGradient.createShader(b),
          child: const Text(
            '연결됨!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '호스트가 게임을 시작하면 자동으로 입장됩니다',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _HintText extends StatelessWidget {
  final String text;
  const _HintText(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.textSecondary, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
