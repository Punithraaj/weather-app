import 'package:flutter/material.dart';

enum AppErrorType { network, location, api, unknown }

class FriendlyError {
  final String title;
  final String message;
  final IconData icon;
  final AppErrorType type;

  const FriendlyError({
    required this.title,
    required this.message,
    required this.icon,
    required this.type,
  });

  // Factory method to generate from exception
  factory FriendlyError.from(Object error) {
    if (error.toString().contains('SocketException')) {
      return const FriendlyError(
        title: 'Network Error',
        message: 'Check your internet connection and try again.',
        icon: Icons.wifi_off,
        type: AppErrorType.network,
      );
    } else if (error.toString().contains('Location')) {
      return const FriendlyError(
        title: 'Location Error',
        message: 'Unable to get your location. Please enable GPS.',
        icon: Icons.location_off,
        type: AppErrorType.location,
      );
    } else if (error.toString().contains('API')) {
      return const FriendlyError(
        title: 'API Error',
        message: 'There was a problem fetching data from the server.',
        icon: Icons.cloud_off,
        type: AppErrorType.api,
      );
    } else {
      return const FriendlyError(
        title: 'Something Went Wrong',
        message: 'We ran into an unexpected issue. Please try again.',
        icon: Icons.error_outline,
        type: AppErrorType.unknown,
      );
    }
  }
}
