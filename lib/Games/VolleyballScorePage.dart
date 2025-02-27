import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../global.dart';

class VolleyballScorePage extends StatefulWidget {
  final bool isLoggedIn;
  final bool isAdmin;

  VolleyballScorePage({required this.isLoggedIn, required this.isAdmin});

  @override
  _VolleyballScorePageState createState() => _VolleyballScorePageState();
}

class _VolleyballScorePageState extends State<VolleyballScorePage> {
  int teamASPoints= 0;
  int teamBPoints = 0;
  int teamASets = 0;
  int teamBSets = 0;
  int teamAGames = 0;
  int teamBGames = 0;
  String teamAName = "Team A";
  String teamBName = "Team B";
  String matchId = "match1";
  String matchStatus = "Status";
  String winnerss="TeamA";

  List<Map<String, dynamic>> matches = [];

  int _selectedIndex = 0;

  TextEditingController teamANameController = TextEditingController();
  TextEditingController teamBNameController = TextEditingController();
  TextEditingController teamAPointsController = TextEditingController();
  TextEditingController teamBPointsController = TextEditingController();
  TextEditingController teamASetsController = TextEditingController();
  TextEditingController teamBSetsController = TextEditingController();
  TextEditingController teamAGamesController = TextEditingController();
  TextEditingController teamBGamesController = TextEditingController();
  TextEditingController matchStatuses = TextEditingController();
  TextEditingController winners = TextEditingController();

