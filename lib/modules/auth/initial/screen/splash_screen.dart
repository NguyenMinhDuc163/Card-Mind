import 'package:card_mind/init.dart';
import 'package:card_mind/modules/dashboard/screen/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = '/splash_screen';
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      redirectIntroScreen();
    });
  }

  void redirectIntroScreen() async {
    // String? token = context.read<SignInRepo>().authService.accessToken;
    // await Future.delayed(const Duration(seconds: 1));
    // if (!mounted) return;
    // if(token != null) {
    //   Navigator.of(context).pushNamed(HomeScreen.routeName);
    // }else{
    //   Navigator.of(context).pushNamed(LoginScreen.routeName);
    //
    // }
    Navigator.of(context).pushReplacementNamed(DashboardScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: AppColors.lavenderColor)),
        // Center(
        //   child: Column(
        //     spacing: 10,
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       // Image.asset(ImagePath.imgSplash),
        //       // Image.asset(ImagePath.imgTitleSplash),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
