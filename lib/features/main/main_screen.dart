import 'package:flutter/material.dart';

import '../../core/property_store.dart';
import '../../models/owner_profile.dart';
import '../home/presentation/home_screen.dart';
import '../landlord/presentation/add_edit_property_screen.dart';
import '../profile/presentation/edit_profile_screen.dart';
import '../profile/presentation/profile_screen.dart';
import '../saved/presentation/saved_screen.dart';

const _shellOrange = Color(0xFFF57C00);

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<OwnerProfile?>(
      valueListenable: PropertyStore.instance.ownerProfileListenable,
      builder: (context, ownerProfile, __) {
        final needsProfileCompletion = ownerProfile?.isComplete != true;

        return Scaffold(
          body: _bodyForCurrentIndex(
            needsProfileCompletion: needsProfileCompletion,
          ),
          bottomNavigationBar: currentIndex == 0
              ? null
              : _ShellBottomNavigationBar(
                  currentIndex: currentIndex,
                  onTabChanged: _onTabChanged,
                  needsProfileCompletion: needsProfileCompletion,
                ),
        );
      },
    );
  }

  Widget _bodyForCurrentIndex({required bool needsProfileCompletion}) {
    switch (currentIndex) {
      case 0:
        return HomeScreen(
          currentIndex: currentIndex,
          onTabChanged: _onTabChanged,
          onAddPropertyTap: _openAddPropertyScreen,
          needsProfileCompletion: needsProfileCompletion,
        );
      case 2:
        return const SavedScreen();
      case 3:
        return const ProfileScreen();
      default:
        return HomeScreen(
          currentIndex: 0,
          onTabChanged: _onTabChanged,
          onAddPropertyTap: _openAddPropertyScreen,
          needsProfileCompletion: needsProfileCompletion,
        );
    }
  }

  void _onTabChanged(int index) {
    if (index == 1) {
      _openAddPropertyScreen();
      return;
    }
    setState(() => currentIndex = index);
  }

  Future<void> _openAddPropertyScreen() async {
    final profile = PropertyStore.instance.activeOwnerProfile;
    if (profile == null || !profile.isComplete) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete and save your profile before uploading properties.',
          ),
        ),
      );

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => EditProfileScreen(initialProfile: profile),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AddEditPropertyScreen()),
    );
  }
}

class _ShellBottomNavigationBar extends StatelessWidget {
  const _ShellBottomNavigationBar({
    required this.currentIndex,
    required this.onTabChanged,
    required this.needsProfileCompletion,
  });

  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final bool needsProfileCompletion;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFFFDFBD), width: 1)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: Colors.white,
        currentIndex: currentIndex,
        onTap: onTabChanged,
        selectedItemColor: _shellOrange,
        unselectedItemColor: const Color(0xFF7E7E7E),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _AddEntryIcon(
              active: false,
              needsProfileCompletion: needsProfileCompletion,
            ),
            activeIcon: _AddEntryIcon(
              active: true,
              needsProfileCompletion: needsProfileCompletion,
            ),
            label: 'Add',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Saved',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _AddEntryIcon extends StatelessWidget {
  const _AddEntryIcon({
    required this.active,
    required this.needsProfileCompletion,
  });

  final bool active;
  final bool needsProfileCompletion;

  @override
  Widget build(BuildContext context) {
    final icon = active
        ? Icons.add_circle_rounded
        : Icons.add_circle_outline_rounded;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (needsProfileCompletion)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              height: 16,
              width: 16,
              decoration: BoxDecoration(
                color: _shellOrange,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: const Text(
                '!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
