import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizzy/presentation/bloc/library/library_cubit.dart';
import 'package:quizzy/presentation/screens/my_library/widgets/library_item_tile.dart';

class MyLibraryScreen extends StatefulWidget {
  const MyLibraryScreen({super.key, required this.cubit});

  final LibraryCubit cubit;

  @override
  State<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDataForTab(0);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      _loadDataForTab(_tabController.index);
    }
  }

  void _loadDataForTab(int index) {
    switch (index) {
      case 0:
        widget.cubit.loadMyCreations();
        break;
      case 1:
        widget.cubit.loadFavorites();
        break;
      case 2:
        widget.cubit.loadInProgress();
        break;
      case 3:
        widget.cubit.loadCompleted();
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi Biblioteca'),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Creaciones'),
              Tab(text: 'Favoritos'),
              Tab(text: 'En Progreso'),
              Tab(text: 'Completados'),
            ],
          ),
        ),
        body: BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(child: Text('Error: ${state.error}'));
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _buildList(state.creations, allowFavToggle: false), // Own creations usually don't need 'favorite' toggle here, or maybe yes.
                _buildList(state.favorites, allowFavToggle: true, isFavList: true),
                _buildList(state.inProgress),
                _buildList(state.completed),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List items, {bool allowFavToggle = false, bool isFavList = false}) {
    if (items.isEmpty) {
      return const Center(child: Text('No hay elementos'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return LibraryItemTile(
          item: item,
          isFavorite: isFavList, // simplistic view
          onFavoriteToggle: allowFavToggle
              ? () {
                  widget.cubit.toggleFavorite(item.id, isFavList);
                }
              : null,
          onTap: () {
            // Navigate to detail or game
          },
        );
      },
    );
  }
}
