import 'package:flutter/material.dart';
import '../../models/task_result.dart';
import 'part2_result_screen.dart';
import 'tasks/sequence_task.dart';
import 'tasks/memory_task.dart';
import 'tasks/spatial_task.dart';
import 'tasks/rhythm_task.dart';
import 'tasks/reaction_task.dart';
import 'tasks/emotion_task.dart';
import 'tasks/reflection_task.dart';
import 'tasks/classify_task.dart';

/// Part2のタスクフローを管理する画面
class Part2FlowScreen extends StatefulWidget {
  final Map<String, double> part1Scores;

  const Part2FlowScreen({
    super.key,
    required this.part1Scores,
  });

  @override
  State<Part2FlowScreen> createState() => _Part2FlowScreenState();
}

class _Part2FlowScreenState extends State<Part2FlowScreen> {
  int _currentTaskIndex = 0;
  final Map<String, TaskResult> _taskResults = {};

  // タスクの順序
  final List<String> _taskOrder = [
    'sequence',  // 論理
    'memory',    // 言語
    'spatial',   // 空間
    'rhythm',    // 音楽
    'reaction',  // 身体
    'emotion',   // 対人
    'reflection', // 内省
    'classify',  // 博物
  ];

  @override
  Widget build(BuildContext context) {
    return _buildCurrentTask();
  }

  Widget _buildCurrentTask() {
    final taskId = _taskOrder[_currentTaskIndex];

    switch (taskId) {
      case 'sequence':
        return SequenceTask(onComplete: _onTaskComplete);
      case 'memory':
        return MemoryTask(onComplete: _onTaskComplete);
      case 'spatial':
        return SpatialTask(onComplete: _onTaskComplete);
      case 'rhythm':
        return RhythmTask(onComplete: _onTaskComplete);
      case 'reaction':
        return ReactionTask(onComplete: _onTaskComplete);
      case 'emotion':
        return EmotionTask(onComplete: _onTaskComplete);
      case 'reflection':
        return ReflectionTask(onComplete: _onTaskComplete);
      case 'classify':
        return ClassifyTask(onComplete: _onTaskComplete);
      default:
        return const SizedBox();
    }
  }

  void _onTaskComplete(TaskResult result) {
    _taskResults[result.taskId] = result;

    if (_currentTaskIndex < _taskOrder.length - 1) {
      // 次のタスクへ
      setState(() {
        _currentTaskIndex++;
      });
    } else {
      // 全タスク完了
      _showPart2Result();
    }
  }

  void _showPart2Result() {
    final part2Result = Part2Result(taskResults: _taskResults);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => Part2ResultScreen(
          part1Scores: widget.part1Scores,
          part2Result: part2Result,
        ),
      ),
    );
  }
}
