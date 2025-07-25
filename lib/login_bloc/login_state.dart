part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final String username;
  final String password;
  final LoginStatus status;
  final String? errorMessage;

  const LoginState({
    this.username = '',
    this.password = '',
    this.status = LoginStatus.initial,
    this.errorMessage,
  });

  LoginState copyWith({
    String? username,
    String? password,
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [username, password, status, errorMessage];
}
