import 'package:flutter/material.dart';
import '../models/channel.dart';
import '../services/auto_update_service.dart';
import '../services/channel_service.dart';
import '../services/favorites_service.dart';
import '../widgets/channel_card.dart';
import '../widgets/update_badge.dart';
import 'player_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.updateChecker});

  /// Fungsi pengecekan pembaruan. Default-nya memakai layanan sungguhan;
  /// parameter ini dipakai test agar alur badge bisa diuji tanpa jaringan.
  final Future<UpdateInfo?> Function()? updateChecker;

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

  /// Informasi rilis baru yang tersedia. Tidak null berarti badge
  /// "Pembaruan Tersedia" perlu ditampilkan di Home Screen.
  UpdateInfo? _availableUpdate;

  @override
  void initState() {
    super.initState();
    _loadChannels();
    _checkForAppUpdate();
  }

  /// Cek pembaruan APK versi terbaru saat aplikasi dibuka.
  ///
  /// Jika ada versi baru, badge "Pembaruan Tersedia" otomatis muncul dengan
  /// animasi dan dialog pembaruan ikut dibuka seperti sebelumnya. Badge
  /// tetap bertahan sebagai pintu masuk pembaruan setelah dialog ditutup.
  Future<void> _checkForAppUpdate() async {
    // Beri sedikit jeda agar tampilan UI home tampil terlebih dahulu
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final updateInfo =
        await (widget.updateChecker?.call() ?? AutoUpdateService.checkForUpdate());
    if (updateInfo == null || !mounted) return;

    setState(() => _availableUpdate = updateInfo);
    AutoUpdateService.showUpdateDialog(context, updateInfo);
  }

  /// Tampilkan dialog pembaruan dari badge "Pembaruan Tersedia".
  void _openUpdateDialog() {
    final info = _availableUpdate;
    if (info == null) return;
    AutoUpdateService.showUpdateDialog(context, info);
  }

  Future<void> _loadChannels() async {
    setState(() => _isLoading = true);

    final channels = ChannelService.getChannels();
    final customChannels = await _loadCustomChannels();
    final allChannels = [...channels, ...customChannels];

    final catList = ChannelService.getCategories(allChannels);
    if (!catList.contains('Favorit')) {
      catList.insert(1, 'Favorit');
    }

    setState(() {
      _allChannels = allChannels;
      _categories = catList;
      _isLoading = false;
    });

    _applyFilter();
  }

  /// Ambil channel dari playlist M3U eksternal yang tersimpan di preferensi.
  Future<List<Channel>> _loadCustomChannels() async {
    final url = await FavoritesService.getCustomM3uUrl();
    if (url == null || url.isEmpty) return <Channel>[];
    try {
      return await ChannelService.parseM3UFromUrl(url);
    } catch (e) {
      debugPrint('Gagal memuat playlist M3U: $e');
      return <Channel>[];
    }
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

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (routeContext) => SettingsScreen(
          onPlaylistLoaded: (url) {
            Navigator.pop(routeContext);
            _loadChannels();
          },
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
            icon: const Icon(Icons.settings_rounded, color: Colors.white70),
            tooltip: 'Playlist & Pengaturan',
            onPressed: _openSettings,
          ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.system_update_rounded,
                  color: _availableUpdate != null
                      ? Colors.redAccent
                      : Colors.amberAccent,
                ),
                // Titik merah penanda bahwa ada versi baru yang tersedia.
                if (_availableUpdate != null)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      key: const Key('update-appbar-dot'),
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF171A24), width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Cek Pembaruan APK',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Memeriksa pembaruan RENATA TV...'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Color(0xFF1E222A),
                ),
              );
              final info = await AutoUpdateService.checkForUpdate();
              if (!mounted) return;
              if (info != null) {
                setState(() => _availableUpdate = info);
                AutoUpdateService.showUpdateDialog(this.context, info);
              } else {
                messenger.showSnackBar(
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
            // Badge "Pembaruan Tersedia" - muncul otomatis saat versi baru
            // terdeteksi, dengan animasi slide turun + fade saat masuk.
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, -0.6),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _availableUpdate == null
                  ? const SizedBox(width: double.infinity, key: ValueKey('no-update'))
                  : UpdateBadge(
                      key: ValueKey(
                          'update-badge-${_availableUpdate!.latestVersionCode}'),
                      updateInfo: _availableUpdate!,
                      onTap: _openUpdateDialog,
                    ),
            ),

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
