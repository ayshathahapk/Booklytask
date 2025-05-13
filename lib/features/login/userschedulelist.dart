// import 'package:flutter/material.dart';
//
// class StaffList extends StatefulWidget {
//   const StaffList({super.key});
//
//   @override
//   State<StaffList> createState() => _StaffListState();
// }
//
// class _StaffListState extends State<StaffList> {
//
//   void _showUpdateDialog(int index) {
//     String? selectedStatus = staffData[index]['Status'];
//
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Update Status'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: ['Completed', 'Pending', 'Postponed'].map((status) {
//               return RadioListTile<String>(
//                 title: Text(status),
//                 value: status,
//                 groupValue: selectedStatus,
//                 onChanged: (value) {
//                   setState(() {
//                     selectedStatus = value;
//                   });
//                   Navigator.of(context).pop(); // Close the current dialog
//                   _confirmUpdateStatus(index, value!); // Show confirmation
//                 },
//               );
//             }).toList(),
//           ),
//         );
//       },
//     );
//   }
//
//   void _confirmUpdateStatus(int index, String newStatus) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Status Change'),
//         content: Text('Are you sure you want to change the status to "$newStatus"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context), // Cancel
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 staffData[index]['Status'] = newStatus;
//               });
//               Navigator.pop(context); // Close confirmation
//             },
//             child: const Text('Confirm'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text(
//           'Staff Updations',
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.black),
//         elevation: 1,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(12),
//         itemCount: staffData.length,
//         itemBuilder: (context, index) {
//           final staff = staffData[index];
//           return Card(
//             color: Colors.grey[300],
//             margin: const EdgeInsets.only(bottom: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   ...staff.entries.map((entry) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 2),
//                       child: Text(
//                         '${entry.key}: ${entry.value}',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     );
//                   }),
//                   const SizedBox(height: 8),
//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: ElevatedButton(
//                       onPressed: () => _showUpdateDialog(index),
//                       child: const Text('Update'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
//
//
//
