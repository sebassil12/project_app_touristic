import 'package:flutter/material.dart';
import 'package:flutter_application_proyecto/features/auth/auth_screen.dart';
import 'package:flutter_application_proyecto/features/home/home_screen.dart';
import 'package:flutter_application_proyecto/features/map/map_screen.dart';
import 'package:flutter_application_proyecto/features/poi/poi_list_screen.dart';
import 'package:flutter_application_proyecto/features/poi/poi_detail_screen.dart';
import 'package:flutter_application_proyecto/features/poi/review_screen.dart';
import 'package:flutter_application_proyecto/features/profile/profile_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/auth': (context) => const AuthScreen(),
  '/home': (context) => const HomeScreen(),
  '/map': (context) => const MapScreen(),
  '/poi-list': (context) => POIListScreen(),
  '/poi-detail': (context) => const POIDetailScreenWrapper(),
  '/review': (context) => const ReviewScreenWrapper(),
  '/profile': (context) => const ProfileScreen(),
};