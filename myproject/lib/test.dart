import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


class test extends StatefulWidget {
  @override
  _testState createState() => _testState();
}

class _testState extends State<test> {
  String choiceChipsValue = 'Réservez Ultérieurement';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          // === SliverPersistentHeader pour épingler les chips ===
          SliverPersistentHeader(
            pinned: true,
            delegate: _ChoiceChipHeaderDelegate(
              child: Container(
                height: 70,
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildChoiceChip(
                            'Ultérieurement',
                            Icons.access_time_rounded,
                          ),
                          SizedBox(width: 8),
                          _buildChoiceChip(
                            'Maintenant',
                            Icons.directions_car,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Divider après les chips
          SliverPersistentHeader(
            pinned: true,
            delegate: _ChoiceChipHeader(
            child: Container(
              height: 30,
              color: Colors.grey[200],
              child : Divider(thickness: 1, color: Colors.grey.shade300),
            )
          ),
          ),

          // Contenu scrollable exemple
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ListTile(
                  title: Text('Élément $index'),
                );
              },
              childCount: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String title, IconData icon) {
    final isSelected = choiceChipsValue == title;

    return ChoiceChip(
      label: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          SizedBox(width: 6),
          Text(title, style: TextStyle(color: Colors.white)),
        ],
      ),
      selectedColor: Color(0xFF09183F),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          choiceChipsValue = title;
        });
      },
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
      ),
      backgroundColor: Colors.grey.shade300,
    );
  }
}

// === Définition du HeaderDelegate pour SliverPersistentHeader ===
class _ChoiceChipHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _ChoiceChipHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 70; // Hauteur maximale du header

  @override
  double get minExtent => 70; // Hauteur minimale si réduit

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration =>
      FloatingHeaderSnapConfiguration();
}

// === Définition du HeaderDelegate pour SliverPersistentHeader ===
class _ChoiceChipHeader extends SliverPersistentHeaderDelegate {
  final Widget child;

  _ChoiceChipHeader({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 30; // Hauteur maximale du header

  @override
  double get minExtent => 30; // Hauteur minimale si réduit

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration =>
      FloatingHeaderSnapConfiguration();
}