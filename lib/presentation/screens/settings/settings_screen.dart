import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_text_styles.dart';
import '../../styles/app_spacing.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../../application/providers/usecases_providers.dart';
import '../../../core/utils/result.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/models/transaction_type.dart';

/// شاشة الإعدادات
/// التصميم مبني على SCREENS_DOCUMENTATION.md
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: GradientBackground.dashboard(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.gapLg),
                  _buildSettingsSections(context, ref),
                  const SizedBox(height: AppSpacing.gapLg),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      // 1. Fetch data
      final result = await ref.read(getTransactionsUseCaseProvider).execute();
      if (result is! Success<List<TransactionEntity>>) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في جلب البيانات للتصدير')),
        );
        return;
      }
      final transactions = (result as Success<List<TransactionEntity>>).value;

      if (transactions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا توجد بيانات للتصدير')),
        );
        return;
      }

      // 2. Convert to CSV
      final buffer = StringBuffer();
      buffer.writeln('ID,Amount,Type,Category,Account,ToAccount,Date,Note');
      for (var tx in transactions) {
        buffer.writeln(
            '${tx.id},${tx.amount.toMajor()},${tx.type.name},${tx.categoryId},${tx.accountId},${tx.toAccountId ?? ""},${tx.date.value.toIso8601String()},"${tx.note?.value.replaceAll('"', '""') ?? ''}"');
      }

      // 3. Write to file
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/transactions_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(buffer.toString());

      // 4. Share
      await Share.shareXFiles([XFile(file.path)], text: 'تصدير معاملات ميزانيتي');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء التصدير: $e')),
      );
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final lines = content.split('\n');

        if (lines.length <= 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('الملف فارغ أو لا يحتوي على بيانات')),
          );
          return;
        }

        int successCount = 0;
        int failCount = 0;
        final addTransactionUseCase = ref.read(addTransactionUseCaseProvider);

        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => const Center(child: CircularProgressIndicator()),
        );

        // Skip header
        for (var i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;

          try {
            // CSV parsing (basic split by comma, handling quotes for note if needed)
            // Note: This is a simple parser. For robust parsing, use a csv package.
            // Assuming the export format: ID,Amount,Type,Category,Account,ToAccount,Date,Note
            // Note might contain commas, so we need to be careful.
            // But export used: "${tx.note.value.replaceAll('"', '""')}"
            // A simple split(',') will break if note has commas.
            // For MVP without adding 'csv' package dependency, we'll assume simple notes or use regex.
            
            // Let's try to add 'csv' package? No, user said "Don't add files unless necessary".
            // I can use a simple regex for CSV or just split if I know the structure.
            // Export format: ID,Amount,Type,Category,Account,ToAccount,Date,"Note"
            
            final parts = line.split(',');
            if (parts.length < 8) {
               // Handle case where note might be split
               // This is tricky without a proper parser.
               // Let's try to parse from the beginning.
            }
            
            // Safer manual parsing logic:
            final values = <String>[];
            bool inQuotes = false;
            StringBuffer currentValue = StringBuffer();
            
            for (int j = 0; j < line.length; j++) {
              final char = line[j];
              if (char == '"') {
                if (j + 1 < line.length && line[j+1] == '"') {
                  currentValue.write('"');
                  j++; // skip escaped quote
                } else {
                  inQuotes = !inQuotes;
                }
              } else if (char == ',' && !inQuotes) {
                values.add(currentValue.toString());
                currentValue.clear();
              } else {
                currentValue.write(char);
              }
            }
            values.add(currentValue.toString());

            if (values.length < 8) {
              failCount++;
              continue;
            }

            // Parse values
            // 0: ID (ignored)
            // 1: Amount (Major)
            final amountMajor = double.tryParse(values[1]) ?? 0.0;
            final amountMinor = (amountMajor * 100).round();
            
            // 2: Type
            final typeStr = values[2];
            final type = TransactionType.values.firstWhere(
              (e) => e.name == typeStr,
              orElse: () => TransactionType.expense,
            );
            
            // 3: CategoryId
            final categoryId = values[3];
            
            // 4: AccountId
            final accountId = values[4];
            
            // 5: ToAccountId
            final toAccountId = values[5].isEmpty ? null : values[5];
            
            // 6: Date
            final dateStr = values[6];
            final date = DateTime.tryParse(dateStr) ?? DateTime.now();
            
            // 7: Note
            final note = values[7];

            final res = await addTransactionUseCase.call(
              amountMinor: amountMinor,
              type: type,
              categoryId: categoryId,
              accountId: accountId,
              date: date,
              note: note,
              toAccountId: toAccountId,
            );

            if (res is Success) {
              successCount++;
            } else {
              failCount++;
            }
          } catch (e) {
            failCount++;
          }
        }

        // Hide loading
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم الاستيراد: $successCount ناجح، $failCount فاشل'),
            backgroundColor: failCount > 0 ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الاستيراد: $e')),
      );
    }
  }

  /// بناء رأس الصفحة
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.paddingMd),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(AppSpacing.paddingMd),
        borderRadius: BorderRadius.circular(32),
        blurStrength: 24,
        child: Center(child: Text('الإعدادات', style: AppTextStyles.h1)),
      ),
    );
  }

  /// بناء أقسام الإعدادات
  Widget _buildSettingsSections(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // قسم الإعدادات العامة
          _buildSectionLabel('الإعدادات العامة'),
          const SizedBox(height: AppSpacing.gapSm),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: Icons.attach_money,
              title: 'العملة',
              subtitle: 'SYP - ليرة سورية',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('قريباً')),
                );
              },
            ),
            _buildDivider(),
            _buildSettingsItem(
              icon: Icons.language,
              title: 'اللغة',
              subtitle: 'العربية',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('قريباً')),
                );
              },
            ),
          ]),

          const SizedBox(height: AppSpacing.gapLg),

          // قسم البيانات
          _buildSectionLabel('البيانات'),
          const SizedBox(height: AppSpacing.gapSm),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: Icons.download,
              title: 'تصدير البيانات',
              subtitle: 'تصدير إلى CSV',
              onTap: () => _exportData(context, ref),
            ),
            _buildDivider(),
            _buildSettingsItem(
              icon: Icons.upload,
              title: 'استيراد البيانات',
              subtitle: 'استيراد من ملف CSV',
              onTap: () => _importData(context, ref),
            ),
            _buildDivider(),
            _buildSettingsItem(
              icon: Icons.cloud,
              title: 'النسخ الاحتياطي',
              subtitle: 'نسخ احتياطي سحابي',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('قريباً')),
                );
              },
            ),
          ]),

          const SizedBox(height: AppSpacing.gapLg),

          // قسم أخرى
          _buildSectionLabel('أخرى'),
          const SizedBox(height: AppSpacing.gapSm),
          _buildSettingsCard([
            _buildSettingsItem(
              icon: Icons.info_outline,
              title: 'معلومات التطبيق',
              subtitle: 'الإصدار 1.0.0',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'ميزانيتي',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.account_balance_wallet, size: 48, color: AppColors.primaryMain),
                  children: [
                    const Text('تطبيق لإدارة المصاريف والميزانية الشخصية.'),
                  ],
                );
              },
            ),
          ]),
        ],
      ),
    );
  }

  /// تسمية القسم
  Widget _buildSectionLabel(String label) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingMd,
        vertical: AppSpacing.paddingSm,
      ),
      borderRadius: BorderRadius.circular(9999),
      backgroundOpacity: 0.5,
      blurStrength: 16,
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF374151)),
      ),
    );
  }

  /// بطاقة الإعدادات
  Widget _buildSettingsCard(List<Widget> children) {
    return GlassmorphicContainer(
      backgroundOpacity: 0.6,
      blurStrength: 16,
      borderRadius: BorderRadius.circular(24),
      child: Column(children: children),
    );
  }

  /// عنصر إعداد واحد
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.paddingMd + 4),
          child: Row(
            children: [
              // دائرة الأيقونة
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark.withOpacity(0.15),
                      AppColors.primaryMain.withOpacity(0.1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 20, color: AppColors.primaryDark),
              ),
              const SizedBox(width: AppSpacing.gapMd),
              // النصوص
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.body),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
              // سهم التنقل
              Icon(Icons.chevron_left, size: 20, color: AppColors.gray400),
            ],
          ),
        ),
      ),
    );
  }

  /// الخط الفاصل بين العناصر
  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingMd),
      color: Colors.black.withOpacity(0.05),
    );
  }

  /// التذييل مع رقم الإصدار
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.paddingMd),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.paddingMd),
        borderRadius: BorderRadius.circular(16),
        backgroundOpacity: 0.4,
        blurStrength: 16,
        child: Column(
          children: [
            Text(
              'الإصدار 1.0.0',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray400),
            ),
            const SizedBox(height: 4),
            Text(
              'صُنع بـ ❤️ في سوريا',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.gray300,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
