import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttercon/common/repository/hive_repository.dart';
import 'package:fluttercon/core/di/injectable.dart';
import 'package:fluttercon/features/about/cubit/fetch_individual_organisers_cubit.dart';
import 'package:fluttercon/features/auth/cubit/google_sign_in_cubit.dart';
import 'package:fluttercon/features/auth/cubit/social_auth_sign_in_cubit.dart';
import 'package:fluttercon/features/feed/cubit/feed_cubit.dart';
import 'package:fluttercon/features/feed/cubit/share_feed_post_cubit.dart';
import 'package:fluttercon/features/feedback/cubit/send_feedback_cubit.dart';
import 'package:fluttercon/features/home/cubit/fetch_sessions_cubit.dart';
import 'package:fluttercon/features/home/cubit/home_cubits.dart';
import 'package:fluttercon/features/sessions/cubit/bookmark_session_cubit.dart';
import 'package:fluttercon/features/sessions/cubit/fetch_grouped_sessions_cubit.dart';
import 'package:fluttercon/features/sessions/cubit/share_session_cubit.dart';
import 'package:fluttercon/firebase_options.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  await runZonedGuarded(() async {
    Bloc.observer = const AppBlocObserver();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await configureDependencies();
    await getIt<HiveRepository>().initBoxes();

    runApp(
      MultiBlocProvider(
        // Register all the BLoCs here
        providers: [
          BlocProvider<GoogleSignInCubit>(
            create: (_) => GoogleSignInCubit(
              authRepository: getIt(),
            ),
          ),
          BlocProvider(
            create: (_) => FetchOrganisersCubit(
              apiRepository: getIt(),
            ),
          ),
          BlocProvider<SocialAuthSignInCubit>(
            create: (_) => SocialAuthSignInCubit(
              authRepository: getIt(),
              hiveRepository: getIt(),
            ),
          ),
          BlocProvider<FetchFeedCubit>(
            create: (_) => FetchFeedCubit(
              apiRepository: getIt(),
            ),
          ),
          BlocProvider<FetchSponsorsCubit>(
            create: (context) => FetchSponsorsCubit(
              apiRepository: getIt(),
            ),
          ),
          BlocProvider<FetchSessionsCubit>(
            create: (context) => FetchSessionsCubit(
              apiRepository: getIt(),
            ),
          ),
          BlocProvider<FetchGroupedSessionsCubit>(
            create: (context) => FetchGroupedSessionsCubit(
              apiRepository: getIt(),
              hiveRepository: getIt(),
            ),
          ),
          BlocProvider<FetchSpeakersCubit>(
            create: (context) => FetchSpeakersCubit(
              apiRepository: getIt(),
            ),
          ),
          BlocProvider<FetchIndividualOrganisersCubit>(
            create: (context) => FetchIndividualOrganisersCubit(
              apiRepository: getIt(),
            ),
          ),
          BlocProvider<BookmarkSessionCubit>(
            create: (context) => BookmarkSessionCubit(
              apiRepository: getIt(),
              hiveRepository: getIt(),
            ),
          ),
          BlocProvider<ShareFeedPostCubit>(
            create: (context) => ShareFeedPostCubit(),
          ),
          BlocProvider<ShareSessionCubit>(
            create: (context) => ShareSessionCubit(),
          ),
          BlocProvider<SendFeedbackCubit>(
            create: (context) => SendFeedbackCubit(apiRepository: getIt()),
          ),
        ],
        child: await builder(),
      ),
    );
  }, (error, stackTrace) {
    if (kDebugMode) {
      log(error.toString(), stackTrace: stackTrace);
    } else {
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  });
}
