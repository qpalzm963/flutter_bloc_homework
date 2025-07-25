import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'lottery_event.dart';
part 'lottery_state.dart';

class LotteryBloc extends Bloc<LotteryEvent, LotteryState> {
  LotteryBloc() : super(const LotteryState()) {
    on<AddParticipant>(_onAddParticipant);
    on<StartDraw>(_onStartDraw);
    on<ResetLottery>(_onResetLottery);
  }

  void _onAddParticipant(AddParticipant event, Emitter<LotteryState> emit) {
    final updatedParticipants = List<String>.from(state.participants);
    if (!updatedParticipants.contains(event.name)) {
      // 避免重复添加
      updatedParticipants.add(event.name);
    }
    emit(state.copyWith(participants: updatedParticipants));
  }

  Future<void> _onStartDraw(StartDraw event, Emitter<LotteryState> emit) async {
    if (state.participants.isEmpty) {
      // 如果没有参与者，不进行抽奖
      return;
    }

    emit(state.copyWith(status: LotteryStatus.drawing, winner: null));

    // 模拟抽奖过程，例如滚动动画
    await Future.delayed(const Duration(seconds: 3)); // 模拟抽奖动画时间

    final random = Random();
    final winnerIndex = random.nextInt(state.participants.length);
    final selectedWinner = state.participants[winnerIndex];

    emit(
      state.copyWith(
        status: LotteryStatus.winnerSelected,
        winner: selectedWinner,
      ),
    );
  }

  void _onResetLottery(ResetLottery event, Emitter<LotteryState> emit) {
    emit(const LotteryState()); // 重置为初始状态
  }
}
