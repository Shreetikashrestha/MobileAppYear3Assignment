# Influencer Registration Fix

## Problem
When selecting "Influencer" during registration, users were being logged in as "Brand" instead. The `isInfluencer` field was being dropped during the registration flow.

## Root Cause
The `isInfluencer` field was not being passed through the entire registration chain:

1. ✅ **SignupScreen** - Correctly set `isInfluencer: _selectedRole == 0` (true for Influencer)
2. ✅ **AuthApiModel** - Had the field and included it in `toJson()`
3. ❌ **RegisterViewModel** - Did NOT pass `isInfluencer` to `RegisterParams`
4. ❌ **RegisterParams** - Did NOT have `isInfluencer` field
5. ❌ **RegisterUseCase** - Did NOT pass `isInfluencer` to repository
6. ❌ **IAuthRepository** - Interface did NOT include `isInfluencer` parameter
7. ❌ **AuthRepositoryImpl** - Did NOT pass `isInfluencer` when creating user model

## Solution Applied

### 1. Updated RegisterParams (register_usecase.dart)
```dart
class RegisterParams extends Equatable {
  final String email;
  final String fullName;
  final String username;
  final String password;
  final bool isInfluencer; // ✅ ADDED

  const RegisterParams({
    required this.email,
    required this.fullName,
    required this.username,
    required this.password,
    required this.isInfluencer, // ✅ ADDED
  });

  @override
  List<Object?> get props => [email, fullName, username, password, isInfluencer];
}
```

### 2. Updated RegisterUseCase (register_usecase.dart)
```dart
Future<Either<Failure, AuthApiModel>> call(RegisterParams params) async {
  return await _authRepository.register(
    params.email,
    params.fullName,
    params.username,
    params.password,
    params.isInfluencer, // ✅ ADDED
  );
}
```

### 3. Updated RegisterViewModel (register_view_model.dart)
```dart
Future<void> register(AuthApiModel user) async {
  state = const AsyncValue.loading();
  
  print('📝 [RegisterViewModel] Registering user with isInfluencer: ${user.isInfluencer}');
  
  final result = await _registerUseCase(RegisterParams(
    email: user.email,
    fullName: user.fullName,
    username: user.username,
    password: user.password ?? '',
    isInfluencer: user.isInfluencer, // ✅ ADDED
  ));
  // ...
}
```

### 4. Updated IAuthRepository Interface (auth_repository.dart)
```dart
abstract class IAuthRepository {
  Future<Either<Failure, AuthApiModel>> register(
    String email,
    String fullName,
    String username,
    String password,
    bool isInfluencer, // ✅ ADDED
  );
  // ...
}
```

### 5. Updated AuthRepositoryImpl (auth_repository_impl.dart)
```dart
@override
Future<Either<Failure, AuthApiModel>> register(
  String email,
  String fullName,
  String username,
  String password,
  bool isInfluencer, // ✅ ADDED
) async {
  try {
    print('📝 [AuthRepository] Registering with isInfluencer: $isInfluencer');
    
    final user = AuthApiModel(
      fullName: fullName,
      email: email,
      username: username,
      password: password,
      isInfluencer: isInfluencer, // ✅ ADDED
    );

    print('📝 [AuthRepository] User model created: ${user.toJson()}');

    final result = await _remoteDataSource.register(user);
    return Right(result);
  }
  // ...
}
```

### 6. Added Backend Logging (auth.controller.ts & user.service.ts)
Added comprehensive logging to track the `isInfluencer` value through the backend:
- Registration request body logging
- Parsed data logging
- User creation logging
- Login response logging

## Testing Steps

1. **Hot Restart** the Flutter app (not just hot reload)
2. **Register a new account**:
   - Select "Influencer" role
   - Fill in name, email, password
   - Click "Create Account"
3. **Login** with the new account
4. **Verify** you're taken to the Influencer Dashboard (not Brand Dashboard)

## Debug Logs to Check

### Flutter Console:
```
📝 [RegisterViewModel] Registering user with isInfluencer: true
📝 [AuthRepository] Registering with isInfluencer: true
📝 [AuthRepository] User model created: {fullName: ..., email: ..., password: ..., isInfluencer: true}
```

### Backend Console:
```
📝 Registration Request Body: { email: '...', password: '...', fullName: '...', isInfluencer: true }
📝 isInfluencer value: true
📝 isInfluencer type: boolean
✅ Parsed data: { email: '...', fullName: '...', isInfluencer: true, ... }
📝 [UserService] Registration data received: { isInfluencer: true, ... }
📝 [UserService] Created user: { id: '...', isInfluencer: true, ... }
```

## Files Modified

### Flutter App:
1. `lib/features/auth/domain/usecases/register_usecase.dart`
2. `lib/features/auth/presentation/view_model/register_view_model.dart`
3. `lib/features/auth/domain/repositories/auth_repository.dart`
4. `lib/features/auth/data/repositories/auth_repository_impl.dart`

### Backend:
1. `src/controllers/auth.controller.ts` (added logging)
2. `src/services/user.service.ts` (added logging)

## Additional Fix: Find Influencer API Paths
Also fixed the influencer data source to use correct API paths:
- Changed `/profiles/influencers` → `/api/profiles/influencers`
- Changed `/profiles/{id}` → `/api/profiles/{id}`

This ensures the Find Influencer screen properly loads influencers from the backend.
