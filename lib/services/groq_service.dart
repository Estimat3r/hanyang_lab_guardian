import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../models/reagent_info.dart';

class GroqService {
  final String apiKey;
  final bool demoMode;

  GroqService({required this.apiKey, this.demoMode = false});

  // ----------------------------
  // ✅ Public API
  // ----------------------------
  Future<ReagentInfo> analyzeChemicalName(String userInput) async {
    final normalized = _normalize(userInput);

    // ✅ 1) 데모 모드면 무조건 “확정 샘플” 반환
    if (demoMode) {
      return _demoResult(normalized);
    }

    // ✅ 2) 실서비스 모드(원하면 나중에 연결)
    // 지금 MVP에서는 demoMode=true로 쓰고 있으니, 아래는 향후 확장용
    //
    // - 여기서 Groq API 호출해서 JSON 받아오고
    // - ReagentInfo.fromJson으로 파싱하면 됨
    //
    // throw UnimplementedError('Real API mode is not wired for MVP.');
    return _demoResult(normalized); // 안전장치: 혹시 demoMode=false라도 데모 결과로
  }

  // ----------------------------
  // ✅ Demo results (HCl / NaOH / Acetone only)
  // ----------------------------
  ReagentInfo _demoResult(String name) {
    final key = name.toUpperCase();

    // ✅ HCl
    if (key == 'HCL') {
      return ReagentInfo.fromJson(_jsonHcl());
    }

    // ✅ NaOH
    if (key == 'NAOH') {
      return ReagentInfo.fromJson(_jsonNaoh());
    }

    // ✅ Acetone
    if (key == 'ACETONE') {
      return ReagentInfo.fromJson(_jsonAcetone());
    }

    // ✅ 그 외: 지원 안 함(보수적으로 WARNING)
    return ReagentInfo.fromJson(_jsonUnsupported(name));
  }

  String _normalize(String s) => s.trim().replaceAll(' ', '');

  // ----------------------------
  // ✅ Demo JSON payloads
  // (ReagentInfo.fromJson이 기대하는 키 형태에 맞춤)
  // ----------------------------
  Map<String, dynamic> _jsonHcl() => {
        "chemical_name": "Hydrochloric Acid",
        "korean_name": "염산(강한 산)",
        "summary": "⚠️ 피부/눈을 심하게 다치게 할 수 있어요.\n"
            "장갑/보안경을 꼭 착용하세요.\n"
            "염기성 물질과 섞이면 뜨거워지며 위험해요.",
        "risk_level": "High",
        "disposal_guide": "Acid",
        "reaction_check": {"acid": "safe", "base": "mix_danger", "organic": "warning"}
      };

  Map<String, dynamic> _jsonNaoh() => {
        "chemical_name": "Sodium Hydroxide",
        "korean_name": "수산화나트륨(강한 염기)",
        "summary": "⚠️ 피부/눈을 심하게 다치게 할 수 있어요.\n"
            "물에 녹을 때 뜨거워질 수 있어요.\n"
            "산과 섞이면 큰 열이 나서 위험해요.",
        "risk_level": "High",
        "disposal_guide": "Basic",
        "reaction_check": {"acid": "mix_danger", "base": "safe", "organic": "warning"}
      };

  Map<String, dynamic> _jsonAcetone() => {
        "chemical_name": "Acetone",
        "korean_name": "아세톤(유기용제)",
        "summary": "🔥 불이 잘 붙는 액체예요.\n"
            "환기를 잘 해야 해요.\n"
            "산화제와 섞으면 화재 위험이 커져요.",
        "risk_level": "Medium",
        "disposal_guide": "Organic",
        "reaction_check": {"acid": "warning", "base": "warning", "organic": "safe"}
      };

  Map<String, dynamic> _jsonUnsupported(String name) => {
        "chemical_name": name.isEmpty ? "Unknown" : name,
        "korean_name": "지원되지 않는 시약",
        "summary": "⚠️ 이 시약은 현재 MVP에서 지원하지 않아요.\n"
            "데모 안정성을 위해 3종(HCl/NaOH/Acetone)만 허용했어요.\n"
            "실제 사용 시에는 MSDS/담당자 확인이 필요해요.",
        "risk_level": "Medium",
        "disposal_guide": "Other",
        "reaction_check": {"acid": "warning", "base": "warning", "organic": "warning"}
      };
}
