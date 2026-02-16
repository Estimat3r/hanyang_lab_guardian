import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reagent_info.dart';

class RecentStore {
  static const _key = 'recent_reagents_v1';
  static const _maxItems = 5;

  /// 최근 목록 불러오기 (최신이 맨 앞)
  static Future<List<ReagentInfo>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final list = <ReagentInfo>[];

    for (final s in raw) {
      try {
        final map = jsonDecode(s) as Map<String, dynamic>;
        list.add(ReagentInfo.fromJson(map));
      } catch (_) {
        // 깨진 데이터는 무시
      }
    }
    return list;
  }

  /// 최근 목록에 추가 (중복 제거 + 5개 유지)
  static Future<void> add(ReagentInfo item) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    // item을 JSON으로 저장하되, "같은 chemicalName"이면 기존 항목 제거
    final newJson = jsonEncode(_toJson(item));
    final upperName = item.chemicalName.trim().toUpperCase();

    final filtered = raw.where((s) {
      try {
        final map = jsonDecode(s) as Map<String, dynamic>;
        final name = (map['chemical_name'] ?? '').toString().trim().toUpperCase();
        return name != upperName;
      } catch (_) {
        // 깨진 항목은 제거
        return false;
      }
    }).toList();

    // 최신을 맨 앞에
    final updated = [newJson, ...filtered];

    // 최대 5개
    if (updated.length > _maxItems) {
      updated.removeRange(_maxItems, updated.length);
    }

    await prefs.setStringList(_key, updated);
  }

  /// ✅ chemical_name 기준으로 특정 항목 삭제 (스와이프 삭제용)
  static Future<void> removeByChemicalName(String chemicalName) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];

    final target = chemicalName.trim().toUpperCase();

    final filtered = raw.where((s) {
      try {
        final map = jsonDecode(s) as Map<String, dynamic>;
        final name = (map['chemical_name'] ?? '').toString().trim().toUpperCase();
        return name != target;
      } catch (_) {
        // 깨진 항목은 제거
        return false;
      }
    }).toList();

    await prefs.setStringList(_key, filtered);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// ReagentInfo -> JSON (MVP 저장용)
  static Map<String, dynamic> _toJson(ReagentInfo r) {
    return {
      "chemical_name": r.chemicalName,
      "korean_name": r.koreanName,
      "summary": r.summary,
      "risk_level": r.riskLevel,
      // MVP에서는 disposalCategory를 disposal_guide에 저장하는 방식 유지
      "disposal_guide": r.disposalCategory,
      "reaction_check": r.reactionCheck,
    };
  }
}
