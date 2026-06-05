import 'package:flutter/material.dart';

import 'app/app_root.dart';

export 'app/app_copy.dart';
export 'app/app_root.dart';
export 'app/theme.dart';
export 'core/api_client.dart';
export 'core/session.dart';
export 'data/models/app_models.dart';
export 'data/models/backend_models.dart';
export 'data/services/mobile_content_service.dart';
export 'data/services/relax_catalog_service.dart';

void main() {
  runApp(const RelaxApp());
}
