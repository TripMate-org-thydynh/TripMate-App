import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/format/money.dart';
import '../domain/expense.dart';

/// Định dạng xuất bảng chi tiêu.
enum ExpenseExportFormat { csv, pdf }

/// Nhãn i18n của từng danh mục — cùng bộ khoá với sheet thêm khoản chi.
const _categoryKeys = {
  'FOOD': 'expense.cat_food',
  'ACCOMMODATION': 'expense.cat_stay',
  'TRANSPORT': 'expense.cat_transport',
  'ACTIVITIES': 'expense.cat_activities',
  'SHOPPING': 'expense.cat_shopping',
  'ENTERTAINMENT': 'expense.cat_fun',
  'OTHER': 'expense.cat_other',
};

String _category(String c) => (_categoryKeys[c] ?? 'expense.cat_other').tr();

String _date(DateTime d) => DateFormat('dd/MM/yyyy').format(d.toLocal());

String _shares(Expense e) =>
    e.splits.map((s) => '${s.user.name}: ${s.shareAmount.round()}').join('; ');

/// Bảng chi tiêu dạng CSV, mở được bằng Google Sheets / Excel.
///
/// Số tiền ghi dạng số trần (không dấu chấm nghìn, không "đ") để bảng tính cộng
/// được. Có BOM ở đầu: thiếu nó Excel đọc file là ANSI và vỡ hết dấu tiếng Việt.
String buildExpenseCsv({
  required String tripName,
  required List<Expense> expenses,
  required BalancesResult balances,
}) {
  final rows = <List<Object>>[
    [tripName],
    [],
    [
      'expense.col_date'.tr(),
      'expense.col_desc'.tr(),
      'expense.col_category'.tr(),
      'expense.col_payer'.tr(),
      'expense.col_amount'.tr(),
      'expense.col_split'.tr(),
    ],
    for (final e in expenses)
      [
        _date(e.createdAt),
        e.description ?? '',
        _category(e.category),
        e.paidBy?.name ?? '',
        e.amount.round(),
        _shares(e),
      ],
    ['', '', '', 'expense.total_spent'.tr(), _total(expenses).round(), ''],
    [],
    ['expense.per_person'.tr()],
    ['expense.col_member'.tr(), 'expense.col_balance'.tr()],
    for (final b in balances.balances) [b.user.name, b.balance.round()],
    [],
    ['expense.settle_minimal'.tr()],
    ['expense.col_from'.tr(), 'expense.col_to'.tr(), 'expense.col_amount'.tr()],
    for (final s in balances.settlements)
      [s.from.name, s.to.name, s.amount.round()],
  ];
  final body = rows.map((r) => r.map(_csvCell).join(',')).join('\r\n');
  return '﻿$body\r\n';
}

String _csvCell(Object v) {
  final s = v.toString();
  if (s.contains(RegExp(r'[",\r\n]'))) return '"${s.replaceAll('"', '""')}"';
  return s;
}

double _total(List<Expense> es) => es.fold(0, (a, e) => a + e.amount);

