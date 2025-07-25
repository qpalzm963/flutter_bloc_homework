import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'roller_event.dart';
part 'roller_state.dart';

class RollerBloc extends Bloc<RollerEvent, RollerBlocState> {
  static const itemCount = 20;
  bool _shouldRoll = false;

  RollerBloc()
    : super(
        const RollerBlocState(
          status: RollerStateEnum.waiting,
          currentIndex: 0,
          speed: 0.10,
        ),
      ) {
    on<RollerStarted>(_onStarted);
    on<RollerLooped>(_onLooped);
    on<RollerStopped>(_onStopped);
    on<RollerResult>(onResult);
  }

  Future<void> _onStarted(
    RollerStarted event,
    Emitter<RollerBlocState> emit,
  ) async {
    var speed = 0.2;
    emit(state.copyWith(status: RollerStateEnum.start, speed: speed));
    _shouldRoll = true;
    while (_shouldRoll && state.status == RollerStateEnum.start) {
      await Future.delayed(
        Duration(milliseconds: (state.speed * 1000).toInt()),
      );
      emit(
        state.copyWith(
          currentIndex: (state.currentIndex + 1) % itemCount,
          speed: state.speed - 0.03,
        ),
      );
    }
  }

  Future<void> _onLooped(
    RollerLooped event,
    Emitter<RollerBlocState> emit,
  ) async {
    emit(state.copyWith(status: RollerStateEnum.loop, speed: 0.1));
    _shouldRoll = true;
    while (_shouldRoll && state.status == RollerStateEnum.loop) {
      await Future.delayed(
        Duration(milliseconds: (state.speed * 1000).toInt()),
      );
      emit(state.copyWith(currentIndex: (state.currentIndex + 1) % itemCount));
    }
  }

  Future<void> _onStopped(
    RollerStopped event,
    Emitter<RollerBlocState> emit,
  ) async {
    emit(
      state.copyWith(
        status: RollerStateEnum.stop,
        targetIndex: event.targetIndex,
      ),
    );
    int index = state.currentIndex;
    const int itemCount = RollerBloc.itemCount;

    int remain = (event.targetIndex - index + itemCount) % itemCount;
    int finalTarget = event.targetIndex;
    if (remain <= 5 && remain != 0) {
      // 再多轉一圈
      finalTarget = (event.targetIndex + itemCount) % itemCount;
      // 注意最終停下時還是 targetIndex 不是 finalTarget
    }

    while (true) {
      remain = (finalTarget - index + itemCount) % itemCount;
      if (remain == 0) {
        emit(
          state.copyWith(
            status: RollerStateEnum.result,
            currentIndex: event.targetIndex, // 最終顯示的 index 還是原本的目標
          ),
        );
        break;
      }

      double speed;
      if (remain > 7) {
        speed = 0.04;
      } else if (remain > 4) {
        speed = 0.14;
      } else if (remain > 1) {
        speed = 0.22;
      } else {
        speed = 0.35;
      }

      await Future.delayed(Duration(milliseconds: (speed * 1000).toInt()));
      index = (index + 1) % itemCount;
      emit(state.copyWith(speed: speed, currentIndex: index));
    }
  }

  void onResult(event, emit) {
    emit(state.copyWith(status: RollerStateEnum.result));
    _shouldRoll = false;
  }
}
