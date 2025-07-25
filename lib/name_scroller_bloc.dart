import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'name_scroller_event.dart';
part 'name_scroller_state.dart';

class NameScrollerBloc extends Bloc<NameScrollerEvent, NameScrollerState> {
  NameScrollerBloc() : super(const NameScrollerState()) {
    on<StartScrolling>((event, emit) {
      emit(
        state.copyWith(
          status: ScrollerStatus.scrollStart,
          participants: event.participants,
          winner: event.winner,
        ),
      );
    });
    on<ScrollLoop>((event, emit) {
      emit(state.copyWith(status: ScrollerStatus.scrolling));
    });

    on<StopScrolling>((event, emit) {
      emit(state.copyWith(status: ScrollerStatus.stopped));
    });

    on<ShowResult>((event, emit) {
      emit(state.copyWith(status: ScrollerStatus.result));
    });
  }
}
