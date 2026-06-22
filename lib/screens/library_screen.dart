import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/screen_header.dart';
import '../data/library_data.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String? _selectedUnit;

  IconData _iconFor(String type) {
    switch (type) {
      case 'Past Paper':
        return Icons.assignment_outlined;
      case 'eBook':
        return Icons.menu_book_outlined;
      case 'Slides':
        return Icons.slideshow_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final units = LibraryData.units;
    final filtered = _selectedUnit == null
        ? LibraryData.resources
        : LibraryData.resources.where((r) => r.unit == _selectedUnit).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(eyebrow: 'ACADEMICS', title: 'Library & resources'),
              const SizedBox(height: AppSpacing.lg),

              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterChip('All', _selectedUnit == null, () => setState(() => _selectedUnit = null)),
                    const SizedBox(width: 8),
                    ...units.map((u) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _filterChip(u, _selectedUnit == u, () => setState(() => _selectedUnit = u)),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final r = filtered[index];
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.violetSoft,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            alignment: Alignment.center,
                            child: Icon(_iconFor(r.type), size: 18, color: AppColors.violet),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.title, style: Theme.of(context).textTheme.titleMedium,
                                    maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text('${r.unit} · ${r.type} · ${r.sizeLabel}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11.5)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Downloading "${r.title}"...')),
                              );
                            },
                            icon: const Icon(Icons.download_outlined, color: AppColors.violet, size: 20),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.violet : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: selected ? AppColors.violet : AppColors.divider),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
