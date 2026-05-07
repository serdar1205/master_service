import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/auth_repository.dart';

enum AuthStatus {
  initial,
  restoring,
  requestingOtp,
  verifyingOtp,
  unauthenticated,
  otpRequested,
  authenticated,
  failure,
}

class AuthState {
  const AuthState({
    required this.status,
    this.phoneNumber,
    this.errorMessage,
    this.profileComplete = false,
    this.categoriesComplete = false,
  });

  const AuthState.initial() : this(status: AuthStatus.initial);

  final AuthStatus status;
  final String? phoneNumber;
  final String? errorMessage;
  final bool profileComplete;
  final bool categoriesComplete;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading =>
      status == AuthStatus.restoring ||
      status == AuthStatus.requestingOtp ||
      status == AuthStatus.verifyingOtp;

  AuthState copyWith({
    AuthStatus? status,
    String? phoneNumber,
    String? errorMessage,
    bool? profileComplete,
    bool? categoriesComplete,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      profileComplete: profileComplete ?? this.profileComplete,
      categoriesComplete: categoriesComplete ?? this.categoriesComplete,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(const AuthState.initial());

  final AuthRepository _authRepository;

  Future<void> restoreSession() async {
    emit(state.copyWith(status: AuthStatus.restoring, clearError: true));

    try {
      final session = await _authRepository.restoreSession();
      if (session == null) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
        return;
      }

      emit(
        AuthState(
          status: AuthStatus.authenticated,
          profileComplete: session.profileComplete,
          categoriesComplete: session.categoriesComplete,
        ),
      );
    } on Object catch (error) {
      emit(
        AuthState(
          status: AuthStatus.failure,
          errorMessage: _friendlyAuthError(error),
        ),
      );
    }
  }

  Future<void> requestOtp(String phoneNumber) async {
    final normalizedPhone = phoneNumber.trim();
    emit(
      state.copyWith(
        status: AuthStatus.requestingOtp,
        phoneNumber: normalizedPhone,
        clearError: true,
      ),
    );

    try {
      await _authRepository.requestOtp(normalizedPhone);
      emit(
        AuthState(
          status: AuthStatus.otpRequested,
          phoneNumber: normalizedPhone,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _friendlyAuthError(error),
        ),
      );
    }
  }

  Future<void> verifyOtp(String otpCode) async {
    final phoneNumber = state.phoneNumber;
    if (phoneNumber == null || phoneNumber.isEmpty) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Enter your phone number again.',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(status: AuthStatus.verifyingOtp, clearError: true));
      final session = await _authRepository.verifyOtp(
        phoneNumber: phoneNumber,
        otpCode: otpCode.trim(),
      );
      emit(
        AuthState(
          status: AuthStatus.authenticated,
          phoneNumber: phoneNumber,
          profileComplete: session.profileComplete,
          categoriesComplete: session.categoriesComplete,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: _friendlyAuthError(error),
        ),
      );
    }
  }

  Future<void> completeProfile() async {
    final session = await _authRepository.markProfileComplete();
    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        profileComplete: session.profileComplete,
        categoriesComplete: session.categoriesComplete,
        clearError: true,
      ),
    );
  }

  Future<void> completeCategories() async {
    final session = await _authRepository.markCategoriesComplete();
    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
        profileComplete: session.profileComplete,
        categoriesComplete: session.categoriesComplete,
        clearError: true,
      ),
    );
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  String _friendlyAuthError(Object error) {
    if (error is ArgumentError) {
      if (error.message == 'invalid_phone') {
        return 'Enter a valid Turkmen phone number.';
      }

      if (error.message == 'invalid_otp') {
        return 'Enter a valid OTP code.';
      }
    }

    return 'We could not complete authentication. Please try again.';
  }
}
