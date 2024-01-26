import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

//this Class is used to implement the dragbehaviour on dashboard widgets and ticket widgets.
// since we need a box around the oherwiese we can't see them
class ListSlidAble extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final void Function(BuildContext)? onEdit;
  final void Function(BuildContext)? onDelete;
  const ListSlidAble(
      {super.key, required this.child, this.onEdit, this.onDelete, this.margin});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            if (onEdit != null)
              SlidableAction(
                onPressed: onEdit!,
                backgroundColor: const Color(0xE51E1E1E),
                foregroundColor: Colors.blue,
                icon: Icons.edit,
                label: 'Edit',
                borderRadius: onDelete != null
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(34.4),
                        bottomLeft: Radius.circular(34.4),
                      )
                    : BorderRadius.circular(34.4),
              ),
            if (onDelete != null)
              SlidableAction(
                onPressed: onDelete!,
                backgroundColor: const Color(0xE51E1E1E),
                foregroundColor: Colors.red,
                borderRadius: onEdit != null
                    ? const BorderRadius.only(
                        topRight: Radius.circular(34.4),
                        bottomRight: Radius.circular(34.4),
                      )
                    : BorderRadius.circular(34.4),
                icon: Icons.delete,
                label: 'Delete',
              ),
            if (onEdit == null && onDelete == null)
              SlidableAction(
                onPressed: (_) {},
                backgroundColor: const Color(0xE51E1E1E),
                foregroundColor: Colors.white,
                borderRadius: BorderRadius.circular(34.4),
                icon: Icons.lock,
              )
          ],
        ),
        child: child,
      ),
    );
  }
}
