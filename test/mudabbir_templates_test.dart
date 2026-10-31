import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/presentation/templates/mudabbir_templates.dart';

void main() {
  testWidgets('shared templates build with minimal valid inputs', (tester) async {
    final sample = Container(width: 40, height: 40, color: Colors.teal);
    final templates = <Widget>[
      DashboardTemplate(header: sample, sections: [sample]),
      ReaderTemplate(reader: sample),
      ChatTemplate(messages: sample, composer: sample),
      LibraryTemplate(items: sample, searchField: sample),
      AnalyticsTemplate(summary: [sample], charts: [sample]),
      GraphTemplate(graph: sample),
      PlayerTemplate(
        artwork: sample,
        trackTitle: 'Track',
        progress: sample,
        controls: sample,
      ),
      SettingsTemplate(groups: [sample]),
      SearchTemplate(searchField: sample, results: sample),
      ProfileTemplate(header: sample, sections: [sample]),
      LabTemplate(controls: sample, output: sample),
      ServiceHubTemplate(services: [sample]),
    ];

    for (final template in templates) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: template)));
      await tester.pump();
      expect(tester.takeException(), isNull);
    }
  });
}
