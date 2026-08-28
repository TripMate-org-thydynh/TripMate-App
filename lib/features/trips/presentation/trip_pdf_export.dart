import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:tripmate/core/theme/app_fonts.dart';
import 'package:tripmate/core/network/error_message.dart';
import '../../trips/domain/trip.dart';
import '../../trip_planner/domain/itinerary_item.dart';
import '../../trip_planner/data/itinerary_repository.dart';
import '../../packing/data/packing_repository.dart';
import '../../packing/application/packing_providers.dart';
import '../../reservations/data/reservations_repository.dart';

/// PDF Export service — tạo PDF plan chuyến client-side bằng package `pdf`.
class TripPdfExporter {
  static Future<void> exportAndShare({
    required Trip trip,
    required Map<int, List<ItineraryItem>> itinerary,
    required PackingList packing,
    required List<Reservation> reservations,
    required BuildContext context,
  }) async {
    final pdf = pw.Document();

    // Cover page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(32),
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFFF5822B),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(16)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '✈️ TripMate',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        trip.name,
                        style: pw.TextStyle(
                          fontSize: 32,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      if (trip.destination != null) ...[
                        pw.SizedBox(height: 8),
                        pw.Text(
                          '📍 ${trip.destination}',
                          style: const pw.TextStyle(
                            fontSize: 16,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                pw.SizedBox(height: 32),
                _infoRow(
                    'trips.pdf_depart'.tr(),
                    '${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year}'),
                _infoRow(
                    'trips.pdf_return'.tr(),
                    '${trip.endDate.day}/${trip.endDate.month}/${trip.endDate.year}'),
                _infoRow('Số ngày', '${trip.durationDays} ngày'),
                _infoRow('Thành viên', '${trip.memberCount} người'),
                if (trip.budget != null)
                  _infoRow(
                      'Ngân sách',
                      '${trip.budget!.toStringAsFixed(0)} ${trip.currency}'),
              ],
            ),
          );
        },
      ),
    );

    // Itinerary pages
    if (itinerary.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (ctx) => [
            pw.Text(
              '📅 Lịch trình chi tiết',
              style: pw.TextStyle(
                  fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            ...itinerary.entries.expand((entry) {
              final day = entry.key;
              final items = entry.value;
              items.sort((a, b) => a.startTime.compareTo(b.startTime));
              return [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: const PdfColor.fromInt(0xFFF5822B),
                    borderRadius:
                        const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Text(
                    'Ngày $day',
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 8),
                ...items.map(
                  (item) => pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 8, bottom: 6),
                    child: pw.Row(
                      children: [
                        pw.Text('${item.startTime}  ',
                            style: const pw.TextStyle(
                                color: PdfColor.fromInt(0xFF888888),
                                fontSize: 11)),
                        pw.Text(item.placeName,
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12)),
                        if (item.category != null)
                          pw.Text(
                              '  [${item.category}]',
                              style: const pw.TextStyle(
                                  color: PdfColor.fromInt(0xFF888888),
                                  fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 12),
              ];
            }),
          ],
        ),
      );
    }

    // Packing list page
    if (packing.items.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (ctx) => [
            pw.Text(
              '🧳 Đồ cần mang',
              style: pw.TextStyle(
                  fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              '${packing.packed}/${packing.total} đã chuẩn bị',
              style: const pw.TextStyle(
                  fontSize: 14, color: PdfColor.fromInt(0xFF888888)),
            ),
            pw.SizedBox(height: 16),
            ...packing.items.map(
              (item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 16,
                      height: 16,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF141210)),
                        color: item.isPacked
                            ? const PdfColor.fromInt(0xFF1FA85C)
                            : PdfColors.white,
                        borderRadius: const pw.BorderRadius.all(
                            pw.Radius.circular(4)),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      item.name,
                      style: pw.TextStyle(
                        fontSize: 13,
                        decoration: item.isPacked
                            ? pw.TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (item.quantity > 1)
                      pw.Text(
                        ' x${item.quantity}',
                        style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColor.fromInt(0xFF888888)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Reservations page
    if (reservations.isNotEmpty) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (ctx) => [
            pw.Text(
              'trips.pdf_reservations'.tr(),
              style: pw.TextStyle(
                  fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            ...reservations.map(
              (r) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                      color: const PdfColor.fromInt(0xFFDDDDDD)),
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(r.title,
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 13)),
                    if (r.location != null)
                      pw.Text('📍 ${r.location}',
                          style: const pw.TextStyle(fontSize: 11)),
                    if (r.confirmationNumber != null)
                      pw.Text('🔖 Mã: ${r.confirmationNumber}',
                          style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Share/print
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'tripmate_${trip.name.replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: const pw.TextStyle(
                  color: PdfColor.fromInt(0xFF888888), fontSize: 13),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Button widget để xuất PDF từ TripHubScreen.
class ExportPdfButton extends ConsumerWidget {
  final Trip trip;
  final bool isDarkMode;

  const ExportPdfButton({
    super.key,
    required this.trip,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packingAsync = ref.watch(packingProvider(trip.id));
    final itineraryAsync = ref.watch(tripItineraryProvider(trip.id));

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8B4DE8),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF141210), width: 2),
        ),
        elevation: 0,
      ),
      onPressed: () async {
        HapticFeedback.mediumImpact();
        final itinerary = itineraryAsync.valueOrNull ?? const <int, List<ItineraryItem>>{};
        final packing = packingAsync.valueOrNull ?? const PackingList();
        try {
          await TripPdfExporter.exportAndShare(
            trip: trip,
            itinerary: itinerary,
            packing: packing,
            reservations: const [],
            context: context,
          );
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Không xuất được PDF. ${friendlyError(e)}'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      icon: Icon(PhosphorIcons.filePdf(PhosphorIconsStyle.fill), size: 18),
      label: Text(
        'trips.pdf_export'.tr(),
        style: AppFonts.heading(
            fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
      ),
    );
  }
}
