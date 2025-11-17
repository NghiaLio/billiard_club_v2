import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/promotion.dart';
import '../../services/database_service.dart';
import 'promotion_state.dart';

class PromotionCubit extends Cubit<PromotionState> {
  PromotionCubit() : super(PromotionInitial());

  Future<void> loadPromotions() async {
    try {
      emit(PromotionLoading());
      final promotions = await DatabaseService.instance.getAllPromotions();
      emit(PromotionLoaded(promotions));
    } catch (e) {
      emit(PromotionError(e.toString()));
    }
  }

  Future<void> loadActivePromotions() async {
    try {
      emit(PromotionLoading());
      final promotions = await DatabaseService.instance.getActivePromotions();
      emit(PromotionLoaded(promotions));
    } catch (e) {
      emit(PromotionError(e.toString()));
    }
  }

  Future<void> addPromotion(Promotion promotion) async {
    try {
      await DatabaseService.instance.insertPromotion(promotion);
      await loadPromotions();
    } catch (e) {
      emit(PromotionError(e.toString()));
    }
  }

  Future<void> updatePromotion(Promotion promotion) async {
    try {
      await DatabaseService.instance.updatePromotion(promotion);
      await loadPromotions();
    } catch (e) {
      emit(PromotionError(e.toString()));
    }
  }

  Future<void> deletePromotion(String id) async {
    try {
      await DatabaseService.instance.deletePromotion(id);
      await loadPromotions();
    } catch (e) {
      emit(PromotionError(e.toString()));
    }
  }

  // Find applicable promotions for a given context
  List<Promotion> findApplicablePromotions({
    String? tableType,
    String? zone,
    String? membershipType,
    required double amount,
    required double playingHours,
  }) {
    final state = this.state;
    if (state is! PromotionLoaded) return [];

    final now = DateTime.now();
    return state.promotions
        .where((promotion) => promotion.isApplicable(
              tableType: tableType,
              zone: zone,
              membershipType: membershipType,
              amount: amount,
              playingHours: playingHours,
              checkTime: now,
            ))
        .toList();
  }
}

