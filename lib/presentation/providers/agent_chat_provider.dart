import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../domain/entities/agent_task.dart';
import '../../services/agent_registry.dart';
import '../../services/ollama_service.dart';
import '../../services/quran_loader_service.dart';
import '../../services/quranic_search_engine.dart';
import '../../services/on_device_training_service.dart';

class AgentChatProvider extends ChangeNotifier {
  final OllamaService _ollama = OllamaService();
  final OnDeviceTrainingService _training = OnDeviceTrainingService();
  AgentTask? _activeTask;
  final List<String> _messages = [];
  bool _paused = false, _cancelled = false, _quranReady = false;
  String? _selectedAgent;
  AgentTask? get activeTask => _activeTask;
  List<String> get messages => List.unmodifiable(_messages);
  bool get paused => _paused;
  String? get selectedAgent => _selectedAgent;

  Future<void> initialize() async {
    if (_quranReady) return;
    final ayahs = await QuranLoaderService.loadAllAyahs();
    QuranicSearchEngine.indexVerses(ayahs.map((a) => {'id': a.id.toString(), 'surah': a.surahName, 'ayah': a.ayahNumber.toString(), 'text': a.text}).toList());
    _quranReady = true; notifyListeners();
  }

  void selectAgent(String? id) { _selectedAgent = id; notifyListeners(); }

  Future<void> executeTask(String query) async {
    final clean = query.trim();
    if (clean.isEmpty || _activeTask != null) return;
    _cancelled = false; _paused = false;
    final agents = _route(clean);
    var task = AgentTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(), userQuery: clean, createdAt: DateTime.now(), status: TaskStatus.running,
      steps: agents.asMap().entries.map((e) => AgentStep(number:e.key+1, agentName:e.value.id, title:e.value.name, subtitle:e.value.description)).toList(),
    );
    _activeTask = task; _messages.add('المستخدم: $clean'); notifyListeners();

