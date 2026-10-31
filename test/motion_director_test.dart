import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mudabbir_al_asrar/services/motion_director.dart';

void main() {
  final scenes = <QuranicScene>[
    const QuranicScene(
      id: 'stars',
      title: 'مشهد النجوم',
      arabicText: 'فلا أقسم بمواقع النجوم',
      reference: 'الواقعة: 75',
      tags: ['cosmic', 'stars', 'night'],
      importance: 1.8,
      template: TopicTemplate.cosmic,
    ),
    const QuranicScene(
      id: 'sun',
      title: 'مشهد الشمس',
      arabicText: 'والشمس تجري لمستقر لها',
      reference: 'يس: 38',
      tags: ['cosmic', 'sun', 'day'],
      importance: 1.5,
      template: TopicTemplate.cosmic,
    ),
    const QuranicScene(
      id: 'garden',
      title: 'مشهد النبات',
      arabicText: 'والله أنبتكم من الأرض نباتا',
      reference: 'نوح: 17',
      tags: ['nature', 'earth'],
      template: TopicTemplate.nature,
    ),
  ];

  test('director chooses relevant scenes and avoids repeats in a cycle', () {
    final director = MotionDirector(
      allScenes: scenes,
      random: Random(7),
    );

    final playlist = director.generatePlaylist(
      context: const MotionContext(
        theme: 'stars',
        hour: 22,
        maxScenes: 3,
      ),
    );

    expect(playlist, hasLength(3));
    expect(playlist.first.scene.id, 'stars');
    expect(playlist.map((item) => item.scene.id).toSet(), hasLength(3));
    expect(director.nextScene(), isNull);

    director.resetCycle();
    expect(director.shownSceneIds, isEmpty);
    expect(director.nextScene(), isNotNull);
  });

  test('duration is word-aware and bounded', () {
    final director = MotionDirector(allScenes: scenes);
    final short = director.calculateDuration(scenes[0]);
    final long = director.calculateDuration(
      QuranicScene(
        id: 'long',
        title: 'long',
        arabicText: List.filled(100, 'كلمة').join(' '),
        reference: 'test',
        tags: const [],
        baseDuration: 4,
      ),
    );

    expect(short.inSeconds, greaterThanOrEqualTo(4));
    expect(long.inSeconds, 18);
  });

  test('template chooses a suitable transition', () {
    final director = MotionDirector(allScenes: scenes, random: Random(1));
    final plan = director.nextScene(
      context: const MotionContext(theme: 'stars', hour: 23),
    );

    expect(plan?.transition, MotionTransition.orbit);
  });

  test('low battery reduces the particle budget', () {
    final director = MotionDirector(allScenes: scenes);
    expect(
      director.particleBudget(
        context: const MotionContext(batteryFraction: 0.15),
      ),
      0.25,
    );
    expect(
      director.particleBudget(
        context: const MotionContext(motionIntensity: 0),
      ),
      lessThan(1),
    );
  });
}
