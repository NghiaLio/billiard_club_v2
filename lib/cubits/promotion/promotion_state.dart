import '../../models/promotion.dart';

abstract class PromotionState {}

class PromotionInitial extends PromotionState {}

class PromotionLoading extends PromotionState {}

class PromotionLoaded extends PromotionState {
  final List<Promotion> promotions;

  PromotionLoaded(this.promotions);
}

class PromotionError extends PromotionState {
  final String message;

  PromotionError(this.message);
}

