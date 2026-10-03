library com.app_track_ota_labs.app.views;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart' as prov;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/constants.dart';
import '../../core/enums/enums.dart';
import '../../core/models/models.dart';
import '../../core/providers/providers.dart';
import '../navigator.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

part 'add_application_screen.dart';
part 'app_detail_screen.dart';
part 'dashboard_view.dart';
part 'home.dart';
part 'login_screen.dart';
part 'my_applications_screen.dart';
part 'settings_view.dart';
