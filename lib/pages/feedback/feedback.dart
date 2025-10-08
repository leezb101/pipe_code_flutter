import 'package:flutter/material.dart';
import 'package:pipe_code_flutter/config/service_locator.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'feedback_bloc.dart';
import '../../services/api/interfaces/profile_api_service.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  late final FeedbackBloc _bloc;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = FeedbackBloc(profileApiService: getIt<ProfileApiService>());
  }

  @override
  void dispose() {
    _bloc.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final ok = await _bloc.submit();
    if (ok && mounted) {
      _controller.clear();
      _bloc.clear();
      context.showSuccessToast('感谢您的反馈！');
    } else {
      _bloc.error$.first.then((err) {
        if (err != null && mounted) {
          context.showErrorToast(err);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('提点建议')),
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(16), child: Container()),
      ),
    );
  }
}
