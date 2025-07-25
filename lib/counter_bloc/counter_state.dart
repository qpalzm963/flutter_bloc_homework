part of 'counter_bloc.dart';

/// 定义计数器的状态。
/// 状态是 BLoC 处理事件后发出的数据，代表了 UI 在某一时刻应该如何显示。
class CounterState extends Equatable {
  /// 当前的计数。
  final int count;

  const CounterState(this.count);

  @override
  List<Object> get props => [count];
}

/// 计数器的初始状态。
/// 继承自 CounterState，并将初始计数设置为 0。
class CounterInitial extends CounterState {
  const CounterInitial() : super(0);
}