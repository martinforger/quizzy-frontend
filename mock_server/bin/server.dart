import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:quizzy_mock_server/routes/auth_routes.dart';
import 'package:quizzy_mock_server/routes/discovery_routes.dart';
import 'package:quizzy_mock_server/routes/slides_routes.dart';

/// Servidor mock para Quizzy. Ejecuta: `dart run bin/server.dart --port 8080 --host 0.0.0.0`
Future<void> main(List<String> args) async {
  final config = _ServerConfig.fromArgs(args);
  final dataDir = Directory('${Directory.current.path}/data');
  final discoveryRoutes = DiscoveryRoutes(dataDir);
  final slidesRoutes = SlidesRoutes(dataDir);

  final router = Router()
    ..get('/health', (Request _) => Response.ok('ok'))
    ..mount('/auth', AuthRoutes().router)
    ..mount('/discovery', discoveryRoutes.router)
    // Rutas públicas según API única
    ..get('/categories', discoveryRoutes.categories)
    ..get('/themes', discoveryRoutes.themes)
    ..get('/kahoots', discoveryRoutes.kahoots)
    ..get('/kahoots/featured', discoveryRoutes.featured)
    // Slides / preguntas
    ..mount('/kahoots/', slidesRoutes.router);

  // Middleware basico: logs + CORS.
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router.call);

  final server = await serve(handler, config.host, config.port);
  stdout.writeln('Mock server corriendo en http://${server.address.host}:${server.port}');
  stdout.writeln('Data dir: ${dataDir.path}');
}

class _ServerConfig {
  _ServerConfig({required this.host, required this.port});

  final String host;
  final int port;

  factory _ServerConfig.fromArgs(List<String> args) {
    String host = '0.0.0.0';
    int port = 8080;
    for (var i = 0; i < args.length; i++) {
      if (args[i] == '--port' && i + 1 < args.length) {
        port = int.tryParse(args[i + 1]) ?? port;
      }
      if (args[i] == '--host' && i + 1 < args.length) {
        host = args[i + 1];
      }
    }
    return _ServerConfig(host: host, port: port);
  }
}
