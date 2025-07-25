part of 'counter_bloc.dart';

/// 定义所有与计数器相关的事件。
/// 事件是用户操作或外部因素的抽象，它们被发送到 BLoC 以触发状态变化。
abstract class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object> get props => [];
}

/// 增加计数器的事件。
/// 当用户点击“增加”按钮时，会发送此事件。
class CounterIncrement extends CounterEvent {}

/// 减少计数器的事件。
/// 当用户点击“减少”按钮时，会发送此事件。
class CounterDecrement extends CounterEvent {}