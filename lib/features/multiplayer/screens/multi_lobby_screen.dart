import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/multi_game_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/level_data.dart';
import '../../../core/services/audio_service.dart';
import 'multi_game_screen.dart';
import 'wifi_lobby_screen.dart';

enum MultiMode { oneVsOne, twoVsTwo, threeVsThree }
enum _ConnType { sameDevice, wifi, internet }

class MultiLobbyScreen extends StatefulWidget {
  const MultiLobbyScreen({super.key});

  @override
  State<MultiLobbyScreen> createState() => _MultiLobbyScreenState();
}

class _MultiLobbyScreenState extends State<MultiLobbyScreen> {
  _ConnType _connType = _ConnType.sameDevice;
  MultiMode _mode = MultiMode.oneVsOne;
  int _selectedLevel = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel('연결 방식'),
                      const SizedBox(height: 12),
                      _ConnTypeSelector(
                        selected: _connType,
                        onChanged: (t) => setState(() => _connType = t),
                      ),
                      const SizedBox(height: 28),
                      if (_connType == _ConnType.sameDevice) ...[
                        _SectionLabel('게임 모드'),
                        const SizedBox(height: 12),
                        _ModeSelector(
                          mode: _mode,
                          onChanged: (m) => setState(() => _mode = m),
                        ),
                        const SizedBox(height: 28),
                        _SectionLabel('레벨 선택'),
                        const SizedBox(height: 12),
                        _LevelPicker(
                          selected: _selectedLevel,
                          onChanged: (l) => setState(() => _selectedLevel = l),
                        ),
                        const SizedBox(height: 36),
                        _StartButton(onTap: _startGame),
                      ] else if (_connType == _ConnType.wifi) ...[
                        _WifiEntryButton(
                          onTap: () {
                            AudioService.instance.playUIClick();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const WifiLobbyScreen()),
                            );
                          },
                        ),
                      ] else ...[
                        _ComingSoonCard(label: '🌐 인터넷 멀티플레이'),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startGame() {
    AudioService.instance.playUIClick();

    if (_mode != MultiMode.oneVsOne) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('2v2 / 3v3 는 준비 중입니다 🔧'),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => MultiGameProvider(),
          child: MultiGameScreen(level: _selectedLevel, stage: 1),
        ),
      ),
    );
  }
}

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
            '멀티 플레이',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
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
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final MultiMode mode;
  final ValueChanged<MultiMode> onChanged;

  const _ModeSelector({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const modes = [
      (MultiMode.oneVsOne, '1 vs 1', '👤 vs 👤', '2명'),
      (MultiMode.twoVsTwo, '2 vs 2', '👥 vs 👥', '4명'),
      (MultiMode.threeVsThree, '3 vs 3', '👨‍👩‍👧 vs 👨‍👩‍👧', '6명'),
    ];

    return Row(
      children: modes.map((m) {
        final selected = mode == m.$1;
        final isAvailable = m.$1 == MultiMode.oneVsOne;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onChanged(m.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: selected ? AppColors.primaryGradient : null,
                  color: selected ? null : AppColors.surface,
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : AppColors.primary.withValues(alpha: 0.2),
                  ),
                  boxShadow: selected
                      ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 12)]
                      : [],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        Text(m.$3, style: TextStyle(fontSize: 22, color: isAvailable ? null : Colors.white38)),
                        const SizedBox(height: 4),
                        Text(
                          m.$2,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: selected
                                ? Colors.white
                                : isAvailable
                                    ? AppColors.textSecondary
                                    : AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          m.$4,
                          style: TextStyle(
                            fontSize: 10,
                            color: selected ? Colors.white70 : AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    if (!isAvailable)
                      Positioned(
                        top: 2,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('준비중', style: TextStyle(fontSize: 8, color: Colors.white38)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
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
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: 10,
      itemBuilder: (_, i) {
        final lv = i + 1;
        final isSelected = lv == selected;
        final cfg = LevelData.levels[i];
        return GestureDetector(
          onTap: () => onChanged(lv),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isSelected ? AppColors.goldGradient : null,
              color: isSelected ? null : AppColors.surface,
              border: Border.all(
                color: isSelected ? Colors.transparent : AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$lv',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${cfg.gridCols}×${cfg.gridRows}',
                  style: TextStyle(
                    fontSize: 9,
                    color: isSelected ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onTap;
  const _StartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('👾', style: TextStyle(fontSize: 22)),
            SizedBox(width: 10),
            Text(
              '게임 시작!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0);
  }
}

// ─── 연결 방식 선택 ───────────────────────────────────────────────────────────

class _ConnTypeSelector extends StatelessWidget {
  final _ConnType selected;
  final ValueChanged<_ConnType> onChanged;
  const _ConnTypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = [
      (_ConnType.sameDevice, '📱', '같은 기기', true),
      (_ConnType.wifi,       '📶', '와이파이',  true),
      (_ConnType.internet,   '🌐', '인터넷',    false),
    ];
    return Row(
      children: items.map((item) {
        final sel = selected == item.$1;
        final available = item.$4;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: available ? () => onChanged(item.$1) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: sel ? AppColors.primaryGradient : null,
                  color: sel ? null : AppColors.surface,
                  border: Border.all(
                    color: sel ? Colors.transparent : AppColors.primary.withValues(alpha: 0.2),
                  ),
                  boxShadow: sel ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 12)] : [],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      children: [
                        Text(item.$2, style: TextStyle(fontSize: 22, color: available ? null : Colors.white24)),
                        const SizedBox(height: 4),
                        Text(item.$3, style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800,
                          color: sel ? Colors.white : (available ? AppColors.textSecondary : AppColors.textSecondary.withValues(alpha: 0.4)),
                        )),
                      ],
                    ),
                    if (!available)
                      Positioned(
                        top: 2, right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(6)),
                          child: const Text('준비중', style: TextStyle(fontSize: 8, color: Colors.white38)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WifiEntryButton extends StatelessWidget {
  final VoidCallback onTap;
  const _WifiEntryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: const Column(
          children: [
            Text('📶', style: TextStyle(fontSize: 36)),
            SizedBox(height: 10),
            Text('와이파이 게임 설정', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1,
            )),
            SizedBox(height: 4),
            Text('방 만들기 / 방 참가', style: TextStyle(fontSize: 13, color: Colors.white70)),
          ],
        ),
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }
}

class _ComingSoonCard extends StatelessWidget {
  final String label;
  const _ComingSoonCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          const Icon(Icons.construction_rounded, color: Colors.white24, size: 40),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white38)),
          const SizedBox(height: 6),
          const Text('곧 출시 예정입니다', style: TextStyle(fontSize: 13, color: Colors.white24)),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 400.ms);
  }
}
