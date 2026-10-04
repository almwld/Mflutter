import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/agent_task.dart';
import '../../../services/agent_registry.dart';
import '../../providers/agent_chat_provider.dart';

class AgentsScreen extends StatelessWidget {
  const AgentsScreen({super.key});
  @override Widget build(BuildContext context)=>ChangeNotifierProvider(create:(_)=>AgentChatProvider(),child:const _AgentsView());
}
class _AgentsView extends StatefulWidget{const _AgentsView();@override State<_AgentsView> createState()=>_AgentsViewState();}
class _AgentsViewState extends State<_AgentsView>{
  final c=TextEditingController();
  @override void dispose(){c.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final p=context.watch<AgentChatProvider>();final t=p.activeTask;
    return Scaffold(backgroundColor:AppColors.background,appBar:AppBar(backgroundColor:AppColors.primaryNavy,title:const Text('مُدَبِّر — الوكلاء',style:TextStyle(color:AppColors.primaryGold)),actions:[Center(child:Text('\${AgentRegistry.all.length} وكيل',style:const TextStyle(color:Colors.white70))),const SizedBox(width:12)]),
    body:Column(children:[
      SizedBox(height:68,child:ListView.builder(scrollDirection:Axis.horizontal,reverse:true,padding:const EdgeInsets.all(10),itemCount:AgentRegistry.all.length,itemBuilder:(_,i){final a=AgentRegistry.all[i];final s=p.selectedAgent==a.id;return Padding(padding:const EdgeInsets.only(left:7),child:ChoiceChip(label:Text(a.name),selected:s,onSelected:(_)=>p.selectAgent(s?null:a.id)));})),
      if(t!=null)_TaskBar(task:t,provider:p),
      Expanded(child:_TaskView(task:t,messages:p.messages)),
      SafeArea(top:false,child:Padding(padding:const EdgeInsets.all(10),child:Row(children:[
        Expanded(child:TextField(controller:c,minLines:1,maxLines:4,textDirection:TextDirection.rtl,style:const TextStyle(color:Colors.white),decoration:InputDecoration(hintText:'كلّف مُدَبِّر بمهمة...',hintStyle:const TextStyle(color:Colors.white38),filled:true,fillColor:AppColors.surface,border:const OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(24)),borderSide:BorderSide.none)),onSubmitted:(_)=>send(p))),
        const SizedBox(width:8),CircleAvatar(backgroundColor:AppColors.primaryGold,child:IconButton(color:AppColors.primaryNavy,icon:const Icon(Icons.send),onPressed:()=>send(p)))
      ])))
    ]));
  }
  void send(AgentChatProvider p){final x=c.text.trim();if(x.isEmpty)return;c.clear();p.executeTask(x);}
}
class _TaskBar extends StatelessWidget{
  final AgentTask task;final AgentChatProvider provider;const _TaskBar({required this.task,required this.provider});
  @override Widget build(BuildContext context){return Container(margin:const EdgeInsets.fromLTRB(12,0,12,8),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:AppColors.primaryNavy,borderRadius:BorderRadius.circular(16),border:Border.all(color:AppColors.primaryGold.withOpacity(.45))),child:Column(children:[
    Row(children:[const Icon(Icons.auto_awesome,color:AppColors.primaryGold),const SizedBox(width:8),Expanded(child:Text(task.userQuery,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold))),Text('${(task.progress*100).round()}%',style:const TextStyle(color:AppColors.primaryGold))]),
    const SizedBox(height:8),LinearProgressIndicator(value:task.progress,minHeight:5),const SizedBox(height:4),
    Row(children:[Text('${task.steps.where((s)=>s.status==StepStatus.done).length}/${task.steps.length} خطوات',style:const TextStyle(color:Colors.white54,fontSize:12)),const Spacer(),IconButton(onPressed:provider.pauseOrResume,icon:Icon(provider.paused?Icons.play_arrow:Icons.pause,color:AppColors.primaryGold)),IconButton(onPressed:provider.cancel,icon:const Icon(Icons.stop_circle_outlined,color:Colors.redAccent))])
  ]));}
}
class _TaskView extends StatelessWidget{
  final AgentTask? task;final List<String> messages;const _TaskView({required this.task,required this.messages});
  @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(14),children:[
    if(task?.finalAnswer!=null)_Message(text:task!.finalAnswer!),
    if(task!=null)...task!.steps.map((s)=>_Step(step:s)),
    ...messages.reversed.map((m)=>_Message(text:m)),
    if(task==null&&messages.isEmpty)const Padding(padding:EdgeInsets.only(top:80),child:Text('اكتب مهمة حقيقية للوكلاء. سترى التنفيذ الفعلي خطوة بخطوة هنا.',textAlign:TextAlign.center,style:TextStyle(color:Colors.white54,fontSize:16)))
  ]);
}
class _Step extends StatelessWidget{
  final AgentStep step;const _Step({required this.step});
  @override Widget build(BuildContext context){final run=step.status==StepStatus.running;final fail=step.status==StepStatus.failed;return Card(color:AppColors.surface,margin:const EdgeInsets.only(bottom:10),child:ExpansionTile(
    leading:run?const SizedBox(width:28,height:28,child:CircularProgressIndicator(strokeWidth:2)):Icon(fail?Icons.error_outline:step.status==StepStatus.done?Icons.check_circle:Icons.schedule,color:fail?Colors.redAccent:AppColors.primaryGold),
    title:Text('\${step.number}. \${step.title}',style:const TextStyle(color:AppColors.primaryGold,fontWeight:FontWeight.bold)),
    subtitle:Text('\${step.agentName} • \${step.subtitle}',style:const TextStyle(color:Colors.white54)),
    children:[if(step.result!=null)Padding(padding:const EdgeInsets.all(14),child:Align(alignment:Alignment.centerRight,child:Text(step.result!,textDirection:TextDirection.rtl,style:const TextStyle(color:Colors.white,height:1.6)))),...step.details.map((d)=>ListTile(dense:true,title:Text(d.label,style:const TextStyle(color:Colors.white54)),subtitle:Text(d.value,maxLines:4,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Colors.white))))]
  ));}
}
class _Message extends StatelessWidget{final String text;const _Message({required this.text});@override Widget build(BuildContext context)=>Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:AppColors.primaryNavy,borderRadius:BorderRadius.circular(16)),child:Text(text,textDirection:TextDirection.rtl,style:const TextStyle(color:Colors.white,height:1.7)));}
