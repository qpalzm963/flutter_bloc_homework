import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_demo/cart_bloc/cart_bloc.dart'; // 导入 CartBloc

class CartPage extends StatelessWidget {
  CartPage({super.key});
  ScrollController controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shopping Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              controller.animateTo(
                1000,
                duration: Duration(seconds: 3),
                curve: Curves.linear,
              ); // 清空购物车时重置滚动位置
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            // return const Center(child: Text('购物车是空的！'));
          }
          List<Color> colors = [
            Colors.red,
            Colors.green,
            Colors.blue,
            Colors.yellow,
            Colors.orange,
          ];
          return ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 30,
            offAxisFraction: 0,
            diameterRatio: 10,
            magnification: 1,
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                return Container(
                  alignment: Alignment.center,
                  color: colors[index % colors.length],
                  child: Text('index $index'),
                );
              },
              // childCount: 100,
            ),
          );
          return ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final itemId = state.items.keys.elementAt(index);
              final quantity = state.items[itemId]!;
              return ListTile(
                title: Text('商品: $itemId'),
                subtitle: Text('数量: $quantity'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () {
                    // 移除一个数量
                    context.read<CartBloc>().add(
                      CartItemRemoved(itemId, quantity: 1),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 模拟添加商品
          final randomId = 'Item_${DateTime.now().second}';
          context.read<CartBloc>().add(CartItemAdded(randomId, 1));
        },
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }
}
