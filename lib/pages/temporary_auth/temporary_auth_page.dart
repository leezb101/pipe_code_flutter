import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/cubits/temporary_auth.dart';
import 'package:pipe_code_flutter/utils/toast_utils.dart';
import 'package:pipe_code_flutter/models/common/common_enum_vo.dart' as enum_vo;

class TemporaryAuthPage extends StatefulWidget {
  const TemporaryAuthPage({super.key});

  @override
  State<TemporaryAuthPage> createState() => _TemporaryAuthPageState();
}

class _TemporaryAuthPageState extends State<TemporaryAuthPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();

    final cubit = context.read<TemporaryAuthCubit>();
    _nameController.addListener(() {
      cubit.onNameChanged(_nameController.text);
    });
    _phoneController.addListener(() {
      cubit.onPhoneChanged(_phoneController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TemporaryAuthCubit, TemporaryAuthState>(
      listener: (context, state) {
        if (state.status == TemporaryPageStatus.success) {
          ToastUtils.showSuccess(context, '授权成功');
          // 清空表单状态
          _nameController.clear();
          _phoneController.clear();
        } else if (state.status == TemporaryPageStatus.error) {
          ToastUtils.showError(
            context,
            '授权失败: ${state.errorMessage ?? '未知错误'}',
          );
          // 清空错误消息
          context.read<TemporaryAuthCubit>().clearErrorMessage();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('授权他人')),
        body: BlocBuilder<TemporaryAuthCubit, TemporaryAuthState>(
          builder: (context, state) {
            switch (state.status) {
              case TemporaryPageStatus.loadingRole:
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('加载中...'),
                    ],
                  ),
                );
              case TemporaryPageStatus.optionSelection:
                return _buildOptionSelectionUI(context, state.availableOptions);
              case TemporaryPageStatus.formReady:
              case TemporaryPageStatus.submitting:
              case TemporaryPageStatus.success:
              case TemporaryPageStatus.error:
                return _buildFormUI(context, state);
            }
          },
        ),
      ),
    );
  }

  Widget _buildOptionSelectionUI(
    BuildContext context,
    List<TemporaryAuthType> options,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '请选择您要授权的用户类型：',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ...options.map(
              (option) => Card(
                child: ListTile(
                  title: Text(option.label),
                  leading: const Icon(Icons.article_outlined),
                  onTap: () {
                    context
                        .read<TemporaryAuthCubit>()
                        .selectTemporaryTypeOption(option);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormUI(BuildContext context, TemporaryAuthState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            state.selectedOption?.label ?? '',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '姓名',
              hintText: '请输入被授权人姓名',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.numberWithOptions(
              decimal: false,
              signed: false,
            ),
            decoration: const InputDecoration(
              labelText: '手机号',
              hintText: '请输入被授权人手机号',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          if (state.selectedOption == TemporaryAuthType.labor)
            // 使用enum中的Interval枚举构造下拉选择器
            DropdownButtonFormField<enum_vo.Interval>(
              decoration: const InputDecoration(
                labelText: '选择授权周期',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
              ),
              items: enum_vo.Interval.values.map((interval) {
                return DropdownMenuItem(
                  value: interval,
                  child: Text(interval.name),
                );
              }).toList(),
              onChanged: (value) {
                context.read<TemporaryAuthCubit>().onIntervalChanged(value!);
              },
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: state.status == TemporaryPageStatus.submitting
                ? null
                : () => context.read<TemporaryAuthCubit>().submitForm(),
            child: state.status == TemporaryPageStatus.submitting
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : const Text('提交'),
          ),
        ],
      ),
    );
  }
}
