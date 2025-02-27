import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../global.dart';

class Cricketscorepage extends StatefulWidget {
  final bool isLoggedIn;
  final bool isAdmin;

  Cricketscorepage({required this.isLoggedIn, required this.isAdmin});

  @override
  _CricketPageState createState() => _CricketPageState();
}

class _CricketPageState extends State<Cricketscorepage> {
  int teamARuns = 0;
  int teamBRuns = 0;
  int teamAOvers = 0;
  int teamBOvers = 0;
  int teamAWickets = 0;
  int teamBWickets = 0;
  String teamAName = "Team A";
  String teamBName = "Team B";
  String matchId = "match1";
  String matchStatus = "Status";

  int _selectedIndex = 0;
  List<Map<String, dynamic>> matches = [];


  TextEditingController teamAController = TextEditingController();
  TextEditingController teamBController = TextEditingController();
  TextEditingController teamARunsController = TextEditingController();
  TextEditingController teamBRunsController = TextEditingController();
  TextEditingController teamAOversController = TextEditingController();
  TextEditingController teamBOversController = TextEditingController();
  TextEditingController teamAWicketsController = TextEditingController();
  TextEditingController teamBWicketsController = TextEditingController();
  TextEditingController matchStatuses = TextEditingController();
  TextEditingController winners = TextEditingController();

