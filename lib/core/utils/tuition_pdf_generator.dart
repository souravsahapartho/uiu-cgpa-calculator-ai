import 'dart:typed_data';
import 'package:flutter/material.dart' show BuildContext, ScaffoldMessenger, SnackBar, Text;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/user_profile_provider.dart';

class TuitionPdfGenerator {
  static String _formatMoney(double amount) {
    final rounded = amount.round().toString();
    return rounded.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  static Future<Uint8List> generatePdfBytes({
    required UserProfile profile,
    required String system,
    required double creditFee,
    required double sessionFee,
    required double regularCredits,
    required double firstRetakeCr,
    required double subRetakeCr,
    required double regularTuition,
    required double firstRetakeTuition,
    required double subRetakeTuition,
    required double firstRetakeDiscount,
    required String discountType,
    required double discountPct,
    required double waiverDiscount,
    required double totalDiscount,
    required double lateFine,
    required int missedInstallments,
    required double totalPayable,
  }) async {
    final pdf = pw.Document();

    final totalRegCredits = regularCredits + firstRetakeCr + subRetakeCr;
    final totalWithFine = totalPayable;
    final now = DateTime.now();

    final primaryColor = PdfColor.fromHex('#EA580C');
    final darkHeader = PdfColor.fromHex('#0F172A');
    final subtleBg = PdfColor.fromHex('#F8FAFC');
    final borderGray = PdfColor.fromHex('#E2E8F0');
    final textDark = PdfColor.fromHex('#1E293B');
    final textMuted = PdfColor.fromHex('#64748B');
    final successColor = PdfColor.fromHex('#059669');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: darkHeader,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'UNITED INTERNATIONAL UNIVERSITY',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'OFFICIAL TUITION & ACADEMIC FEE BREAKDOWN',
                          style: pw.TextStyle(
                            color: primaryColor,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'DATE: ${_formatDate(now)}',
                          style: const pw.TextStyle(color: PdfColors.white, fontSize: 8),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'SYSTEM: ${system.toUpperCase()}',
                          style: pw.TextStyle(
                            color: primaryColor,
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 14),

              // Student Info Card
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: pw.BoxDecoration(
                  color: subtleBg,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border.all(color: borderGray),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('STUDENT NAME', style: pw.TextStyle(color: textMuted, fontSize: 7, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text(profile.name.isNotEmpty ? profile.name : 'UIU Student', style: pw.TextStyle(color: textDark, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 6),
                        pw.Text('STUDENT ID', style: pw.TextStyle(color: textMuted, fontSize: 7, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text(profile.studentId.isNotEmpty ? profile.studentId : 'N/A', style: pw.TextStyle(color: textDark, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('PROGRAM / DEPT', style: pw.TextStyle(color: textMuted, fontSize: 7, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text(profile.program.isNotEmpty ? profile.program : profile.department, style: pw.TextStyle(color: textDark, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 6),
                        pw.Text('BATCH & CGPA', style: pw.TextStyle(color: textMuted, fontSize: 7, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text('Batch ${profile.batch.isNotEmpty ? profile.batch : '—'} • CGPA ${profile.currentCGPA.toStringAsFixed(2)}', style: pw.TextStyle(color: textDark, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('TOTAL REGISTERED CREDITS', style: pw.TextStyle(color: textMuted, fontSize: 7, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text('${totalRegCredits.toStringAsFixed(1)} Credits', style: pw.TextStyle(color: primaryColor, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 6),
                        pw.Text('RATE PER CREDIT', style: pw.TextStyle(color: textMuted, fontSize: 7, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text('${_formatMoney(creditFee)} BDT', style: pw.TextStyle(color: textDark, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 14),

              // Fee Breakdown Table
              pw.Text('1. FEE & COURSEWORK BREAKDOWN', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: textDark)),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: borderGray, width: 0.8),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: subtleBg),
                    children: [
                      _th('Description', align: pw.TextAlign.left),
                      _th('Credits'),
                      _th('Rate (BDT)'),
                      _th('Total Amount (BDT)', align: pw.TextAlign.right),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _td('Regular Course Tuition'),
                      _td('${regularCredits.toStringAsFixed(1)} Cr'),
                      _td(_formatMoney(creditFee)),
                      _td('${_formatMoney(regularTuition)} BDT', align: pw.TextAlign.right),
                    ],
                  ),
                  if (firstRetakeCr > 0)
                    pw.TableRow(
                      children: [
                        _td('1st-Time Retake (50% UIU Flat Reduction)'),
                        _td('${firstRetakeCr.toStringAsFixed(1)} Cr'),
                        _td(_formatMoney(creditFee / 2)),
                        _td('${_formatMoney(firstRetakeTuition)} BDT', align: pw.TextAlign.right),
                      ],
                    ),
                  if (subRetakeCr > 0)
                    pw.TableRow(
                      children: [
                        _td('Subsequent Retake Tuition (Full Rate)'),
                        _td('${subRetakeCr.toStringAsFixed(1)} Cr'),
                        _td(_formatMoney(creditFee)),
                        _td('${_formatMoney(subRetakeTuition)} BDT', align: pw.TextAlign.right),
                      ],
                    ),
                  pw.TableRow(
                    children: [
                      _td('${system == 'trimester' ? 'Trimester' : 'Semester'} Session Fee'),
                      _td('—'),
                      _td('Fixed'),
                      _td('${_formatMoney(sessionFee)} BDT', align: pw.TextAlign.right),
                    ],
                  ),
                  if (missedInstallments > 0)
                    pw.TableRow(
                      children: [
                        _td('Late Fine ($missedInstallments missed installment@ 500 BDT)'),
                        _td('—'),
                        _td('500 / missed'),
                        _td('+${_formatMoney(lateFine)} BDT', align: pw.TextAlign.right),
                      ],
                    ),
                ],
              ),

              pw.SizedBox(height: 12),

              // Deductions & Scholarships Table
              pw.Text('2. DEDUCTIONS, SCHOLARSHIP & WAIVER SUMMARY', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: textDark)),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: borderGray, width: 0.8),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: subtleBg),
                    children: [
                      _th('Discount Category', align: pw.TextAlign.left),
                      _th('Applied %'),
                      _th('Credit Eligibility'),
                      _th('Savings (BDT)', align: pw.TextAlign.right),
                    ],
                  ),
                  if (firstRetakeDiscount > 0)
                    pw.TableRow(
                      children: [
                        _td('1st Retake Flat Reduction'),
                        _td('50%'),
                        _td('${firstRetakeCr.toStringAsFixed(1)} Cr'),
                        _td('−${_formatMoney(firstRetakeDiscount)} BDT', align: pw.TextAlign.right, color: successColor),
                      ],
                    ),
                  if (waiverDiscount > 0)
                    pw.TableRow(
                      children: [
                        _td(discountType == 'scholarship' ? 'Merit Scholarship' : 'Tuition Waiver'),
                        _td('${discountPct.toStringAsFixed(0)}%'),
                        _td(discountType == 'scholarship' ? 'Max 13.0 Credits' : 'All Eligible Credits'),
                        _td('−${_formatMoney(waiverDiscount)} BDT', align: pw.TextAlign.right, color: successColor),
                      ],
                    ),
                  pw.TableRow(
                    children: [
                      _td('TOTAL DISCOUNT APPLIED', isBold: true),
                      _td('—', isBold: true),
                      _td('—', isBold: true),
                      _td('−${_formatMoney(totalDiscount)} BDT', align: pw.TextAlign.right, isBold: true, color: successColor),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              // Final Total Payable Card
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('NET TOTAL PAYABLE TUITION FEE', style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          missedInstallments > 0
                              ? 'Includes course tuition, session fee & ${_formatMoney(lateFine)} BDT late fines'
                              : 'Includes course tuition and academic session fee after all discounts',
                          style: const pw.TextStyle(color: PdfColors.white, fontSize: 7),
                        ),
                      ],
                    ),
                    pw.Text(
                      '৳ ${_formatMoney(totalWithFine)} BDT',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 14),

              // Installment Schedule
              pw.Text('3. PAYMENT & INSTALLMENT SCHEDULE', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: textDark)),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: borderGray, width: 0.8),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: subtleBg),
                    children: [
                      _th('Installment Stage', align: pw.TextAlign.left),
                      _th('Share (%)'),
                      _th('Timeline / Milestone'),
                      _th('Payable Amount (BDT)', align: pw.TextAlign.right),
                    ],
                  ),
                  if (system == 'trimester') ...[
                    pw.TableRow(
                      children: [
                        _td('1st Installment'),
                        _td('40%'),
                        _td('Course Registration & Term Opening'),
                        _td('${_formatMoney(totalWithFine * 0.40)} BDT', align: pw.TextAlign.right, isBold: true),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _td('2nd Installment'),
                        _td('30%'),
                        _td('Prior to Midterm Examinations'),
                        _td('${_formatMoney(totalWithFine * 0.30)} BDT', align: pw.TextAlign.right, isBold: true),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _td('3rd Installment'),
                        _td('30%'),
                        _td('Prior to Final Examinations'),
                        _td('${_formatMoney(totalWithFine * 0.30)} BDT', align: pw.TextAlign.right, isBold: true),
                      ],
                    ),
                  ] else ...[
                    pw.TableRow(
                      children: [
                        _td('1st Installment'),
                        _td('25%'),
                        _td('Course Registration & Start'),
                        _td('${_formatMoney(totalWithFine * 0.25)} BDT', align: pw.TextAlign.right, isBold: true),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _td('2nd Installment'),
                        _td('25%'),
                        _td('Before 1st Term Assessment'),
                        _td('${_formatMoney(totalWithFine * 0.25)} BDT', align: pw.TextAlign.right, isBold: true),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _td('3rd Installment'),
                        _td('25%'),
                        _td('Before Midterm Examinations'),
                        _td('${_formatMoney(totalWithFine * 0.25)} BDT', align: pw.TextAlign.right, isBold: true),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _td('4th Installment'),
                        _td('25%'),
                        _td('Before Final Examinations'),
                        _td('${_formatMoney(totalWithFine * 0.25)} BDT', align: pw.TextAlign.right, isBold: true),
                      ],
                    ),
                  ],
                ],
              ),

              pw.Spacer(),

              // Notes & Rules
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: subtleBg,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border.all(color: borderGray),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('UIU Official Policies:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7, color: textDark)),
                    pw.SizedBox(height: 3),
                    pw.Text('• 1st-Time Retake Policy: Students receive 50% tuition reduction on retaking any course for the first time.', style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700)),
                    pw.Text('• Scholarship Limit: Merit scholarship is capped at a maximum of 13 credits per trimester.', style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700)),
                    pw.Text('• Late Fine Policy: A late fee of 500 BDT applies per missed installment deadline.', style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700)),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),

              // Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Generated via UIU CGPA Calculator AI (Official)', style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 7)),
                  pw.Text('Developer: Sourav Saha (www.sourav.com.bd)', style: pw.TextStyle(color: primaryColor, fontSize: 7, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> printOrDownloadPdf({
    required BuildContext context,
    required UserProfile profile,
    required String system,
    required double creditFee,
    required double sessionFee,
    required double regularCredits,
    required double firstRetakeCr,
    required double subRetakeCr,
    required double regularTuition,
    required double firstRetakeTuition,
    required double subRetakeTuition,
    required double firstRetakeDiscount,
    required String discountType,
    required double discountPct,
    required double waiverDiscount,
    required double totalDiscount,
    required double lateFine,
    required int missedInstallments,
    required double totalPayable,
  }) async {
    try {
      final pdfBytes = await generatePdfBytes(
        profile: profile,
        system: system,
        creditFee: creditFee,
        sessionFee: sessionFee,
        regularCredits: regularCredits,
        firstRetakeCr: firstRetakeCr,
        subRetakeCr: subRetakeCr,
        regularTuition: regularTuition,
        firstRetakeTuition: firstRetakeTuition,
        subRetakeTuition: subRetakeTuition,
        firstRetakeDiscount: firstRetakeDiscount,
        discountType: discountType,
        discountPct: discountPct,
        waiverDiscount: waiverDiscount,
        totalDiscount: totalDiscount,
        lateFine: lateFine,
        missedInstallments: missedInstallments,
        totalPayable: totalPayable,
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'UIU_Tuition_Fee_Breakdown_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    }
  }

  static pw.Widget _th(String text, {pw.TextAlign align = pw.TextAlign.center}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#1E293B')),
      ),
    );
  }

  static pw.Widget _td(String text, {pw.TextAlign align = pw.TextAlign.center, bool isBold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4.5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColor.fromHex('#334155'),
        ),
      ),
    );
  }
}
