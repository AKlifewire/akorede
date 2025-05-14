import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

/// Service to handle authentication operations
class AuthService {
  /// Sign up a new user
  Future<SignUpResult> signUp({
    required String username,
    required String password,
    required String email,
  }) async {
    try {
      final userAttributes = <CognitoUserAttributeKey, String>{
        CognitoUserAttributeKey.email: email,
      };
      
      final result = await Amplify.Auth.signUp(
        username: username,
        password: password,
        options: SignUpOptions(
          userAttributes: userAttributes,
        ),
      );
      
      return result;
    } catch (e) {
      safePrint('Error signing up: $e');
      rethrow;
    }
  }

  /// Confirm sign up with verification code
  Future<SignUpResult> confirmSignUp({
    required String username,
    required String confirmationCode,
  }) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: username,
        confirmationCode: confirmationCode,
      );
      
      return result;
    } catch (e) {
      safePrint('Error confirming sign up: $e');
      rethrow;
    }
  }

  /// Sign in a user
  Future<SignInResult> signIn({
    required String username,
    required String password,
  }) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );
      
      return result;
    } catch (e) {
      safePrint('Error signing in: $e');
      rethrow;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
    } catch (e) {
      safePrint('Error signing out: $e');
      rethrow;
    }
  }

  /// Reset password
  Future<ResetPasswordResult> resetPassword({
    required String username,
  }) async {
    try {
      final result = await Amplify.Auth.resetPassword(
        username: username,
      );
      
      return result;
    } catch (e) {
      safePrint('Error resetting password: $e');
      rethrow;
    }
  }

  /// Confirm new password with confirmation code
  Future<void> confirmResetPassword({
    required String username,
    required String newPassword,
    required String confirmationCode,
  }) async {
    try {
      await Amplify.Auth.confirmResetPassword(
        username: username,
        newPassword: newPassword,
        confirmationCode: confirmationCode,
      );
    } catch (e) {
      safePrint('Error confirming reset password: $e');
      rethrow;
    }
  }

  /// Get current authenticated user
  Future<AuthUser> getCurrentUser() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      return user;
    } catch (e) {
      safePrint('Error getting current user: $e');
      rethrow;
    }
  }

  /// Check if user is signed in
  Future<bool> isSignedIn() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } catch (e) {
      safePrint('Error checking auth status: $e');
      return false;
    }
  }

  /// Get user attributes
  Future<Map<CognitoUserAttributeKey, String>> getUserAttributes() async {
    try {
      final result = await Amplify.Auth.fetchUserAttributes();
      final attributes = <CognitoUserAttributeKey, String>{};
      
      for (final attribute in result) {
        attributes[attribute.userAttributeKey] = attribute.value;
      }
      
      return attributes;
    } catch (e) {
      safePrint('Error fetching user attributes: $e');
      rethrow;
    }
  }

  /// Update user attribute
  Future<void> updateUserAttribute({
    required CognitoUserAttributeKey attributeKey,
    required String value,
  }) async {
    try {
      await Amplify.Auth.updateUserAttribute(
        userAttributeKey: attributeKey,
        value: value,
      );
    } catch (e) {
      safePrint('Error updating user attribute: $e');
      rethrow;
    }
  }
}