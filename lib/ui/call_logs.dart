import 'package:call_log/call_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:whatspp_direct/Providers/phone_provider.dart';
import 'package:whatspp_direct/Providers/state_provider.dart';
import 'package:whatspp_direct/utils/extensions.dart';
import 'package:workmanager/workmanager.dart';

import '../Providers/name_provider.dart';

class CallLogs extends StatefulWidget {
  const CallLogs({Key? key}) : super(key: key);

  @override
  _CallLogsState createState() => _CallLogsState();
}

class _CallLogsState extends State<CallLogs> {
  bool isLoading = false;
  Iterable<CallLogEntry> _callLogEntries = <CallLogEntry>[];

  @override
  void initState() {
    super.initState();
    loadCallLogs();
  }

  Future<void> loadCallLogs() async {
    setState(() {
      isLoading = true;
    });
    await Workmanager()
        .registerOneOffTask(
      DateTime.now().millisecondsSinceEpoch.toString(),
      'simpleTask',
      existingWorkPolicy: ExistingWorkPolicy.replace,
    )
        .then((value) async {
      final Iterable<CallLogEntry> result = await CallLog.query(
          dateTimeTo: DateTime.now(),
          dateTimeFrom: (DateTime.now().subtract(const Duration(days: 7))));
      setState(() {
        _callLogEntries = result;
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _callLogEntries.length,
                itemBuilder: (context, index) {
                  final entry = _callLogEntries.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.only(top: 7.0),
                    child: InkWell(
                      onTap: () {
                        print('uuu${entry.number}');
                        context.read<PhoneProvider>().phone = entry.number!;
                        if (entry.name != null) {
                          context.read<NameProvider>().name = entry.name!;
                        } else {
                          context.read<NameProvider>().name = "";
                        }
                        context.read<StateProvider>().navigateToDirectMessage();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (entry.callType
                                  .toString()
                                  .split(".")
                                  .last
                                  .toLowerCase() ==
                              "outgoing")
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Icon(
                                Icons.call_made,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ),
                          if (entry.callType
                                  .toString()
                                  .split(".")
                                  .last
                                  .toLowerCase() ==
                              "incoming")
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Icon(Icons.call_received,
                                  size: 18, color: Colors.grey),
                            ),
                          if (entry.callType
                                  .toString()
                                  .split(".")
                                  .last
                                  .toLowerCase() ==
                              "missed")
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Icon(Icons.call_missed_outgoing,
                                  size: 18, color: Colors.grey),
                            ),
                          if (entry.callType
                                  .toString()
                                  .split(".")
                                  .last
                                  .toLowerCase() ==
                              "rejected")
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Icon(Icons.block_flipped,
                                  size: 16, color: Colors.grey),
                            ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                      entry.name != null
                                          ? '${entry.name}'
                                          : '${entry.number}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          letterSpacing: 0.5)),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3.0),
                                    child: Text('${entry.cachedMatchedNumber}',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color:
                                                Colors.grey.withOpacity(0.5))),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                              DateFormat('hh:mm a dd/MM/yyyy').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    entry.timestamp!),
                              ),
                              style: TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 12,
                                  color: Colors.grey.withOpacity(0.5))),
                          IgnorePointer(
                            child: IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  CupertinoIcons.chevron_right,
                                  size: 16,
                                )),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
