import 'package:flutter/material.dart';

import '../models/reagent_info.dart';
import '../storage/recent_store.dart';
import 'reagent_input_screen.dart';
import 'reagent_result_screen.dart';
import 'waste_qr_screen.dart';

class HomeScreen extends StatefulWidget {
  static const route = '/';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ReagentInfo>> _recentFuture;

  @override
  void initState() {
    super.initState();
    _recentFuture = RecentStore.load();
  }

  Future<void> _refreshRecent() async {
    setState(() {
      _recentFuture = RecentStore.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hanyang Lab-Guardian')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '버리기 전에 3초.\n폭발/화재 위험을 “행동 시점”에 막습니다.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, height: 1.25),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: const [
                  Icon(Icons.shield, size: 26),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '1) 시약 라벨 스캔(OCR)\n2) 폐액통 QR 스캔 → OK / STOP',
                      style: TextStyle(fontWeight: FontWeight.w700, height: 1.25),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          FilledButton.icon(
            onPressed: () async {
              await Navigator.pushNamed(context, ReagentInputScreen.route);
              await _refreshRecent();
            },
            icon: const Icon(Icons.document_scanner),
            label: const Text('시약 스캔 시작'),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Expanded(
                child: Text('최근 스캔 5개', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ),
              TextButton(
                onPressed: () async {
                  await RecentStore.clear();
                  await _refreshRecent();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('최근 기록을 비웠어요.'), duration: Duration(seconds: 2)),
                  );
                },
                child: const Text('비우기'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          FutureBuilder<List<ReagentInfo>>(
            future: _recentFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Row(
                      children: [
                        SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 10),
                        Text('최근 기록 불러오는 중...'),
                      ],
                    ),
                  ),
                );
              }

              final recent = snap.data ?? [];
              if (recent.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('아직 저장된 기록이 없어요.', style: TextStyle(fontWeight: FontWeight.w800)),
                        SizedBox(height: 6),
                        Text('시약을 한 번 분석하면 최근 5개가 여기에 표시돼요.', style: TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ),
                );
              }

              // ✅ 최근 5개: 스와이프 삭제(Dismissible) 적용
              return Column(
                children: recent.take(5).map((r) {
                  return Dismissible(
                    key: ValueKey(r.chemicalName),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE6EA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete, color: Color(0xFF8A1021)),
                    ),
                    onDismissed: (_) async {
                      await RecentStore.removeByChemicalName(r.chemicalName);
                      await _refreshRecent();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${r.koreanName} 기록을 삭제했어요.'), duration: const Duration(seconds: 2)),
                      );
                    },
                    child: _RecentItem(
                      reagent: r,
                      onOpenCard: () async {
                        await Navigator.pushNamed(context, ReagentResultScreen.route, arguments: r);
                        await _refreshRecent();
                      },
                      onQuickQr: () async {
                        await Navigator.pushNamed(context, WasteQrScreen.route, arguments: r);
                        await _refreshRecent();
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RecentItem extends StatelessWidget {
  final ReagentInfo reagent;
  final VoidCallback onOpenCard;
  final VoidCallback onQuickQr;

  const _RecentItem({
    required this.reagent,
    required this.onOpenCard,
    required this.onQuickQr,
  });

  @override
  Widget build(BuildContext context) {
    final level = reagent.riskLevel.toUpperCase();
    String emoji = '✅';
    if (level == 'HIGH') emoji = '🚨';
    if (level == 'MEDIUM') emoji = '⚠️';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${reagent.koreanName}  $emoji',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                ),
                _RiskChip(level: reagent.riskLevel),
              ],
            ),
            const SizedBox(height: 6),
            Text(reagent.chemicalName, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: onOpenCard, child: const Text('결과 카드'))),
                const SizedBox(width: 10),
                Expanded(child: FilledButton(onPressed: onQuickQr, child: const Text('바로 QR'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskChip extends StatelessWidget {
  final String level;
  const _RiskChip({required this.level});

  @override
  Widget build(BuildContext context) {
    final u = level.toUpperCase();

    Color bg = Colors.white;
    Color fg = Colors.black87;

    if (u == 'HIGH') {
      bg = const Color(0xFFFFE6EA);
      fg = const Color(0xFF8A1021);
    } else if (u == 'MEDIUM') {
      bg = const Color(0xFFFFF1D6);
      fg = const Color(0xFF6B4A00);
    } else {
      bg = const Color(0xFFE9F7EF);
      fg = const Color(0xFF0C4A2A);
    }

    return Chip(
      backgroundColor: bg,
      side: BorderSide(color: Colors.black.withOpacity(0.08)),
      label: Text('RISK: $level', style: TextStyle(color: fg, fontWeight: FontWeight.w900)),
    );
  }
}
