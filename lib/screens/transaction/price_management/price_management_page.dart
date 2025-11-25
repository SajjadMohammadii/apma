import 'dart:async';
import 'package:apma_app/core/constants/app_colors.dart';
import 'package:apma_app/core/network/soap_client.dart';
import 'package:apma_app/core/di/injection_container.dart';
import 'package:apma_app/screens/transaction/price_management/bloc/price_management_bloc.dart';
import 'package:apma_app/screens/transaction/price_management/bloc/price_management_event.dart';
import 'package:apma_app/screens/transaction/price_management/bloc/price_management_state.dart';
import 'package:apma_app/screens/transaction/price_management/services/price_request_service.dart';
import 'package:apma_app/screens/transaction/price_management/models/price_request_model.dart';
import 'package:apma_app/screens/transaction/price_management/widgets/advanced_filter_dialog.dart';
import 'package:apma_app/screens/transaction/price_management/widgets/date_field_widget.dart';
import 'package:apma_app/screens/transaction/price_management/widgets/filter_button_widget.dart';
import 'package:apma_app/screens/transaction/price_management/widgets/status_dropdown_widget.dart';
import 'package:apma_app/screens/transaction/price_management/widgets/table_header_widget.dart';
import 'package:apma_app/screens/transaction/price_management/widgets/table_row_widget.dart';
import 'package:apma_app/screens/transaction/price_management/widgets/sub_table_widget.dart';
import 'package:apma_app/shared/widgets/persian_date_picker/persian_date_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamsi_date/shamsi_date.dart';

class PriceManagementPage extends StatefulWidget {
  const PriceManagementPage({super.key});

  @override
  State<PriceManagementPage> createState() => _PriceManagementPageState();
}

class _PriceManagementPageState extends State<PriceManagementPage> {
  String selectedStatus = 'همه';
  Map<String, String> subFieldStatuses = {};
  final List<String> statusOptions = [
    'همه',
    'در حال بررسی',
    'تایید شده',
    'رد شده',
  ];

  Set<int> expandedRows = {};

  int? sortColumnIndex;
  bool isAscending = true;

  Map<int, int?> subSortColumnIndex = {};
  Map<int, bool> subIsAscending = {};

  String fromDate = '';
  String toDate = '';

  final TextEditingController _numberFilterController = TextEditingController();
  final TextEditingController _customerFilterController =
      TextEditingController();
  final TextEditingController _issuerFilterController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();

  late PriceManagementBloc _bloc;
  Timer? _autoRefreshTimer;
  bool _isAutoRefreshEnabled = true;

  List<Map<String, dynamic>> mainData = [];
  List<Map<String, dynamic>> filteredData = [];
  Map<int, List<Map<String, dynamic>>> subData = {};
  Map<int, List<Map<String, dynamic>>> originalSubData =
      {}; // نگهداری داده‌های اصلی

