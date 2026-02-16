import 'package:flutter/material.dart';
import '../models/reagent_info.dart';
import '../storage/recent_store.dart';
import 'waste_qr_screen.dart';

class ReagentResultScreen extends StatefulWidget {
  static const route = '/reagent-result';
  const ReagentResultScreen({super.key});

  @override
  State<ReagentResultScreen> createState() => _ReagentResultScreenState();
}

class _ReagentResultScreenState extends State<ReagentResultScreen> {
  bool _saved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // arguments를 didChangeDependencies에서 안전하게 읽고, 1회만 저장
    if (_saved) return;
    final reagent = ModalRoute.of(context)!.settings.arguments as ReagentInfo;

    _saved = true;
    RecentStore.add(reagent); // 최근 5개 저장
  }

  @override
  Widget build(BuildContext context) {
    final reagent = ModalRoute.of(context)!.settings.arguments as ReagentInfo;

    return Scaffold(
      appBar: AppBar(title: const Text('시약 결과 카드')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RiskHeader(reagent: reagent),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  reagent.summary,
                  style: const TextStyle(fontSize: 15, height: 1.3),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('폐기 분류'),
                subtitle: Text(reagent.disposalCategory),
                leading: const Icon(Icons.delete_outline),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, WasteQrScreen.route, arguments: reagent),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('폐액통 QR 찍고 버리기', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskHeader extends StatelessWidget {
  final ReagentInfo reagent;
  const _RiskHeader({required this.reagent});

  @override
  Widget build(BuildContext context) {
    final level = reagent.riskLevel.toUpperCase();

    String emoji = '✅';
    if (level == 'HIGH') emoji = '🚨';
    if (level == 'MEDIUM') emoji = '⚠️';

    // ✅ Risk별 칩 색(가독성 고정)
    Color chipBg = Colors.white;
    Color chipText = Colors.black87;

    if (level == 'HIGH') {
      chipBg = const Color(0xFFFFE6EA);   // 연한 핑크
      chipText = const Color(0xFF8A1021); // 진한 레드
    } else if (level == 'MEDIUM') {
      chipBg = const Color(0xFFFFF1D6);   // 연한 노랑
      chipText = const Color(0xFF6B4A00); // 브라운
    } else {
      chipBg = const Color(0xFFE9F7EF);   // 연한 그린
      chipText = const Color(0xFF0C4A2A); // 진한 그린
    }

    return Card(
      child: ListTile(
        title: Text(
          '${reagent.koreanName}  $emoji',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(reagent.chemicalName),
        trailing: Chip(
          backgroundColor: chipBg,
          side: BorderSide(color: Colors.black.withOpacity(0.08)),
          label: Text(
            'Risk: ${reagent.riskLevel}',
            style: TextStyle(
              color: chipText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
