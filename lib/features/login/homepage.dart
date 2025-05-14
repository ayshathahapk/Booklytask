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


class HomePage extends StatefulWidget {
  final String empId;
  const HomePage({Key? key, required this.empId}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController _empIdController;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _staffData = [];

  @override
  void initState() {
    super.initState();
    _empIdController = TextEditingController(text: widget.empId);
    _fetchScheduleData();
  }

  Future<void> _fetchScheduleData() async {
    final empId = _empIdController.text.trim();
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    if (empId.isEmpty) return;

    final url = Uri.parse(
      "https://neptonglobal.co.in/Master/schedule/scheduledata.php",
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'empid': empId, 'edate': formattedDate},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _staffData = data.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else {
        _showErrorSnackbar('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackbar('Something went wrong: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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

    if (picked != null) {
      setState(() => _selectedDate = picked);
      _fetchScheduleData();
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  ///update function
  void _showUpdateDialog(int index) {
    String? selectedStatus = _staffData[index]['Status'];
    final TextEditingController remarksController = TextEditingController();
    final TextEditingController serviceChargeController = TextEditingController();
    final TextEditingController receiptsNoController = TextEditingController();
    final TextEditingController paymentDescriptionController = TextEditingController();
    final TextEditingController taController = TextEditingController();

    String? selectedPaymentType;
    DateTime? selectedNextDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _pickDate() async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  selectedNextDate = pickedDate;
                });
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...['Completed', 'Pending', 'Cancel'].map((status) {
                      return RadioListTile<String>(
                        title: Text(status, style: const TextStyle(fontSize: 16)),
                        value: status,
                        groupValue: selectedStatus,
                        onChanged: (value) => setState(() => selectedStatus = value),
                      );
                    }).toList(),
                    const Divider(height: 30),
                    TextField(
                      controller: remarksController,
                      decoration: const InputDecoration(
                        labelText: 'Remarks',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
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
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
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
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedPaymentType,
                      items: ['Cash', 'Transfer', 'Cheque'].map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type, style: const TextStyle(fontSize: 16, color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedPaymentType = value),
                      decoration: const InputDecoration(
                        labelText: 'Payment Type',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: paymentDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Payment Description',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: taController,
                      decoration: const InputDecoration(
                        labelText: 'TA',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    if (selectedStatus == 'Pending') ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedNextDate == null
                                  ? 'Next Date: Not selected'
                                  : 'Next Date: ${selectedNextDate!.toLocal().toString().split(' ')[0]}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today, size: 24),
                            onPressed: _pickDate,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Validation
                    if (selectedStatus == null ||
                        remarksController.text.isEmpty ||
                        serviceChargeController.text.isEmpty ||
                        receiptsNoController.text.isEmpty ||
                        selectedPaymentType == null ||
                        paymentDescriptionController.text.isEmpty ||
                        taController.text.isEmpty ||
                        (selectedStatus == 'Pending' && selectedNextDate == null)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields before confirming.')),
                      );
                      return;
                    }

                    if (_staffData[index]['Status'] == selectedStatus) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This status is already updated.')),
                      );
                      return;
                    }

                    Navigator.pop(context); // Close dialog

                    // Show loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );

                    final body = {
                      'ticket': _staffData[index]['ticket'].toString(),
                      'Status': selectedStatus,
                      'Next Date': selectedNextDate?.toIso8601String().split('T').first ?? '',
                      'Remarks': remarksController.text,
                      'Service Charge': serviceChargeController.text,
                      'Receipts No': receiptsNoController.text,
                      'Payments Type': selectedPaymentType,
                      'Pay Description': paymentDescriptionController.text,
                      'TA': taController.text,
                      'chequedt': DateFormat('yy-MM-dd').format(DateTime.now()),
                    };

                    try {
                      final response = await http.post(
                        Uri.parse('https://neptonglobal.co.in/Master/schedule/save_sch.php'),
                        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                        body: body,
                      );

                      Navigator.pop(context); // Close loading

                      if (response.statusCode == 200 &&
                          response.body.trim().toLowerCase() == 'success') {
                        setState(() {
                          _staffData[index]['Status'] = selectedStatus;
                          _staffData[index].addAll(body);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Status updated successfully!')),
                        );
                      } else {
                        throw Exception('Failed to save data');
                      }
                    } catch (e) {
                      Navigator.pop(context); // Close loading if still open
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error'),
                          content: Text('Failed to update status. ${e.toString()}'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: const Text('Update', style: TextStyle(fontSize: 16)),
                ),
              ],
            );
          },
        );
      },
    );
  }
  ///update function

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
                ),
              ),
              ..._staffData.map((staff) {
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
              }).toList(),
            ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  pw.Widget _pdfRow(String title, String value) {
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
          pw.Expanded(child: pw.Text(value ?? '')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final empId = _empIdController.text.trim();
    Future<void> _makePhoneCall(String phoneNumber) async {
      final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch dialer for $phoneNumber')),
        );
      }
    }

    Widget _buildInfoRow(String title, dynamic value) {
      Color? statusColor;
      if (title.toLowerCase() == 'status') {
        switch (value.toUpperCase()) {
          case 'PENDING':
            statusColor = Colors.orange;
            break;
          case 'CANCEL':
            statusColor = Colors.red;
            break;
          case 'COMPLETED':
            statusColor = Colors.green;
            break;
          default:
            statusColor = Colors.black87;
        }
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 110,
              child: Text(
                '$title:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
              ),
            ),
            Expanded(
              child:
                  value is Widget
                      ? value
                      : Text(
                        value,
                        style: TextStyle(
                          fontSize: 14.5,
                          color: statusColor ?? Colors.black87,
                          fontWeight:
                              title.toLowerCase() == 'status'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
            ),
          ],
        ),
      );
    }

    Widget _buildStatusButton(int index) {
      return Container(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () => _showUpdateDialog(index),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('UPDATE'),
        ),
      );

    }

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
            Text(
              "Select Date",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Color(0xFF435EA6)),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child:
                  _staffData.isEmpty
                      ? const Center(child: Text("No schedule found"))
                      : ListView.builder(
                        itemCount: _staffData.length,
                        itemBuilder: (context, index) {
                          final staff = _staffData[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow('Ticket No', staff['ticket']),
                                  _buildInfoRow('Date', staff['date']),
                                  _buildInfoRow('NEP ID', staff['nepid']),
                                  _buildInfoRow('Customer', staff['cust']),
                                  _buildInfoRow('Description', staff['desp']),
                                  // 👇 Replaced mobile row with clickable phone
                                  _buildInfoRow(
                                    'Mobile',
                                    GestureDetector(
                                      onTap: () => _makePhoneCall(staff['mob']),
                                      child: Row(
                                        children: [
                                          Text(
                                            staff['mob'],
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontSize: 14.5,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.phone,
                                            size: 18,
                                            color: Colors.green,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _buildInfoRow('Area', staff['area']),
                                  _buildInfoRow(
                                    'Service Type',
                                    staff['service_type'],
                                  ),
                                  _buildInfoRow('Status', staff['status']),
                                  const SizedBox(height: 8),
                                  _buildStatusButton(index),
                                ],
                              ),
                            ),
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
