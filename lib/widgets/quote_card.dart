import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quote.dart';
import '../screens/quote_detail_screen.dart';

// -----------------------------------------------------------------------------
// DESIGN SYSTEM TOKENS & CATEGORIES
// -----------------------------------------------------------------------------

enum QuoteCategory {
  philosopher,
  writer,
  scientist,
  mathematician,
  activist,
  statesman,
  other,
}

class CategoryTheme {
  final String label;
  final Color accentColor;
  final Color surfaceTint;

  const CategoryTheme({
    required this.label,
    required this.accentColor,
    required this.surfaceTint,
  });
}

class WizTokens {
  // Global canvas backgrounds
  static const Color surfaceBackground = Color(0xFF0C0E11); // Deep nocturnal black
  static const Color cardSurface = Color(0xFF13161A);       // Specimen elevated tone
  static const Color cardBorder = Color(0xFF1E2228);        // Subtle framing border
  static const Color quoteText = Color(0xFFF7F5F0);         // Cotton-rag off-white
  static const Color mutedText = Color(0xFF8E9299);         // Subdued metadata grey
  static const Color faintText = Color(0xFF52565C);         // Hairline rule & faint folio

  // Category Accent Definitions (from approved design system)
  static final Map<QuoteCategory, CategoryTheme> categories = {
    QuoteCategory.philosopher: const CategoryTheme(
      label: 'PHILOSOPHY & STOIC ARCHIVE',
      accentColor: Color(0xFFB84C5B), // Deep Muted Burgundy / Oxblood
      surfaceTint: Color(0x1FB84C5B),
    ),
    QuoteCategory.writer: const CategoryTheme(
      label: 'LITERATURE & POETRY',
      accentColor: Color(0xFF659A7A), // Soft Forest Green / Sage
      surfaceTint: Color(0x1F659A7A),
    ),
    QuoteCategory.scientist: const CategoryTheme(
      label: 'PHYSICAL SCIENCE & COSMOS',
      accentColor: Color(0xFF72B5D8), // Cool Ice-Blue / Cyan-White
      surfaceTint: Color(0x1F72B5D8),
    ),
    QuoteCategory.mathematician: const CategoryTheme(
      label: 'PURE MATHEMATICS & GEOMETRY',
      accentColor: Color(0xFFD6A75C), // Warm Graphite-Ochre
      surfaceTint: Color(0x1FD6A75C),
    ),
    QuoteCategory.activist: const CategoryTheme(
      label: 'CIVIL RIGHTS & ADVOCACY',
      accentColor: Color(0xFFC86A4B), // Muted Terracotta Rust
      surfaceTint: Color(0x1FC86A4B),
    ),
    QuoteCategory.statesman: const CategoryTheme(
      label: 'STATECRAFT & CIVIC LEADERSHIP',
      accentColor: Color(0xFF9E906E), // Patinated Antique Bronze
      surfaceTint: Color(0x1F9E906E),
    ),
    QuoteCategory.other: const CategoryTheme(
      label: 'POLYMATH & GENERAL ANTHOLOGY',
      accentColor: Color(0xFFD1CDC4), // Neutral Bone Ivory / Silver Gray
      surfaceTint: Color(0x1FD1CDC4),
    ),
  };
}

// -----------------------------------------------------------------------------
// SINGLE FULL-SCREEN QUOTE CARD VIEW
// -----------------------------------------------------------------------------

