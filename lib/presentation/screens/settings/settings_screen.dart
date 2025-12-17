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
            '${tx.id},${tx.amount.toMajor()},${tx.type.name},${tx.categoryId},${tx.accountId},${tx.toAccountId ?? ""},${tx.date.value.toIso8601String()},"${tx.note.value.replaceAll('"', '""')}"');
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
        // TODO: Implement actual CSV parsing and database insertion
        // This requires careful handling of IDs and existing data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم اختيار الملف. وظيفة الاستيراد قيد التطوير.')),
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
