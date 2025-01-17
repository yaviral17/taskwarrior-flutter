import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:taskwarrior/model/json.dart';
import 'package:taskwarrior/widgets/taskw.dart';

import '../model/storage/storage_widget.dart';

class TaskListItem extends StatefulWidget {
  const TaskListItem(this.task,
      {this.pendingFilter = false, super.key, required this.darkmode});

  final Task task;
  final bool pendingFilter;
  final bool darkmode;

  @override
  State<TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> {
  late Modify modify;
  bool isChecked = false;

  void setStatus(String newValue, String id) {
    var storageWidget = StorageWidget.of(context);
    modify = Modify(
      getTask: storageWidget.getTask,
      mergeTask: storageWidget.mergeTask,
      uuid: id,
    );
    modify.set('status', newValue);
    saveChanges();
  }

  bool isDueWithinOneDay(DateTime dueDate) {
    DateTime now = DateTime.now();
    Duration difference = dueDate.difference(now);
    return difference.inDays <= 1 && difference.inDays >= 0;
  }

  void saveChanges() async {
    var now = DateTime.now().toUtc();
    modify.save(
      modified: () => now,
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Task Updated'),
      duration: Duration(seconds: 2),
    ));
  }

  //dynamic status_value = StatusWidgetData.value;

  @override
  Widget build(BuildContext context) {
    MaterialColor colours = Colors.grey;
    var colour = widget.darkmode ? Colors.white : Colors.black;
    var dimColor = widget.darkmode
        ? const Color.fromARGB(137, 248, 248, 248)
        : const Color.fromARGB(136, 17, 17, 17);

    if (widget.task.priority == 'H') {
      colours = Colors.red;
    } else if (widget.task.priority == 'M') {
      colours = Colors.yellow;
    } else if (widget.task.priority == 'L') {
      colours = Colors.green;
    }

    if ((widget.task.status[0].toUpperCase()) == 'P') {
      // to differentiate between pending and completed tasks
      // pending tasks will be having the check boxes, on the other hand completed one's doesn't
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: (widget.task.due != null &&
                isDueWithinOneDay(widget.task.due!))
                ? Colors.red // Set border color to red if due within 1 day
                : dimColor, // Set default border color
          ),
          borderRadius: BorderRadius.circular(
              8.0), // You can adjust the border radius as needed
        ),
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colours,
                    radius: 8,
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.70,
                    child: Text(
                      '${(widget.task.id == 0) ? '#' : widget.task.id}. ${widget
                          .task.description}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: colour,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                (widget.task.annotations != null)
                    ? ' [${widget.task.annotations!.length}]'
                    : '',
                style: GoogleFonts.poppins(
                  color: colour,
                ),
              ),
            ],
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    '${widget.pendingFilter ? '' : '${widget.task.status[0]
                        .toUpperCase()}\n'}'
                        'Last Modified: ${(widget.task.modified != null) ? age(
                        widget.task.modified!) : ((widget.task.start != null)
                        ? age(widget.task.start!)
                        : '-')} | '
                        'Due: ${(widget.task.due != null) ? when(
                        widget.task.due!) : '-'}'
                        .replaceFirst(RegExp(r' \[\]$'), '')
                        .replaceAll(RegExp(r' +'), ' '),
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: dimColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Text(
                formatUrgency(urgency(widget.task)),
                style: GoogleFonts.poppins(
                  color: colour,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Completed tasks
      return ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colours,
                  radius: 8,
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.65,
                  child: Text(
                    '${(widget.task.id == 0) ? '#' : widget.task.id}. ${widget
                        .task.description}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: colour,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  'Last Modified: ${(widget.task.modified != null) ? age(
                      widget.task.modified!) : ((widget.task.start != null)
                      ? age(widget.task.start!)
                      : '-')} | '
                      'Due: ${(widget.task.due != null)
                      ? when(widget.task.due!)
                      : '-'}'
                      .replaceFirst(RegExp(r' \[\]$'), '')
                      .replaceAll(RegExp(r' +'), ' '),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: dimColor,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Text(
              formatUrgency(urgency(widget.task)),
              style: GoogleFonts.poppins(
                color: colour,
              ),
            ),
          ],
        ),
      );

    }
  }
}