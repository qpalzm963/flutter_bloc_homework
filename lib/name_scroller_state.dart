part of 'name_scroller_bloc.dart';

enum ScrollerStatus { waiting, scrollStart, scrolling, stopped, result }

class NameScrollerState extends Equatable {
  final ScrollerStatus status;
  final List<String> participants;
  final String? winner;

  const NameScrollerState({
    this.status = ScrollerStatus.waiting,
    this.participants = const [],
    this.winner,
  });

  NameScrollerState copyWith({
    ScrollerStatus? status,
    List<String>? participants,
    String? winner,
  }) {
    return NameScrollerState(
      status: status ?? this.status,
      participants: participants ?? this.participants,
      winner: winner ?? this.winner,
    );
  }

  @override
  List<Object?> get props => [status, participants, winner];
}
