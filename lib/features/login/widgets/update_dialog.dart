import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpdateDialog extends StatelessWidget {
  final String? selectedStatus;
  final TextEditingController remarksController;
  final TextEditingController serviceChargeController;
  final TextEditingController receiptsNoController;
  final TextEditingController paymentDescriptionController;
  final TextEditingController taController;
  final String? selectedPaymentType;
  final DateTime? selectedNextDate;
  final Function(String?) onStatusChanged;
  final Function(String?) onPaymentTypeChanged;
  final Future<void> Function() onPickDate;
  final VoidCallback onUpdate;

  const UpdateDialog({
    Key? key,
    required this.selectedStatus,
    required this.remarksController,
    required this.serviceChargeController,
    required this.receiptsNoController,
    required this.paymentDescriptionController,
    required this.taController,
    required this.selectedPaymentType,
    required this.selectedNextDate,
    required this.onStatusChanged,
    required this.onPaymentTypeChanged,
    required this.onPickDate,
    required this.onUpdate,
  }) : super(key: key);

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Next Date';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Text(
        'Update Status',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...['Completed', 'Pending', 'Cancel'].map((status) {
              return RadioListTile<String>(
                title: Text(
                  status,
                  style: const TextStyle(fontSize: 16),
                ),
                value: status,
                groupValue: selectedStatus,
                onChanged: onStatusChanged,
              );
            }).toList(),
            const Divider(height: 30),
            TextField(
              controller: remarksController,
              decoration: const InputDecoration(
                labelText: 'Remarks',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 12,
                ),
              ),
              style: const TextStyle(fontSize: 16),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: serviceChargeController,
              decoration: const InputDecoration(
                labelText: 'Service Charge',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 12,
                ),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: receiptsNoController,
              decoration: const InputDecoration(
                labelText: 'Receipts No',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 12,
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedPaymentType,
              items: ['Cash', 'Transfer', 'Cheque'].map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onPaymentTypeChanged,
              decoration: const InputDecoration(
                labelText: 'Payment Type',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 12,
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: paymentDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Payment Description',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 12,
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: taController,
              decoration: const InputDecoration(
                labelText: 'TA',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 12,
                ),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  onPickDate();
                }
              },
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Next Date',
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 12,
                ),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              controller: TextEditingController(
                text: selectedNextDate != null 
                    ? DateFormat('yyyy-MM-dd').format(selectedNextDate!)
                    : 'Select Next Date',
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onUpdate,
          child: const Text('Update'),
        ),
      ],
    );
  }
} 