import 'package:flutter/material.dart';
import '../models/channel.dart';
import '../services/auto_update_service.dart';
import '../services/channel_service.dart';
import '../services/favorites_service.dart';
import '../widgets/channel_card.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Channel> _allChannels = [];
  List<Channel> _filteredChannels = [];
  List<String> _categories = ['Semua', 'Favorit'];
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChannels();
    _checkForAppUpdate();
  }

  /// Cek pembaruan APK versi terbaru saat aplikasi dibuka
  Future<void> _checkForAppUpdate() async {
    // Beri sedikit jeda agar tampilan UI home tampil terlebih dahulu
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final updateInfo = await AutoUpdateService.checkForUpdate();
    if (updateInfo != null && mounted) {
      AutoUpdateService.showUpdateDialog(context, updateInfo);
    }
  }

  Future<void> _loadChannels() async {
    setState(() => _isLoading = true);

    final channels = ChannelService.getChannels();
    final catList = ChannelService.getCategories(channels);
    if (!catList.contains('Favorit')) {
      catList.insert(1, 'Favorit');
    }

    setState(() {
      _allChannels = channels;
      _categories = catList;
      _isLoading = false;
    });

    _applyFilter();
  }

  Future<void> _applyFilter() async {
    List<Channel> list = List.from(_allChannels);

    // Filter kategori
    if (_selectedCategory == 'Favorit') {
      final favIds = await FavoritesService.getFavoriteIds();
      list = list.where((ch) => favIds.contains(ch.id)).toList();
    } else if (_selectedCategory != 'Semua') {
      list = list.where((ch) => ch.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }

    // Filter pencarian
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((ch) =>
              ch.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              ch.category.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredChannels = list;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilter();
  }

  void _openPlayer(Channel channel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(
          channel: channel,
          allChannels: _allChannels,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10131A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171A24),
        elevation: 0,
        title: Row(
          children: [
            // Logo Icon RENATA TV
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.redAccent,
                    child: const Icon(Icons.live_tv, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RENATA TV',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    fontSize: 17,
                  ),
                ),
                Text(
                  'Live Streaming Siaran TV Indonesia',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.system_update_rounded, color: Colors.amberAccent),
            tooltip: 'Cek Pembaruan APK',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Memeriksa pembaruan RENATA TV...'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Color(0xFF1E222A),
                ),
              );
              final info = await AutoUpdateService.checkForUpdate();
              if (info != null && mounted) {
                AutoUpdateService.showUpdateDialog(context, info);
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Aplikasi Anda sudah versi terbaru!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.redAccent,
        backgroundColor: const Color(0xFF1E222A),
        onRefresh: _loadChannels,
        child: Column(
          children: [
            // Kotak Pencarian Channel
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cari siaran (Trans TV, Metro, Net TV, dsb)...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.white38),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            _applyFilter();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF1B1E28),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                  _applyFilter();
                },
              ),
            ),

            // Horizontal Tab Kategori
            SizedBox(
              height: 42,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: Colors.redAccent,
                      backgroundColor: const Color(0xFF1B1E28),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: isSelected ? Colors.redAccent : Colors.white12,
                        ),
                      ),
                      onSelected: (_) => _onCategorySelected(cat),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Grid Daftar Channel TV
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.redAccent),
                    )
                  : _filteredChannels.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedCategory == 'Favorit'
                                    ? Icons.favorite_border
                                    : Icons.tv_off,
                                size: 52,
                                color: Colors.white24,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _selectedCategory == 'Favorit'
                                    ? 'Belum ada channel favorit'
                                    : 'Channel tidak ditemukan',
                                style: const TextStyle(color: Colors.white60, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.15,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _filteredChannels.length,
                          itemBuilder: (context, index) {
                            final channel = _filteredChannels[index];
                            return ChannelCard(
                              channel: channel,
                              onTap: () => _openPlayer(channel),
                              onFavoriteChanged: () {
                                if (_selectedCategory == 'Favorit') {
                                  _applyFilter();
                                }
                              },
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
