import 'package:flutter/material.dart';

class LeadListWidget extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final List<LeadAction> actions;
  final IconData? icon;
  final Color? color;
  final Function(Map<String, dynamic>)? onTap;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;

  const LeadListWidget({
    super.key,
    required this.items,
    required this.actions,
    this.icon,
    this.color,
    this.onTap,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.onLoadMore,
  });

  @override
  State<LeadListWidget> createState() => _LeadListWidgetState();
}

class _LeadListWidgetState extends State<LeadListWidget> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 0),
      itemCount: widget.hasMore ? widget.items.length + 1 : widget.items.length,
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(

              child: widget.isLoadingMore
                  ? const SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      // Disable the button if loading (onPressed: null)
                      onPressed: widget.isLoadingMore
                          ? null
                          : widget.onLoadMore,
                      child: const Text("Load More Leads"),
                    ),
            ),
          );
        }

        final item = widget.items[index];
        final isExpanded = expandedIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          // margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            color: Colors.blue.shade50,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  expandedIndex = isExpanded ? null : index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "by Marketing, ${item['marketingDate'] ?? 'N/A'}",
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ],
                        ),
                        if (widget.icon != null)
                          IconButton(
                            icon:
                                (item['status'] == 'Completed' ||
                                    item['status'] == 'booked' ||
                                    item['status'] == 'not_interested' ||
                                       item['status'] == 'BOOKING_IN_PROGRESS' || 
                                    item['status'] == 'lost')
                                ? const Icon(Icons.lock, color: Colors.grey)
                                : Icon(
                                    widget.icon,
                                  ), // Shows Phone or Check icon
                            onPressed: () {
                              // Check if status is closed before triggering the widget's internal onTap
                              if (item['status'] == 'completed' ||
                                  item['status'] == 'not_interested') {
                                return; // Do nothing if locked
                              }
                              widget.onTap!(item);
                            },
                          ),
                      ],
                    ),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: const SizedBox(),
                      secondChild: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: widget.actions.map((action) {
                            return GestureDetector(
                              onTap: () => action.onTap(item),
                              child: Container(
                                margin: EdgeInsets.all(1),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        action.icon,
                                        size: 22,
                                        color: action.color,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    if (action.lable != null)
                                      Text(action.lable.toString()),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Simple class to define an action
class LeadAction {
  final String? lable;
  final IconData icon;
  final Color color;
  final Function(Map<String, dynamic>) onTap;

  LeadAction({
    required this.icon,
    required this.color,
    required this.onTap,
    this.lable,
  });
}
