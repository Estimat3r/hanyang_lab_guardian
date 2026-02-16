String parseBinTypeFromQr(String qr) {
  final raw = qr.trim();
  final upper = raw.toUpperCase();

  // ✅ 우리 폐액통 스티커 포맷인지 판정 (최소 조건)
  // 예: HY-LAB-01-ACID
  final looksLikeOurSticker = upper.contains('HY') && upper.contains('LAB');

  // ✅ 우리 스티커가 아니면: 폐액통 QR로 취급하지 않음
  if (!looksLikeOurSticker) return 'Invalid';

  // 알파벳 토큰만 뽑기 (HY, LAB, ACID ...)
  final tokens = RegExp(r'[A-Z]+')
      .allMatches(upper)
      .map((m) => m.group(0)!)
      .toList();

  bool hasAny(List<String> list) => list.any(tokens.contains);

  // ✅ 정상 타입 판정 (우리 스티커라면 타입이 반드시 있어야 함)
  if (hasAny(['ACID', 'ACIDIC'])) return 'Acid';
  if (hasAny(['BASIC', 'BASE', 'ALKALI', 'ALKALINE'])) return 'Basic';
  if (hasAny(['ORGANIC', 'SOLVENT'])) return 'Organic';
  if (hasAny(['OXIDIZER', 'OXIDISER', 'OXIDIZING', 'OXIDISING', 'OXID'])) return 'Oxidizer';

  // ✅ 우리 스티커인데 타입이 없으면 = 스티커 제작 실수
  return 'Invalid';
}

String analyzeMixingSafety({
  required String reagentType, // Acid/Basic/Organic/Oxidizer/Other
  required String binType,      // Acid/Basic/Organic/Oxidizer/Other
}) {
  // 핵심 매트릭스 (MVP)
  if (reagentType == 'Acid' && binType == 'Basic') return 'STOP';
  if (reagentType == 'Basic' && binType == 'Acid') return 'STOP';
  if (reagentType == 'Organic' && binType == 'Oxidizer') return 'STOP';
  if (reagentType == 'Oxidizer' && binType == 'Organic') return 'STOP';

  if (reagentType == binType && reagentType != 'Other') return 'OK';

  // 애매하면 경고
  return 'WARNING';
}