class QuoteCard extends StatefulWidget {
  final Quote quote;
  final int folioNumber;
  final int totalFolios;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.folioNumber,
    required this.totalFolios,
  });

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  bool _isBookmarked = false;

  QuoteCategory _mapCategory(String? categoryStr) {
    switch (categoryStr?.toLowerCase()) {
      case 'philosopher':
        return QuoteCategory.philosopher;
      case 'writer':
        return QuoteCategory.writer;
      case 'scientist':
        return QuoteCategory.scientist;
      case 'mathematician':
        return QuoteCategory.mathematician;
      case 'activist':
        return QuoteCategory.activist;
      case 'statesman':
        return QuoteCategory.statesman;
      default:
        return QuoteCategory.other;
    }
  }

  @override
  Widget build(BuildContext context) {
    final catEnum = _mapCategory(widget.quote.authorCategory);
    final categoryTheme = WizTokens.categories[catEnum]!;
    final accent = categoryTheme.accentColor;
    final formattedFolio = widget.folioNumber.toString().padLeft(2, '0');
    final formattedTotal = widget.totalFolios.toString().padLeft(2, '0');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TOP STATUS & FOLIO HEADER
            _buildTopFolioBar(categoryTheme, accent, formattedFolio, formattedTotal),

            const SizedBox(height: 14),

            // ARCHIVAL SPECIMEN PLATE
            _buildArchivalSpecimenPlate(accent, catEnum),

            const Spacer(flex: 1),

            // QUOTE HERO SECTION
            _buildQuoteHeroSection(accent),

            const SizedBox(height: 18),

            // AUTHOR ATTRIBUTION & ERA
            _buildAuthorAttribution(accent),

            const Spacer(flex: 2),

            // EDITOR'S NOTE / ACTION BAR
            _buildReflectionActionCard(accent),

            const SizedBox(height: 16),

            // MINIMAL SWIPE TO TURN AFFORDANCE
            _buildSwipeAffordance(accent),
          ],
        ),
      ),
    );
  }

  Widget _buildTopFolioBar(CategoryTheme theme, Color accent, String current, String total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 2,
          width: 84,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  theme.label,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w500,
                    color: WizTokens.mutedText,
                  ),
                ),
              ],
            ),
            Text(
              '$current / $total',
              style: GoogleFonts.inter(
                fontSize: 9.5,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w600,
                color: WizTokens.faintText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArchivalSpecimenPlate(Color accent, QuoteCategory cat) {
    final safeCategory = widget.quote.authorCategory.isNotEmpty ? widget.quote.authorCategory : 'OTH';
    final refCode = 'REF-${safeCategory.toUpperCase().substring(0, 3)}-${widget.folioNumber.toString().padLeft(3, '0')}';
    final plateTitle = 'PLATE ${widget.folioNumber}: SPECIMEN ARCHIVE';

    return Container(
      height: 145,
      decoration: BoxDecoration(
        color: WizTokens.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: WizTokens.cardBorder,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: WizTokens.cardSurface,
              child: Center(
                child: Icon(Icons.grain, color: accent.withAlpha(50), size: 40),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(75),
                    Colors.transparent,
                    Colors.black.withAlpha(215),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(165),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white.withAlpha(25), width: 0.5),
                ),
                child: Text(
                  refCode,
                  style: GoogleFonts.inter(
                    fontSize: 8.5,
                    letterSpacing: 1.1,
                    color: WizTokens.mutedText,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(180),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white.withAlpha(20), width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        plateTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 9.0,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600,
                          color: WizTokens.quoteText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateFontSize(String text) {
    if (text.length > 120) return 19.5;
    if (text.length > 80) return 23.0;
    return 27.5;
  }

  Widget _buildQuoteHeroSection(Color accent) {
    final dynamicFontSize = _calculateFontSize(widget.quote.quoteText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '“',
          style: GoogleFonts.fraunces(
            fontSize: 40,
            height: 0.6,
            fontWeight: FontWeight.w400,
            color: accent.withAlpha(200),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.quote.quoteText,
          style: GoogleFonts.fraunces(
            fontSize: dynamicFontSize,
            height: 1.34,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.2,
            color: WizTokens.quoteText,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorAttribution(Color accent) {
    final role = widget.quote.authorCategory.toUpperCase();
    final sourceWork = (widget.quote.source.isNotEmpty) ? widget.quote.source : 'UNKNOWN SOURCE';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              widget.quote.author,
              style: GoogleFonts.inter(
                fontSize: 21,
                fontWeight: FontWeight.w500,
                color: accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          '$role • $sourceWork',
          style: GoogleFonts.inter(
            fontSize: 9.5,
            letterSpacing: 1.3,
            fontWeight: FontWeight.w500,
            color: WizTokens.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildReflectionActionCard(Color accent) {
    final note = widget.quote.explanation.isNotEmpty 
        ? widget.quote.explanation 
        : 'Stored to general anthology archive.';
        
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: WizTokens.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: WizTokens.cardBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuoteDetailScreen(
                      quote: widget.quote,
                      folioNumber: widget.folioNumber,
                      totalFolios: widget.totalFolios,
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'EDITOR\'S NOTE',
                            style: GoogleFonts.inter(
                              fontSize: 8.5,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w700,
                              color: WizTokens.faintText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            note,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontStyle: FontStyle.italic,
                              color: WizTokens.quoteText.withAlpha(230),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withAlpha(40),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: accent.withAlpha(80), width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'EXPLORE',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.chevron_right_rounded, size: 12, color: accent),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 1,
            height: 24,
            color: WizTokens.cardBorder,
          ),
          const SizedBox(width: 6),
          _buildQuietIconButton(
            icon: _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            iconColor: _isBookmarked ? accent : null,
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
            },
          ),
          const SizedBox(width: 2),
          _buildQuietIconButton(
            icon: Icons.share_outlined,
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing quote...')),
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildQuietIconButton({required IconData icon, Color? iconColor, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withAlpha(15), width: 0.5),
        ),
        child: Icon(
          icon,
          size: 16,
          color: iconColor ?? WizTokens.mutedText,
        ),
      ),
    );
  }

  Widget _buildSwipeAffordance(Color accent) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 2.5,
          decoration: BoxDecoration(
            color: accent.withAlpha(150),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SWIPE TO TURN',
              style: GoogleFonts.inter(
                fontSize: 8.5,
                letterSpacing: 2.2,
                fontWeight: FontWeight.w600,
                color: WizTokens.faintText,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 13,
              color: WizTokens.faintText,
            ),
          ],
        ),
      ],
    );
  }
}
