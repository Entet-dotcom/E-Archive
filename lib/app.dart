import 'package:flutter/material.dart';

import 'core/constants/app_theme.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/pages/login_page.dart';

class EArchiveApp extends StatelessWidget {
  const EArchiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dataSource = AuthLocalDataSource();
    final repository = AuthRepositoryImpl(dataSource);
    final loginUseCase = LoginUseCase(repository);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Archive',
      theme: AppTheme.darkTheme,
      builder: AppTheme.poppinsBuilder,
      home: LoginPage(loginUseCase: loginUseCase),
    );
  }
}