  final String apiUrl = "$api/volleyball";

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
    print("ddd $endpoint");

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
      'teamAName': teamANameController.text,
      'teamBName': teamBNameController.text,
      'teamASPoints': int.tryParse(teamAPointsController.text) ?? 0,
      'teamBPoints': int.tryParse(teamBPointsController.text) ?? 0,
      'teamASets': int.tryParse(teamASetsController.text) ?? 0,
      'teamBSets': int.tryParse(teamBSetsController.text) ?? 0,
      'teamAGames': int.tryParse(teamAGamesController.text) ?? 0,
      'teamBGames': int.tryParse(teamBGamesController.text) ?? 0,
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
        setState(() {

          int matchIndex = matches.indexWhere((m) => m['_id'] == matchId);
          if (matchIndex != -1) {
            matches[matchIndex] = {
              '_id': matchId,
              'teamAName': teamAName,
              'teamBName': teamBName,
              'teamASPoints': teamASPoints,
              'teamBPoints': teamBPoints,
              'teamASets': teamASets,
              'teamBSets': teamBSets,
              'teamAGames': teamAGames,
              'teamBGames': teamBGames,
              'matchStatus': matchStatus,
              'winner': winners,
            };
          }

        });
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
  void _showDialogToAddMatch() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Match'),
          content: SingleChildScrollView( // Added to prevent overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: teamANameController,
                  decoration: InputDecoration(labelText: 'Team A Name'),
                ),
                TextField(
                  controller: teamBNameController,
                  decoration: InputDecoration(labelText: 'Team B Name'),
                ),
                TextField(
                  controller: teamAPointsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Team A Points'),
                ),
                TextField(
                  controller: teamBPointsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Team B Points'),
                ),
                TextField(
                  controller: teamASetsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Team A Sets'),
                ),
                TextField(
                  controller: teamBSetsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Team B Sets'),
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
            icon: Icon(Icons.sports_volleyball_outlined, color: Colors.black),
            onPressed: () {},
          ),
          title: Text('Volleyball '),
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
    TextEditingController teamAPointsController = TextEditingController(text: match['teamASPoints'].toString());
    TextEditingController teamBPointsController = TextEditingController(text: match['teamBPoints'].toString());
    TextEditingController teamASetsController = TextEditingController(text: match['teamASets'].toString());
    TextEditingController teamBSetsController = TextEditingController(text: match['teamBSets'].toString());
    TextEditingController teamAGamesController = TextEditingController(text: match['teamAGames'].toString());
    TextEditingController teamBGamesController = TextEditingController(text: match['teamBGames'].toString());
    String matchStatus = match['matchStatus'].toString();
    TextEditingController winnersController = TextEditingController(text: match['winner'].toString());

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
                      controller: teamASetsController,
                      decoration: InputDecoration(labelText: 'Team A Sets'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() {}),
                    ),
                    TextField(
                      controller: teamBSetsController,
                      decoration: InputDecoration(labelText: 'Team B Sets'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() {}),
                    ),
                    TextField(
                      controller: teamAPointsController,
                      decoration: InputDecoration(labelText: 'Team A Points'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => setState(() {}),
                    ),TextField(
                      controller: teamBPointsController,
                      decoration: InputDecoration(labelText: 'Team B Points'),
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
                      int.tryParse(teamAPointsController.text) ?? 0,
                      int.tryParse(teamBPointsController.text) ?? 0,
                      int.tryParse(teamASetsController.text) ?? 0,
                      int.tryParse(teamBSetsController.text) ?? 0,
                      int.tryParse(teamAGamesController.text) ?? 0,
                      int.tryParse(teamBGamesController.text) ?? 0,
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
  int teamASPoints,
  int teamBPoints ,
  int teamASets ,
  int teamBSets,
  int teamAGames,
  int teamBGames ,
      String matchStatus,
      String winner,
      ) async {
    if (!widget.isAdmin) {
      _showUnauthorizedMessage();
      return;
    }

    final matchData = {
      'teamAName': teamAName,
      'teamBName': teamBName,
     'teamAPoints':teamASPoints,
     'teamBPoints':teamBPoints,
    'teamASets':teamASets,
    'teamBSets':teamBSets,
    'teamAGames':teamAGames,
    'teamBGames' : teamBGames,
      'matchStatus': matchStatus,
      'winner': winners.text,
    };
print("match $matchData");
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

  Widget _buildLivePage() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchMatches('live'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF5E35B1),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading matches',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
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
                Icon(Icons.sports_volleyball, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No live matches at the moment',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var match = snapshot.data![index];
              return _buildMatchCard(match, 'live');
            },
          ),
        );
      },
    );
  }

  Widget _buildPastMatchesPage() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchMatches('completed'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF5E35B1),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading completed matches',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
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
                Icon(Icons.history, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No completed matches found',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var match = snapshot.data![index];
              return _buildMatchCard(match, 'completed');
            },
          ),
        );
      },
    );
  }

  Widget _buildUpcomingMatchesPage() {
    return FutureBuilder<List<dynamic>>(
      future: _fetchMatches('upcoming'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF5E35B1),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading upcoming matches',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
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
                Icon(Icons.calendar_today, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No upcoming matches scheduled',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var match = snapshot.data![index];
              return _buildMatchCard(match, 'upcoming');
            },
          ),
        );
      },
    );
  }

  Widget _buildMatchCard(dynamic match, String matchType) {
    Color cardColor = Colors.white;
    Color statusColor = Colors.grey;
    Icon statusIcon = Icon(Icons.access_time, color: Colors.grey[600]);
    String statusText = 'Scheduled';

    // Safely get integer values, ensuring we handle both String and int types
    int teamAPoints = _safeParseInt(match['teamAPoints']);
    int teamBPoints = _safeParseInt(match['teamBPoints']);
    int teamASets = _safeParseInt(match['teamASets']);
    int teamBSets = _safeParseInt(match['teamBSets']);

    if (matchType == 'live') {
      cardColor = Colors.red[50]!;
      statusColor = Colors.red;
      statusIcon = const Icon(Icons.fiber_manual_record, color: Colors.red, size: 12);
      statusText = 'LIVE';
    } else if (matchType == 'completed') {
      statusIcon = Icon(Icons.done_all, color: Colors.green[600]);
      statusText = 'Completed';
    } else if (matchType == 'upcoming') {
      statusIcon = Icon(Icons.event_available, color: Colors.blue[600]);
      statusText = 'Upcoming';
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: cardColor,
          child: Column(
            children: [
              // Match status bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: statusColor.withOpacity(0.1),
                child: Row(
                  children: [
                    statusIcon,
                    const SizedBox(width: 8),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const Spacer(),
                    if (matchType == 'live')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.sports_volleyball, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'WATCH',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Match details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Team A
                    Expanded(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.indigo[100],
                            child: Text(
                              _getInitial(match['teamAName']),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo[800],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            match['teamAName'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          // Sets indicator for Team A
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.indigo[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'SETS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$teamASets',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center content with points
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'POINTS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: matchType == 'live' ? Colors.red[50] : Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                            border: matchType == 'live'
                                ? Border.all(color: Colors.red.withOpacity(0.5))
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$teamAPoints',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[800],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '-',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Text(
                                '$teamBPoints',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (matchType == 'live')
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.sports_volleyball, size: 12, color: Colors.green[700]),
                                const SizedBox(width: 4),
                                Text(
                                  'SET ${teamASets + teamBSets + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    // Team B
                    Expanded(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.orange[100],
                            child: Text(
                              _getInitial(match['teamBName']),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[800],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            match['teamBName'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          // Sets indicator for Team B
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'SETS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$teamBSets',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Admin actions
              if (widget.isAdmin)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () => _editMatch(match),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit Match'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.indigo[700],
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: Colors.grey[300],
                      ),
                      TextButton.icon(
                        onPressed: () => _deleteMatch(match['_id']),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red[700],
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
  }

// Helper method to safely get the initial letter from a team name
  String _getInitial(dynamic teamName) {
    if (teamName == null) return '?';
    String name = teamName.toString();
    return name.isNotEmpty ? name.substring(0, 1) : '?';
  }

// Helper method to safely parse integer values from dynamic map fields
  int _safeParseInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }
}
