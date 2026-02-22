import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';
import '../view_model/auth_providers.dart';

final loginViewModelProvider = StateNotifierProvider<LoginViewModel, AsyncValue<AuthApiModel?>>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  return LoginViewModel(loginUseCase);
});

class LoginViewModel extends StateNotifier<AsyncValue<AuthApiModel?>> {
  final LoginUseCase _loginUseCase;

  LoginViewModel(this._loginUseCase) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _loginUseCase(LoginParams(email: email, password: password));

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }
}
