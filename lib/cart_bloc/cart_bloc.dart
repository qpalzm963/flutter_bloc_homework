import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    // 修正构造函数，提供初始状态
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartCleared>(_onCartCleared);
  }

  void _onItemAdded(CartItemAdded event, Emitter<CartState> emit) {
    final updatedItems = Map<String, int>.from(state.items);
    updatedItems[event.itemId] =
        (updatedItems[event.itemId] ?? 0) + event.quantity;
    emit(state.copyWith(items: updatedItems));
  }

  void _onItemRemoved(CartItemRemoved event, Emitter<CartState> emit) {
    final updatedItems = Map<String, int>.from(state.items);
    if (updatedItems.containsKey(event.itemId)) {
      final currentQuantity = updatedItems[event.itemId]!;
      if (event.quantity >= currentQuantity || event.quantity <= 0) {
        updatedItems.remove(event.itemId); // 完全移除
      } else {
        updatedItems[event.itemId] = currentQuantity - event.quantity; // 减少数量
      }
    }
    emit(state.copyWith(items: updatedItems));
  }

  void _onCartCleared(CartCleared event, Emitter<CartState> emit) {
    emit(state.copyWith(items: {})); // 清空购物车
  }
}
