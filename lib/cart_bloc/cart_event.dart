part of 'cart_bloc.dart';

/// 购物车事件的密封类。
/// 确保所有购物车事件都在此定义，便于穷尽性检查。
sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

/// 添加商品到购物车的事件。
final class CartItemAdded extends CartEvent {
  final String itemId;
  final int quantity;

  const CartItemAdded(this.itemId, this.quantity);

  @override
  List<Object> get props => [itemId, quantity];
}

/// 从购物车移除商品的事件。
final class CartItemRemoved extends CartEvent {
  final String itemId;
  final int quantity; // 移除的数量，如果为 0 或负数，则完全移除

  const CartItemRemoved(this.itemId, {this.quantity = 1});

  @override
  List<Object> get props => [itemId, quantity];
}

/// 清空购物车的事件。
final class CartCleared extends CartEvent {
  const CartCleared();

  @override
  List<Object> get props => [];
}
