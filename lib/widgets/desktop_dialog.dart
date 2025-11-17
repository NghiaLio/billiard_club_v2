import 'package:flutter/material.dart';

/// A dialog wrapper optimized for desktop/macOS layout
/// with appropriate width constraints and better content spacing
class DesktopDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final double? maxWidth;
  final double? maxHeight;

  const DesktopDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
    this.maxWidth = 600,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? 600,
          maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: content,
              ),
            ),
            // Actions
            if (actions != null && actions!.isNotEmpty) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (int i = 0; i < actions!.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      actions![i],
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Builds a two-column form layout for desktop
class DesktopFormLayout extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final int columns;

  const DesktopFormLayout({
    super.key,
    required this.children,
    this.spacing = 16,
    this.columns = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    // For single column or mobile, stack vertically
    if (columns == 1 || MediaQuery.of(context).size.width < 600) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: spacing),
            children[i],
          ],
        ],
      );
    }

    // Two-column layout for desktop
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += columns) {
      final rowChildren = <Widget>[];
      for (int j = 0; j < columns && i + j < children.length; j++) {
        if (j > 0) rowChildren.add(SizedBox(width: spacing));
        rowChildren.add(Expanded(child: children[i + j]));
      }

      // Fill remaining space if odd number of children
      if (rowChildren.length < columns * 2 - 1) {
        rowChildren.add(SizedBox(width: spacing));
        rowChildren.add(const Expanded(child: SizedBox.shrink()));
      }

      if (i > 0) rows.add(SizedBox(height: spacing));
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowChildren,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}
