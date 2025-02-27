import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../global.dart';

class NoticeBoardScreen extends StatefulWidget {
  final bool isLoggedIn;
  final bool isAdmin;

  NoticeBoardScreen({required this.isLoggedIn, required this.isAdmin});

  @override
  _NoticeBoardScreenState createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  List<Map<String, dynamic>> notices = [];
  final String apiUrl = "$api/notice";

  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  String? selectedNoticeId;

  @override
  void initState() {
    super.initState();
    _fetchNotices();
  }

  Future<void> _fetchNotices() async {
    final String endpoint = '$apiUrl/get-notice';

    try {
      final response = await http.get(Uri.parse(endpoint));
      print("Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('notice')) {
          setState(() {
            notices = List<Map<String, dynamic>>.from(data['notice']);
          });
        } else {
          throw Exception("Invalid data format: Expected a list under 'notice' key");
        }
      } else {
        throw Exception('Failed to load notices');
      }
    } catch (e) {
      print("Error fetching notices: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching notices")),
      );
    }
  }

  Future<void> _addNotice() async {
    final String endpoint = '$apiUrl/add-notice';

    final noticeData = {
      'title': titleController.text,
      'body': bodyController.text,
      'status': statusController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: json.encode(noticeData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notice Added Successfully')),
        );

        // Refresh the notices list
        _fetchNotices();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add notice')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _editNotice(String noticeId) async {
    final String endpoint = '$apiUrl/update-notice/$noticeId';

    final noticeData = {
      'title': titleController.text,
      'body': bodyController.text,
      'status': statusController.text,
    };

    try {
      final response = await http.put(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: json.encode(noticeData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notice Edited Successfully')),
        );

        // Refresh the notices list
        _fetchNotices();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to edit notice')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showAddOrEditNoticeDialog({String? noticeId}) {
    // If noticeId is provided, we are in Edit mode
    if (noticeId != null) {
      final selectedNotice = notices.firstWhere((notice) => notice['_id'] == noticeId);
      titleController.text = selectedNotice['title'];
      bodyController.text = selectedNotice['body'];
      statusController.text = selectedNotice['status'];
      selectedNoticeId = noticeId;
    } else {
      titleController.clear();
      bodyController.clear();
      statusController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(noticeId == null ? "Add Notice" : "Edit Notice"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: bodyController,
                decoration: InputDecoration(labelText: "Content"),
              ),
              DropdownButtonFormField<String>(
                value: statusController.text.isNotEmpty ? statusController.text : null,
                decoration: InputDecoration(labelText: 'Match Status'),
                items: ['important', 'general']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (value) {
                  statusController.text = value ?? '';
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (noticeId == null) {
                  _addNotice();
                } else {
                  _editNotice(selectedNoticeId!);
                }
                Navigator.pop(context);
              },
              child: Text(noticeId == null ? "Add" : "Save"),
            ),
          ],
        );
      },
    );
  }

  String formatDate(String isoDate) {
    try {
      DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return "Invalid Date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
          title: Text('Notice')),
      body: notices.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 64,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Notices Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'New notices will appear here',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            // Add your refresh logic here
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              var notice = notices[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notice['title'] ?? "No Title",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(notice['status'])
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: _getStatusColor(notice['status'])
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(notice['status']),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            notice['status'].toString().toUpperCase() ?? "",
                                            style: TextStyle(
                                              color: _getStatusColor(notice['status']),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.isAdmin)
                                PopupMenuButton(
                                  icon: const Icon(Icons.more_vert),
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: Row(
                                        children: const [
                                          Icon(Icons.edit, color: Colors.blue),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                      onTap: () {
                                        _showAddOrEditNoticeDialog(
                                            noticeId: notice['_id']);
                                      },
                                    ),
                                    PopupMenuItem(
                                      child: Row(
                                        children: const [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete'),
                                        ],
                                      ),
                                      onTap: () {
                                        // Add delete functionality
                                      },
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            notice['body'] ?? "",
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatDate(notice['createdAt'] ?? ""),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
        onPressed: () {
          _showAddOrEditNoticeDialog();
        },
        backgroundColor: Colors.green,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'New Notice',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      )
          : null,




    );
  }
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'general':
        return Colors.orange;
      case 'important':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
