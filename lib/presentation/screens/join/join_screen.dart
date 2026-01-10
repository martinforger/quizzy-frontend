import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:animate_do/animate_do.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';
import '../../bloc/multiplayer/multiplayer_game_cubit.dart';
import '../../bloc/multiplayer/multiplayer_game_state.dart';
import '../multiplayer/player/player_lobby_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizzy/injection_container.dart';

/// Pantalla para unirse a una sesión (PIN o QR).
class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isScannerOpen = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _onJoinPressed() async {
    final pin = _pinController.text.replaceAll(' ', '');

    // Get real JWT
    final prefs = getIt<SharedPreferences>();
    final token = prefs.getString('accessToken');

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para unirte a una partida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (pin.length >= 6) {
      context.read<MultiplayerGameCubit>().connectAsPlayer(pin, token);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El PIN debe tener al menos 6 dígitos')),
      );
    }
  }

  void _onScanQr(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _isScannerOpen = false;
        });

        final prefs = getIt<SharedPreferences>();
        final token = prefs.getString('accessToken');

        if (token == null || token.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debes iniciar sesión para unirte a una partida'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        context.read<MultiplayerGameCubit>().connectWithQrToken(
          barcode.rawValue!,
          token,
        );
        break; // Take first valid code
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isScannerOpen) {
      return Scaffold(
        body: Stack(
          children: [
            MobileScanner(onDetect: _onScanQr),
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => setState(() => _isScannerOpen = false),
              ),
            ),
            const Center(
              child: Text(
                'Escanea el código QR del anfitrión',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return BlocConsumer<MultiplayerGameCubit, MultiplayerGameState>(
      listener: (context, state) {
        if (state is PlayerLobbyState) {
          // Navigate to PlayerLobbyScreen specifically
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PlayerLobbyScreen()));
        } else if (state is MultiplayerError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is MultiplayerConnecting;

        return Scaffold(
          backgroundColor: AppColors.surface,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: const BackButton(color: Colors.white),
            elevation: 0,
          ),
          body: Stack(
            children: [
              // Background Gradient Effect
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 100,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentTeal.withOpacity(0.15),
                        blurRadius: 100,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeInDown(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              size: 64,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Unirse a la Partida',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ingresa el PIN para comenzar',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      FadeIn(
                        delay: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.border),
                            boxShadow: AppShadows.medium,
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: _pinController,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  counterText: "",
                                  hintText: '000 000',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () => _onJoinPressed(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 8,
                                    shadowColor: AppColors.primary.withOpacity(
                                      0.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'Entrar',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: Column(
                          children: [
                            const Text(
                              'O escanea el código QR',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _isScannerOpen = true),
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.accentTeal.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accentTeal.withOpacity(
                                        0.2,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.qr_code_scanner,
                                  color: AppColors.accentTeal,
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
