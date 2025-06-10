import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../screens/usage_detail_screen.dart';

class HoverBox extends StatefulWidget {
  final String title;
  final String detail;

  const HoverBox({required this.title, required this.detail});

  @override
  _HoverBoxState createState() => _HoverBoxState();
}

class _HoverBoxState extends State<HoverBox> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UsageDetailPage(
                title: widget.title,
                detail: widget.detail,
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: _hovering ? Colors.red[50] : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: Offset(0, 3),
              )
            ],
          ),
          child: Row(
            children: [
              Icon(CupertinoIcons.arrow_right_circle_fill,
                  color: Colors.red[300], size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RMindBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const RMindBottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<RMindBottomNavBar> createState() => _RMindBottomNavBarState();
}

class _RMindBottomNavBarState extends State<RMindBottomNavBar> {
  int? hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.selectedIndex,
      onTap: widget.onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey[500],
      items: List.generate(3, (index) {
        final isHovered = hoveredIndex == index;
        final color = isHovered ? Colors.red : null;

        IconData icon;
        String label;

        switch (index) {
          case 0:
            icon = Icons.home;
            label = "Home";
            break;
          case 1:
            icon = Icons.list_alt;
            label = "List";
            break;
          case 2:
            icon = Icons.settings;
            label = "Settings";
            break;
          default:
            icon = Icons.circle;
            label = "";
        }

        return BottomNavigationBarItem(
          icon: MouseRegion(
            onEnter: (_) => setState(() => hoveredIndex = index),
            onExit: (_) => setState(() => hoveredIndex = null),
            child: Icon(icon, color: color),
          ),
          label: label,
        );
      }),
    );
  }
}
