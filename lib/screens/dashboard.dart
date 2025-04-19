import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vermeni/services/gemini_service.dart';

class NavigationDashboard extends StatefulWidget {
  final GeminiService? geminiService;
  const NavigationDashboard({super.key, this.geminiService});

  @override
  State<NavigationDashboard> createState() => _NavigationDashboardState();
}

class _NavigationDashboardState extends State<NavigationDashboard> {
  // Color scheme
  static const Color _primaryColor = Color.fromARGB(255, 74, 9, 124);
  static const Color _accentColor = Color(0xFF00B4D8);
  static const Color _successColor = Color(0xFF4CAF50);
  static const Color _warningColor = Color(0xFFFFA000);
  static const Color _infoColor = Color(0xFF2196F3);
  static const Color _dangerColor = Color(0xFFEF5350);

  // Data variables
  List<NavigationActivity> _recentActivities = [];
  List<EducationalContent> _educationalContent = [];
  Map<String, LearningProgress> _learningProgress = {};
  bool _isLoading = false;
  bool _usingGemini = false;
  String _userName = "Aditya Bhattacharya";
  String _userTitle = "Liquid Galaxy Contributor";
  String _userImage = "https://upload.wikimedia.org/wikipedia/commons/8/88/Tom_Cruise_December_2024_cropped.png";

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    setState(() {
      _recentActivities = [
        NavigationActivity("Completed Earth navigation", "2 hours ago", Icons.public, _successColor),
        NavigationActivity("Practiced KML upload", "5 hours ago", Icons.map, _infoColor),
        NavigationActivity("Learned new shortcuts", "1 day ago", Icons.keyboard, _warningColor),
        NavigationActivity("Mastered tour creation", "2 days ago", Icons.tour, _accentColor),
      ];
      
      _educationalContent = [
        EducationalContent(
          "Advanced KML Techniques",
          "Learn to create interactive tours",
          "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjzI4JzY6oUy-dQaiW-HLmn5NQ7qiw7NUOoK-2cDU9cI6JwhPrNv0EkCacuKWFViEgXYrCFzlbCtHZQffY6a73j6_ATFjfeU7r6OxXxN5K8sGjfOlp3vvd6eCXZrozlu34fUG5_cKHmzZWa4axb-vJRKjLr2tryz0Zw30gTv3S0ET57xsCiD25WMPn3wA/s800/LIQUIDGALAXYLOGO.png",
          _primaryColor,
        ),
        EducationalContent(
          "Liquid Galaxy Shortcuts",
          "Master navigation controls",
          "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjzI4JzY6oUy-dQaiW-HLmn5NQ7qiw7NUOoK-2cDU9cI6JwhPrNv0EkCacuKWFViEgXYrCFzlbCtHZQffY6a73j6_ATFjfeU7r6OxXxN5K8sGjfOlp3vvd6eCXZrozlu34fUG5_cKHmzZWa4axb-vJRKjLr2tryz0Zw30gTv3S0ET57xsCiD25WMPn3wA/s800/LIQUIDGALAXYLOGO.png",
          _infoColor,
        ),
      ];
      
      _learningProgress = {
        "Navigation Skills": LearningProgress(0.7, _accentColor),
        "KML Proficiency": LearningProgress(0.4, _infoColor),
        "System Commands": LearningProgress(0.9, _successColor),
      };
    });

