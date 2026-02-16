import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/groq_service.dart';
import '../services/ocr_service.dart';
import 'reagent_result_screen.dart';

class ReagentInputScreen extends StatefulWidget {
  static const route = '/reagent-input';
  const ReagentInputScreen({super.key});

  @override
  State<ReagentInputScreen> createState() => _ReagentInputScreenState();
}

class _ReagentInputScreenState extends State<ReagentInputScreen> {
  final _controller = TextEditingController(text: 'HCl');
  bool _loading = false;

  // OCR 관련
  final _picker = ImagePicker();
  final _ocr = OcrService();
  File? _pickedImage;
  String? _ocrPreview;

  // ✅ OCR 후보(최대 3개)
  List<String> _ocrCandidates = [];

  // ✅ MVP: 허용 시약 3종만
  static const List<String> _allowed = ['HCl', 'NaOH', 'Acetone'];
  String? _inputError; // 허용되지 않는 입력 안내문

  // Groq (MVP: demoMode=true면 API 키 없어도 동작)
  final _service = GroqService(apiKey: 'YOUR_GROQ_API_KEY', demoMode: true);

  // ----------------------------
  // ✅ 입력 검증 유틸
  // ----------------------------
  String _normalize(String s) => s.trim().replaceAll(' ', '');

  bool _isAllowed(String s) {
    final v = _normalize(s);
    if (v.isEmpty) return false;
    return _allowed.any((a) => a.toUpperCase() == v.toUpperCase());
  }

  String? _validate(String s) {
    final v = _normalize(s);
    if (v.isEmpty) return '시약 이름을 입력해 주세요.';
    if (!_isAllowed(v)) {
      return 'MVP에서는 HCl, NaOH, Acetone만 지원해요.\n'
          '데모 안정성을 위해 다른 물질은 막아두었어요.';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    // 초기 검증
    _inputError = _validate(_controller.text);

    // 실시간 검증
    _controller.addListener(() {
      final err = _validate(_controller.text);
      if (err != _inputError) {
        setState(() => _inputError = err);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _ocr.dispose();
    super.dispose();
  }

  // ✅ 실제 분석(입력값을 파라미터로 받아서, controller 덮어쓰기 방지)
  Future<void> _analyzeWithName(String rawName) async {
    final name = _normalize(rawName);

    // 안전장치: 버튼이 비활성화여도 혹시 호출될 수 있으니 한 번 더 막기
    final err = _validate(name);
    if (err != null) {
      if (!mounted) return;
      setState(() => _inputError = err);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), duration: const Duration(seconds: 2)),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await _service.analyzeChemicalName(name);

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.pushNamed(
      context,
      ReagentResultScreen.route,
      arguments: result,
    );
  }

  Future<void> _scanLabelAndFill() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo == null) return;

      setState(() {
        _loading = true;
        _pickedImage = File(photo.path);
        _ocrPreview = null;
        _ocrCandidates = []; // ✅ 이전 후보 지우기
      });

      // ✅ OCR 실행
      final text = await _ocr.recognizeTextFromFile(File(photo.path));

      // ✅ 후보 3개 뽑기
      final candidates = _extractTopCandidates(text);

      if (!mounted) return;
      setState(() {
        _loading = false;
        _ocrPreview = text.isEmpty ? '(인식된 텍스트 없음)' : text;
        _ocrCandidates = candidates;

        // ✅ 1순위 자동 입력
        if (candidates.isNotEmpty) {
          _controller.text = candidates.first;
        }

        // ✅ OCR로 채운 값도 즉시 검증
        _inputError = _validate(_controller.text);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _ocrPreview = 'OCR 실패: 조명/초점/라벨 각도를 바꿔 다시 시도해보세요.';
        _ocrCandidates = [];
      });
    }
  }

  // ✅ OCR 텍스트에서 후보 최대 3개 추출
  List<String> _extractTopCandidates(String raw) {
    final lines = raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    bool isNoise(String s) {
      final u = s.toUpperCase();
      const noise = [
        'WARNING',
        'DANGER',
        'CAUTION',
        'FLAMMABLE',
        'HAZARD',
        'PRECAUTIONS',
        'FIRST AID',
        'WEAR',
        'STORE',
        'READ',
        'SDS',
        'MSDS'
      ];
      return noise.any((k) => u.contains(k));
    }

    final cleaned = lines.where((l) => !isNoise(l)).toList();

    // 1) 화학식 같은 짧은 토큰 우선 (HCl, NaOH 등)
    final formula = RegExp(r'^[A-Za-z]{1,3}\d{0,2}[A-Za-z]{0,3}\d{0,2}$');
    final formulas = cleaned
        .map((l) => l.replaceAll(' ', ''))
        .where((l) => l.length <= 12 && formula.hasMatch(l))
        .toList();

    // 2) 짧은 영문명 (Hydrochloric Acid 등)
    final names = cleaned.where((l) {
      final words = l.split(RegExp(r'\s+'));
      if (l.length < 4 || l.length > 30) return false;
      if (words.length > 4) return false;
      final nonLetters = RegExp(r'[^A-Za-z\s\-]').allMatches(l).length;
      return nonLetters <= 2;
    }).toList();

    // 3) 중복 제거 + 최대 3개
    final merged = <String>[];
    for (final s in [...formulas, ...names]) {
      if (merged.contains(s)) continue;
      merged.add(s);
      if (merged.length == 3) break;
    }
    return merged;
  }

  @override
  Widget build(BuildContext context) {
    final canAnalyze = !_loading && _inputError == null;

    return Scaffold(
      appBar: AppBar(title: const Text('시약 확인')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '라벨을 찍어 시약명을 자동 입력(OCR)하거나, 직접 입력해도 됩니다.\n'
            'MVP는 “데모가 안 끊기는 흐름”이 목표예요.',
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: '시약 이름(예: HCl, NaOH, Acetone)',
              border: const OutlineInputBorder(),
              errorText: _inputError, // ✅ 허용되지 않으면 여기에 메시지 표시
            ),
          ),

          // ✅ OCR 후보 버튼(최대 3개) - 기존 그대로 유지
          if (_ocrCandidates.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _ocrCandidates.map((c) {
                return ActionChip(
                  label: Text(c),
                  onPressed: () {
                    setState(() {
                      _controller.text = c;
                      _inputError = _validate(_controller.text); // ✅ 탭해도 검증
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
          ],

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: _loading ? null : _scanLabelAndFill,
            icon: const Icon(Icons.camera_alt),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('라벨 스캔해서 자동 입력(OCR)', style: TextStyle(fontSize: 16)),
            ),
          ),

          const SizedBox(height: 12),

          FilledButton(
            onPressed: canAnalyze ? () => _analyzeWithName(_controller.text) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: _loading
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('분석하기 (3초 카드)', style: TextStyle(fontSize: 16)),
            ),
          ),

          const SizedBox(height: 12),

          // ✅ 샘플 버튼: controller를 덮어쓰지 않고 바로 분석 (데모 안정성 ↑)
          OutlinedButton(
            onPressed: _loading ? null : () => _analyzeWithName('Acetone'),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('샘플(아세톤)로 바로 보기', style: TextStyle(fontSize: 16)),
            ),
          ),

          if (_pickedImage != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_pickedImage!, height: 180, fit: BoxFit.cover),
            ),
          ],

          if (_ocrPreview != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'OCR 결과(일부):\n${_ocrPreview!.length > 300 ? _ocrPreview!.substring(0, 300) + '...' : _ocrPreview!}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
