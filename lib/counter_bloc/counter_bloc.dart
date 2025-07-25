import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'counter_event.dart';
part 'counter_state.dart';

/// 计数器的 BLoC。
/// 负责处理 CounterEvent 并发出 CounterState。
class CounterBloc extends Bloc<CounterEvent, CounterState> {
  /// 构造函数，初始化 BLoC 并设置初始状态为 CounterInitial。
  /// 同时注册事件处理器。
  CounterBloc() : super(const CounterInitial()) {
    /// 注册 CounterIncrement 事件的处理器。
    /// 当接收到 CounterIncrement 事件时，将当前计数加 1 并发出新的状态。
    on<CounterIncrement>((event, emit) => emit(CounterState(state.count + 1)));

    /// 注册 CounterDecrement 事件的处理器。
    /// 当接收到 CounterDecrement 事件时，将当前计数减 1 并发出新的状态。
    on<CounterDecrement>((event, emit) => emit(CounterState(state.count - 1)));
  }
}