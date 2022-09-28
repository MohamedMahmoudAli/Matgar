import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matgar/Screens/splash/splash_screen.dart';
import 'package:matgar/cubit/cubit.dart';
import 'package:matgar/network/cache_helper.dart';
import 'package:matgar/shared/bloc_observer.dart';
import 'package:matgar/shared/components/constants.dart';
import 'package:matgar/shared/mode_cubit/cubit.dart';
import 'package:matgar/shared/mode_cubit/state.dart';
import 'package:matgar/shared/styles/themes.dart';
import 'Screens/login/login_screen.dart';
import 'Screens/onboarding/on_boarding_screen.dart';
import 'layout/home_layout.dart';
import 'network/dio_helper.dart';
// metgar
void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  blocObserver: MyBlocObserver();

  await DioHelper.init();
  await CacheHelper.init();

  bool? isDark = CacheHelper.getBoolean(key: 'isDark');
  Widget widget;

  bool? onBoarding = CacheHelper.getData(key: 'onBoarding');

  token = CacheHelper.getData(key: 'token');

  if(onBoarding != null)
  {
    if(token != null) {
      widget = HomeScreen();
    } else {
      widget = LoginScreen();
    }
  }else
  {
    widget = onBoardingScreen();
  }
  runApp(MyApp(
    startWidget: widget,
    isDark: isDark,
  ));
}

class MyApp extends StatelessWidget {
  final  bool? isDark;
  final Widget startWidget;
  const MyApp({Key? key,required this.startWidget, this.isDark});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => MainCubit()
              ..getHomeData()
              ..getCategoriesData()
              ..getFavoritesData()
              ..getUserData()
              ..getCartData()
              ..getFaqData()),
        BlocProvider(
          create: (context) => ModeCubit()
            ..changeAppMode(
              fromShared: isDark,
            ),
        ),
      ],
      child: BlocConsumer<ModeCubit, ModeStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return MaterialApp(
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode:ModeCubit.get(context).isDark
                ? ThemeMode.dark
                : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: AnimatedSplashScreen(
              splash: const SplashScreen(),
              backgroundColor:
              ModeCubit.get(context).backgroundColor.withOpacity(1),
              nextScreen: startWidget,
              animationDuration: const Duration(milliseconds: 2000),
              splashTransition: SplashTransition.scaleTransition,
                // navigationbar()
            ),
          );
        },
      ),
    );
  }
}