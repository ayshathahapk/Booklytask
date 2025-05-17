import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:booklytask/features/login/loginpage.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:booklytask/features/login/widgets/schedule_card.dart';
import 'package:booklytask/features/login/widgets/date_picker_button.dart';

class HomePage extends StatefulWidget {
  final String empId;
  const HomePage({Key? key, required this.empId}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controllers
  late TextEditingController _empIdController;
  // State variables
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _staffData = [];
  // API endpoints
  static const String _baseUrl = 'https://neptonglobal.co.in/Master/schedule';
  static const String _scheduleDataEndpoint = '/scheduledata.php';
  static const String _saveScheduleEndpoint = '/save_sch.php';

  @override
  void initState() {
    super.initState();
    _empIdController = TextEditingController(text: widget.empId);
    _fetchScheduleData();
  }

  @override
  void dispose() {
    _empIdController.dispose();
    super.dispose();
  }

  // API Calls
  Future<void> _fetchScheduleData() async {
    final empId = _empIdController.text.trim();
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    if (empId.isEmpty) {
      _showErrorSnackbar('Employee ID is required');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_scheduleDataEndpoint'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'empid': empId, 'edate': formattedDate},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _staffData = data.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else {
        _showErrorSnackbar('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Failed to fetch schedule data: $e');
    }
  }

  // UI Helper Functions
  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF7453A1)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
      await _fetchScheduleData();
    }
  }
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Could not launch dialer');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Could not launch dialer for $phoneNumber');
    }
  }
  Future<void> logout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      _showErrorSnackbar('Failed to logout: $e');
    }
  }

  Future<bool> _updateScheduleStatus(Map<String, dynamic> updateData) async {
    try {
      final body = {
        'json_val': jsonEncode(updateData), // This sends JSON inside a form field
      };

      debugPrint('Sending update data: $body');

      final response = await http.post(
        Uri.parse('$_baseUrl$_saveScheduleEndpoint'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody is Map &&
            (responseBody['status'] == 'success' ||
                responseBody['message']?.toString().toLowerCase().contains('success') == true)) {
          return true;
        }
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Update error: $e');
      if (mounted) {
        _showErrorSnackbar(
          'Update failed: ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
      return false;
    }

    return false;
  }

  void _showUpdateDialog(int index) {
    final staffItem = _staffData[index];
    String? selectedStatus = staffItem['Status'];
    final remarksController = TextEditingController(text: staffItem['Remarks'] ?? '');
    final serviceChargeController = TextEditingController(
        text: staffItem['Service Charge']?.toString() ?? '');
    final receiptsNoController = TextEditingController(
        text: staffItem['Receipts No'] ?? '');
    final paymentDescriptionController = TextEditingController(
        text: staffItem['Pay Description'] ?? '');
    final taController = TextEditingController(
        text: staffItem['TA']?.toString() ?? '');
    String? selectedPaymentType = staffItem['Payments Type'];
    DateTime? selectedNextDate = staffItem['Next Date'] != null
        ? DateTime.tryParse(staffItem['Next Date'])
        : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          Future<void> _pickNextDate() async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedNextDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (pickedDate != null) {
              setState(() => selectedNextDate = pickedDate);
            }
          }

          return AlertDialog(
            title: const Text('Update Status'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: ['Completed', 'Pending', 'Cancel']
                        .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                        .toList(),
                    onChanged: (value) => setState(() => selectedStatus = value),
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),

                  if (selectedStatus == 'Pending') ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                          text: selectedNextDate != null
                              ? DateFormat('yyyy-MM-dd').format(selectedNextDate!)
                              : ''),
                      decoration: const InputDecoration(
                        labelText: 'Next Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: _pickNextDate,
                    ),
                  ],

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: remarksController,
                    decoration: const InputDecoration(labelText: 'Remarks'),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: serviceChargeController,
                    decoration: const InputDecoration(labelText: 'Service Charge'),
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: receiptsNoController,
                    decoration: const InputDecoration(labelText: 'Receipts No'),
                  ),

                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedPaymentType,
                    items: ['Cash', 'Check', 'Transfer', ]
                        .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                        .toList(),
                    onChanged: (value) => setState(() => selectedPaymentType = value),
                    decoration: const InputDecoration(labelText: 'Payment Type'),
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: paymentDescriptionController,
                    decoration: const InputDecoration(labelText: 'Payment Description'),
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: taController,
                    decoration: const InputDecoration(labelText: 'TA'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!_validateUpdateFields(
                    selectedStatus,
                    remarksController,
                    serviceChargeController,
                    receiptsNoController,
                    selectedPaymentType,
                    paymentDescriptionController,
                    taController,
                    selectedNextDate,
                  )) {
                    return;
                  }

                  final updateData = _prepareUpdateData(
                    index,
                    selectedStatus!,
                    remarksController.text,
                    serviceChargeController.text,
                    receiptsNoController.text,
                    selectedPaymentType!,
                    paymentDescriptionController.text,
                    taController.text,
                    selectedNextDate,
                  );

                  final success = await _updateScheduleStatus(updateData);
                  if (success && mounted) {
                    Navigator.pop(context);
                    await _fetchScheduleData();
                    _showSuccessDialog();
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _validateUpdateFields(
      String? status,
      TextEditingController remarks,
      TextEditingController serviceCharge,
      TextEditingController receiptsNo,
      String? paymentType,
      TextEditingController paymentDescription,
      TextEditingController ta,
      DateTime? nextDate,
      ) {
    if (status == null) {
      _showErrorSnackbar('Please select a status');
      return false;
    }

    if (status == 'Pending' && nextDate == null) {
      _showErrorSnackbar('Next Date is required when status is Pending');
      return false;
    }

    if (serviceCharge.text.isNotEmpty && double.tryParse(serviceCharge.text) == null) {
      _showErrorSnackbar('Service Charge must be a valid number');
      return false;
    }

    if (ta.text.isNotEmpty && double.tryParse(ta.text) == null) {
      _showErrorSnackbar('TA must be a valid number');
      return false;
    }

    return true;
  }
  Map<String, dynamic> _prepareUpdateData(
      int index,
      String status,
      String remarks,
      String serviceCharge,
      String receiptsNo,
      String paymentType,
      String paymentDescription,
      String ta,
      DateTime? nextDate,
      ) {
    final Map<String, dynamic> data = {
      'ticket': _staffData[index]['ticket']?.toString() ?? '',
      'Status': status,
      'Remarks': remarks.trim(),
      'Service Charge': double.tryParse(serviceCharge) ?? 0,
      'Receipts No': receiptsNo.trim(),
      'Payments Type': paymentType.trim(),
      'Pay Description': paymentDescription.trim(),
      'TA': double.tryParse(ta) ?? 0,
      'chequedt': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    };

    if (status == 'Pending' && nextDate != null) {
      data['Next Date'] = DateFormat('yyyy-MM-dd').format(nextDate);
    }

    return data;
  }
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Status updated successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {}); // Refresh the UI
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }


  ///update function

  // PDF Generation
  Future<void> _generateAndPrintPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build:
            (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              "Schedule for ${DateFormat('yyyy-MM-dd').format(_selectedDate)}",
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          ..._staffData.map((staff) => _buildPdfStaffCard(staff)).toList(),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  pw.Widget _buildPdfStaffCard(Map<String, dynamic> staff) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _pdfRow("Ticket No", staff['ticket']),
          _pdfRow("Date", staff['date']),
          _pdfRow("NEP ID", staff['nepid']),
          _pdfRow("Customer", staff['cust']),
          _pdfRow("Description", staff['desp']),
          _pdfRow("Mobile", staff['mob']),
          _pdfRow("Area", staff['area']),
          _pdfRow("Service Type", staff['service_type']),
          _pdfRow("Status", staff['status']),
        ],
      ),
    );
  }

  pw.Widget _pdfRow(String title, dynamic value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 100,
            child: pw.Text(
              "$title:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value?.toString() ?? '')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final empId = _empIdController.text.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF7453A1),
        title: Text(
          "Employee: $empId",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: _generateAndPrintPdf,
            tooltip: 'Print or Save as PDF',
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (BuildContext context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Do you really want to log out?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => logout(context),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(w * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            DatePickerButton(selectedDate: _selectedDate, onPressed: _pickDate),
            const SizedBox(height: 24),
            Expanded(
              child:
              _staffData.isEmpty
                  ? const Center(child: Text("No schedule found"))
                  : ListView.builder(
                itemCount: _staffData.length,
                itemBuilder: (context, index) {
                  return ScheduleCard(
                    staff: _staffData[index],
                    onPhoneCall: _makePhoneCall,
                    onUpdate: () => _showUpdateDialog(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


