class ReagentInfo {
  final String chemicalName;
  final String koreanName;
  final String summary; // 쉬운 3줄
  final String riskLevel; // High/Medium/Low
  final String disposalCategory; // Acid/Basic/Organic/Oxidizer/Other
  final Map<String, String> reactionCheck; // acid/base/organic

  const ReagentInfo({
    required this.chemicalName,
    required this.koreanName,
    required this.summary,
    required this.riskLevel,
    required this.disposalCategory,
    required this.reactionCheck,
  });

  factory ReagentInfo.fromJson(Map<String, dynamic> json) {
    final rc = (json['reaction_check'] as Map?)?.cast<String, dynamic>() ?? {};
    return ReagentInfo(
      chemicalName: (json['chemical_name'] ?? '').toString(),
      koreanName: (json['korean_name'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      riskLevel: (json['risk_level'] ?? '').toString(),
      disposalCategory: (json['disposal_guide'] ?? '').toString(), // MVP에서는 disposal_guide에 분류를 실어도 됨
      reactionCheck: rc.map((k, v) => MapEntry(k.toString(), v.toString())),
    );
  }
}
