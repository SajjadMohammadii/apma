import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductionControl extends StatefulWidget {
  const ProductionControl({super.key});

  @override
  State<ProductionControl> createState() => _ProductionControlState();
}

class _ProductionControlState extends State<ProductionControl> {
  // ================= Controllers =================
  final jinsCtrl = TextEditingController();
  final rangCtrl = TextEditingController();
  final arzFromCtrl = TextEditingController();
  final arzToCtrl = TextEditingController();
  final toolFromCtrl = TextEditingController();
  final toolToCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  final customerCtrl = TextEditingController();

  final tedadCtrl = TextEditingController();
  final arzCtrl = TextEditingController();
  final toolCtrl = TextEditingController();
  final tighCtrl = TextEditingController();
  final faseleCtrl = TextEditingController();
  final rollOutCtrl = TextEditingController();

  // ================= States =================
  bool showSpecial = false;
  bool showClosed = false;
  bool enterProduction = false;
  String productionStatus = 'در حال تولید';

  @override
  void dispose() {
    jinsCtrl.dispose();
    rangCtrl.dispose();
    arzFromCtrl.dispose();
    arzToCtrl.dispose();
    toolFromCtrl.dispose();
    toolToCtrl.dispose();
    unitCtrl.dispose();
    customerCtrl.dispose();
    tedadCtrl.dispose();
    arzCtrl.dispose();
    toolCtrl.dispose();
    tighCtrl.dispose();
    faseleCtrl.dispose();
    rollOutCtrl.dispose();
    super.dispose();
  }

