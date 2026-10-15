import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fedcaretex_ai/core/constants/app_colors.dart';
import 'package:fedcaretex_ai/core/widgets/app_navbar.dart';
import 'package:fedcaretex_ai/features/dashboard/components/profile_header.dart';

void main() {
  testWidgets('AppNavbar muat di layar sempit tanpa overflow', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    for (var i = 0; i < 5; i++) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: AppColors.backgroundLight,
            bottomNavigationBar: AppNavbar(currentIndex: i, onTap: (_) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('ProfileHeader menampilkan inisial setiap kata jika foto profil kosong', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileHeader(
            userName: 'Budi Santoso',
            photoUrl: null,
            onAvatarTap: () {},
            onSearchTap: () {},
            onNotificationTap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('BS'), findsOneWidget);
    expect(find.text('Hello, Budi Santoso! '), findsOneWidget);
  });
}
