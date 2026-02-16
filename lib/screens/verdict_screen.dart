import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/reagent_info.dart';

class VerdictScreen extends StatefulWidget {
  static const route = '/verdict';
  const VerdictScreen({super.key});

  @override
  State<VerdictScreen> createState() => _VerdictScreenState();
}

class _VerdictScreenState extends State<VerdictScreen> {
  final FlutterTts _tts = FlutterTts();

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.48);
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final reagent = args['reagent'] as ReagentInfo;
    final decision = (args['decision'] as String).toUpperCase();
    final binType = (args['binType'] as String);

    final ui = VerdictUi.fromDecision(decision, reagent.disposalCategory, binType);
    final bg = ui.background;
    final fg = ui.foreground;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: fg,
        elevation: 0,
        title: const Text('판정 결과'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            children: [
              // ✅ 상단 “큰 판정 카드”
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: ui.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ui.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(ui.emoji, style: const TextStyle(fontSize: 34)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ui.title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: ui.titleColor,
                              height: 1.1,
                            ),
                          ),
                        ),

                        // ✅ BIN 배지(흰 배경 + 검은 글씨로 고정)
                        Chip(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.black.withOpacity(0.08)),
                          label: Text(
                            'BIN: $binType',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ✅ 한 줄 지침(가장 중요)
                    Text(
                      ui.oneLine,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: fg,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ✅ 이유
                    Text(
                      ui.reason,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: fg.withOpacity(0.92),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ✅ 하단 “상세 정보” 카드
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('시약', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(
                        '${reagent.koreanName}  (${reagent.chemicalName})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _InfoPill(label: '시약 성상', value: reagent.disposalCategory)),
                          const SizedBox(width: 8),
                          Expanded(child: _InfoPill(label: '판정', value: decision)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('대체 행동', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(
                        ui.action,
                        style: const TextStyle(fontSize: 14.5, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // ✅ STOP일 때 TTS 버튼
              if (decision == 'STOP') ...[
                OutlinedButton.icon(
                  onPressed: () => _speak(ui.tts),
                  icon: const Icon(Icons.volume_up),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('경고 다시 듣기', style: TextStyle(fontSize: 16)),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: fg,
                    side: BorderSide(color: fg.withOpacity(0.6)),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // ✅ 공통 CTA
              FilledButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('홈으로 돌아가기', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  const _InfoPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

/// ✅ 판정 UI 레이어: “애매한 Other/Invalid”도 제품처럼 말하게
class VerdictUi {
  final String emoji;
  final String title;
  final String oneLine;
  final String reason;
  final String action;
  final String tts;
  final Color background;
  final Color foreground;
  final Color cardColor;
  final Color borderColor;
  final Color titleColor;

  VerdictUi({
    required this.emoji,
    required this.title,
    required this.oneLine,
    required this.reason,
    required this.action,
    required this.tts,
    required this.background,
    required this.foreground,
    required this.cardColor,
    required this.borderColor,
    required this.titleColor,
  });

  static VerdictUi fromDecision(String decision, String reagentType, String binType) {
    if (decision == 'STOP') {
      return VerdictUi(
        emoji: '🚨',
        title: 'STOP — 지금 버리면 위험해요',
        oneLine: '지금은 버리지 말고, 같은 성상 폐액통을 확인하세요.',
        reason: '시약($reagentType)과 폐액통($binType)의 혼합은 발열/반응 위험이 있어요.',
        action: '폐액통 라벨을 다시 확인하고, 안전관리자/TA에게 문의하세요.',
        tts: '위험합니다. 지금은 버리지 마세요. 폐액통을 다시 확인하세요.',
        background: const Color(0xFF2B0F14),
        foreground: Colors.white,
        cardColor: const Color(0xFF3B1119),
        borderColor: const Color(0xFFFFB4C0),
        titleColor: const Color(0xFFFFD1D8),
      );
    }

    if (decision == 'OK') {
      return VerdictUi(
        emoji: '✅',
        title: 'OK — 같은 성상이라 안전해요',
        oneLine: '같은 성상 폐액통으로 천천히 버리세요.',
        reason: '시약($reagentType)과 폐액통($binType)이 같은 분류로 판단돼요.',
        action: '천천히 버리고, 뚜껑을 닫고, 주변에 튄 곳이 없는지 확인하세요.',
        tts: '안전합니다. 같은 성상 폐액통으로 천천히 버리세요.',
        background: const Color(0xFF0E1F16),
        foreground: Colors.white,
        cardColor: const Color(0xFF122B1E),
        borderColor: const Color(0xFF7CE2B3),
        titleColor: const Color(0xFFBFF5DA),
      );
    }

    // WARNING
    return VerdictUi(
      emoji: '⚠️',
      title: 'WARNING — 확인이 필요해요',
      oneLine: '지금은 잠깐 멈추고, 폐액통 라벨을 다시 확인하세요.',
      reason: '시약($reagentType)과 폐액통($binType)의 조합이 확실하지 않아요.',
      action: '폐액통 종류(산/염기/유기/산화제)를 확인하고, 불확실하면 STOP하세요.',
      tts: '주의하세요. 지금은 확인이 필요합니다. 폐액통 라벨을 다시 확인하세요.',
      background: const Color(0xFF241A07),
      foreground: Colors.white,
      cardColor: const Color(0xFF2F210A),
      borderColor: const Color(0xFFFFDB8C),
      titleColor: const Color(0xFFFFE6B3),
    );
  }
}
