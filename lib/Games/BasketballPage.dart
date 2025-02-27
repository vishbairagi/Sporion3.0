import 'dart:core';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../global.dart';
class BasketballPage extends StatefulWidget {
  final bool isLoggedIn;
  final bool isAdmin;

  BasketballPage({required this.isLoggedIn, required this.isAdmin});

  @override
  _BasketballPageState createState() => _BasketballPageState();
}

class _BasketballPageState extends State<BasketballPage> {
  int teamAScore = 0;
  int teamBScore = 0;
  int period = 1;
  String teamAName = "Team A";
  String teamBName = "Team B";
  String matchId = "match1";
  String matchStatus = "Status";

  int _selectedIndex = 0;

  TextEditingController teamAController = TextEditingController();
  TextEditingController teamBController = TextEditingController();
  TextEditingController teamAScoreController = TextEditingController();
  TextEditingController teamBScoreController = TextEditingController();
  TextEditingController matchStatuses = TextEditingController();
  TextEditingController winners = TextEditingController();
  TextEditingController periodController=TextEditingController();

  final String apiUrl = "$api/basketball";

  // Fetch match data from the API
  Future<List<dynamic>> _fetchMatches(String status) async {
    final String endpoint;
print(status);
    if (status == 'live') {
    endpoint = '$apiUrl/get-live';
    }
    else if (status == 'completed') {
      endpoint = '$apiUrl/get-completed';
    } else if (status == 'upcoming') {
      endpoint = '$apiUrl/get-scheduled';
    }  else {
      throw Exception("Invalid match status: $status");
    }
    print(endpoint);

    final response = await http.get(Uri.parse(endpoint));
print(response);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
print("sfdgsdf: $data,$status");
      if (data is Map<String, dynamic> && data.containsKey('matches')) {
        return data['matches'] as List<dynamic>;
      } else {
        throw Exception("Invalid data format: Expected a list under 'matches' key");
      }
    } else {
      throw Exception('Failed to load matches');
    }
  }

  // Add a match using its details (admin only)
  Future<void> _addMatch() async {
    if (!widget.isAdmin) {
      _showUnauthorizedMessage();
      return;
    }

    final matchData = {
      'teamAName': teamAController.text,
      'teamBName': teamBController.text,
      'teamAScore': int.tryParse(teamAScoreController.text) ?? 0,
      'teamBScore': int.tryParse(teamBScoreController.text) ?? 0,
      'period': period,
      'matchStatus': matchStatuses.text,
      'winner': winners.text
    };

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/add-match'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(matchData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Match Added Successfully')));
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add match')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteMatch(String matchId) async {
    if (!widget.isAdmin) {
      _showUnauthorizedMessage();
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/delete-match/$matchId'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Match Deleted Successfully')));
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete match')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showUnauthorizedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You must be an admin to perform this action!')));
  }

  // Update match details (admin only)
  void _updateMatchDetails() {
    if (widget.isAdmin) {
      final matchData = {
        'teamAName': teamAController.text,
        'teamBName': teamBController.text,
        'teamAScore': teamAScore,
        'teamBScore': teamBScore,
        'period': period,
      };
      http.put(Uri.parse('$apiUrl/$matchId'), body: json.encode(matchData));
    } else {
      _showUnauthorizedMessage();
    }
  }

  void _showDialogToAddMatch() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Match'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: teamAController,
                  decoration: InputDecoration(labelText: 'Team A Name'),
                ),
                TextField(
                  controller: teamBController,
                  decoration: InputDecoration(labelText: 'Team B Name'),
                ),
                TextField(
                  controller: teamAScoreController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Team A Score'),
                ),
                TextField(
                  controller: teamBScoreController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Team B Score'),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Period'),
                  onChanged: (value) => period = int.tryParse(value) ?? 1,
                ),
                DropdownButtonFormField<String>(
                  value: matchStatuses.text.isNotEmpty ? matchStatuses.text : null,
                  decoration: InputDecoration(labelText: 'Match Status'),
                  items: ['completed', 'live', 'scheduled']
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                  onChanged: (value) {
                    matchStatuses.text = value ?? '';
                  },
                ),
                TextField(
                  controller: winners,
                  decoration: InputDecoration(labelText: 'Winner'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addMatch();
                Navigator.of(context).pop();
              },
              child: Text('Add Match'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.sports_basketball_sharp, color: Colors.black),
            onPressed: () {},
          ),
          title: Text('Basketball'),
          backgroundColor: Colors.white,

          bottom: TabBar(
            onTap: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            tabs: [
              Tab(text: 'PAST MATCHES'),
              Tab(text: 'UPCOMING'),
              Tab(text: 'LIVE'),
            ],
          ),
        ),
        body: widget.isLoggedIn ? _getSelectedPage(_selectedIndex) : Center(
          child: Text('You must log in to view this page!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        floatingActionButton: widget.isAdmin ? FloatingActionButton(
          onPressed: _showDialogToAddMatch,
          backgroundColor: Colors.green,
          child: Icon(Icons.add),
        ) : null,
      ),
    );
  }

  Widget _getSelectedPage(int index) {
    print(index);
    switch (index) {
      case 0: return _buildPastMatchesPage();
      case 1: return _buildUpcomingMatchesPage();
      case 2: return _buildLivePage();
      default: return _buildLivePage();
    }
  }


  void _editMatch(Map<String, dynamic> match) {
    TextEditingController teamANameController = TextEditingController(text: match['teamAName']);
    TextEditingController teamBNameController = TextEditingController(text: match['teamBName']);
    TextEditingController teamAScoreController = TextEditingController(text: match['teamAScore'].toString());
    TextEditingController teamBScoreController = TextEditingController(text: match['teamBScore'].toString());
    String matchStatus = match['matchStatus'].toString();
    TextEditingController winnersController = TextEditingController(text: match['winner'].toString());
    TextEditingController   periodController = TextEditingController(text: match['period'].toString());


    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Match'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: teamANameController,
                      decoration: InputDecoration(labelText: 'Team A Name'),
                      onChanged: (value) => setState(() {}),
                    ),
                    TextField(
                      controller: teamBNameController,
                      decoration: InputDecoration(labelText: 'Team B Name'),
                      onChanged: (value) => setState(() {}),
                    ),
                    TextField(
                      controller: teamAScoreController,
                      decoration: InputDecoration(labelText: 'Team A Score'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() {}),
                    ),
                    TextField(
                      controller: teamBScoreController,
                      decoration: InputDecoration(labelText: 'Team B Score'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() {}),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Period'),
                      onChanged: (value) => period = int.tryParse(value) ?? 1,
                    ),
                    DropdownButtonFormField<String>(
                      value: matchStatus,
                      decoration: InputDecoration(labelText: 'Match Status'),
                      items: ['completed', 'live', 'scheduled']
                          .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          matchStatus = value ?? '';
                        });
                      },
                    ),
                    TextField(
                      controller: winnersController,
                      decoration: InputDecoration(labelText: 'Winner Team'),
                      onChanged: (value) => setState(() {}),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _updateMatch(
                      match['_id'],
                      teamANameController.text,
                      teamBNameController.text,
                      int.tryParse(teamAScoreController.text) ?? 0,
                      int.tryParse(teamBScoreController.text) ?? 0,
                      matchStatus,
                      winnersController.text,
                      int.tryParse(periodController.text) ?? 0,


                    );
                    Navigator.pop(context);
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  Future<void> _updateMatch(
      String matchId,
      String teamAName,
      String teamBName,
      int teamAScore,
      int teamBScore,
      String matchStatus,
      String winner,
      int period

  ) async {
    if (!widget.isAdmin) {
      _showUnauthorizedMessage();
      return;
    }

    final matchData = {
      'teamAName': teamAName,
      'teamBName': teamBName,
      'teamAScore': teamAScore,
      'teamBScore': teamBScore,
      'matchStatus': matchStatus,
      'winner': winner,
      'period':period
    };

    try {
      final response = await http.put(
        Uri.parse('$apiUrl/update-match/$matchId'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(matchData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Match Updated Successfully')),
        );

        // Update UI in real time
        setState(() {
          // Refresh or fetch updated data from API
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update match')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildMatchList(String type) {
    final isLive = type == 'live';
    final isUpcoming = type == 'upcoming';

    return FutureBuilder<List<dynamic>>(
      future: _fetchMatches(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        isLive ? Colors.red[400]! :
                        isUpcoming ? Colors.green[400]! : Colors.blue[400]!
                    ),
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Loading matches...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Failed to load match data',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data!.isEmpty) {
          return Center(
            child: Container(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isLive ? Icons.live_tv_rounded :
                    isUpcoming ? Icons.upcoming_rounded :
                    Icons.history_rounded,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No ${type} matches',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Check back later for updates',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var match = snapshot.data![index];
            return Container(
              margin: EdgeInsets.only(bottom: 16),
              child: Material(
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isLive
                          ? [Colors.red[50]!, Colors.red[100]!]
                          : isUpcoming
                          ? [Colors.green[50]!, Colors.green[100]!]
                          : [Colors.blue[50]!, Colors.blue[100]!],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Match Status Bar
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                if (isLive) ...[
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                ],
                                Text(
                                  type.toUpperCase(),
                                  style: TextStyle(
                                    color: isLive ? Colors.red :
                                    isUpcoming ? Colors.green :
                                    Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${match['venue'] ?? 'Main Ground'}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Teams and Score Section
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Teams
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.grey[200],
                                        child: Text(
                                          match['teamAName'][0],
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        match['teamAName'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    children: [
                                      Text(
                                        'VS',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      if (isUpcoming)
                                        Text(
                                          '${match['matchTime'] ?? '3:00 PM'}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.grey[200],
                                        child: Text(
                                          match['teamBName'][0],
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        match['teamBName'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // Score
                            if (!isUpcoming) ...[
                              SizedBox(height: 20),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${match['teamAScore']}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        '-',
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${match['teamBScore']}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Admin Actions
                      if (widget.isAdmin)
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: () => _editMatch(match),
                                  icon: Icon(Icons.edit_rounded),
                                  label: Text('Edit Match'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.blue[700],
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 36,
                                color: Colors.grey[200],
                              ),
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: () => _deleteMatch(match['_id']),
                                  icon: Icon(Icons.delete_rounded),
                                  label: Text('Delete'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red[700],
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

// Usage remains the same:
  Widget _buildLivePage() => _buildMatchList('live');
  Widget _buildPastMatchesPage() => _buildMatchList('completed');
  Widget _buildUpcomingMatchesPage() => _buildMatchList('upcoming');
}
