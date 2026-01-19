// lib/features/authentication/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:waka_fit/shared/widgets/state_widget.dart';
import 'package:logger/logger.dart';

class AppAuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger logger = Logger();

  StateData _stateData = const StateData(state: ViewState.idle);
  User? _user;

  // PUBLIC GETTERS
  StateData get stateData => _stateData;
  bool get isLoading => _stateData.state == ViewState.loading;
  bool get isError => _stateData.state == ViewState.error;
  bool get isSuccess => _stateData.state == ViewState.success;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  AppAuthProvider() {
    _listenToAuthChanges();
  }

  // LISTEN TO FIREBASE AUTH STATE CHANGES
  void _listenToAuthChanges() {
    _auth.authStateChanges().listen((firebaseUser) {
      _user = firebaseUser;

      if (_user != null) {
        logger.i("[AuthProvider] User logged in: ${_user!.email}");
        _updateState(const StateData(state: ViewState.success));
      } else {
        logger.i("[AuthProvider] User logged out");
        _updateState(const StateData(state: ViewState.idle));
      }

      notifyListeners();
    });
  }

  // Update loading/error/success states
  void _updateState(StateData newState) {
    _stateData = newState;
    notifyListeners();
  }

  void setLoading() {
    _updateState(const StateData(state: ViewState.loading));
  }

  void setError(String message) {
    _updateState(StateData(state: ViewState.error, message: message));
  }

  void reset() {
    _updateState(const StateData(state: ViewState.idle));
  }

  // GOOGLE LOGIN HANDLER
  Future<void> signInWithCredential(AuthCredential credential) async {
    try {
      setLoading();
      await _auth.signInWithCredential(credential);
      // authStateChanges listener will update state
    } catch (e) {
      logger.e("Login failed", error: e);
      setError("Login failed. Try again.");
    }
  }

  // LOGOUT METHOD
  Future<void> signOut() async {
    await _auth.signOut();
    // Listener will update state automatically
  }
}
