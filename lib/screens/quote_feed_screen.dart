import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';
import '../widgets/quote_card.dart';

/// The main feed screen — a full-screen, vertically snapping [PageView]
/// that streams quote cards from Firestore.
///
/// Features:
/// - Real-time Firestore stream (quotes where active == true)
/// - Full-screen snap behaviour mimicking Reels / TikTok
/// - Loading spinner while data is in-flight
/// - Friendly error state if Firestore is unreachable
/// - Empty state when no active quotes exist
class QuoteFeedScreen extends StatefulWidget {
  const QuoteFeedScreen({super.key});

  @override
  State<QuoteFeedScreen> createState() => _QuoteFeedScreenState();
}

class _QuoteFeedScreenState extends State<QuoteFeedScreen> {
  late final QuoteService _service;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _service = QuoteService();
    _pageController = PageController();

    // Full-screen immersive experience: hide status bar, keep navigation.
    // SystemChrome system UI APIs are mobile-only — skip on web.
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom],
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Restore system UI when leaving this screen (mobile only).
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<List<Quote>>(
        stream: _service.watchActiveQuotes(),
        builder: (context, snapshot) {
          // ----------------------------------------------------------------
          // Loading state
          // ----------------------------------------------------------------
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _LoadingView();
          }

          // ----------------------------------------------------------------
          // Error state
          // ----------------------------------------------------------------
          if (snapshot.hasError) {
            return _ErrorView(error: snapshot.error.toString());
          }

          // ----------------------------------------------------------------
          // Empty state
          // ----------------------------------------------------------------
          final quotes = snapshot.data ?? [];
          if (quotes.isEmpty) {
            return const _EmptyView();
          }

          // ----------------------------------------------------------------
          // Quote feed
          // ----------------------------------------------------------------
          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            // Snapping physics — each swipe lands on exactly one card.
            physics: const PageScrollPhysics(),
            itemCount: quotes.length,
            itemBuilder: (context, index) {
              return QuoteCard(
                quote: quotes[index],
                folioNumber: index + 1,
                totalFolios: quotes.length,
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Auxiliary state views
// ---------------------------------------------------------------------------

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0A0F), Color(0xFF12121A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Color(0xFFB39DDB)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading quotes…',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white38,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0F),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: Color(0xFF555566), size: 48),
            const SizedBox(height: 24),
            Text(
              'Couldn\'t reach the server',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Check your internet connection and try again.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white38,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            // Show the actual error for debugging
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withAlpha(60)),
              ),
              child: Text(
                'Debug: $error',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.redAccent.withAlpha(200),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A0F),
      child: Center(
        child: Text(
          'No quotes yet.\nCheck back soon.',
          style: GoogleFonts.lora(
            fontSize: 20,
            color: Colors.white38,
            height: 1.7,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