/// Bảng chi tiêu dạng PDF để gửi vào nhóm chat sau chuyến.
///
/// Phông Be Vietnam Pro tải qua `PdfGoogleFonts` (có cache sau lần đầu): phông
/// mặc định của gói `pdf` không có dấu tiếng Việt, tên người sẽ thành ô vuông.
Future<Uint8List> buildExpensePdf({
  required String tripName,
  required List<Expense> expenses,
  required BalancesResult balances,
  required String locale,

  /// Chỉ để test truyền phông cục bộ (môi trường test chặn mạng).
  pw.Font? regularFont,
  pw.Font? boldFont,
}) async {
  final regular = regularFont ?? await PdfGoogleFonts.beVietnamProRegular();
  final bold = boldFont ?? await PdfGoogleFonts.beVietnamProBold();
  const accent = PdfColor.fromInt(0xFFB4543A);
  const ink = PdfColor.fromInt(0xFF1C1A17);
  const inkSoft = PdfColor.fromInt(0xFF6B655C);
  const line = PdfColor.fromInt(0xFFE3DDD2);
  const fill = PdfColor.fromInt(0xFFF0EBE2);
  String money(double v) => formatMoney(v, locale: locale);
  final members = [for (final b in balances.balances) b.user];

  pw.Widget heading(String t) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 12, bottom: 5),
    child: pw.Text(
      t,
      style: pw.TextStyle(font: bold, fontSize: 12, color: ink),
    ),
  );

  pw.Widget table(
    List<String> headers,
    List<List<String>> data, {
    Map<int, pw.Alignment> align = const {},
    Map<int, pw.TableColumnWidth>? widths,
  }) {
    // Cột chữ căn trái cho tiêu đề thẳng hàng với dữ liệu; cột tiền căn phải.
    final aligns = {
      for (var i = 0; i < headers.length; i++)
        i: align[i] ?? pw.Alignment.centerLeft,
    };
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder(
        horizontalInside: const pw.BorderSide(color: line, width: 0.5),
        bottom: const pw.BorderSide(color: line, width: 0.5),
      ),
      headerDecoration: const pw.BoxDecoration(color: fill),
      headerStyle: pw.TextStyle(font: bold, fontSize: 9, color: ink),
      cellStyle: pw.TextStyle(font: regular, fontSize: 9, color: ink),
      cellAlignments: aligns,
      headerAlignments: aligns,
      columnWidths: widths,
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    );
  }

  final settleTable = table(
    ['expense.col_from'.tr(), 'expense.col_to'.tr(), 'expense.col_amount'.tr()],
    [
      for (final s in balances.settlements)
        [s.from.name, s.to.name, money(s.amount)],
    ],
    align: {2: pw.Alignment.centerRight},
  );
  final balanceTable = table(
    ['expense.col_member'.tr(), 'expense.col_balance'.tr()],
    [
      for (final b in balances.balances)
        [
          b.user.name,
          '${b.balance >= 0 ? 'expense.is_owed'.tr() : 'expense.owes'.tr()} ${money(b.balance.abs())}',
        ],
    ],
    align: {1: pw.Alignment.centerRight},
  );

  // Quyết toán và số dư đặt cạnh nhau để nhóm cỡ thường (≤ 20 người) gọn
  // trong một trang A4. Một Row không tách qua trang được, nên nhóm quá đông
  // thì xếp chồng như cũ để MultiPage tự sang trang.
  final sideBySide =
      balances.settlements.isNotEmpty && balances.balances.length <= 20;
  final summary = sideBySide
      ? <pw.Widget>[
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    heading('expense.settle_minimal'.tr()),
                    settleTable,
                  ],
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [heading('expense.per_person'.tr()), balanceTable],
                ),
              ),
            ],
          ),
        ]
      : <pw.Widget>[
          if (balances.settlements.isNotEmpty) ...[
            heading('expense.settle_minimal'.tr()),
            settleTable,
          ],
          heading('expense.per_person'.tr()),
          balanceTable,
        ];

  final doc = pw.Document(title: tripName, author: 'TripMate');
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
      footer: (ctx) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'TripMate · ${ctx.pageNumber}/${ctx.pagesCount}',
          style: pw.TextStyle(font: regular, fontSize: 8, color: inkSoft),
        ),
      ),
      build: (ctx) => [
        pw.Text(
          'expense.split_title'.tr(),
          style: pw.TextStyle(font: regular, fontSize: 10, color: inkSoft),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          tripName,
          style: pw.TextStyle(font: bold, fontSize: 22, color: ink),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: const pw.BoxDecoration(
                color: accent,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Text(
                '${'expense.total_spent'.tr()}: ${money(_total(expenses))}',
                style: pw.TextStyle(
                  font: bold,
                  fontSize: 11,
                  color: PdfColors.white,
                ),
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Text(
              'expense.generated_at'.tr(
                namedArgs: {'date': _date(DateTime.now())},
              ),
              style: pw.TextStyle(font: regular, fontSize: 9, color: inkSoft),
            ),
          ],
        ),
        ...summary,
        heading('expense.section_expenses'.tr()),
        // Cột "Chia cho" cho biết khoản nào của cả nhóm, khoản nào chỉ vài
        // người. Bỏ cột danh mục ở bản PDF (CSV vẫn có) để vừa một trang.
        table(
          [
            'expense.col_date'.tr(),
            'expense.col_desc'.tr(),
            'expense.col_payer'.tr(),
            'expense.col_amount'.tr(),
            'expense.col_split'.tr(),
          ],
          [
            for (final e in expenses)
              [
                DateFormat('dd/MM').format(e.createdAt.toLocal()),
                e.description ?? '',
                e.paidBy?.name ?? '',
                money(e.amount),
                splitLabel(e, members, money),
              ],
          ],
          align: {3: pw.Alignment.centerRight},
          // Cột tiền đủ rộng cho "3.000.000 đ" trên một dòng; phần còn lại
          // nhường cho "Chia cho" vốn dài nhất.
          widths: const {
            0: pw.FlexColumnWidth(0.7),
            1: pw.FlexColumnWidth(2.1),
            2: pw.FlexColumnWidth(1.2),
            3: pw.FlexColumnWidth(1.4),
            4: pw.FlexColumnWidth(4.2),
          },
        ),
      ],
    ),
  );
  return doc.save();
}

