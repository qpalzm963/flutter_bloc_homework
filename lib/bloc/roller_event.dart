part of 'roller_bloc.dart';

sealed class RollerEvent extends Equatable {
  const RollerEvent();

  @override
  List<Object> get props => [];
}

class RollerStarted extends RollerEvent {}

class RollerLooped extends RollerEvent {}

class RollerStopped extends RollerEvent {
  final int targetIndex;
  const RollerStopped(this.targetIndex);
}

class RollerResult extends RollerEvent {}
