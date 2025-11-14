import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/auth/auth_cubit.dart';
import 'cubits/table/table_cubit.dart';
import 'cubits/member/member_cubit.dart';
import 'cubits/product/product_cubit.dart';
import 'cubits/order/order_cubit.dart';
import 'cubits/invoice/invoice_cubit.dart';
import 'cubits/user/user_cubit.dart';
import 'screens/login_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(create: (_) => TableCubit()),
        BlocProvider(create: (_) => MemberCubit()),
        BlocProvider(create: (_) => ProductCubit()),
        BlocProvider(create: (_) => OrderCubit()),
        BlocProvider(create: (_) => InvoiceCubit()),
        BlocProvider(create: (_) => UserCubit()),
      ],
      child: MaterialApp(
        title: 'Quản lý Billiard Club',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          cardTheme: CardThemeData(
            elevation: AppSizes.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingLarge,
                vertical: AppSizes.paddingMedium,
              ),
            ),
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
