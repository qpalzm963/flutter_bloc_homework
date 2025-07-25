part of 'cart_bloc.dart';

/// 购物车状态。
/// 包含购物车中的商品及其数量。
class CartState extends Equatable {
  /// 购物车中的商品，键为商品ID，值为数量。
  final Map<String, int> items;

  const CartState({this.items = const {}});

  /// 创建一个新的 CartState 实例，并可以覆盖部分属性。
  CartState copyWith({Map<String, int>? items}) {
    return CartState(items: items ?? this.items);
  }

  @override
  List<Object> get props => [items];
}