/// Mô tả ngắn "chia cho ai" của một khoản — gọn đủ nằm trong một ô bảng.
///
/// Cả nhóm thì ghi "Cả nhóm (12)"; gần cả nhóm thì ghi người bị trừ ra, vì
/// liệt kê 9 cái tên thì dài mà người đọc chỉ cần biết ai KHÔNG có phần; còn
/// khoản vài người thì ghi tên. Chia đều thì kèm số tiền mỗi người.
String splitLabel(
  Expense e,
  List<ExpenseUser> members,
  String Function(double) money,
) {
  if (e.splits.isEmpty) return '';
  final ids = {for (final s in e.splits) s.user.id};
  final String who;
  if (members.isNotEmpty && ids.length == members.length) {
    who = 'expense.split_everyone'.tr(namedArgs: {'n': '${ids.length}'});
  } else if (members.isNotEmpty && ids.length > members.length / 2) {
    final left = members.where((m) => !ids.contains(m.id)).map((m) => m.name);
    who = 'expense.split_except'.tr(
      namedArgs: {'n': '${ids.length}', 'names': left.join(', ')},
    );
  } else {
    who = e.splits.map((s) => s.user.name).join(', ');
  }
  // Đều nhau nếu chênh không quá phần dư làm tròn (người trả gánh phần lẻ).
  final shares = e.splits.map((s) => s.shareAmount).toList()..sort();
  final even = shares.last - shares.first <= e.splits.length;
  return even
      ? '$who · ${'expense.per_head'.tr(namedArgs: {'amount': money(shares.first)})}'
      : who;
}

/// Tên file an toàn cho mọi hệ điều hành: bỏ dấu, bỏ ký tự lạ.
String exportFileName(String tripName, ExpenseExportFormat f) {
  const from =
      'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
  const to =
      'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
  final lower = tripName.toLowerCase();
  final buf = StringBuffer();
  for (final ch in lower.split('')) {
    final i = from.indexOf(ch);
    buf.write(i >= 0 ? to[i] : ch);
  }
  var slug = buf
      .toString()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  if (slug.isEmpty) slug = 'chuyen_di';
  if (slug.length > 40) slug = slug.substring(0, 40);
  final stamp = DateFormat('yyyyMMdd').format(DateTime.now());
  return 'tripmate_chi_tieu_${slug}_$stamp.${f.name}';
}

/// Dựng file, ghi vào thư mục tạm rồi mở khung chia sẻ của máy.
Future<void> exportAndShareExpenses({
  required ExpenseExportFormat format,
  required String tripName,
  required List<Expense> expenses,
  required BalancesResult balances,
  required String locale,
}) async {
  final Uint8List bytes = switch (format) {
    ExpenseExportFormat.csv => Uint8List.fromList(
      utf8.encode(
        buildExpenseCsv(
          tripName: tripName,
          expenses: expenses,
          balances: balances,
        ),
      ),
    ),
    ExpenseExportFormat.pdf => await buildExpensePdf(
      tripName: tripName,
      expenses: expenses,
      balances: balances,
      locale: locale,
    ),
  };
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${exportFileName(tripName, format)}');
  await file.writeAsBytes(bytes, flush: true);
  await Share.shareXFiles([
    XFile(
      file.path,
      mimeType: format == ExpenseExportFormat.csv
          ? 'text/csv'
          : 'application/pdf',
    ),
  ], subject: '${'expense.split_title'.tr()} · $tripName');
}
