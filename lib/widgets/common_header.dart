import 'package:flutter/material.dart';

class CommonHeader extends StatefulWidget {
  final String title;
  final TextEditingController searchController;
  final VoidCallback onFilterTap;
  final bool showClearButton;
  final VoidCallback onClearTap;
  final Function(String) onSearchChanged;
  final Color themeColor;

  const CommonHeader({
    super.key,
    required this.title,
    required this.searchController,
    required this.onFilterTap,
    required this.onClearTap,
    required this.showClearButton,
    required this.onSearchChanged,
    this.themeColor = Colors.green, 
  });

  @override
  State<CommonHeader> createState() => _CommonHeaderState();
}

class _CommonHeaderState extends State<CommonHeader> {
  bool isSearch = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Dynamic Title
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showClearButton)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _topIcon(
                        Icons.clear_all_outlined,
                        onTap: widget.onClearTap,
                      ),
                    ),

                  _topIcon(
                    isSearch ? Icons.close : Icons.search,
                    onTap: () {
                      setState(() {
                        isSearch = !isSearch;
                        if (!isSearch) {
                          widget.searchController.clear();
                          widget.onSearchChanged(
                            "",
                          ); // Reset search query in parent
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  _topIcon(
                    Icons.filter_alt_outlined,
                    onTap: widget.onFilterTap,
                  ),
                ],
              ),
            ],
          ),
        ),

        // 3. Conditional Search Bar
        if (isSearch)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: TextFormField(
              controller: widget.searchController,
              onChanged: widget.onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search ${widget.title.toLowerCase()}...",
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                prefixIcon: Icon(
                  Icons.search,
                  color: widget.themeColor,
                  size: 22,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.themeColor, width: 1.5),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Private Helper for Header Icons
  Widget _topIcon(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
