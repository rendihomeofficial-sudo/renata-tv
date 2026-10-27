import 'package:flutter/material.dart';
import '../models/channel.dart';
import '../services/auto_update_service.dart';
import '../services/channel_service.dart';
import '../services/favorites_service.dart';
import '../theme/app_theme.dart';
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

  /// Kode versi pembaruan yang dialognya sudah pernah ditolak pengguna.
  Set<int> _dismissedUpdateCodes = <int>{};

  @override
  void initState() {
    super.initState();
    _loadDismissedUpdates();
    _loadChannels();
    _checkForAppUpdate();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Muat daftar versi pembaruan yang dialognya sudah ditolak.
  Future<void> _loadDismissedUpdates() async {
    final codes = await AutoUpdateService.loadDismissedUpdateCodes();
    if (!mounted) return;
    setState(() => _dismissedUpdateCodes = codes);
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

    // Kalau pengguna sudah menolak dialog ini sebelumnya, badge tetap
    // ditampilkan tapi dialog tidak dibuka otomatis lagi.
    if (_dismissedUpdateCodes.contains(updateInfo.latestVersionCode)) return;

    AutoUpdateService.showUpdateDialog(context, updateInfo);
  }

  /// Tampilkan dialog pembaruan dari badge "Pembaruan Tersedia".
  void _openUpdateDialog() {
    final info = _availableUpdate;
    if (info == null) return;
    AutoUpdateService.showUpdateDialog(context, info);
  }

  Future<void> _loadChannels() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final channels = ChannelService.getChannels();
    final customChannels = await _loadCustomChannels();
    final allChannels = [...channels, ...customChannels];

    final catList = ChannelService.getCategories(allChannels);
    if (!catList.contains('Favorit')) {
      catList.insert(1, 'Favorit');
    }

    if (!mounted) return;
    setState(() {
      _allChannels = allChannels;
      _categories = catList;
      _isLoading = false;
    });

    await _applyFilter();
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

    if (!mounted) return;
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

  /// Jumlah kolom grid channel menyesuaikan lebar layar yang tersedia.
  /// HP hasilnya 2-3 kolom, tablet 4, dan TV/LAYAR besar 5-6 kolom.
  int _crossAxisCountFor(double width) {
    if (width >= 1200) return 6;
    if (width >= 900) return 5;
    if (width >= 600) return 4;
    if (width >= 420) return 3;
    return 2;
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
          onPlaylistRemoved: () {
            Navigator.pop(routeContext);
            _loadChannels();
          },
        ),
      ),
    );
  }

  /// Panel hero di bagian atas Home Screen.
  ///
  /// Berisi headline singkat, lencana mutu, dan angka ringkas supaya
  /// pengguna langsung tahu posisi aplikasi sebelum menggulir daftar.
  Widget _buildHeroPanel() {
    final total = _allChannels.length;
    final categoryCount =
        (_categories.where((c) => c != 'Semua' && c != 'Favorit')).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: AppShadows.soft(opacity: 0.4, blur: 22, offsetY: 8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: const Text(
                  'PREMIUM',
                  style: TextStyle(
                    color: Color(0xFF3A2A05),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Tanpa buffering',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Siaran TV Indonesia,\nsatu ketukan dari rumah.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              height: 1.25,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildHeroMetric(
                value: '$total',
                label: 'Kanal live',
                icon: Icons.live_tv_rounded,
              ),
              const SizedBox(width: 10),
              _buildHeroMetric(
                value: '$categoryCount',
                label: 'Kategori',
                icon: Icons.category_rounded,
              ),
              const SizedBox(width: 10),
              _buildHeroMetric(
                value: '${_filteredChannels.length}',
                label: 'Ditampilkan',
                icon: Icons.filter_alt_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Angka ringkas kecil di dalam panel hero.
  Widget _buildHeroMetric({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: AppColors.primaryLight),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            // Logo Icon RENATA TV
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: AppColors.brandGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primary,
                    child: const Icon(Icons.live_tv, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Expanded supaya judul tetap muat di HP sempit. Tanpa itu,
            // teks subtitle membuat baris AppBar meluber ke luar layar.
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'RENATA TV',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    'Live Streaming Siaran TV Indonesia',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.textSecondary),
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
                      ? AppColors.primaryLight
                      : AppColors.textSecondary,
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
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 1.5),
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
              final info = await AutoUpdateService.checkForUpdate(force: true);
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

            // Panel hero: posisi aplikasi, lencana mutu, dan ringkasan data.
            _buildHeroPanel(),

            // Kotak Pencarian Channel
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.soft(opacity: 0.3, blur: 16, offsetY: 4),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Cari siaran (Trans TV, Metro, Net TV, dsb)...',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                              _applyFilter();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                    _applyFilter();
                  },
                ),
              ),
            ),

            // Horizontal Tab Kategori
            SizedBox(
              height: 38,
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
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.border,
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
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : _filteredChannels.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _selectedCategory == 'Favorit'
                                    ? Icons.favorite_border_rounded
                                    : Icons.live_tv_rounded,
                                size: 54,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _selectedCategory == 'Favorit'
                                    ? 'Belum ada channel favorit'
                                    : 'Channel tidak ditemukan',
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 14),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Coba kategori lain atau gunakan kolom pencarian.',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount =
                                _crossAxisCountFor(constraints.maxWidth);
                            const gridPadding = 16.0;
                            const gridSpacing = 14.0;
                            // Lebar tiap tile dihitung manual supaya rasio
                            // kartu bisa disesuaikan dengan lebar tile itu.
                            final tileWidth =
                                (constraints.maxWidth -
                                        gridPadding * 2 -
                                        gridSpacing * (crossAxisCount - 1)) /
                                    crossAxisCount;
                            return GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio:
                                    ChannelCard.aspectRatioFor(tileWidth),
                                crossAxisSpacing: gridSpacing,
                                mainAxisSpacing: gridSpacing,
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
