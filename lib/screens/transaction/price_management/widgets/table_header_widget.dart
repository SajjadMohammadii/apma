import 'package:apma_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class TableHeaderWidget extends StatelessWidget {
  final int? sortColumnIndex;
  final bool isAscending;
  final Function(int) onSort;

  const TableHeaderWidget({
    super.key,
    required this.sortColumnIndex,
    required this.isAscending,
    required this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                _buildSortableHeader(
                  'ردیف',
                  flex: 1,
                  index: -1,
                ), // ردیف سورت نمیخوره
                _buildDivider(),
                _buildSortableHeader('تاریخ پیش فاکتور', flex: 2, index: 0),
                _buildDivider(),
                _buildSortableHeader('شماره پیش فاکتور', flex: 2, index: 1),
                _buildDivider(),
                _buildSortableHeader('مشتری', flex: 3, index: 2),
                _buildDivider(),
                _buildSortableHeader('صادرکننده', flex: 2, index: 3),
              ],
            ),
          ),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.3),
            margin: const EdgeInsets.only(top: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildSortableHeader(
    String text, {
    required int flex,
    required int index,
  }) {
    final isActive = sortColumnIndex == index;
    final isSortable = index >= 0; // ردیف سورت نمیخوره

    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: isSortable ? () => onSort(index) : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Vazir',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSortable) ...[
              const SizedBox(width: 4),
              Icon(
                isActive
                    ? (isAscending ? Icons.arrow_upward : Icons.arrow_downward)
                    : Icons.unfold_more,
                color: Colors.white,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, color: Colors.white.withOpacity(0.3));
  }
}
