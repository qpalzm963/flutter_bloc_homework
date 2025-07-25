part of 'roller_bloc.dart';

sealed class RollerState extends Equatable {
  const RollerState();

  @override
  List<Object> get props => [];
}

enum RollerStateEnum { waiting, start, loop, stop, result }

class RollerBlocState extends Equatable {
  final RollerStateEnum status;
  final int currentIndex;
  final int? targetIndex;
  final double speed;

  const RollerBlocState({
    required this.status,
    required this.currentIndex,
    this.targetIndex,
    required this.speed,
  });

  @override
  List<Object?> get props => [status, currentIndex, targetIndex, speed];

  RollerBlocState copyWith({
    RollerStateEnum? status,
    int? currentIndex,
    int? targetIndex,
    double? speed,
  }) {
    return RollerBlocState(
      status: status ?? this.status,
      currentIndex: currentIndex ?? this.currentIndex,
      targetIndex: targetIndex ?? this.targetIndex,
      speed: speed ?? this.speed,
    );
  }
}