    if (widget.geminiService != null) {
      _enhanceWithGemini();
    }
  }

  Future<void> _enhanceWithGemini() async {
    setState(() {
      _isLoading = true;
      _usingGemini = true;
    });

    try {
      final profileResponse = await widget.geminiService!.getResponse(
        "Generate a user profile for a Liquid Galaxy operator. Return as JSON with name, title, and imageUrl."
      );
      _updateProfile(profileResponse);

      final activitiesResponse = await widget.geminiService!.getResponse(
        "Suggest 4 recent activities for a Liquid Galaxy operator. Return as JSON array with title, timeAgo, icon and color fields."
      );
      _updateActivities(activitiesResponse);

      final contentResponse = await widget.geminiService!.getResponse(
        "Suggest 2 educational resources for learning Liquid Galaxy navigation. Return as JSON array with title, description, imageUrl and color."
      );
      _updateEducationalContent(contentResponse);

      final progressResponse = await widget.geminiService!.getResponse(
        "Generate realistic learning progress metrics for a Liquid Galaxy operator. Return as JSON with navigation_skills, kml_proficiency, and system_commands fields."
      );
      _updateLearningProgress(progressResponse);

    } catch (e) {
      debugPrint("Gemini enhancement failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateProfile(String response) {
    try {
      final json = jsonDecode(response.replaceAll('```json', '').replaceAll('```', ''));
      setState(() {
        _userName = json['name'] ?? _userName;
        _userTitle = json['title'] ?? _userTitle;
        _userImage = json['imageUrl'] ?? _userImage;
      });
    } catch (e) {
      debugPrint("Failed to parse profile: $e");
    }
  }

  void _updateActivities(String response) {
    try {
      final json = jsonDecode(response.replaceAll('```json', '').replaceAll('```', ''));
      final activities = (json as List).map((item) => NavigationActivity(
        item['title'] ?? "Navigation Activity",
        item['timeAgo'] ?? "Recently",
        _parseIcon(item['icon']),
        _parseColor(item['color']),
      )).toList();
      
      if (activities.length >= 4) {
        setState(() => _recentActivities = activities);
      }
    } catch (e) {
      debugPrint("Failed to parse activities: $e");
    }
  }

  void _updateEducationalContent(String response) {
    try {
      final json = jsonDecode(response.replaceAll('```json', '').replaceAll('```', ''));
      final content = (json as List).map((item) => EducationalContent(
        item['title'] ?? "Educational Resource",
        item['description'] ?? "Learn about Liquid Galaxy",
        item['imageUrl'] ?? "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjzI4JzY6oUy-dQaiW-HLmn5NQ7qiw7NUOoK-2cDU9cI6JwhPrNv0EkCacuKWFViEgXYrCFzlbCtHZQffY6a73j6_ATFjfeU7r6OxXxN5K8sGjfOlp3vvd6eCXZrozlu34fUG5_cKHmzZWa4axb-vJRKjLr2tryz0Zw30gTv3S0ET57xsCiD25WMPn3wA/s800/LIQUIDGALAXYLOGO.png",
        _parseColor(item['color']),
      )).toList();
      
      if (content.length >= 2) {
        setState(() => _educationalContent = content);
      }
    } catch (e) {
      debugPrint("Failed to parse educational content: $e");
    }
  }

  void _updateLearningProgress(String response) {
    try {
      final json = jsonDecode(response.replaceAll('```json', '').replaceAll('```', ''));
      final progress = {
        "Navigation Skills": LearningProgress(
          double.tryParse(json['navigation_skills']?['progress']?.toString() ?? '0.7') ?? 0.7,
          _parseColor(json['navigation_skills']?['color']) ?? _accentColor,
        ),
        "KML Proficiency": LearningProgress(
          double.tryParse(json['kml_proficiency']?['progress']?.toString() ?? '0.4') ?? 0.4,
          _parseColor(json['kml_proficiency']?['color']) ?? _infoColor,
        ),
        "System Commands": LearningProgress(
          double.tryParse(json['system_commands']?['progress']?.toString() ?? '0.9') ?? 0.9,
          _parseColor(json['system_commands']?['color']) ?? _successColor,
        ),
      };
      setState(() => _learningProgress = progress);
    } catch (e) {
      debugPrint("Failed to parse learning progress: $e");
    }
  }

  IconData _parseIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'public': return Icons.public;
      case 'map': return Icons.map;
      case 'keyboard': return Icons.keyboard;
      case 'tour': return Icons.tour;
      case 'school': return Icons.school;
      default: return Icons.explore;
    }
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null) return _primaryColor;
    try {
      return Color(int.parse(colorHex.replaceFirst('0x', '0xFF')));
    } catch (e) {
      return _primaryColor;
    }
  }

  void _showActivityDetails(NavigationActivity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Completed: ${activity.timeAgo}"),
            const SizedBox(height: 16),
            if (widget.geminiService != null)
              FutureBuilder(
                future: widget.geminiService!.getResponse(
                  "Explain the Liquid Galaxy navigation activity: ${activity.title}. "
                  "Provide 2-3 sentences about its importance and tips for improvement."
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  return Text(snapshot.data ?? "No additional information available");
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showContentDetails(EducationalContent content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(content.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                color: content.color.withOpacity(0.1),
                child: Center(
                  child: Icon(
                    Icons.public,
                    size: 50,
                    color: content.color.withOpacity(0.3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(content.description),
              const SizedBox(height: 16),
              if (widget.geminiService != null)
                FutureBuilder(
                  future: widget.geminiService!.getResponse(
                    "Generate a brief learning guide about ${content.title} for Liquid Galaxy. "
                    "Include 3 key points and a practice exercise."
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    return Text(snapshot.data ?? "No additional learning guide available");
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Navigation Dashboard Help"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("This dashboard helps you track your Liquid Galaxy navigation progress."),
              const SizedBox(height: 16),
              if (widget.geminiService != null)
                FutureBuilder(
                  future: widget.geminiService!.getResponse(
                    "Provide 3 tips for using the Liquid Galaxy Navigation Dashboard effectively."
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    return Text(snapshot.data ?? "No tips available");
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it!"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Navigation Dashboard"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (widget.geminiService != null)
            IconButton(
              icon: Icon(_usingGemini ? Icons.auto_awesome : Icons.auto_awesome_mosaic),
              onPressed: _enhanceWithGemini,
              tooltip: 'Enhance with AI',
            ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOperatorProfile(),
                const SizedBox(height: 20),
                _buildLearningProgress(),
                const SizedBox(height: 20),
                _buildRecentNavigationActivities(),
                const SizedBox(height: 20),
                _buildEducationalResources(),
                if (_usingGemini)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Center(
                      child: Text(
                        'Enhanced with Navigation AI',
                        style: TextStyle(
                          color: _accentColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOperatorProfile() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: _primaryColor.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _accentColor,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 38,
                backgroundImage: NetworkImage(_userImage),
                child: _userImage.isEmpty ? Icon(Icons.person, size: 38) : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userTitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildStatItem(Icons.school, "Navigation Level", _infoColor),
                      _buildStatItem(Icons.map, "${(_learningProgress['KML Proficiency']?.progress.toStringAsFixed(1) ?? '0')} KML", _accentColor),
                      _buildStatItem(Icons.bolt, "Surveys", _warningColor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningProgress() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: _primaryColor.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: _primaryColor),
                const SizedBox(width: 8),
                Text(
                  "Activity Progress",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._learningProgress.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "${(entry.value.progress * 100).toInt()}%",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: entry.value.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: entry.value.progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        color: entry.value.color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentNavigationActivities() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: _primaryColor.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: _primaryColor),
                const SizedBox(width: 8),
                Text(
                  "Recent Navigation Activities",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._recentActivities.map((activity) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: activity.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(activity.icon, color: activity.color),
                  ),
                  title: Text(
                    activity.title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    activity.timeAgo,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                  onTap: () => _showActivityDetails(activity),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

 Widget _buildEducationalResources() {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    shadowColor: _primaryColor.withOpacity(0.2),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book, color: _primaryColor),
              const SizedBox(width: 8),
              Text(
                "Educational Resources",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 224, 
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _educationalContent.length,
              itemBuilder: (context, index) {
                final content = _educationalContent[index];
                return Container(
                  width: 180, 
                  margin: EdgeInsets.only(
                    right: index == _educationalContent.length - 1 ? 0 : 16,
                    left: index == 0 ? 0 : 0,
                  ),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showContentDetails(content),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: content.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.public,
                                  size: 40,
                                  color: content.color.withOpacity(0.3),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              content.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: content.color,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              content.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
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

class NavigationActivity {
  final String title;
  final String timeAgo;
  final IconData icon;
  final Color color;

  NavigationActivity(this.title, this.timeAgo, this.icon, this.color);
}

class EducationalContent {
  final String title;
  final String description;
  final String imageUrl;
  final Color color;

  EducationalContent(this.title, this.description, this.imageUrl, this.color);
}

class LearningProgress {
  final double progress;
  final Color color;

  LearningProgress(this.progress, this.color);
}