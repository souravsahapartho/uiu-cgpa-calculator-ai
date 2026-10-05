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
    final statementRef = 'UIU-TF-${now.millisecondsSinceEpoch.toString().substring(5)}';

    final primaryOrange = PdfColor.fromHex('#EA580C');
    final darkNavy = PdfColor.fromHex('#0F172A');
    final lightNavy = PdfColor.fromHex('#1E293B');
    final softBg = PdfColor.fromHex('#F8FAFC');
    final altRowBg = PdfColor.fromHex('#F1F5F9');
    final borderGray = PdfColor.fromHex('#CBD5E1');
    final textDark = PdfColor.fromHex('#0F172A');
    final textMuted = PdfColor.fromHex('#475569');
    final successGreen = PdfColor.fromHex('#047857');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 26),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Top Header Banner
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: pw.BoxDecoration(
                  color: darkNavy,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'UNITED INTERNATIONAL UNIVERSITY',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'OFFICIAL TUITION STATEMENT & INSTALLMENT BREAKDOWN',
                          style: pw.TextStyle(
                            color: primaryOrange,
                            fontSize: 8.5,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: pw.BoxDecoration(
                        color: lightNavy,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                        border: pw.Border.all(color: primaryOrange, width: 0.8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'REF: $statementRef',
                            style: pw.TextStyle(color: PdfColors.white, fontSize: 7.5, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'SYSTEM: ${system.toUpperCase()} (3 TERMS/YR)',
                            style: pw.TextStyle(color: primaryOrange, fontSize: 7, fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // Student & Academic Profile Card
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: softBg,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border.all(color: borderGray, width: 0.8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // Col 1: Student
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('STUDENT NAME', style: pw.TextStyle(color: textMuted, fontSize: 6.5, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2),
                          pw.Text(profile.name.isNotEmpty ? profile.name : 'UIU Student', style: pw.TextStyle(color: textDark, fontSize: 9.5, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 5),
                          pw.Text('STUDENT ID', style: pw.TextStyle(color: textMuted, fontSize: 6.5, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2),
                          pw.Text(profile.studentId.isNotEmpty ? profile.studentId : 'N/A', style: pw.TextStyle(color: textDark, fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                    // Col 2: Program & Batch
                    pw.Expanded(
                      flex: 4,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('PROGRAM & DEPARTMENT', style: pw.TextStyle(color: textMuted, fontSize: 6.5, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2),
                          pw.Text(profile.program.isNotEmpty ? profile.program : profile.department, style: pw.TextStyle(color: textDark, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 5),
                          pw.Text('BATCH & STANDING CGPA', style: pw.TextStyle(color: textMuted, fontSize: 6.5, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2),
                          pw.Text('Batch: ${profile.batch.isNotEmpty ? profile.batch : "-"}   |   CGPA: ${profile.currentCGPA.toStringAsFixed(2)}', style: pw.TextStyle(color: textDark, fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                    // Col 3: Credits & Rate
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('REGISTERED CREDITS', style: pw.TextStyle(color: textMuted, fontSize: 6.5, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2),
                          pw.Text('${totalRegCredits.toStringAsFixed(1)} Credits', style: pw.TextStyle(color: primaryOrange, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 5),
                          pw.Text('PER CREDIT RATE', style: pw.TextStyle(color: textMuted, fontSize: 6.5, fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2),
                          pw.Text('${_formatMoney(creditFee)} BDT', style: pw.TextStyle(color: textDark, fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // Section 1: Coursework & Fee Breakdown Table
              _sectionTitle('1. COURSEWORK & TUITION FEE BREAKDOWN'),
              pw.SizedBox(height: 4),
              pw.Table(
                border: pw.TableBorder.all(color: borderGray, width: 0.6),
                columnWidths: {
                  0: const pw.FlexColumnWidth(5),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2.5),
                  3: const pw.FlexColumnWidth(3),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: darkNavy),
                    children: [
                      _thWhite('Item Description', align: pw.TextAlign.left),
                      _thWhite('Credits'),
                      _thWhite('Unit Rate (BDT)'),
                      _thWhite('Gross Amount (BDT)', align: pw.TextAlign.right),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _td('Regular Registered Coursework'),
                      _td('${regularCredits.toStringAsFixed(1)} Cr'),
                      _td(_formatMoney(creditFee)),
                      _td('${_formatMoney(regularTuition)} BDT', align: pw.TextAlign.right, isBold: true),
                    ],
                  ),
                  if (firstRetakeCr > 0)
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: altRowBg),
                      children: [
                        _td('1st-Time Retake (50% UIU Flat Reduction)'),
                        _td('${firstRetakeCr.toStringAsFixed(1)} Cr'),
                        _td(_formatMoney(creditFee / 2)),
                        _td('${_formatMoney(firstRetakeTuition)} BDT', align: pw.TextAlign.right, isBold: true),
                      ],
                    ),
                  if (subRetakeCr > 0)
                    pw.TableRow(
                      children: [
                        _td('Subsequent Retake Coursework (Full Rate)'),
                        _td('${subRetakeCr.toStringAsFixed(1)} Cr'),
                        _td(_formatMoney(creditFee)),
                        _td('${_formatMoney(subRetakeTuition)} BDT', align: pw.TextAlign.right, isBold: true),
                      ],
                    ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: altRowBg),
                    children: [
                      _td('${system == 'trimester' ? 'Trimester' : 'Semester'} Academic Session Fee'),
                      _td('Fixed'),
                      _td('Fixed'),
                      _td('${_formatMoney(sessionFee)} BDT', align: pw.TextAlign.right, isBold: true),
                    ],
                  ),
                  if (missedInstallments > 0)
                    pw.TableRow(
                      children: [
                        _td('Late Fine ($missedInstallments missed installment deadlines)'),
                        _td('N/A'),
                        _td('500 / missed'),
                        _td('+ ${_formatMoney(lateFine)} BDT', align: pw.TextAlign.right, color: PdfColors.red700, isBold: true),
                      ],
                    ),
                ],
              ),

              pw.SizedBox(height: 10),

              // Section 2: Deductions & Scholarships
              _sectionTitle('2. SCHOLARSHIP, WAIVER & DEDUCTIONS SUMMARY'),
              pw.SizedBox(height: 4),
              pw.Table(
                border: pw.TableBorder.all(color: borderGray, width: 0.6),
                columnWidths: {
                  0: const pw.FlexColumnWidth(5),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2.5),
                  3: const pw.FlexColumnWidth(3),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: lightNavy),
                    children: [
                      _thWhite('Discount Category', align: pw.TextAlign.left),
                      _thWhite('Applied %'),
                      _thWhite('Credit Scope'),
                      _thWhite('Savings Amount (BDT)', align: pw.TextAlign.right),
                    ],
                  ),
                  if (firstRetakeDiscount > 0)
                    pw.TableRow(
                      children: [
                        _td('1st-Time Retake 50% Reduction'),
                        _td('50%'),
                        _td('${firstRetakeCr.toStringAsFixed(1)} Cr'),
                        _td('- ${_formatMoney(firstRetakeDiscount)} BDT', align: pw.TextAlign.right, color: successGreen, isBold: true),
                      ],
                    ),
                  if (waiverDiscount > 0)
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: altRowBg),
                      children: [
                        _td(discountType == 'scholarship' ? 'Merit Scholarship (Official Policy)' : 'Tuition Fee Waiver'),
                        _td('${discountPct.toStringAsFixed(0)}%'),
                        _td(discountType == 'scholarship' ? 'Max 13.0 Cr' : 'All Eligible Cr'),
                        _td('- ${_formatMoney(waiverDiscount)} BDT', align: pw.TextAlign.right, color: successGreen, isBold: true),
                      ],
                    ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: softBg),
                    children: [
                      _td('TOTAL DEDUCTIONS & DISCOUNTS', isBold: true),
                      _td('Total', isBold: true),
                      _td('Applied', isBold: true),
                      _td('- ${_formatMoney(totalDiscount)} BDT', align: pw.TextAlign.right, isBold: true, color: successGreen),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // Executive Total Payable Bar
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: pw.BoxDecoration(
                  color: primaryOrange,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'NET TOTAL PAYABLE TUITION FEE',
                          style: pw.TextStyle(color: PdfColors.white, fontSize: 9.5, fontWeight: pw.FontWeight.bold, letterSpacing: 0.5),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          missedInstallments > 0
                              ? 'Includes tuition, session fee & ${_formatMoney(lateFine)} BDT late fines'
                              : 'Includes coursework tuition and academic session fee after all deductions',
                          style: const pw.TextStyle(color: PdfColors.white, fontSize: 7),
                        ),
                      ],
                    ),
                    pw.Text(
                      'BDT ${_formatMoney(totalWithFine)}',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 17,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 10),

              // Section 3: Installment Schedule
              _sectionTitle('3. PAYMENT & INSTALLMENT SCHEDULE'),
              pw.SizedBox(height: 4),
              pw.Table(
                border: pw.TableBorder.all(color: borderGray, width: 0.6),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(4.5),
                  3: const pw.FlexColumnWidth(3),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: darkNavy),
                    children: [
                      _thWhite('Installment', align: pw.TextAlign.left),
                      _thWhite('Share (%)'),
                      _thWhite('Official Timeline / Milestone'),
                      _thWhite('Payable (BDT)', align: pw.TextAlign.right),
                    ],
                  ),
                  if (system == 'trimester') ...[
                    pw.TableRow(
                      children: [
                        _td('1st Installment', isBold: true),
                        _td('40%'),
                        _td('Course Registration & Term Opening'),
                        _td('${_formatMoney(totalWithFine * 0.40)} BDT', align: pw.TextAlign.right, isBold: true),
                      ],
                    ),
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: altRowBg),
                      children: [
                        _td('2nd Installment', isBold: true),
                        _td('30%'),
                        _td('Prior to Midterm Examination'),
                        _td('${_formatMoney(totalWithFine * 0.30)} BDT', align: pw.TextAlign.right, isBold: true),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _td('3rd Installment', isBold: true),
                        _td('30%'),
                        _td('Prior to Final Examination'),
                        _td('${_formatMoney(totalWithFine * 0.30)} BDT', align: pw.TextAlign.right, isBold: true),
                      ],
                    ),
                  ] else ...[
                    pw.TableRow(
                      children: [
                        _td('1st Installment', isBold: true),
                        _td('25%'),
                        _td('Course Registration & Start'),
                        _td('${_formatMoney(totalWithFine * 0.25)} BDT', align: pw.TextAlign.right, isBold: true),
                      ],
                    ),
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: altRowBg),
                      children: [
                        _td('2nd Installment', isBold: true),
                        _td('25%'),
                        _td('Before 1st Term Assessment'),
                        _td('${_formatMoney(totalWithFine * 0.25)} BDT', align: pw.TextAlign.right, isBold: true),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        _td('3rd Installment', isBold: true),
                        _td('25%'),
                        _td('Prior to Midterm Examination'),
                        _td('${_formatMoney(totalWithFine * 0.25)} BDT', align: pw.TextAlign.right, isBold: true),
                      ],
                    ),
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: altRowBg),
                      children: [
                        _td('4th Installment', isBold: true),
                        _td('25%'),
                        _td('Prior to Final Examination'),
                        _td('${_formatMoney(totalWithFine * 0.25)} BDT', align: pw.TextAlign.right, isBold: true),
                      ],
                    ),
                  ],
                ],
              ),

              pw.SizedBox(height: 10),

              // Official Policies & Notes
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: softBg,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
                  border: pw.Border.all(color: borderGray, width: 0.6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('OFFICIAL UIU TUITION & SCHOLARSHIP POLICIES:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7, color: darkNavy)),
                    pw.SizedBox(height: 3),
                    _policyLine('1st-Time Retake Policy: Students receive a flat 50% tuition reduction on retaking any course for the first time.'),
                    _policyLine('Scholarship Cap: Merit scholarship discounts are applicable up to a maximum of 13.0 credits per trimester.'),
                    _policyLine('Late Payment Fine: A late penalty fee of BDT 500 applies per missed installment deadline.'),
                    _policyLine('Exam Clearance: Students must settle due installments prior to exam permit issuance according to academic calendar.'),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              // Signatures & Verification Area
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 140, height: 0.8, color: borderGray),
                      pw.SizedBox(height: 4),
                      pw.Text('Student Signature & Date', style: pw.TextStyle(fontSize: 7, color: textMuted)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(width: 140, height: 0.8, color: borderGray),
                      pw.SizedBox(height: 4),
                      pw.Text('Accounts Office / Authorized Verification', style: pw.TextStyle(fontSize: 7, color: textMuted)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // Footer
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 6),
                decoration: pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: borderGray, width: 0.6)),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Generated via UIU CGPA Calculator AI | Official Academic Companion', style: pw.TextStyle(color: textMuted, fontSize: 6.5)),
                    pw.Text('Developer: Sourav Saha (www.sourav.com.bd)', style: pw.TextStyle(color: primaryOrange, fontSize: 6.5, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
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

      final filename = 'UIU_Tuition_Fee_${profile.studentId.isNotEmpty ? profile.studentId : "Student"}.pdf';
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: filename,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    }
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 8.5,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromHex('#0F172A'),
        letterSpacing: 0.3,
      ),
    );
  }

  static pw.Widget _thWhite(String text, {pw.TextAlign align = pw.TextAlign.center}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4.5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      ),
    );
  }

  static pw.Widget _td(String text, {pw.TextAlign align = pw.TextAlign.center, bool isBold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColor.fromHex('#1E293B'),
        ),
      ),
    );
  }

  static pw.Widget _policyLine(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('- ', style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#EA580C'))),
          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey800),
            ),
          ),
        ],
      ),
    );
  }
}

