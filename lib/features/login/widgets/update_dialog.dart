import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpdateDialog extends StatefulWidget {
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

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {

  String? statusss;

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
                groupValue: widget.selectedStatus,
                onChanged: (value) {
                  widget.onStatusChanged(value??'');
                  statusss=value!;
                  setState(() {

                  });
                },
              );
            }).toList(),
            const SizedBox(height: 16),
            TextField(
              controller: widget.taController,
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
              controller: widget.serviceChargeController,
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
            const Divider(height: 30),
            TextField(
              controller: widget.remarksController,
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
              controller: widget.receiptsNoController,
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
              value: widget.selectedPaymentType,
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
              onChanged: widget.onPaymentTypeChanged,
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
              controller: widget.paymentDescriptionController,
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
            if(statusss=='Pending')
              TextField(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    widget.onPickDate();
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
                  text: widget.selectedNextDate != null
                      ? DateFormat('yyyy-MM-dd').format(widget.selectedNextDate!)
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
          onPressed: widget.onUpdate,
          child: const Text('Update'),
        ),
      ],
    );
  }
}




