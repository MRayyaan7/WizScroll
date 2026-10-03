import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quote.dart';
import '../widgets/quote_card.dart' show QuoteCategory, CategoryTheme, WizTokens;

class QuoteDetailScreen extends StatefulWidget {
  final Quote quote;
  final int folioNumber;
  final int totalFolios;

  const QuoteDetailScreen({
    super.key,
    required this.quote,
    required this.folioNumber,
    required this.totalFolios,
  });

  @override
  State<QuoteDetailScreen> createState() => _QuoteDetailScreenState();
}

class _QuoteDetailScreenState extends State<QuoteDetailScreen> {
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

    return Scaffold(
      backgroundColor: WizTokens.surfaceBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopAppBar(context, accent),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildQuoteRecapCard(accent),
                    const SizedBox(height: 28),
                    
                    if (widget.quote.explanation.isNotEmpty) ...[
                      _buildSectionHeader(
                        accent: accent,
                        sectionNumber: '01',
                        title: 'EXPLANATION & CONTEXT',
                      ),
                      const SizedBox(height: 12),
                      _buildExplanationCard(accent),
                      const SizedBox(height: 28),
                    ],

                    if (widget.quote.realLifeScenarios.isNotEmpty) ...[
                      _buildSectionHeader(
                        accent: accent,
                        sectionNumber: widget.quote.explanation.isNotEmpty ? '02' : '01',
                        title: 'PRAXIS: REAL-LIFE APPLICATION',
                        subtitle: 'Translating this wisdom into everyday modern practice.',
                      ),
                      const SizedBox(height: 14),
                      _buildApplicationCards(accent),
                      const SizedBox(height: 28),
                    ],

                    _buildActionButtons(context, accent),
                    const SizedBox(height: 36),
                    _buildSwipeDownAffordance(),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context, Color accent) {
    final formattedFolio = widget.folioNumber.toString().padLeft(2, '0');
    final safeCategory = widget.quote.authorCategory.isNotEmpty ? widget.quote.authorCategory : 'OTH';
    final refCode = 'REF-${safeCategory.toUpperCase().substring(0, 3)}-${widget.folioNumber.toString().padLeft(3, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 16,
                    color: accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'FOLIO $formattedFolio',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                      color: WizTokens.quoteText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: WizTokens.cardSurface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: WizTokens.cardBorder, width: 0.6),
            ),
            child: Text(
              refCode,
              style: GoogleFonts.inter(
                fontSize: 9,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w500,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteRecapCard(Color accent) {
    final sourceWork = (widget.quote.source.isNotEmpty) ? widget.quote.source : 'UNKNOWN SOURCE';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WizTokens.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WizTokens.cardBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '“ ',
                  style: GoogleFonts.fraunces(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: accent,
                  ),
                ),
                TextSpan(
                  text: widget.quote.quoteText,
                  style: GoogleFonts.fraunces(
                    fontSize: 16,
                    height: 1.35,
                    fontStyle: FontStyle.italic,
                    color: WizTokens.quoteText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${widget.quote.author.toUpperCase()} • $sourceWork',
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: WizTokens.mutedText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required Color accent,
    required String sectionNumber,
    required String title,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(width: 8),
            Text(
              '$sectionNumber // $title',
              style: GoogleFonts.inter(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: WizTokens.mutedText,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: WizTokens.mutedText,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExplanationCard(Color accent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WizTokens.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WizTokens.cardBorder, width: 0.8),
      ),
      child: Text(
        widget.quote.explanation,
        style: GoogleFonts.inter(
          fontSize: 16,
          height: 1.55,
          fontWeight: FontWeight.w400,
          color: WizTokens.quoteText.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildApplicationCards(Color accent) {
    return Column(
      children: widget.quote.realLifeScenarios.map((scenario) {
        String tag = 'FOR THE GENERAL AUDIENCE';
        IconData icon = Icons.lightbulb_outline_rounded;

        if (scenario.audience.toLowerCase() == 'student') {
          tag = 'FOR THE STUDENT';
          icon = Icons.school_outlined;
        } else if (scenario.audience.toLowerCase() == 'traveler') {
          tag = 'FOR THE TRAVELER';
          icon = Icons.flight_takeoff_rounded;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPraxisCard(
            accent: accent,
            tag: tag,
            icon: icon,
            body: scenario.text,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPraxisCard({
    required Color accent,
    required String tag,
    required IconData icon,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WizTokens.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WizTokens.cardBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.inter(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: accent,
                  ),
                ),
              ),
              Icon(icon, size: 16, color: WizTokens.mutedText),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: GoogleFonts.inter(
              fontSize: 14.5,
              height: 1.5,
              color: WizTokens.quoteText.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Color accent) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: WizTokens.cardSurface,
              foregroundColor: WizTokens.quoteText,
              side: const BorderSide(color: WizTokens.cardBorder, width: 0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
            },
            icon: Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              size: 18,
              color: _isBookmarked ? accent : WizTokens.mutedText,
            ),
            label: Text(
              _isBookmarked ? 'BOOKMARKED' : 'BOOKMARK QUOTE',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: WizTokens.quoteText,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: WizTokens.cardSurface,
              foregroundColor: WizTokens.quoteText,
              side: const BorderSide(color: WizTokens.cardBorder, width: 0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing quote...')),
              );
            },
            icon: const Icon(Icons.share_outlined, size: 18, color: WizTokens.mutedText),
            label: Text(
              'SHARE',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: WizTokens.quoteText,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeDownAffordance() {
    return Column(
      children: [
        const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 16,
          color: WizTokens.faintText,
        ),
        const SizedBox(height: 2),
        Text(
          'SWIPE DOWN OR TAP BACK TO CLOSE',
          style: GoogleFonts.inter(
            fontSize: 8,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w600,
            color: WizTokens.faintText,
          ),
        ),
      ],
    );
  }
}
