import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:influcollb_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:influcollb_app/features/auth/data/models/auth_api_model.dart';
import '../view_model/auth_providers.dart';

final registerViewModelProvider = StateNotifierProvider<RegisterViewModel, AsyncValue<AuthApiModel?>>((ref) {
  final registerUseCase = ref.watch(registerUseCaseProvider);
  return RegisterViewModel(registerUseCase);
});

class RegisterViewModel extends StateNotifier<AsyncValue<AuthApiModel?>> {
  final RegisterUseCase _registerUseCase;

  RegisterViewModel(this._registerUseCase) : super(const AsyncValue.data(null));

  Future<void> register(AuthApiModel user) async {
    state = const AsyncValue.loading();
    
    print('📝 [RegisterViewModel] Registering user with isInfluencer: ${user.isInfluencer}');
    
    final result = await _registerUseCase(RegisterParams(
      email: user.email,
      fullName: user.fullName,
      username: user.username,
      password: user.password ?? '',
      isInfluencer: user.isInfluencer,
    ));

    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (user) => state = AsyncValue.data(user),
    );
  }
}