  bool get _isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  void initState() {
    super.initState();
    if (_isMobile) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('کنترل تولید')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              headerSection(),
              const SizedBox(height: 16),
              tablesSection(),
              const SizedBox(height: 16),
              productionControls(),
              const SizedBox(height: 16),
              actionButtons(),
              const SizedBox(height: 16),
              outputTable(),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Header Grid (3 ستون + فاصله ردیف 4px)

  Widget headerGrid({
    required BoxConstraints constraints,
    required List<Widget> children,
  }) {
    if (constraints.maxWidth < 600) {
      // حالت ستونی فشرده
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children
            .map(
              (w) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: w,
          ),
        )
            .toList(),
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 4,   // فاصله بین ردیف‌ها
      crossAxisSpacing: 8,  // فاصله بین ستون‌ها
      childAspectRatio: 3.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }

  // =========================================================
  // Header Section

  Widget headerSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: headerGrid(
              constraints: constraints,
              children: [
                field('جنس', jinsCtrl),
                field('رنگ', rangCtrl),
                field('عرض از', arzFromCtrl),
                field('عرض تا', arzToCtrl),
                field('طول از', toolFromCtrl),
                field('طول تا', toolToCtrl),
                field('واحد', unitCtrl),
                field('مشتری', customerCtrl),
                productionDropdown(),
                checkboxWidget(
                  'نمایش موارد خاص',
                  showSpecial,
                      (v) => setState(() => showSpecial = v),
                ),
                checkboxWidget(
                  'نمایش حواله بسته',
                  showClosed,
                      (v) => setState(() => showClosed = v),
                ),
                checkboxWidget(
                  'ورود به تولید',
                  enterProduction,
                      (v) => setState(() => enterProduction = v),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // Tables

  Widget tablesSection() {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth > 1000) {
          return Row(
            children: [
              Expanded(child: leftTable()),
              const SizedBox(width: 12),
              Expanded(child: rightTable()),
            ],
          );
        } else {
          return Column(
            children: [
              leftTable(),
              const SizedBox(height: 12),
              rightTable(),
            ],
          );
        }
      },
    );
  }

  Widget leftTable() {
    return Card(
      child: scrollable(
        DataTable(
          columns: const [
            DataColumn(label: Text('ردیف')),
            DataColumn(label: Text('مشتری')),
            DataColumn(label: Text('عنوان')),
            DataColumn(label: Text('تعداد')),
            DataColumn(label: Text('متراژ کل')),
            DataColumn(label: Text('باقی‌مانده')),
            DataColumn(label: Text('وضعیت')),
            DataColumn(label: Text('کد سفارش')),
          ],
          rows: List.generate(
            5,
                (i) => DataRow(cells: [
              DataCell(Text('${i + 1}')),
              const DataCell(Text('مشتری')),
              const DataCell(Text('محصول')),
              const DataCell(Text('56000')),
              const DataCell(Text('96411')),
              const DataCell(Text('56000')),
              const DataCell(Text('فعال')),
              const DataCell(Text('ORD-01')),
            ]),
          ),
        ),
      ),
    );
  }

  Widget rightTable() {
    return Card(
      child: scrollable(
        DataTable(
          columns: const [
            DataColumn(label: Text('ردیف')),
            DataColumn(label: Text('تعداد')),
            DataColumn(label: Text('عرض')),
            DataColumn(label: Text('طول')),
            DataColumn(label: Text('در رول')),
            DataColumn(label: Text('تعداد رول')),
            DataColumn(label: Text('ضایعات')),
            DataColumn(label: Text('متراژ')),
            DataColumn(label: Text('وضعیت')),
          ],
          rows: List.generate(
            5,
                (i) => DataRow(cells: [
              DataCell(Text('${i + 1}')),
              const DataCell(Text('56000')),
              const DataCell(Text('22')),
              const DataCell(Text('68')),
              const DataCell(Text('10')),
              const DataCell(Text('4')),
              const DataCell(Text('0')),
              const DataCell(Text('56000')),
              const DataCell(Text('ورود')),
            ]),
          ),
        ),
      ),
    );
  }

  // =========================================================
  Widget productionControls() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: threeColumnGrid(
              constraints: constraints,
              children: [
                field('تعداد', tedadCtrl),
                field('عرض', arzCtrl),
                field('طول', toolCtrl),
                field('تیغ', tighCtrl),
                field('فاصله', faseleCtrl),
                field('تعداد رول خروجی', rollOutCtrl),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget threeColumnGrid({
    required BoxConstraints constraints,
    required List<Widget> children,
  }) {
    if (constraints.maxWidth < 600) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children
            .map(
              (e) => ClipRect(
            child: e,
          ),
        )
            .toList(),

      );
    }

    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 4,   // فاصله بین ردیف‌ها
      crossAxisSpacing: 8,  // فاصله بین ستون‌ها
      childAspectRatio: 3.6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }


  // =========================================================
  // Actions

  Widget actionButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        actionBtn('ساخت برش‌ها'),
        actionBtn('تولید جدید'),
        actionBtn('بروزرسانی'),
        actionBtn('حذف'),
        actionBtn('افزودن جامبو'),
        actionBtn('حذف جامبو'),
      ],
    );
  }

  // =========================================================
  // Output Table

  Widget outputTable() {
    return Card(
      child: scrollable(
        DataTable(
          columns: const [
            DataColumn(label: Text('ردیف')),
            DataColumn(label: Text('عنوان')),
            DataColumn(label: Text('متراژ اولیه')),
            DataColumn(label: Text('مصرف‌شده')),
            DataColumn(label: Text('باقی‌مانده')),
            DataColumn(label: Text('عرض')),
            DataColumn(label: Text('طول')),
            DataColumn(label: Text('رزرو')),
          ],
          rows: List.generate(
            4,
                (i) => DataRow(cells: [
              DataCell(Text('${i + 1}')),
              const DataCell(Text('جامبو سفید')),
              const DataCell(Text('1000')),
              const DataCell(Text('0')),
              const DataCell(Text('1000')),
              const DataCell(Text('280')),
              const DataCell(Text('1000')),
              const DataCell(Text('0')),
            ]),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Widgets

  Widget field(String label, TextEditingController c) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // لیبل
          SizedBox(
            width: 55,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // ⭐ جلوگیری از بیرون‌زدن
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 6),

          // ادیت تکست
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: c,
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget productionDropdown() {
    return SizedBox(
      width: double.infinity,
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 55,
            child: Text(
              'وضعیت',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: SizedBox(
              height: 36,
              child: DropdownButtonFormField<String>(
                value: productionStatus,
                isDense: true,
                items: const [
                  DropdownMenuItem(
                    value: 'در حال تولید',
                    child: Text('در حال تولید'),
                  ),
                  DropdownMenuItem(
                    value: 'متوقف',
                    child: Text('متوقف'),
                  ),
                ],
                onChanged: (v) => setState(() => productionStatus = v!),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget checkboxWidget(
      String label,
      bool value,
      Function(bool) onChanged,
      ) {
    return Row(
      children: [
        Checkbox(value: value, onChanged: (v) => onChanged(v!)),
        Expanded(child: Text(label)),
      ],
    );
  }

  Widget actionBtn(String text) {
    return ElevatedButton(onPressed: () {}, child: Text(text));
  }

  Widget scrollable(Widget child) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: child,
        ),
      ),
    );
  }
}
