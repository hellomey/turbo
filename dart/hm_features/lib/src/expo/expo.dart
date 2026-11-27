/// Feature: Expo Challenge (BOLT-0111) - a timed quiz for stall visitors that ends with a lit lamp
/// and a one-time sticker code (CLAUDE.md §8).
///
///   presentation/  challenge and sticker screens
///   application/   Riverpod controller
///   domain/        models and JSON parsing
///   data/          repository over HmApi
library;

export 'application/expo_controller.dart';
export 'data/expo_repository.dart';
export 'domain/expo_models.dart';
export 'presentation/expo_challenge_screen.dart';
export 'presentation/sticker_screen.dart';
