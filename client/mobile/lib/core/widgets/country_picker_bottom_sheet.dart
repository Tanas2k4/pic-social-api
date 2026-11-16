import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:solar_icons/solar_icons.dart';
import '../constants/app_colors.dart';
import '../constants/country_codes.dart';

class CountryPickerBottomSheet extends StatefulWidget {
  final CountryCodeItem selectedCountry;
  final ValueChanged<CountryCodeItem> onSelect;

  const CountryPickerBottomSheet({
    super.key,
    required this.selectedCountry,
    required this.onSelect,
  });

  static Future<CountryCodeItem?> show(
    BuildContext context, {
    required CountryCodeItem currentCountry,
  }) {
    return showModalBottomSheet<CountryCodeItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CountryPickerBottomSheet(
        selectedCountry: currentCountry,
        onSelect: (item) => Navigator.pop(ctx, item),
      ),
    );
  }

  @override
  State<CountryPickerBottomSheet> createState() => _CountryPickerBottomSheetState();
}

class _CountryPickerBottomSheetState extends State<CountryPickerBottomSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<CountryCodeItem> _filteredList = CountryCodes.list;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredList = CountryCodes.list;
      } else {
        _filteredList = CountryCodes.list.where((item) {
          return item.name.toLowerCase().contains(query) ||
              item.dialCode.toLowerCase().contains(query) ||
              item.code.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.75;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(SolarIconsOutline.global, size: 20, color: Colors.white70),
                SizedBox(width: 8),
                Text(
                  'Chọn mã quốc gia',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Search box - Không viền (Border-free)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên hoặc mã (+84, US, VN)...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
                  prefixIcon: Icon(SolarIconsOutline.magnifier, color: Colors.white.withValues(alpha: 0.4), size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(12, 8, 12, mediaQuery.padding.bottom + 16),
              itemCount: _filteredList.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.white.withValues(alpha: 0.05),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final item = _filteredList[index];
                final isSelected = item.dialCode == widget.selectedCountry.dialCode &&
                    item.code == widget.selectedCountry.code;

                return ListTile(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onSelect(item);
                  },
                  dense: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  leading: Text(
                    item.flag,
                    style: const TextStyle(fontSize: 22),
                  ),
                  title: Text(
                    item.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.dialCode,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white54,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        const Icon(SolarIconsBold.checkCircle, color: Colors.white, size: 16),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