  final String apiUrl = "$api/cricket";

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
      'teamARuns': int.tryParse(teamARunsController.text) ?? 0,
      'teamBRuns': int.tryParse(teamBRunsController.text) ?? 0,
      'teamAOvers': int.tryParse(teamAOversController.text) ?? 0,
      'teamBOvers': int.tryParse(teamBOversController.text) ?? 0,
      'teamAWickets': int.tryParse(teamAWicketsController.text) ?? 0,
      'teamBWickets': int.tryParse(teamBWicketsController.text) ?? 0,
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
        'teamARuns': teamARuns,
        'teamBRuns': teamBRuns,
        'teamAOvers': teamAOvers,
        'teamBOvers': teamBOvers,
        'teamAWickets': teamAWickets,
        'teamBWickets': teamBWickets,

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
                  controller: teamARunsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Team A Runs'),
                ),
                TextField(
                  controller: teamBRunsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Team B Runs'),
                ),
            
                TextField(
                  controller: teamAWicketsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Team A Wickets'),
                ),
                TextField(
                  controller: teamBWicketsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Team B Wickets'),
                ),
                TextField(
                  controller: teamAOversController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Team A Overs'),
                ),
                TextField(
                  controller: teamBOversController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Team B Overs'),
                ),
            
                /*TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Period'),
                  onChanged: (value) => period = int.tryParse(value) ?? 1,
                ),*/
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
            icon: Icon(Icons.sports_cricket, color: Colors.black),
            onPressed: () {},
          ),
          title: Text('Cricket '),
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
   /* TextEditingController teamANameController = TextEditingController(text: match['teamAName']);
    TextEditingController teamBNameController = TextEditingController(text: match['teamBName']);
    TextEditingController teamAScoreController = TextEditingController(text: match['teamAScore'].toString());
    TextEditingController teamBScoreController = TextEditingController(text: match['teamBScore'].toString());
    String matchStatus = match['matchStatus'].toString();*/

    TextEditingController teamAController = TextEditingController(text: match['teamAName']);
    TextEditingController teamBController = TextEditingController(text: match['teamBName']);
    TextEditingController teamARunsController = TextEditingController(text: match['teamARuns'].toString());
    TextEditingController teamBRunsController = TextEditingController(text: match['teamBRuns'].toString());
    TextEditingController teamAOversController = TextEditingController(text: match['teamAOvers'].toString());
    TextEditingController teamBOversController = TextEditingController(text: match['teamBOvers'].toString());
    TextEditingController teamAWicketsController = TextEditingController(text: match['teamAWickets'].toString());
    TextEditingController teamBWicketsController = TextEditingController(text: match['teamBWickets'].toString());
    TextEditingController winnersController = TextEditingController(text: match['winners'].toString());
   // TextEditingController matchStatuses = TextEditingController();
    String matchStatus = match['matchStatus'].toString();


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
                      controller: teamAController,
                      decoration: InputDecoration(labelText: 'Team A Name'),
                      onChanged: (value) => setState(() {}),
                    ),
                    TextField(
                      controller: teamBController,
                      decoration: InputDecoration(labelText: 'Team B Name'),
                      onChanged: (value) => setState(() {}),
                    ),
                    TextField(
                      controller: teamARunsController,
                      decoration: InputDecoration(labelText: 'Team A Runs'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() {}),
                    ),
                    TextField(
                      controller: teamBRunsController,
                      decoration: InputDecoration(labelText: 'Team B Runs'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() {}),
                    ),
                    TextField(
                      controller: teamAOversController,
                      decoration: InputDecoration(labelText: 'Team A Over'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() {}),
                    ),
                    TextField(
                      controller: teamBOversController,
                      decoration: InputDecoration(labelText: 'Team B Over'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() {}),
                    ),
                    TextField(
                      controller: teamAWicketsController,
                      decoration: InputDecoration(labelText: 'Team A Wickets'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() {}),
                    ),
                    TextField(
                      controller: teamBWicketsController,
                      decoration: InputDecoration(labelText: 'Team B Wickets'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() {}),
                    ),
                    DropdownButtonFormField<String>(
                      value: matchStatus,
                      decoration: InputDecoration(labelText: 'Match Status'),
                      items: ['completed', 'live', 'scheduled']
                          .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      )).toList(),
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
                      teamAController.text,
                      teamBController.text,
                      int.tryParse(teamARunsController.text) ?? 0,
                      int.tryParse(teamBRunsController.text) ?? 0,
                      int.tryParse(teamAOversController.text) ?? 0,
                      int.tryParse(teamBOversController.text) ?? 0,
                      int.tryParse(teamAWicketsController.text) ?? 0,
                      int.tryParse(teamBWicketsController.text) ?? 0,
                      matchStatus,
                      winnersController.text,
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
  int teamARuns ,
  int teamBRuns,
  int teamAOvers ,
  int teamBOvers,
  int teamAWickets ,
  int teamBWickets,
      String matchStatus,
      String winners,
      ) async {
    if (!widget.isAdmin) {
      _showUnauthorizedMessage();
      return;
    }

    final matchData = {
     // 'matchId':matchId,
    'teamAName': teamAName,
      'teamBName': teamBName,
      'teamARuns': teamARuns,
      'teamBRuns': teamBRuns,
      'teamAOvers': teamAOvers,
      'teamBOvers': teamBOvers,
      'teamAWickets': teamAWickets,
      'teamBWickets': teamBWickets,
      'matchStatus': matchStatus,
      'winner': winners,
    };
print("zzz $matchData");
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
          int matchIndex = matches.indexWhere((match) => match['_id'] == matchId);
          if (matchIndex != -1) {
            matches[matchIndex] = {
              '_id': matchId,
              'teamAName': teamAName,
              'teamBName': teamBName,
              'teamARuns': teamARuns,
              'teamBRuns': teamBRuns,
              'teamAOvers': teamAOvers,
              'teamBOvers': teamBOvers,
              'teamAWickets': teamAWickets,
              'teamBWickets': teamBWickets,
              'matchStatus': matchStatus,
              'winners': winners,
            };
          }


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
    return FutureBuilder<List<dynamic>>(
      future: _fetchMatches(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasData && snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == 'live' ? Icons.sports_cricket :
                  type == 'upcoming' ? Icons.upcoming :
                  Icons.history,
                  size: 60,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'No ${type} matches found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var match = snapshot.data![index];
            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: type == 'live'
                          ? [Colors.blue[50]!, Colors.blue[100]!]
                          : type == 'upcoming'
                          ? [Colors.green[50]!, Colors.green[100]!]
                          : [Colors.grey[50]!, Colors.grey[100]!],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Teams Header
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                match['teamAName'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: type == 'live' ? Colors.red[400] :
                                type == 'upcoming' ? Colors.green[400] :
                                Colors.grey[400],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                type.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                match['teamBName'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Score Section
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Team A Score
                            Column(
                              children: [
                                Text(
                                  '${match['teamARuns']}/${match['teamAWickets']}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '(${match['teamAOvers']})',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),

                            // VS Divider
                            Container(
                              height: 50,
                              width: 1,
                              color: Colors.grey[300],
                            ),

                            // Team B Score
                            Column(
                              children: [
                                Text(
                                  '${match['teamBRuns']}/${match['teamBWickets']}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '(${match['teamBOvers']})',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton.icon(
                                onPressed: () => _editMatch(match),
                                icon: Icon(Icons.edit, color: Colors.blue),
                                label: Text('Edit', style: TextStyle(color: Colors.blue)),
                              ),
                              Container(
                                width: 1,
                                height: 24,
                                color: Colors.grey[300],
                              ),
                              TextButton.icon(
                                onPressed: () => _deleteMatch(match['_id']),
                                icon: Icon(Icons.delete, color: Colors.red),
                                label: Text('Delete', style: TextStyle(color: Colors.red)),
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

// Usage:
  Widget _buildPastMatchesPage() => _buildMatchList('completed');
  Widget _buildLivePage() => _buildMatchList('live');
  Widget _buildUpcomingMatchesPage() => _buildMatchList('upcoming');
}
