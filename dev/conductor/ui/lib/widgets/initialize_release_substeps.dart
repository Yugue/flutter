// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' as io;

import 'package:conductor_core/conductor_core.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';

@override
class Checkouts {
  Checkouts({
    required this.fileSystem,
    required this.platform,
    required this.processManager,
    required this.stdio,
    required Directory parentDirectory,
    String directoryName = 'flutter_conductor_checkouts',
  }) : directory = parentDirectory.childDirectory(directoryName) {
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
  }

  final Directory directory;
  final FileSystem fileSystem;
  final Platform platform;
  final ProcessManager processManager;
  final Stdio stdio;
}

/// Displays all substeps related to the 1st step.
///
/// Uses input fields and dropdowns to capture all the parameters of the conductor start command.
class InitializeReleaseSubsteps extends StatefulWidget {
  const InitializeReleaseSubsteps({
    Key? key,
    required this.nextStep,
  }) : super(key: key);

  final VoidCallback nextStep;

  @override
  InitializeReleaseSubstepsState createState() => InitializeReleaseSubstepsState();

  static const List<String> substepTitles = <String>[
    'Candidate Branch',
    'Release Channel',
    'Framework Mirror',
    'Engine Mirror',
    'Engine Cherrypicks (if necessary)',
    'Framework Cherrypicks (if necessary)',
    'Dart Revision (if necessary)',
    'Increment',
  ];

  /// Default values of release initialization parameters.
  static const Map<String, String?> releaseDataDefault = <String, String?>{
    'Release Channel': '-',
    'Increment': '-',
  };
}

class InitializeReleaseSubstepsState extends State<InitializeReleaseSubsteps> {
  late Map<String, String?> _releaseData;
  late StartContext startContext;

  @override
  void initState() {
    super.initState();
    _releaseData = InitializeReleaseSubsteps.releaseDataDefault;

    const FileSystem fileSystem = LocalFileSystem();
    const ProcessManager processManager = LocalProcessManager();
    const Platform platform = LocalPlatform();
    final Stdio stdio = VerboseStdio(
      stdout: io.stdout,
      stderr: io.stderr,
      stdin: io.stdin,
    );
    final Checkouts checkouts = Checkouts(
      fileSystem: fileSystem,
      parentDirectory: localFlutterRoot.parent,
      platform: platform,
      processManager: processManager,
      stdio: stdio,
    );
    // final String _stateFilePath = defaultStateFilePath(platform);
    // final File _stateFile = fileSystem.file(_stateFilePath);
    // final StartContext startContext = StartContext(
    //   candidateBranch: _releaseData['Candidate Branch']!,
    //   checkouts: checkouts,
    //   dartRevision: _releaseData['Dart Revision (if necessary)'],
    //   engineCherrypickRevisions: _releaseData['Engine Cherrypicks (if necessary)']!.split(','),
    //   engineMirror: _releaseData['Engine Mirror']!,
    //   engineUpstream: EngineRepository.defaultUpstream,
    //   flutterRoot: localFlutterRoot,
    //   frameworkCherrypickRevisions: _releaseData['Framework Cherrypicks (if necessary)']!.split(','),
    //   frameworkMirror: _releaseData['Framework Mirror']!,
    //   frameworkUpstream: FrameworkRepository.defaultUpstream,
    //   incrementLetter: _releaseData['Increment']!,
    //   processManager: processManager,
    //   releaseChannel: _releaseData['Release Channel']!,
    //   stateFile: _stateFile,
    //   stdio: stdio,
    // );
  }

  /// Updates the corresponding [field] in [_releaseData] with [data].
  void setReleaseData(String field, String data) {
    setState(() {
      _releaseData = <String, String?>{
        ..._releaseData,
        field: data,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InputAsSubstep(
          index: 0,
          setReleaseData: setReleaseData,
          hintText: 'The candidate branch the release will be based on.',
        ),
        CheckboxListTileDropdown(
          index: 1,
          releaseData: _releaseData,
          setReleaseData: setReleaseData,
          options: const <String>['-', 'dev', 'beta', 'stable'],
        ),
        InputAsSubstep(
          index: 2,
          setReleaseData: setReleaseData,
          hintText: "Git remote of the Conductor user's Framework repository mirror.",
        ),
        InputAsSubstep(
          index: 3,
          setReleaseData: setReleaseData,
          hintText: "Git remote of the Conductor user's Engine repository mirror.",
        ),
        InputAsSubstep(
          index: 4,
          setReleaseData: setReleaseData,
          hintText: 'Engine cherrypick hashes to be applied. Multiple hashes delimited by a comma, no spaces.',
        ),
        InputAsSubstep(
          index: 5,
          setReleaseData: setReleaseData,
          hintText: 'Framework cherrypick hashes to be applied. Multiple hashes delimited by a comma, no spaces.',
        ),
        InputAsSubstep(
          index: 6,
          setReleaseData: setReleaseData,
          hintText: 'New Dart revision to cherrypick.',
        ),
        CheckboxListTileDropdown(
          index: 7,
          releaseData: _releaseData,
          setReleaseData: setReleaseData,
          options: const <String>['-', 'y', 'z', 'm', 'n'],
        ),
        const SizedBox(height: 20.0),
        Center(
          // TODO(Yugue): Add regex validation for each parameter input
          // before Continue button is enabled, https://github.com/flutter/flutter/issues/91925.
          child: ElevatedButton(
            key: const Key('step1continue'),
            onPressed: () async {
              await startContext.run();
              widget.nextStep();
            },
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }
}

typedef SetReleaseData = void Function(String name, String data);

/// Captures the input values and updates the corresponding field in [_releaseData].
class InputAsSubstep extends StatelessWidget {
  const InputAsSubstep({
    Key? key,
    required this.index,
    required this.setReleaseData,
    this.hintText,
  }) : super(key: key);

  final int index;
  final SetReleaseData setReleaseData;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: Key(InitializeReleaseSubsteps.substepTitles[index]),
      decoration: InputDecoration(labelText: InitializeReleaseSubsteps.substepTitles[index], hintText: hintText),
      onChanged: (String data) {
        setReleaseData(InitializeReleaseSubsteps.substepTitles[index], data);
      },
    );
  }
}

/// Captures the chosen option and updates the corresponding field in [_releaseData].
class CheckboxListTileDropdown extends StatelessWidget {
  const CheckboxListTileDropdown({
    Key? key,
    required this.index,
    required this.releaseData,
    required this.setReleaseData,
    required this.options,
  }) : super(key: key);

  final int index;
  final Map<String, String?> releaseData;
  final SetReleaseData setReleaseData;
  final List<String> options;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          InitializeReleaseSubsteps.substepTitles[index],
          style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.grey[700]),
        ),
        const SizedBox(width: 20.0),
        DropdownButton<String>(
          key: Key(InitializeReleaseSubsteps.substepTitles[index]),
          value: releaseData[InitializeReleaseSubsteps.substepTitles[index]],
          icon: const Icon(Icons.arrow_downward),
          items: options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setReleaseData(InitializeReleaseSubsteps.substepTitles[index], newValue!);
          },
        ),
      ],
    );
  }
}
