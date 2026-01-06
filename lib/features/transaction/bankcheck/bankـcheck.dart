// صفحه چک بانکی - نمایش چک‌های مشتری یا بانک
// مرتبط با: transaction.dart, customer.dart, bank.dart

import 'package:apma_app/core/constants/app_colors.dart'; // رنگ‌های برنامه
import 'package:apma_app/features/bank/domain/repositories/cheque_repository.dart';
import 'package:apma_app/features/transaction/bankcheck/bank/bank.dart'; // صفحه چک بانک
import 'package:apma_app/features/transaction/bankcheck/custumer/customer.dart'; // صفحه چک مشتری
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constant.dart';
import '../../../core/network/soap_client.dart';
import '../../bank/data/datasource/cheque_remote_datasource.dart';
import '../../bank/data/repositories/cheque_repositorry_impl.dart';
import '../../bank/presentation/bloc/cheque_bloc.dart'; // ویجت‌های متریال

// کلاس BankCheckPage - صفحه چک بانکی
class BankCheckPage extends StatefulWidget {
  const BankCheckPage({super.key});

  @override
  State<BankCheckPage> createState() => _BankCheckPageState();
}

// کلاس _BankCheckPageState - state صفحه چک بانکی
class _BankCheckPageState extends State<BankCheckPage> {
  String selectedCheckType = 'مشتری'; // نوع چک انتخاب شده
  final List<String> checkTypes = ['مشتری', 'بانک']; // انواع چک

  // @override
  // Widget build(BuildContext context) {
  //   bool isCustomer = selectedCheckType == "مشتری"; // آیا چک مشتری
  //   bool isBank = selectedCheckType == "بانک"; // آیا چک بانک
  //
  //   return Directionality(
  //     textDirection: TextDirection.rtl, // راست به چپ
  //     child: Scaffold(
  //       backgroundColor: AppColors.backgroundColor, // رنگ پس‌زمینه
  //       appBar: AppBar(
  //         backgroundColor: AppColors.primaryGreen,
  //         elevation: 0,
  //         leading: IconButton(
  //           icon: const Icon(Icons.arrow_back, color: Colors.white),
  //           onPressed: () => Navigator.pop(context), // برگشت
  //         ),
  //         centerTitle: true,
  //         title: _buildMainDropdown(), // دراپ‌داون انتخاب نوع
  //       ),
  //       body:
  //           isCustomer
  //               ? const CustomerPage() // صفحه چک مشتری
  //               : isBank
  //               ? const BankPage() // صفحه چک بانک
  //               : Container(),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    bool isCustomer = selectedCheckType == "مشتری";
    bool isBank = selectedCheckType == "بانک";

    // ساخت SoapClient و Repository
    final soapClient = SoapClient(
      baseUrl: AppConstants.serverUrl,
    );

    final chequeRemoteDataSource = ChequeRemoteDataSourceImpl(soapClient: soapClient);
    final chequeRepository = ChequeRepositoryImpl(remote: chequeRemoteDataSource);

    return BlocProvider(
      create: (_) => ChequeBloc(repository: chequeRepository),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppColors.primaryGreen,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: _buildMainDropdown(),
          ),
          body: isCustomer
              ? const CustomerPage()
              : isBank
              ? const BankPage()
              : Container(),
        ),
      ),
    );
  }




  // متد _buildMainDropdown - ساخت دراپ‌داون انتخاب نوع چک
  Widget _buildMainDropdown() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCheckType, // مقدار انتخاب شده
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          style: const TextStyle(
            fontFamily: "Vazir",
            fontSize: 14,
            color: AppColors.primaryPurple,
          ),
          dropdownColor: Colors.white,
          items:
              checkTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  alignment: Alignment.centerRight,
                  child: Text(type, textAlign: TextAlign.right),
                );
              }).toList(),
          onChanged: (value) {
            setState(() => selectedCheckType = value!); // تغییر نوع
          },
        ),
      ),
    );
  }
}

// BlocProvider(
// create: (_) => ChequeBloc(ChequeRepository()),
// child: BlocBuilder<ChequeBloc, ChequeState>(
// builder: (context, state) {
// if (state is ChequeLoading) {
// return const CircularProgressIndicator();
// } else if (state is ChequeLoaded) {
// return ListView.builder(
// itemCount: state.response.items.length,
// itemBuilder: (context, index) {
// final item = state.response.items[index];
// return ListTile(
// title: Text("Cheque: ${item.chequeNumber}"),
// subtitle: Text("Status: ${item.status}"),
// );
// },
// );
// } else if (state is ChequeError) {
// return Text("Error: ${state.message}");
// }
// return const SizedBox.shrink();
// },
// ),
// );

