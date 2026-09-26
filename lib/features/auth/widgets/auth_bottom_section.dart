import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthBottomSection extends StatefulWidget {
  const AuthBottomSection({super.key});

  @override
  State<AuthBottomSection> createState() => _AuthBottomSectionState();
}

class _AuthBottomSectionState extends State<AuthBottomSection> {
  final _supabase = Supabase.instance.client;
}
