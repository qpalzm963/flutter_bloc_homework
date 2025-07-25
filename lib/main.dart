import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_demo/cart_bloc/cart_bloc.dart';
import 'package:map_demo/cart_page.dart';
import 'package:map_demo/lottery_bloc/lottery_bloc.dart'; // 导入 LotteryBloc
import 'package:map_demo/lottery_page.dart'; // 导入 LotteryPage
import 'package:map_demo/rolller_main.dart';
import 'package:map_demo/simple_bloc_observer.dart'; // 导入 SimpleBlocObserver

void main() {
  Bloc.observer = SimpleBlocObserver(); // 注册 BlocObserver
  runApp(const RollerApp());
}

/// 应用程序的根 Widget。
/// 在这里我们使用 BlocProvider 来提供 LotteryBloc，使其在整个应用树中可用。
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CartBloc(), // 创建并提供 LotteryBloc 实例
      child: MaterialApp(
        title: 'Flutter Lottery App with BLoC',
        theme: ThemeData(primarySwatch: Colors.purple),
        home: CartPage(), // 设置 LotteryPage 作为应用的首页
      ),
    );
  }
}

// 原始的 CartPage, LoginPage, CounterPage, MapSample 和 BookingPage 代码保留在下方以供参考，
// 但在此示例中未被用作 home widget。
// 你可以通过修改 MyApp 中的 home 属性来切换回它们。

/*
import 'package:map_demo/cart_bloc/cart_bloc.dart';
import 'package:map_demo/cart_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shopping Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              context.read<CartBloc>().add(const CartCleared());
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return const Center(child: Text('购物车是空的！'));
          }
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
                    context.read<CartBloc>().add(CartItemRemoved(itemId, quantity: 1));
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

import 'package:map_demo/login_bloc/login_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login with BLoC')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 用户名输入框
            TextField(
              onChanged: (username) =>
                  context.read<LoginBloc>().add(LoginUsernameChanged(username)),
              decoration: const InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            // 密码输入框
            TextField(
              onChanged: (password) =>
                  context.read<LoginBloc>().add(LoginPasswordChanged(password)),
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '密码',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24.0),
            // 登录按钮和状态显示
            BlocConsumer<LoginBloc, LoginState>(
              listener: (context, state) {
                if (state.status == LoginStatus.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('登录成功!')),
                  );
                  // 可以在这里导航到主页
                } else if (state.status == LoginStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('登录失败: ${state.errorMessage}')),
                  );
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    if (state.status == LoginStatus.loading)
                      const CircularProgressIndicator(),
                    if (state.status != LoginStatus.loading)
                      ElevatedButton(
                        onPressed: () =>
                            context.read<LoginBloc>().add(LoginSubmitted()),
                        child: const Text('登录'),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:map_demo/counter_bloc/counter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter with BLoC')),
      body: Center(
        /// BlocBuilder 监听 CounterBloc 的状态变化。
        /// 每当 CounterBloc 发出新的 CounterState 时，BlocBuilder 都会重建其子 Widget。
        child: BlocBuilder<CounterBloc, CounterState>(
          builder: (context, state) {
            return Text(
              'Count: \${state.count}',
              style: Theme.of(context).textTheme.headlineMedium,
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          /// 增加按钮。
          /// 当点击时，通过 context.read<CounterBloc>().add() 发送 CounterIncrement 事件。
          FloatingActionButton(
            heroTag: 'incrementButton',
            onPressed: () => context.read<CounterBloc>().add(CounterIncrement()),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          /// 减少按钮。
          /// 当点击时，通过 context.read<CounterBloc>().add() 发送 CounterDecrement 事件。
          FloatingActionButton(
            heroTag: 'decrementButton',
            onPressed: () => context.read<CounterBloc>().add(CounterDecrement()),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_demo/mapSample.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(23.6, 120.9); // Center of Taiwan

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OneCar Travel Pass'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '路線怎麼走，你說了算，OneCar 幫你接送到底',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '乘客人數',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '停留地區',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '地區',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      Checkbox(value: false, onChanged: (bool? value) {}),
                      const Text('自動安排最佳路線'),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    height: 300, // Adjust map height as needed
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _center,
                        zoom: 7.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // How-to Guide Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '如何使用OneCar',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8.0),
                  _buildHowToStep(
                    '1. 選擇你想停留的區域',
                    'Choose the area you want to stop at',
                  ),
                  _buildHowToStep(
                    '2. 系統自動安排最佳路線',
                    'System automatically arranges the best route',
                  ),
                  _buildHowToStep(
                    '3. 輕鬆預訂，準時接送',
                    'Easy booking, punctual pick-up and drop-off',
                  ),
                ],
              ),
            ),
            // Footer (simplified for now)
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              child: const Text(
                '© Tripool Inc.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowToStep(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(description),
        ],
      ),
    );
  }
}
*/
