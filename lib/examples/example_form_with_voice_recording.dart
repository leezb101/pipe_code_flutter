// example_form_with_voice_recording.dart
// 示例：在业务表单中使用语音录制功能

import 'package:flutter/material.dart';
import '../widgets/speech_input_widget.dart';

/// 示例表单页面，展示如何使用带录音功能的语音输入组件
class ExampleFormWithVoiceRecording extends StatefulWidget {
  const ExampleFormWithVoiceRecording({super.key});

  @override
  State<ExampleFormWithVoiceRecording> createState() =>
      _ExampleFormWithVoiceRecordingState();
}

class _ExampleFormWithVoiceRecordingState
    extends State<ExampleFormWithVoiceRecording> {
  final _formKey = GlobalKey<FormState>();

  // 表单字段控制器
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _remarksController = TextEditingController();

  // 新增：录音文件路径字段
  String? _voiceRecordingPath;
  String? _descriptionVoicePath;
  String? _remarksVoicePath;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  /// 提交表单数据
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 准备提交的数据
      final formData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'remarks': _remarksController.text,
        // 新增：录音文件路径
        'voiceRecordingPath': _voiceRecordingPath,
        'descriptionVoicePath': _descriptionVoicePath,
        'remarksVoicePath': _remarksVoicePath,
        'submitTime': DateTime.now().toIso8601String(),
      };

      // 这里调用API提交表单数据
      print('提交表单数据: $formData');

      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('表单提交成功！'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('带录音功能的语音输入示例'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 普通文本输入框（不需要语音功能）
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '标题',
                  hintText: '请输入标题',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入标题';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 带语音识别和录音功能的描述输入框
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '描述',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  SpeechInputWidget(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: '请输入或语音输入描述...',
                      border: OutlineInputBorder(),
                    ),
                    onVoiceRecordingPath: (filePath) {
                      // 录音文件上传完成，保存文件路径
                      setState(() {
                        _descriptionVoicePath = filePath;
                      });
                      print('描述录音文件路径: $filePath');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('录音已保存并上传成功！'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  // 显示录音文件状态
                  if (_descriptionVoicePath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.mic, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '录音已上传: $_descriptionVoicePath',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // 带语音识别和录音功能的备注输入框
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '备注',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  SpeechInputWidget(
                    controller: _remarksController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: '请输入或语音输入备注...',
                      border: OutlineInputBorder(),
                    ),
                    onVoiceRecordingPath: (filePath) {
                      // 录音文件上传完成，保存文件路径
                      setState(() {
                        _remarksVoicePath = filePath;
                      });
                      print('备注录音文件路径: $filePath');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('录音已保存并上传成功！'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  // 显示录音文件状态
                  if (_remarksVoicePath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.mic, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '录音已上传: $_remarksVoicePath',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // 提交按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('提交表单', style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 16),

              // 功能说明
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '功能说明：',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 点击麦克风图标开始语音识别和录音\n'
                      '• 语音识别的文字会实时显示在输入框中\n'
                      '• 录音文件会自动上传到服务器\n'
                      '• 上传完成后会显示录音文件路径\n'
                      '• 提交表单时会同时提交文字和录音文件路径',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
