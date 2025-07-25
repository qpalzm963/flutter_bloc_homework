import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
  }

  void _onUsernameChanged(LoginUsernameChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(username: event.username, status: LoginStatus.initial, errorMessage: null));
  }

  void _onPasswordChanged(LoginPasswordChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(password: event.password, status: LoginStatus.initial, errorMessage: null));
  }

  Future<void> _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    // 简单的表单验证
    if (state.username.isEmpty || state.password.isEmpty) {
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: '用户名或密码不能为空'));
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));
    try {
      // 模拟网络请求
      await Future.delayed(const Duration(seconds: 2));

      // 简单的登录逻辑
      if (state.username == 'test' && state.password == 'password') {
        emit(state.copyWith(status: LoginStatus.success));
      } else {
        emit(state.copyWith(status: LoginStatus.failure, errorMessage: '用户名或密码错误'));
      }
    } catch (e) {
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: e.toString()));
    }
  }
}
