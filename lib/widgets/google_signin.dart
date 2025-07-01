import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInWidget extends StatefulWidget {
  final GoogleSignInAccount? currentUser;
  final bool isAuthorized;
  final bool isLoading;
  final String errorMessage;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;
  final VoidCallback onRequestPermissions;

  const GoogleSignInWidget({
    super.key,
    required this.currentUser,
    required this.isAuthorized,
    required this.isLoading,
    required this.errorMessage,
    required this.onSignIn,
    required this.onSignOut,
    required this.onRequestPermissions,
  });

  @override
  State<GoogleSignInWidget> createState() => _GoogleSignInWidgetState();
}

class _GoogleSignInWidgetState extends State<GoogleSignInWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      );
    }

    if (widget.errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (widget.currentUser == null) {
      return _buildSignInPrompt();
    }

    if (!widget.isAuthorized) {
      return _buildAuthorizationPrompt();
    }

    // If user is signed in and authorized, return empty container
    // The parent widget should handle the main content
    return const SizedBox.shrink();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Error', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              widget.errorMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  widget.currentUser == null
                      ? widget.onSignIn
                      : widget.onRequestPermissions,
              child: Text(
                widget.currentUser == null ? 'Sign In' : 'Request Permissions',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Calendar App',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Sign in with your Google account to view your calendar events',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: widget.onSignIn,
              icon: const Icon(Icons.login),
              label: const Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorizationPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage:
                  widget.currentUser?.photoUrl != null
                      ? NetworkImage(widget.currentUser!.photoUrl!)
                      : null,
              child:
                  widget.currentUser?.photoUrl == null
                      ? Text(
                        widget.currentUser?.displayName
                                ?.substring(0, 1)
                                .toUpperCase() ??
                            'U',
                        style: const TextStyle(fontSize: 24),
                      )
                      : null,
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome, ${widget.currentUser?.displayName ?? widget.currentUser?.email ?? 'User'}!',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'To view your calendar events, we need permission to access your Google Calendar',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: widget.onRequestPermissions,
              icon: const Icon(Icons.calendar_month),
              label: const Text('Grant Calendar Access'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
