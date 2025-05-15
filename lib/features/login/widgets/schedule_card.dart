import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final Map<String, dynamic> staff;
  final Function(String) onPhoneCall;
  final VoidCallback onUpdate;

  const ScheduleCard({
    Key? key,
    required this.staff,
    required this.onPhoneCall,
    required this.onUpdate,
  }) : super(key: key);

  Widget _buildInfoRow(String title, dynamic value) {
    Color? statusColor;
    if (title.toLowerCase() == 'status') {
      statusColor = _getStatusColor(value.toString());
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
            child: value is Widget
                ? value
                : Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 14.5,
                      color: statusColor ?? Colors.black87,
                      fontWeight: title.toLowerCase() == 'status'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'CANCEL':
        return Colors.red;
      case 'COMPLETED':
        return Colors.green;
      default:
        return Colors.black87;
    }
  }

  Widget _buildStatusButton() {
    return Container(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: onUpdate,
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

  @override
  Widget build(BuildContext context) {
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
            _buildInfoRow(
              'Mobile',
              GestureDetector(
                onTap: () => onPhoneCall(staff['mob']),
                child: Row(
                  children: [
                    Text(
                      staff['mob'],
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
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
            _buildInfoRow('Service Type', staff['service_type']),
            _buildInfoRow('Status', staff['status']),
            const SizedBox(height: 8),
            _buildStatusButton(),
          ],
        ),
      ),
    );
  }
}

