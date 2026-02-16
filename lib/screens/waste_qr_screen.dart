import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/reagent_info.dart';
import '../logic/mixing_logic.dart';
import 'verdict_screen.dart';

class WasteQrScreen extends StatefulWidget {
  static const route = '/waste-qr';
  const WasteQrScreen({super.key});

  @override
  State<WasteQrScreen> createState() => _WasteQrScreenState();
}

class _WasteQrScreenState extends State<WasteQrScreen> {
  bool _handled = false;

  // ✅ Invalid QR 스팸 방지용 쿨다운
  DateTime _lastInvalidToast = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Widget build(BuildContext context) {
    final reagent = ModalRoute.of(context)!.settings.arguments as ReagentInfo;

    return Scaffold(
      appBar: AppBar(title: const Text('폐액통 QR 스캔')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_handled) return;

              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;

              final raw = (barcodes.first.rawValue ?? '').trim();
              if (raw.isEmpty) return;

              final binType = parseBinTypeFromQr(raw);

              // ✅ Invalid QR이면: 화면 전환 X, 안내만 띄우고 계속 스캔
              if (binType == 'Invalid') {
                final now = DateTime.now();
                if (now.difference(_lastInvalidToast).inMilliseconds < 1500) return;
                _lastInvalidToast = now;

                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('이 QR은 폐액통 QR이 아니에요. 폐액통 스티커 QR을 찍어주세요.'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }

              // ✅ 정상 QR이면 기존 로직대로 진행
              _handled = true;

              final decision = analyzeMixingSafety(
                reagentType: reagent.disposalCategory,
                binType: binType,
              );

              Navigator.pushReplacementNamed(
                context,
                VerdictScreen.route,
                arguments: {
                  'reagent': reagent,
                  'qr': raw,
                  'binType': binType,
                  'decision': decision,
                },
              );
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('팁', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('QR 예시: HY-LAB-01-ACID / HY-LAB-01-BASIC / HY-LAB-01-ORGANIC'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
