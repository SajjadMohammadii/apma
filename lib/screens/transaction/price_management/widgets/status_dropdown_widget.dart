import 'package:flutter/material.dart';

class StatusDropdownWidget extends StatelessWidget {
  final String selectedStatus;
  final List<String> statusOptions;
  final Function(String?) onChanged;

  const StatusDropdownWidget({
    super.key,
    required this.selectedStatus,
    required this.statusOptions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatus,
          dropdownColor: Colors.white,
          isDense: true,
          alignment: Alignment.centerRight,
          style: const TextStyle(
            fontFamily: 'Vazir',
            fontSize: 10,
            color: Colors.black87,
          ),
          selectedItemBuilder: (BuildContext context) {
            return statusOptions.map((String value) {
              return Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Vazir',
                    fontSize: 10,
                    color: Colors.black87,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              );
            }).toList();
          },
          items:
              statusOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  alignment: Alignment.centerRight,
                  child: Text(
                    value,
                    style: const TextStyle(fontFamily: 'Vazir', fontSize: 10),
                    textDirection: TextDirection.rtl,
                  ),
                );
              }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