  @override
  void initState() {
    super.initState();

    // تنظیم تاریخ سال جاری
    final now = Jalali.now();
    final lastDay = Jalali(now.year, 12).monthLength;
    fromDate = '${now.year}/01/01';
    toDate = '${now.year}/12/$lastDay';

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    final soapClient = sl<SoapClient>();
    final service = PriceRequestService(soapClient: soapClient);
    _bloc = PriceManagementBloc(priceRequestService: service);

    _loadData();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isAutoRefreshEnabled) {
        _loadDataSilently();
      }
    });
  }

  void _loadDataSilently() {
    final fromDateGregorian = _persianToGregorian(fromDate);
    final toDateGregorian = _persianToGregorian(toDate);

    _bloc.add(
      LoadPriceRequestsEvent(
        fromDate: fromDateGregorian,
        toDate: toDateGregorian,
        status: 0,
        criteria: _keywordsController.text,
      ),
    );
  }

  void _loadData() {
    // تبدیل تاریخ‌های شمسی به میلادی برای ارسال به سرور
    final fromDateGregorian = _persianToGregorian(fromDate);
    final toDateGregorian = _persianToGregorian(toDate);

    _bloc.add(
      LoadPriceRequestsEvent(
        fromDate: fromDateGregorian,
        toDate: toDateGregorian,
        status: 0,
        criteria: _keywordsController.text,
      ),
    );
  }

  String _persianToGregorian(String persianDate) {
    try {
      final parts = persianDate.split('/');
      final jalali = Jalali(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final g = jalali.toGregorian();
      return '${g.year}${g.month.toString().padLeft(2, '0')}${g.day.toString().padLeft(2, '0')}';
    } catch (_) {}
    return persianDate.replaceAll('/', '');
  }

  String _gregorianToPersian(String gregorianDate) {
    try {
      final g = Gregorian(
        int.parse(gregorianDate.substring(0, 4)),
        int.parse(gregorianDate.substring(4, 6)),
        int.parse(gregorianDate.substring(6, 8)),
      );
      final j = g.toJalali();
      return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
    } catch (_) {}
    return gregorianDate;
  }

  int _persianDateToComparable(String d) {
    try {
      final parts = d.split('/');
      final g =
          Jalali(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          ).toGregorian();
      return DateTime(g.year, g.month, g.day).millisecondsSinceEpoch;
    } catch (_) {
      return 0;
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _numberFilterController.dispose();
    _customerFilterController.dispose();
    _issuerFilterController.dispose();
    _keywordsController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _convertApiDataToUIFormat(Map<String, List<PriceRequestModel>> grouped) {
    // همیشه همه داده‌ها را از نو بسازیم
    mainData.clear();
    subData.clear();
    originalSubData.clear();

    int id = 1;
    grouped.forEach((orderNumber, items) {
      if (items.isNotEmpty) {
        final first = items.first;

        mainData.add({
          'id': id,
          'date': _gregorianToPersian(first.orderDate),
          'number': orderNumber,
          'customer': first.sherkat,
          'issuer': first.fullPersonName,
        });

        subData[id] =
            items.map((item) {
              // استفاده از وضعیت ذخیره شده در subFieldStatuses یا وضعیت سرور
              final status =
                  subFieldStatuses.containsKey(item.id)
                      ? subFieldStatuses[item.id]!
                      : item.statusString;

              // اگر وضعیت در subFieldStatuses نبود، اضافه کن
              if (!subFieldStatuses.containsKey(item.id)) {
                subFieldStatuses[item.id] = item.statusString;
              }

              return {
                'request_date': _gregorianToPersian(item.date),
                'product_name': item.title,
                'request_type': item.requestType,
                'current_price': item.currentPrice.toInt(),
                'requested_price': item.requestedPrice.toInt(),
                'approval_status': status,
                'original_id': item.id,
              };
            }).toList();

        originalSubData[id] = List.from(subData[id]!);
        id++;
      }
    });

    filteredData = List.from(mainData);
    _applyFiltersWithoutSetState();

    if (sortColumnIndex != null) {
      _applySortMainWithoutSetState(sortColumnIndex!, isAscending);
    }
  }

  void _applyFiltersWithoutSetState() {
    // اگر فیلتر "همه" انتخاب شده
    if (selectedStatus == 'همه') {
      filteredData = List.from(mainData);
      // بازسازی subData از originalSubData
      subData.clear();
      originalSubData.forEach((key, value) {
        subData[key] = List.from(value);
        // آپدیت کردن وضعیت‌ها بر اساس subFieldStatuses
        subData[key]!.forEach((item) {
          final origId = item['original_id']?.toString() ?? '';
          if (subFieldStatuses.containsKey(origId)) {
            item['approval_status'] = subFieldStatuses[origId];
          }
        });
      });
    } else {
      // فیلتر کردن بر اساس وضعیت انتخابی
      filteredData = [];
      subData.clear();

      for (var item in mainData) {
        final id = item['id'];

        if (!originalSubData.containsKey(id)) continue;

        // فیلتر کردن آیتم‌های فرعی
        final matchingSubItems =
            originalSubData[id]!
                .where((s) {
                  final origId = s['original_id']?.toString() ?? '';
                  // همیشه از آخرین وضعیت در subFieldStatuses استفاده کن
                  final currentStatus =
                      subFieldStatuses.containsKey(origId)
                          ? subFieldStatuses[origId]
                          : s['approval_status'];

                  return currentStatus == selectedStatus;
                })
                .map((item) {
                  // کپی آیتم با وضعیت آپدیت شده
                  var newItem = Map<String, dynamic>.from(item);
                  final origId = newItem['original_id']?.toString() ?? '';
                  if (subFieldStatuses.containsKey(origId)) {
                    newItem['approval_status'] = subFieldStatuses[origId];
                  }
                  return newItem;
                })
                .toList();

        if (matchingSubItems.isNotEmpty) {
          final newId = filteredData.length + 1;

          filteredData.add({
            'id': newId,
            'date': item['date'],
            'number': item['number'],
            'customer': item['customer'],
            'issuer': item['issuer'],
          });

          subData[newId] = matchingSubItems;
        }
      }
    }

    // اعمال فیلترهای متنی
    if (_numberFilterController.text.isNotEmpty) {
      filteredData =
          filteredData
              .where(
                (item) => item['number'].toString().contains(
                  _numberFilterController.text,
                ),
              )
              .toList();
    }

    if (_customerFilterController.text.isNotEmpty) {
      filteredData =
          filteredData
              .where(
                (item) => item['customer'].toString().toLowerCase().contains(
                  _customerFilterController.text.toLowerCase(),
                ),
              )
              .toList();
    }

    if (_issuerFilterController.text.isNotEmpty) {
      filteredData =
          filteredData
              .where(
                (item) => item['issuer'].toString().toLowerCase().contains(
                  _issuerFilterController.text.toLowerCase(),
                ),
              )
              .toList();
    }

    if (_keywordsController.text.isNotEmpty) {
      final key = _keywordsController.text.trim().toLowerCase();
      filteredData =
          filteredData.where((item) {
            final combo =
                '${item['number']} ${item['customer']} ${item['issuer']}'
                    .toLowerCase();
            return combo.contains(key);
          }).toList();
    }
  }

  void _applyFilters() {
    setState(() {
      _applyFiltersWithoutSetState();
      if (sortColumnIndex != null) {
        _applySortMainWithoutSetState(sortColumnIndex!, isAscending);
      }
    });
  }

  void _applySortMainWithoutSetState(int columnIndex, bool asc) {
    filteredData.sort((a, b) {
      dynamic av, bv;

      switch (columnIndex) {
        case 0:
          av = _persianDateToComparable(a['date']);
          bv = _persianDateToComparable(b['date']);
          break;
        case 1:
          av = int.tryParse(a['number']) ?? 0;
          bv = int.tryParse(b['number']) ?? 0;
          break;
        default:
          av = a.values.elementAt(columnIndex).toString();
          bv = b.values.elementAt(columnIndex).toString();
      }

      int c =
          (av is int)
              ? av.compareTo(bv)
              : av.toString().compareTo(bv.toString());
      return asc ? c : -c;
    });
  }

  void _sortMainTable(int col) {
    setState(() {
      if (sortColumnIndex == col)
        isAscending = !isAscending;
      else {
        sortColumnIndex = col;
        isAscending = true;
      }
      _applySortMainWithoutSetState(col, isAscending);
    });
  }

  void _sortSubTable(int parentId, int col) {
    setState(() {
      if (subSortColumnIndex[parentId] == col) {
        subIsAscending[parentId] = !(subIsAscending[parentId] ?? true);
      } else {
        subSortColumnIndex[parentId] = col;
        subIsAscending[parentId] = true;
      }

      final asc = subIsAscending[parentId] ?? true;

      subData[parentId]!.sort((a, b) {
        dynamic av, bv;

        switch (col) {
          case 0:
            av = _persianDateToComparable(a['request_date']);
            bv = _persianDateToComparable(b['request_date']);
            break;
          case 3:
          case 4:
            av = a[col == 3 ? 'current_price' : 'requested_price'];
            bv = b[col == 3 ? 'current_price' : 'requested_price'];
            break;
          case 5:
            final aOrig = a['original_id']?.toString() ?? '';
            final bOrig = b['original_id']?.toString() ?? '';
            av = subFieldStatuses[aOrig] ?? a['approval_status'];
            bv = subFieldStatuses[bOrig] ?? b['approval_status'];
            break;
          default:
            av = a.values.elementAt(col).toString();
            bv = b.values.elementAt(col).toString();
        }

        final c =
            (av is int)
                ? av.compareTo(bv)
                : av.toString().compareTo(bv.toString());
        return asc ? c : -c;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.primaryGreen,
          appBar: _buildAppBar(),
          body: _buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryGreen,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Row(
        children: [
          DateFieldWidget(
            text: 'از: $fromDate',
            onTap: () => _selectDate(true),
          ),
          const SizedBox(width: 6),
          DateFieldWidget(text: 'تا: $toDate', onTap: () => _selectDate(false)),
          const SizedBox(width: 6),
          FilterButtonWidget(onTap: _showAdvancedFilterDialog),
          const SizedBox(width: 6),
          StatusDropdownWidget(
            selectedStatus: selectedStatus,
            statusOptions: statusOptions,
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  selectedStatus = v;
                  _applyFilters();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: BlocListener<PriceManagementBloc, PriceManagementState>(
        listener: (context, state) {
          if (state is PriceManagementLoaded) {
            setState(() {
              _convertApiDataToUIFormat(state.groupedByOrder);
            });
          }
        },
        child: BlocBuilder<PriceManagementBloc, PriceManagementState>(
          buildWhen: (previous, current) {
            return false;
          },
          builder: (context, state) {
            return Column(
              children: [
                TableHeaderWidget(
                  sortColumnIndex: sortColumnIndex,
                  isAscending: isAscending,
                  onSort: _sortMainTable,
                ),
                Expanded(
                  child:
                      filteredData.isEmpty
                          ? const Center(child: Text('داده‌ای یافت نشد'))
                          : ListView.builder(
                            itemCount: filteredData.length,
                            itemBuilder: (context, index) {
                              final item = filteredData[index];
                              final id = item['id'];
                              final expanded = expandedRows.contains(id);

                              return Column(
                                children: [
                                  TableRowWidget(
                                    item: item,
                                    isExpanded: expanded,
                                    onTap: () {
                                      setState(() {
                                        expanded
                                            ? expandedRows.remove(id)
                                            : expandedRows.add(id);
                                      });
                                    },
                                  ),
                                  if (expanded && subData.containsKey(id))
                                    SubTableWidget(
                                      parentId: id,
                                      subItems: subData[id]!,
                                      subFieldStatuses: subFieldStatuses,
                                      statusOptions: statusOptions,
                                      sortColumnIndex: subSortColumnIndex[id],
                                      isAscending: subIsAscending[id] ?? true,
                                      onSort: (c) => _sortSubTable(id, c),
                                      onStatusChange: (subId, status) {
                                        // آپدیت وضعیت در subFieldStatuses
                                        subFieldStatuses[subId] = status;

                                        // آپدیت وضعیت در originalSubData
                                        originalSubData.forEach((key, items) {
                                          for (var item in items) {
                                            if (item['original_id']
                                                    ?.toString() ==
                                                subId) {
                                              item['approval_status'] = status;
                                            }
                                          }
                                        });

                                        // آپدیت وضعیت در subData فعلی
                                        subData.forEach((key, items) {
                                          for (var item in items) {
                                            if (item['original_id']
                                                    ?.toString() ==
                                                subId) {
                                              item['approval_status'] = status;
                                            }
                                          }
                                        });

                                        int statusCode = 1;
                                        if (status == 'تایید شده')
                                          statusCode = 2;
                                        if (status == 'رد شده') statusCode = 3;

                                        _bloc.add(
                                          UpdatePriceRequestStatusEvent(
                                            requestId: subId,
                                            newStatus: statusCode,
                                          ),
                                        );

                                        setState(() {
                                          _applyFilters();
                                        });
                                      },
                                    ),
                                  const SizedBox(height: 8),
                                ],
                              );
                            },
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isFrom) async {
    final selected = await PersianDatePickerDialog.show(
      context,
      isFrom ? fromDate : toDate,
    );
    if (selected != null) {
      setState(() {
        if (isFrom)
          fromDate = selected;
        else
          toDate = selected;
        _loadData();
      });
    }
  }

  void _showAdvancedFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AdvancedFilterDialog(
            numberController: _numberFilterController,
            customerController: _customerFilterController,
            issuerController: _issuerFilterController,
            keywordsController: _keywordsController,
            initialSearchMode: 'AND',
            onApply: (searchMode) {
              _applyFilters();
            },
            onClear: () {
              _numberFilterController.clear();
              _customerFilterController.clear();
              _issuerFilterController.clear();
              _keywordsController.clear();
              _applyFilters();
            },
          ),
    );
  }
}
