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
import 'package:apma_app/screens/transaction/price_management/widgets/save_button_widget.dart';
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
  String selectedStatus = 'در حال بررسی';
  Map<int, String> subFieldStatuses = {};
  final List<String> statusOptions = [
    'همه',
    'در حال بررسی',
    'تایید شده',
    'رد شده',
  ];
  Set<int> expandedRows = {};

  // Sort variables
  int? sortColumnIndex;
  bool isAscending = true;
  Map<int, int?> subSortColumnIndex = {};
  Map<int, bool> subIsAscending = {};

  String fromDate = '1403/01/01';
  String toDate = '1403/12/29';

  final TextEditingController _numberFilterController = TextEditingController();
  final TextEditingController _customerFilterController =
      TextEditingController();
  final TextEditingController _issuerFilterController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();

  late PriceManagementBloc _bloc;

  // داده‌های تبدیل شده برای UI
  List<Map<String, dynamic>> mainData = [];
  List<Map<String, dynamic>> filteredData = [];
  Map<int, List<Map<String, dynamic>>> subData = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    final soapClient = sl<SoapClient>();
    final service = PriceRequestService(soapClient: soapClient);
    _bloc = PriceManagementBloc(priceRequestService: service);

    _loadData();
  }

  void _loadData() {
    // اگه بازه تاریخ کل سال باشه، NULL بفرست
    final bool isFullYear = fromDate == '1403/01/01' && toDate == '1403/12/29';

    final fromDateGregorian =
        isFullYear ? 'NULL' : _persianToGregorian(fromDate);
    final toDateGregorian = isFullYear ? 'NULL' : _persianToGregorian(toDate);

    // Always load all data, filtering will be done locally
    final statusCode = 0; // 'همه' - load all statuses

    _bloc.add(
      LoadPriceRequestsEvent(
        fromDate: fromDateGregorian,
        toDate: toDateGregorian,
        status: statusCode,
        criteria: _keywordsController.text,
      ),
    );
  }

  int _getStatusCode(String status) {
    switch (status) {
      case 'همه':
        return 0;
      case 'در حال بررسی':
        return 1;
      case 'تایید شده':
        return 2;
      case 'رد شده':
        return 3;
      default:
        return 0;
    }
  }

  String _persianToGregorian(String persianDate) {
    try {
      final parts = persianDate.split('/');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);

        final jalali = Jalali(year, month, day);
        final gregorian = jalali.toGregorian();

        return '${gregorian.year}'
            '${gregorian.month.toString().padLeft(2, '0')}'
            '${gregorian.day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      print('خطا در تبدیل تاریخ: $e');
    }
    return persianDate.replaceAll('/', '');
  }

  String _gregorianToPersian(String gregorianDate) {
    try {
      if (gregorianDate.length >= 8) {
        final year = int.parse(gregorianDate.substring(0, 4));
        final month = int.parse(gregorianDate.substring(4, 6));
        final day = int.parse(gregorianDate.substring(6, 8));

        final gregorian = Gregorian(year, month, day);
        final jalali = gregorian.toJalali();

        return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      print('خطا در تبدیل تاریخ میلادی به شمسی: $e');
    }
    return gregorianDate;
  }

  int _persianDateToComparable(String persianDate) {
    try {
      final parts = persianDate.split('/');
      if (parts.length == 3) {
        final y = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final d = int.parse(parts[2]);
        final jalali = Jalali(y, m, d);
        final g = jalali.toGregorian();
        final dt = DateTime(g.year, g.month, g.day);
        return dt.millisecondsSinceEpoch;
      } else {
        // fallback: remove slashes and parse as int
        return int.tryParse(persianDate.replaceAll('/', '')) ?? 0;
      }
    } catch (_) {
      return int.tryParse(persianDate.replaceAll('/', '')) ?? 0;
    }
  }

  int _gregorianStringToComparable(String gregorianDate) {
    try {
      if (gregorianDate.length >= 8) {
        final year = int.parse(gregorianDate.substring(0, 4));
        final month = int.parse(gregorianDate.substring(4, 6));
        final day = int.parse(gregorianDate.substring(6, 8));
        final dt = DateTime(year, month, day);
        return dt.millisecondsSinceEpoch;
      }
    } catch (_) {}
    return int.tryParse(gregorianDate.replaceAll('/', '')) ?? 0;
  }

  @override
  void dispose() {
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

  Future<void> _selectDate(bool isFromDate) async {
    final selectedDate = await PersianDatePickerDialog.show(
      context,
      isFromDate ? fromDate : toDate,
    );
    if (selectedDate != null) {
      setState(() {
        if (isFromDate) {
          fromDate = selectedDate;
        } else {
          toDate = selectedDate;
        }
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

  void _convertApiDataToUIFormat(
    Map<String, List<PriceRequestModel>> groupedByOrder,
  ) {
    mainData.clear();
    subData.clear();
    int id = 1;

    groupedByOrder.forEach((orderNumber, items) {
      if (items.isNotEmpty) {
        final firstItem = items.first;

        mainData.add({
          'id': id,
          'date': _gregorianToPersian(firstItem.orderDate),
          'number': orderNumber,
          'customer': firstItem.sherkat,
          'issuer': firstItem.fullPersonName,
        });

        subData[id] =
            items.map((item) {
              final origIdInt = int.tryParse(item.id) ?? 0;
              if (!subFieldStatuses.containsKey(origIdInt)) {
                subFieldStatuses[origIdInt] = item.statusString;
              }

              return {
                'request_date': _gregorianToPersian(item.date),
                'product_name': item.title,
                'request_type': item.requestType,
                'current_price': item.currentPrice.toInt(),
                'requested_price': item.requestedPrice.toInt(),
                'approval_status': item.statusString,
                'original_id': item.id,
              };
            }).toList();

        id++;
      }
    });

    // initially filteredData is a copy of mainData
    filteredData = List.from(mainData);

    // apply filters without setState so that initial display logic can continue properly
    _applyFiltersWithoutSetState();

    // if a sort was active, reapply it to filteredData
    if (sortColumnIndex != null) {
      _applySortMainWithoutSetState(sortColumnIndex!, isAscending);
    }
  }

  void _applyFiltersWithoutSetState() {
    filteredData =
        mainData.where((item) {
          if (selectedStatus != 'همه') {
            final itemId = item['id'];
            if (subData.containsKey(itemId)) {
              final hasMatchingStatus = subData[itemId]!.any((subItem) {
                final currentStatus =
                    subFieldStatuses[int.tryParse(
                          subItem['original_id'] ?? '0',
                        ) ??
                        0] ??
                    subItem['approval_status'] ??
                    'در حال بررسی';
                return currentStatus == selectedStatus;
              });
              if (!hasMatchingStatus) return false;
            }
          }

          if (_numberFilterController.text.isNotEmpty &&
              !item['number'].toString().contains(
                _numberFilterController.text,
              )) {
            return false;
          }

          if (_customerFilterController.text.isNotEmpty &&
              !item['customer'].toString().toLowerCase().contains(
                _customerFilterController.text.toLowerCase(),
              )) {
            return false;
          }

          if (_issuerFilterController.text.isNotEmpty &&
              !item['issuer'].toString().toLowerCase().contains(
                _issuerFilterController.text.toLowerCase(),
              )) {
            return false;
          }

          // keywords search (from advanced dialog) - split by space and use AND semantics by default
          if (_keywordsController.text.isNotEmpty) {
            final keywords =
                _keywordsController.text
                    .split(RegExp(r'\s+'))
                    .where((k) => k.trim().isNotEmpty)
                    .map((k) => k.trim().toLowerCase())
                    .toList();
            if (keywords.isNotEmpty) {
              final combined =
                  '${item['number']} ${item['customer']} ${item['issuer']}'
                      .toLowerCase();
              final matchesAll = keywords.every((kw) => combined.contains(kw));
              if (!matchesAll) return false;
            }
          }

          return true;
        }).toList();
  }

  void _applyFilters() {
    setState(() {
      _applyFiltersWithoutSetState();

      // After filtering, if a sort is active reapply it to filteredData
      if (sortColumnIndex != null) {
        _applySortMainWithoutSetState(sortColumnIndex!, isAscending);
      }
    });
  }

  void _applySortMainWithoutSetState(int columnIndex, bool ascending) {
    filteredData.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (columnIndex) {
        case 0: // تاریخ
          aValue = _persianDateToComparable(a['date'].toString());
          bValue = _persianDateToComparable(b['date'].toString());
          break;
        case 1: // شماره
          aValue = int.tryParse(a['number'].toString()) ?? 0;
          bValue = int.tryParse(b['number'].toString()) ?? 0;
          break;
        case 2: // مشتری
          aValue = a['customer'].toString();
          bValue = b['customer'].toString();
          break;
        case 3: // صادرکننده
          aValue = a['issuer'].toString();
          bValue = b['issuer'].toString();
          break;
        default:
          return 0;
      }

      int comparison;
      if (columnIndex <= 1) {
        comparison = (aValue as int).compareTo(bValue as int);
      } else {
        comparison = aValue.toString().compareTo(bValue.toString());
      }

      return ascending ? comparison : -comparison;
    });
  }

  void _sortMainTable(int columnIndex) {
    setState(() {
      if (sortColumnIndex == columnIndex) {
        isAscending = !isAscending;
      } else {
        sortColumnIndex = columnIndex;
        isAscending = true;
      }

      _applySortMainWithoutSetState(columnIndex, isAscending);
    });
  }

  void _sortSubTable(int parentId, int columnIndex) {
    setState(() {
      if (subSortColumnIndex[parentId] == columnIndex) {
        subIsAscending[parentId] = !(subIsAscending[parentId] ?? true);
      } else {
        subSortColumnIndex[parentId] = columnIndex;
        subIsAscending[parentId] = true;
      }

      if (subData.containsKey(parentId)) {
        final ascending = subIsAscending[parentId] ?? true;
        subData[parentId]!.sort((a, b) {
          dynamic aValue;
          dynamic bValue;

          switch (columnIndex) {
            case 0: // تاریخ درخواست (شمسی نمایش شده اما مقدار ذخیره شمسی هم هست)
              aValue = _persianDateToComparable(a['request_date'].toString());
              bValue = _persianDateToComparable(b['request_date'].toString());
              break;
            case 1: // عنوان کالا
              aValue = a['product_name'].toString();
              bValue = b['product_name'].toString();
              break;
            case 2: // نوع درخواست
              aValue = a['request_type'].toString();
              bValue = b['request_type'].toString();
              break;
            case 3: // مبلغ فعلی
              aValue = a['current_price'] ?? 0;
              bValue = b['current_price'] ?? 0;
              break;
            case 4: // مبلغ درخواستی
              aValue = a['requested_price'] ?? 0;
              bValue = b['requested_price'] ?? 0;
              break;
            case 5: // وضعیت
              final aId = int.tryParse(a['original_id'] ?? '0') ?? 0;
              final bId = int.tryParse(b['original_id'] ?? '0') ?? 0;
              aValue = subFieldStatuses[aId] ?? a['approval_status'] ?? '';
              bValue = subFieldStatuses[bId] ?? b['approval_status'] ?? '';
              break;
            default:
              return 0;
          }

          int comparison;
          if (columnIndex == 0 || columnIndex == 3 || columnIndex == 4) {
            final aNum =
                (aValue is int) ? aValue : int.tryParse(aValue.toString()) ?? 0;
            final bNum =
                (bValue is int) ? bValue : int.tryParse(bValue.toString()) ?? 0;
            comparison = aNum.compareTo(bNum);
          } else {
            comparison = aValue.toString().compareTo(bValue.toString());
          }

          return ascending ? comparison : -comparison;
        });
      }
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
      automaticallyImplyLeading: true,
      title: BlocBuilder<PriceManagementBloc, PriceManagementState>(
        builder: (context, state) {
          final hasChanges = state is PriceManagementLoaded && state.hasChanges;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                DateFieldWidget(
                  text: 'از: $fromDate',
                  onTap: () => _selectDate(true),
                ),
                const SizedBox(width: 8),
                DateFieldWidget(
                  text: 'تا: $toDate',
                  onTap: () => _selectDate(false),
                ),
                const SizedBox(width: 8),
                FilterButtonWidget(onTap: _showAdvancedFilterDialog),
                const SizedBox(width: 8),
                StatusDropdownWidget(
                  selectedStatus: selectedStatus,
                  statusOptions: statusOptions,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedStatus = newValue;
                        // Apply filter on the full mainData (not current filteredData) so appbar filter always
                        // considers the complete dataset that was loaded from server.
                        _applyFilters();
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                SaveButtonWidget(
                  hasChanges: hasChanges,
                  onTap: () {
                    _bloc.add(const SaveChangesEvent());
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BlocConsumer<PriceManagementBloc, PriceManagementState>(
        listener: (context, state) {
          if (state is PriceManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PriceManagementSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is PriceManagementLoaded) {
            // when loaded, convert to UI format and ensure filters/sorts applied
            _convertApiDataToUIFormat(state.groupedByOrder);
          }
        },
        builder: (context, state) {
          if (state is PriceManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PriceManagementError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'خطا در دریافت داده‌ها',
                    style: TextStyle(
                      fontFamily: 'Vazir',
                      fontSize: 18,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      style: const TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      _bloc.add(const RefreshPriceRequestsEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('تلاش مجدد'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is PriceManagementLoaded) {
            return Column(
              children: [
                TableHeaderWidget(
                  sortColumnIndex: sortColumnIndex,
                  isAscending: isAscending,
                  onSort: _sortMainTable,
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child:
                        filteredData.isEmpty
                            ? const Center(
                              child: Text(
                                'داده‌ای یافت نشد',
                                style: TextStyle(
                                  fontFamily: 'Vazir',
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                            : ListView.builder(
                              itemCount: filteredData.length,
                              itemBuilder: (context, index) {
                                final item = filteredData[index];
                                final isExpanded = expandedRows.contains(
                                  item['id'],
                                );

                                return Column(
                                  children: [
                                    TableRowWidget(
                                      item: item,
                                      isExpanded: isExpanded,
                                      onTap: () {
                                        setState(() {
                                          if (isExpanded) {
                                            expandedRows.remove(item['id']);
                                          } else {
                                            expandedRows.add(item['id']);
                                          }
                                        });
                                      },
                                    ),
                                    if (isExpanded) ...[
                                      const SizedBox(height: 8),
                                      if (subData.containsKey(item['id']))
                                        SubTableWidget(
                                          parentId: item['id'],
                                          subItems: subData[item['id']]!,
                                          subFieldStatuses: subFieldStatuses,
                                          statusOptions: statusOptions,
                                          sortColumnIndex:
                                              subSortColumnIndex[item['id']],
                                          isAscending:
                                              subIsAscending[item['id']] ??
                                              true,
                                          onSort:
                                              (colIndex) => _sortSubTable(
                                                item['id'],
                                                colIndex,
                                              ),
                                          onStatusChange: (id, status) {
                                            setState(() {
                                              subFieldStatuses[id] = status;

                                              final subItem =
                                                  subData[item['id']]!
                                                      .firstWhere(
                                                        (s) =>
                                                            int.tryParse(
                                                              s['original_id'] ??
                                                                  '0',
                                                            ) ==
                                                            id,
                                                        orElse: () => {},
                                                      );

                                              if (subItem.isNotEmpty &&
                                                  subItem['original_id'] !=
                                                      null) {
                                                subItem['approval_status'] =
                                                    status;

                                                final originalId =
                                                    subItem['original_id'];

                                                int statusCode = 1;
                                                if (status == 'تایید شده')
                                                  statusCode = 2;
                                                if (status == 'رد شده')
                                                  statusCode = 3;

                                                _bloc.add(
                                                  UpdatePriceRequestStatusEvent(
                                                    requestId: originalId,
                                                    newStatus: statusCode,
                                                  ),
                                                );
                                              }
                                            });
                                          },
                                        ),
                                      const SizedBox(height: 8),
                                    ],
                                  ],
                                );
                              },
                            ),
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text(
              'لطفاً فیلترها را انتخاب کرده و جستجو کنید',
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}
