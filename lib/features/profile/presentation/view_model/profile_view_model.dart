import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/profile_providers.dart';

final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, AsyncValue<void>>((ref) {
  return ProfileViewModel(ref);
});

class ProfileViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  ProfileViewModel(this._ref) : super(const AsyncValue.data(null));

  Future<void> uploadProfile(File image) async {
    state = const AsyncValue.loading();
    try {
      final uploadUseCase = _ref.read(uploadImageUseCaseProvider);
      final result = await uploadUseCase.call(image);
      
      result.fold(
        (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
        (imageUrl) => state = const AsyncValue.data(null),
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
