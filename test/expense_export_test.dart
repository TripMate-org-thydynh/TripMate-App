import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tripmate/features/expense_tracker/application/expense_export.dart';
import 'package:tripmate/features/expense_tracker/domain/expense.dart';

import 'helpers/localized.dart';

void main() {
  setUpAll(initLocalization);

  const an = ExpenseUser(id: 'a', name: 'An');
  const binh = ExpenseUser(id: 'b', name: 'Bình, "Béo"');

  final expenses = [
    Expense(
      id: '1',
      amount: 600000,
      category: 'FOOD',
      description: 'Lẩu gà lá é',
      splitType: 'EQUAL',
      paidBy: an,
      createdAt: DateTime(2026, 9, 20, 12),
      splits: const [
        ExpenseShare(user: an, shareAmount: 300000),
        ExpenseShare(user: binh, shareAmount: 300000),
      ],
    ),
    Expense(
      id: '2',
      amount: 200000,
      category: 'TRANSPORT',
      description: 'Taxi',
      splitType: 'EQUAL',
      paidBy: binh,
      createdAt: DateTime(2026, 9, 21, 9),
    ),
  ];
  const balances = BalancesResult(
    balances: [
      MemberBalance(user: an, balance: 200000),
      MemberBalance(user: binh, balance: -200000),
    ],
    settlements: [Settlement(from: binh, to: an, amount: 200000)],
  );

  String csv() => buildExpenseCsv(
    tripName: 'Đà Lạt chill',
    expenses: expenses,
    balances: balances,
  );

  test('CSV mở đầu bằng BOM để Excel đọc đúng dấu tiếng Việt', () {
    expect(csv().codeUnitAt(0), 0xFEFF);
  });

  test('CSV có từng khoản chi với số tiền dạng số trần', () {
    final out = csv();
    expect(out, contains('20/09/2026,Lẩu gà lá é,'));
    expect(out, contains(',An,600000,'));
    expect(out, contains('Tổng chi,800000'));
  });

  test('CSV bọc và thoát dấu phẩy / nháy kép trong tên', () {
    expect(csv(), contains('"Bình, ""Béo"""'));
  });

  test('CSV có phần chia cho từng người và gợi ý chuyển tiền', () {
    final out = csv();
    expect(out, contains('An: 300000'));
    expect(out, contains(',An,200000'));
  });

  test('PDF dựng được, có tên chuyến và số trang', () async {
    // Phông hệ thống có dấu tiếng Việt; không có thì bỏ qua (máy CI Linux).
    final ttf = File('C:/Windows/Fonts/arial.ttf');
    final ttfBold = File('C:/Windows/Fonts/arialbd.ttf');
    if (!ttf.existsSync() || !ttfBold.existsSync()) {
      markTestSkipped('Không có phông Arial trên máy này');
      return;
    }
    final bytes = await buildExpensePdf(
      tripName: 'Đà Lạt chill',
      expenses: expenses,
      balances: balances,
      locale: 'vi',
      regularFont: pw.Font.ttf(ttf.readAsBytesSync().buffer.asByteData()),
      boldFont: pw.Font.ttf(ttfBold.readAsBytesSync().buffer.asByteData()),
    );
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    final out = Platform.environment['EXPORT_PDF_OUT'];
    if (out != null) File(out).writeAsBytesSync(bytes);
  });

  test('Tên file bỏ dấu, bỏ ký tự lạ, đúng đuôi', () {
    final name = exportFileName('Đà Lạt: Săn mây!', ExpenseExportFormat.pdf);
    expect(
      name,
      matches(RegExp(r'^tripmate_chi_tieu_da_lat_san_may_\d{8}\.pdf$')),
    );
    expect(
      exportFileName('!!!', ExpenseExportFormat.csv),
      matches(RegExp(r'^tripmate_chi_tieu_chuyen_di_\d{8}\.csv$')),
    );
  });
}
