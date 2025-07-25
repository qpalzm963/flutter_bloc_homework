part of 'lottery_bloc.dart';

sealed class LotteryEvent extends Equatable {
  const LotteryEvent();

  @override
  List<Object> get props => [];
}

/// 添加参与者的事件。
final class AddParticipant extends LotteryEvent {
  final String name;

  const AddParticipant(this.name);

  @override
  List<Object> get props => [name];
}

/// 开始抽奖的事件。
final class StartDraw extends LotteryEvent {
  const StartDraw();
}

/// 重置抽奖的事件（清空参与者和赢家）。
final class ResetLottery extends LotteryEvent {
  const ResetLottery();
}
