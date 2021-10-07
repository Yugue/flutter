// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:conductor_core/conductor_core.dart';
import 'package:conductor_core/proto.dart' as pb;
import 'package:flutter/material.dart';

/// Display the current conductor state
class ConductorStatus extends StatefulWidget {
  const ConductorStatus({
    Key? key,
    this.releaseState,
    required this.stateFilePath,
  }) : super(key: key);

  final pb.ConductorState? releaseState;
  final String stateFilePath;

  @override
  ConductorStatusState createState() => ConductorStatusState();
}

class ConductorStatusState extends State<ConductorStatus> {
  @override
  Widget build(BuildContext context) {
    final Map<String, Object> currentStatus = presentStateDesktop(widget.releaseState!);
    final List<Map<String, Object>> engineCherrypicks =
        currentStatus['engineCherrypicks']! as List<Map<String, Object>>;

    print(presentStateDesktop(widget.releaseState!));
    return Column(
      children: <Widget>[
        if (widget.releaseState != null) ...<Widget>[
          Column(
            children: <Widget>[
              Table(
                children: <TableRow>[
                  TableRow(
                    children: <Widget>[
                      const Text('Conductor version'),
                      SelectableText(currentStatus['conductorVersion']! as String),
                    ],
                  ),
                  TableRow(
                    children: <Widget>[
                      const Text('Release channel'),
                      SelectableText(currentStatus['releaseChannel']! as String),
                    ],
                  ),
                  TableRow(
                    children: <Widget>[
                      const Text('Release version'),
                      SelectableText(currentStatus['releaseVersion']! as String),
                    ],
                  ),
                  TableRow(
                    children: <Widget>[
                      const Text('Release started at'),
                      SelectableText(currentStatus['startedAt']! as String),
                    ],
                  ),
                  TableRow(
                    children: <Widget>[
                      const Text('Release updated at'),
                      SelectableText(currentStatus['updatedAt']! as String),
                    ],
                  ),
                ],
              ),
              DataTable(
                columns: const <DataColumn>[
                  DataColumn(label: Text('Engine Cherrypicks')),
                  DataColumn(label: Text('Status')),
                ],
                rows: engineCherrypicks.map((Map<String, Object> engineCherrypick) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(
                        Text(engineCherrypick['trunkRevision']! as String),
                      ),
                      DataCell(
                        Text(engineCherrypick['state']! as String),
                      ),
                    ],
                  );
                }).toList(),
              )
            ],
          )
        ] else ...<Widget>[
          SelectableText('No persistent state file found at ${widget.stateFilePath}'),
        ],
        const SizedBox(height: 40.0),
        SelectableText(presentState(widget.releaseState!)),
      ],
    );
  }
}
