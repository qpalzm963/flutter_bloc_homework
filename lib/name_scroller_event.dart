part of 'name_scroller_bloc.dart';

abstract class NameScrollerEvent extends Equatable {
  const NameScrollerEvent();

  @override
  List<Object> get props => [];
}

class StartScrolling extends NameScrollerEvent {
  final List<String> participants;
  final String? winner;

  const StartScrolling({required this.participants, this.winner});

  @override
  List<Object> get props => [participants];
}

class ScrollLoop extends NameScrollerEvent {
  const ScrollLoop();
}

class StopScrolling extends NameScrollerEvent {}

class ShowResult extends NameScrollerEvent {}
