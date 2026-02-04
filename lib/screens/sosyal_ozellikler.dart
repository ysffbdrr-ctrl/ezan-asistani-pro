import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezan_asistani/services/gamification_service.dart' as gamification_service;

class SosyalOzellikler extends StatefulWidget {
  const SosyalOzellikler({super.key});

  @override
  State<SosyalOzellikler> createState() => _SosyalOzelliklerState();
}

class _SosyalOzelliklerState extends State<SosyalOzellikler> {
  String _userId = '';
  String _userName = 'Misafir';
  int _points = 0;
  int _level = 1;
  Set<String> _followedUserIds = <String>{};
  bool _loading = true;

  final List<Map<String, String>> _suggestedUsers = const [
    {'id': 'u_ahmet', 'name': 'Ahmet'},
    {'id': 'u_fatma', 'name': 'Fatma'},
    {'id': 'u_mehmet', 'name': 'Mehmet'},
    {'id': 'u_ayse', 'name': 'Ayşe'},
    {'id': 'u_omer', 'name': 'Ömer'},
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final existingId = prefs.getString('user_id');
    final userId = existingId ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString('user_id', userId);

    final userName = prefs.getString('kullanici_adi') ?? 'Misafir';
    final followed = prefs.getStringList('followed_user_ids') ?? <String>[];

    final points = await gamification_service.GamificationService.getTotalPoints();
    final level = await gamification_service.GamificationService.getLevel();

    if (!mounted) return;
    setState(() {
      _userId = userId;
      _userName = userName;
      _followedUserIds = followed.toSet();
      _points = points;
      _level = level;
      _loading = false;
    });
  }

  Future<void> _persistFollowed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('followed_user_ids', _followedUserIds.toList());
  }

  Future<void> _toggleFollow(String otherUserId) async {
    setState(() {
      if (_followedUserIds.contains(otherUserId)) {
        _followedUserIds.remove(otherUserId);
      } else {
        _followedUserIds.add(otherUserId);
      }
    });
    await _persistFollowed();
  }

  Future<void> _editUserName() async {
    final controller = TextEditingController(text: _userName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kullanıcı Adı'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Ad',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryYellow, foregroundColor: Colors.black),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kullanici_adi', result);
    if (!mounted) return;
    setState(() {
      _userName = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sosyal Özellikler'),
        backgroundColor: AppTheme.primaryYellow,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryYellow),
            )
          : RefreshIndicator(
              onRefresh: _init,
              color: AppTheme.primaryYellow,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppTheme.primaryYellow,
                                foregroundColor: Colors.black,
                                child: Text(_userName.isEmpty ? 'M' : _userName.characters.first.toUpperCase()),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _userName,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'ID: $_userId',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: _editUserName,
                                icon: const Icon(Icons.edit),
                                tooltip: 'Düzenle',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _statTile('Seviye', '$_level'),
                              ),
                              Expanded(
                                child: _statTile('Puan', '$_points'),
                              ),
                              Expanded(
                                child: _statTile('Takip', '${_followedUserIds.length}'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Önerilen Kişiler',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._suggestedUsers.map((u) {
                    final id = u['id']!;
                    final name = u['name']!;
                    final isFollowing = _followedUserIds.contains(id);
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.lightYellow,
                          foregroundColor: Colors.black,
                          child: Text(name.characters.first.toUpperCase()),
                        ),
                        title: Text(name),
                        subtitle: Text(isFollowing ? 'Takip ediliyor' : 'Takip et'),
                        trailing: ElevatedButton(
                          onPressed: () => _toggleFollow(id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing ? Colors.grey[300] : AppTheme.primaryYellow,
                            foregroundColor: Colors.black,
                          ),
                          child: Text(isFollowing ? 'Bırak' : 'Takip Et'),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _statTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
