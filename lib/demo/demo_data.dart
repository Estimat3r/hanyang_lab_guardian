import '../models/reagent_info.dart';

class DemoData {
  static const acid = ReagentInfo(
    chemicalName: 'Hydrochloric Acid',
    koreanName: '염산(강한 산)',
    summary: '⚠️ 피부/눈을 심하게 다치게 할 수 있어요.\n장갑/보안경을 꼭 착용하세요.\n염기성 물질과 섞으면 뜨거워지며 위험해요.',
    riskLevel: 'High',
    disposalCategory: 'Acid',
    reactionCheck: {'acid': 'safe', 'base': 'mix_danger', 'organic': 'warning'},
  );

  static const basic = ReagentInfo(
    chemicalName: 'Sodium Hydroxide',
    koreanName: '수산화나트륨(강한 염기)',
    summary: '⚠️ 피부를 녹일 수 있어요.\n장갑/보안경 필수!\n산과 섞으면 뜨거워지며 위험해요.',
    riskLevel: 'High',
    disposalCategory: 'Basic',
    reactionCheck: {'acid': 'mix_danger', 'base': 'safe', 'organic': 'warning'},
  );

  static const organic = ReagentInfo(
    chemicalName: 'Acetone',
    koreanName: '아세톤(유기용제)',
    summary: '🔥 불이 잘 붙는 액체예요.\n환기를 잘 해야 해요.\n산화제와 섞으면 화재 위험이 커져요.',
    riskLevel: 'Medium',
    disposalCategory: 'Organic',
    reactionCheck: {'acid': 'warning', 'base': 'warning', 'organic': 'safe'},
  );
}
