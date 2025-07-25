part of 'lottery_bloc.dart';

enum LotteryStatus { initial, drawing, winnerSelected }

class LotteryState extends Equatable {
  final List<String> participants;
  final LotteryStatus status;
  final String? winner;

  const LotteryState({
    this.participants = const [],
    this.status = LotteryStatus.initial,
    this.winner,
  });

  LotteryState copyWith({
    List<String>? participants,
    LotteryStatus? status,
    String? winner,
  }) {
    return LotteryState(
      participants: participants ?? this.participants,
      status: status ?? this.status,
      winner: winner, // winner 可以为 null，所以不使用 ??
    );
  }

  @override
  List<Object?> get props => [participants, status, winner];
}
