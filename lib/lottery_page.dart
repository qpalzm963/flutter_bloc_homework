import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_demo/lottery_bloc/lottery_bloc.dart';
import 'package:map_demo/roulette_wheel.dart'; // 导入轮盘抽奖组件
import 'package:map_demo/name_scroller.dart'; // 导入名字滚动抽奖组件
import 'package:map_demo/name_scroller_bloc.dart'; // 导入名字滚动抽奖组件的 BLoC

enum LotteryDisplayType { roulette, scroller }

class LotteryPage extends StatefulWidget {
  const LotteryPage({super.key});

  @override
  State<LotteryPage> createState() => _LotteryPageState();
}

class _LotteryPageState extends State<LotteryPage> {
  final TextEditingController _nameController = TextEditingController();
  LotteryDisplayType _selectedDisplayType =
      LotteryDisplayType.roulette; // 默认显示轮盘

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NameScrollerBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('抽奖页面')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 添加参与者输入框
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '输入参与者名字',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_nameController.text.isNotEmpty) {
                        context.read<LotteryBloc>().add(
                          AddParticipant(_nameController.text),
                        );
                        _nameController.clear();
                      }
                    },
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    context.read<LotteryBloc>().add(AddParticipant(value));
                    _nameController.clear();
                  }
                },
              ),
              const SizedBox(height: 20),
              // 抽奖类型选择
              SegmentedButton<LotteryDisplayType>(
                segments: const <ButtonSegment<LotteryDisplayType>>[
                  ButtonSegment<LotteryDisplayType>(
                    value: LotteryDisplayType.roulette,
                    label: Text('轮盘'),
                    icon: Icon(Icons.circle),
                  ),
                  ButtonSegment<LotteryDisplayType>(
                    value: LotteryDisplayType.scroller,
                    label: Text('滚动'),
                    icon: Icon(Icons.list),
                  ),
                ],
                selected: <LotteryDisplayType>{_selectedDisplayType},
                onSelectionChanged: (Set<LotteryDisplayType> newSelection) {
                  setState(() {
                    _selectedDisplayType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 20),
              // 参与者列表
              Expanded(
                child: BlocBuilder<LotteryBloc, LotteryState>(
                  buildWhen:
                      (previous, current) =>
                          previous.participants != current.participants,
                  builder: (context, state) {
                    if (state.participants.isEmpty) {
                      return const Center(child: Text('暂无参与者'));
                    }
                    return ListView.builder(
                      itemCount: state.participants.length,
                      itemBuilder: (context, index) {
                        return ListTile(title: Text(state.participants[index]));
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              // 抽奖显示区域
              BlocBuilder<LotteryBloc, LotteryState>(
                buildWhen:
                    (previous, current) =>
                        previous.participants != current.participants ||
                        previous.winner != current.winner ||
                        previous.status != current.status,
                builder: (context, state) {
                  return SizedBox(
                    width: 300,
                    height: 300,
                    child:
                        _selectedDisplayType == LotteryDisplayType.roulette
                            ? Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.topCenter, // 指针在顶部
                              children: [
                                RouletteWheel(
                                  participants: state.participants,
                                  winner: state.winner,
                                  isDrawing:
                                      state.status == LotteryStatus.drawing,
                                ),
                                // 固定在顶部的指针
                                Positioned(
                                  top: -40,
                                  child: CustomPaint(
                                    painter: _PointerPainter(),
                                    size: const Size(20, 30), // 指针大小
                                  ),
                                ),
                              ],
                            )
                            : const NameScroller(),
                  );
                },
              ),
              const SizedBox(height: 20),
              // 抽奖结果和按钮
              BlocConsumer<LotteryBloc, LotteryState>(
                listener: (context, state) {
                  if (state.status == LotteryStatus.winnerSelected &&
                      state.winner != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('恭喜 ${state.winner} 中奖！')),
                    );
                    context.read<NameScrollerBloc>().add(StopScrolling());
                  } else if (state.status == LotteryStatus.drawing) {
                    context.read<NameScrollerBloc>().add(
                      ScrollLoop(
                        // participants: state.participants,
                        // winner: state.winner,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return Column(
                    children: [
                      if (state.status == LotteryStatus.drawing)
                        const CircularProgressIndicator(),
                      if (state.status == LotteryStatus.winnerSelected &&
                          state.winner != null)
                        Text(
                          '中奖者: ${state.winner}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed:
                                state.participants.isEmpty ||
                                        state.status == LotteryStatus.drawing
                                    ? null
                                    : () => context.read<LotteryBloc>().add(
                                      const StartDraw(),
                                    ),
                            child: const Text('开始抽奖'),
                          ),
                          ElevatedButton(
                            onPressed:
                                () => context.read<LotteryBloc>().add(
                                  const ResetLottery(),
                                ),
                            child: const Text('重置'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.red;
    final path =
        Path()
          ..moveTo(size.width / 2, 0) // 顶部中心
          ..lineTo(0, size.height) // 左下角
          ..lineTo(size.width, size.height) // 右下角
          ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