    for (var i=0; i<agents.length; i++) {
      if (_cancelled) { _activeTask=task.copyWith(status:TaskStatus.cancelled); notifyListeners(); return; }
      while (_paused && !_cancelled) { await Future<void>.delayed(const Duration(milliseconds:100)); }
      if (_cancelled) continue;
      final current=task.steps[i];
      task=task.copyWith(steps:_replaceStep(task.steps,i,current.copyWith(status:StepStatus.running,startedAt:DateTime.now())));
      _activeTask=task; notifyListeners();
      try {
        final result=await _executeAgent(agents[i],clean);
        task=task.copyWith(steps:_replaceStep(task.steps,i,current.copyWith(status:StepStatus.done,progress:1,details:_detailsFor(agents[i],result),result:result,completedAt:DateTime.now())));
        _activeTask=task; notifyListeners();
      } catch(e) {
        task=task.copyWith(status:TaskStatus.failed,steps:_replaceStep(task.steps,i,current.copyWith(status:StepStatus.failed,result:e.toString(),completedAt:DateTime.now())),error:e.toString());
        _activeTask=task; notifyListeners(); return;
      }
    }
    final answer=await _composeAnswer(task);
    task=task.copyWith(status:TaskStatus.completed,completedAt:DateTime.now(),finalAnswer:answer);
    _activeTask=task; _messages.add('مُدَبِّر: $answer'); notifyListeners();
  }

  void pauseOrResume() { if(_activeTask==null)return; _paused=!_paused; _activeTask=_activeTask!.copyWith(status:_paused?TaskStatus.paused:TaskStatus.running); notifyListeners(); }
  void cancel() { _cancelled=true; _paused=false; if(_activeTask!=null){_activeTask=_activeTask!.copyWith(status:TaskStatus.cancelled);notifyListeners();} }

  List<AgentStep> _replaceStep(List<AgentStep> steps,int index,AgentStep value){final c=List<AgentStep>.from(steps);c[index]=value;return c;}

  List<AgentDefinition> _route(String query) {
    final result=<AgentDefinition>[AgentRegistry.byId('muwajjih')!];
    if(_selectedAgent!=null){final a=AgentRegistry.byId(_selectedAgent!);if(a!=null&&!result.any((x)=>x.id==a.id))result.add(a);}
    if(RegExp(r'آية|قرآن|سورة|تفسير|معنى|النور|الصمد|تحليل').hasMatch(query.toLowerCase())){
      for(final id in ['ayaat','tafsir','siyaq','jummal']){final a=AgentRegistry.byId(id);if(a!=null&&!result.any((x)=>x.id==id))result.add(a);}
    }
    final d=AgentRegistry.byId('damj')!;if(!result.any((x)=>x.id==d.id))result.add(d);return result;
  }

  Future<String> _executeAgent(AgentDefinition agent,String query) async {
    switch(agent.id){
      case 'muwajjih':
        final route = _route(query).where((a) => a.id != 'muwajjih').map((a) => a.name).toList();
        return route.isEmpty ? 'لم تُحدد حاجة لوكيل إضافي لهذا الطلب.' : 'تحليل الطلب: تم توجيهه فعلياً إلى: ${route.join(' ← ')}';
      case 'ayaat':
        await initialize(); final hits=QuranicSearchEngine.search(query).take(8).toList();
        if(hits.isEmpty) return 'لم تُوجد آية مطابقة بعد تطبيع النص في كامل الفهرس المحلي (6236 آية).';
        return hits.map((v) => "${v['surah']} ${v['ayah']}: ${v['text']}").join('\\n');
      case 'jummal': return 'قيمة الجمل الحسابية للنص المدخل: ${_abjad(query)}';
      case 'siyaq':
        await initialize(); final hits=QuranicSearchEngine.search(query).take(3).toList();
        return hits.isEmpty?'لا يوجد سياق مطابق في الفهرس المحلي.':'تم العثور على ${hits.length} مواضع سياقية.';
      case 'tadrib':
        final ayahs = await QuranLoaderService.loadAllAyahs();
        final verses = ayahs.map((a) => {'text': a.text, 'axis_type': a.axisType}).toList();
        await _training.startTraining(verses: verses, epochs: 1);
        return 'اكتملت دورة تدريب فعلية على ${verses.length} آية محلياً.';
      case 'ikhtibar':
        await initialize();
        final hits = QuranicSearchEngine.search(query).take(5).toList();
        return 'تم الاختبار على الفهرس المحلي؛ النتائج المطابقة: ${hits.length}.';
      case 'damj':
        final previous = _activeTask?.steps.where((s) => s.result != null).map((s) => s.result!).where((r) => r.isNotEmpty).toList() ?? const <String>[];
        return previous.isEmpty ? 'لا توجد نتائج سابقة لدمجها.' : previous.join('\\n\\n');
      default:
        // الوكلاء التحليليون يبدأون من دليل قرآني حقيقي، لا من توليد حر.
        // عند غياب المطابقة نصرّح بذلك ولا نختلق آية.
        await initialize();
        final hits = QuranicSearchEngine.search(query).take(3).toList();
        if (hits.isEmpty) {
          return 'لا توجد مطابقة قرآنية مباشرة للاستعلام «$query» في الفهرس المحلي؛ لم يتم توليد آية بديلة.';
        }
        final evidence = hits.map((v) => '${v['surah']} ${v['ayah']}: ${v['text']}').join('\\n');
        return 'دليل قرآني محلي للوكيل ${agent.name}:\\n$evidence';
    }
  }

  List<StepDetail> _detailsFor(AgentDefinition agent,String result)=>[
    StepDetail('الوكيل',agent.name),StepDetail('الطبقة',agent.layer),StepDetail('الحالة','تنفيذ حقيقي'),
    StepDetail('النتيجة',result.length>220?'${result.substring(0,220)}…':result),
  ];

  Future<String> _composeAnswer(AgentTask task) async {
    // لا نسمح للنموذج اللغوي بإعادة صياغة النص القرآني أو اختلاق شواهد.
    final context = task.steps
        .where((s) => s.result != null && s.result!.trim().isNotEmpty)
        .map((s) => '${s.agentName}: ${s.result}')
        .join('\\n\\n');
    return context.isEmpty
        ? 'اكتمل التنفيذ المحلي دون العثور على دليل قرآني مباشر.'
        : 'النتائج الموثقة محلياً:\\n\\n$context';
  }
  int _abjad(String text){
    const v={'ا':1,'أ':1,'إ':1,'آ':1,'ب':2,'ج':3,'د':4,'ه':5,'ة':5,'و':6,'ز':7,'ح':8,'ط':9,'ي':10,'ى':10,'ك':20,'ل':30,'م':40,'ن':50,'س':60,'ع':70,'ف':80,'ص':90,'ق':100,'ر':200,'ش':300,'ت':400,'ث':500,'خ':600,'ذ':700,'ض':800,'ظ':900,'غ':1000};
    var total=0;for(final r in text.runes)total+=v[String.fromCharCode(r)]??0;return total;
  }

  String exportJson(){final t=_activeTask;if(t==null)return '{}';return const JsonEncoder.withIndent('  ').convert({'id':t.id,'query':t.userQuery,'status':t.status.name,'progress':t.progress,'steps':t.steps.map((s)=>{'agent':s.agentName,'title':s.title,'status':s.status.name,'result':s.result}).toList(),'answer':t.finalAnswer});}
}
