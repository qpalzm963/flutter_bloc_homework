import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_demo/bloc/roller_bloc.dart';

class RollerApp extends StatelessWidget {
  const RollerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloc 抽獎滾輪',
      home: BlocProvider(
        create: (_) => RollerBloc(),
        child: const RollerPage(),
      ),
    );
  }
}

class RollerPage extends StatefulWidget {
  const RollerPage({super.key});

  @override
  State<RollerPage> createState() => _RollerPageState();
}

class _RollerPageState extends State<RollerPage> {
  static const itemCount = 20;
  final _controller = FixedExtentScrollController();
  int _lastIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = List.generate(
      itemCount,
      (i) => Colors.primaries[i % Colors.primaries.length].shade200,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('BLoC 抽獎滾輪')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            BlocBuilder<RollerBloc, RollerBlocState>(
              builder: (context, state) {
                return Text(
                  '中獎編號: ${state.currentIndex}',
                  style: const TextStyle(fontSize: 20),
                );
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocConsumer<RollerBloc, RollerBlocState>(
                listener: (context, state) {
                  if (state.status == RollerStateEnum.start) {
                    if (state.speed <= 0.1) {
                      context.read<RollerBloc>().add(RollerLooped());
                    }
                  }
                  // 滾動動畫（只要 currentIndex 變動）
                  if (_controller.hasClients &&
                      state.currentIndex != _lastIndex) {
                    _controller.animateToItem(
                      state.currentIndex,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut,
                    );
                    _lastIndex = state.currentIndex;
                  }
                  // 結果彈窗
                  if (state.status == RollerStateEnum.result &&
                      state.targetIndex != null) {
                    Future.delayed(Duration(seconds: 1)).then(
                      (value) => showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: const Text("🎉 恭喜！"),
                              content: Text("抽到的是 #${state.targetIndex!}"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return ListWheelScrollView.useDelegate(
                    controller: _controller,
                    itemExtent: 50,
                    diameterRatio: 5,
                    offAxisFraction: 0,
                    magnification: 1.15,
                    physics: const NeverScrollableScrollPhysics(),
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        final selected = (index == state.currentIndex);
                        return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                selected ? Colors.orangeAccent : colors[index],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '🎁  index $index',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: selected ? 26 : 18,
                              color: selected ? Colors.white : Colors.black87,
                            ),
                          ),
                        );
                      },
                      childCount: itemCount,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            BlocBuilder<RollerBloc, RollerBlocState>(
              builder: (context, state) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed:
                          state.status == RollerStateEnum.waiting ||
                                  state.status == RollerStateEnum.result
                              ? () {
                                final bloc = context.read<RollerBloc>();
                                bloc.add(RollerStarted());
                                // Future.delayed(const Duration(seconds: 1), () {
                                //   bloc.add(RollerLooped());
                                // });
                                // Future.delayed(const Duration(seconds: 2), () {
                                //   final target = Random().nextInt(itemCount);
                                //   bloc.add(RollerStopped(target));
                                // });
                              }
                              : null,
                      child: const Text('開始抽獎'),
                    ),
                    ElevatedButton(
                      onPressed:
                          state.status == RollerStateEnum.loop ||
                                  state.status == RollerStateEnum.start
                              ? () {
                                final target = Random().nextInt(itemCount);
                                context.read<RollerBloc>().add(
                                  RollerStopped(target),
                                );
                              }
                              : null,
                      child: const Text('手動停止'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
