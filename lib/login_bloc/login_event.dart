part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

/// 当用户名输入框内容改变时触发的事件。
class LoginUsernameChanged extends LoginEvent {
  final String username;

  const LoginUsernameChanged(this.username);

  @override
  List<Object> get props => [username];
}

/// 当密码输入框内容改变时触发的事件。
class LoginPasswordChanged extends LoginEvent {
  final String password;

  const LoginPasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

/// 当用户点击登录按钮时触发的事件。
class LoginSubmitted extends LoginEvent {}
