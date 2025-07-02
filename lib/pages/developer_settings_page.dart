import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../utils/toast_utils.dart';

class DeveloperSettingsPage extends StatefulWidget {
  const DeveloperSettingsPage({super.key});

  @override
  State<DeveloperSettingsPage> createState() => _DeveloperSettingsPageState();
}

class _DeveloperSettingsPageState extends State<DeveloperSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Settings'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Environment Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEnvironmentSelector(),
                    const SizedBox(height: 16),
                    _buildDataSourceSelector(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildConfigInfo(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _restartApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Restart App'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetSettings,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Reset Settings'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Card(
              color: Colors.amber,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Developer Notice',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Settings are now automatically saved. Changes will persist after app restart. '
                      'Use Mock data source when no backend is available.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Environment:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Environment>(
          value: AppConfig.environment,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: Environment.values.map((env) {
            return DropdownMenuItem(
              value: env,
              child: Text(_environmentName(env)),
            );
          }).toList(),
          onChanged: (Environment? value) async {
            if (value != null) {
              await AppConfig.setEnvironment(value);
              setState(() {});
            }
          },
        ),
      ],
    );
  }

  Widget _buildDataSourceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Source:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<DataSource>(
          value: AppConfig.dataSource,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: DataSource.values.map((source) {
            return DropdownMenuItem(
              value: source,
              child: Row(
                children: [
                  Icon(
                    source == DataSource.mock ? Icons.code : Icons.cloud,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(_dataSourceName(source)),
                ],
              ),
            );
          }).toList(),
          onChanged: (DataSource? value) async {
            if (value != null) {
              await AppConfig.setDataSource(value);
              setState(() {});
            }
          },
        ),
      ],
    );
  }

  Widget _buildConfigInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Environment', _environmentName(AppConfig.environment)),
        _buildInfoRow('Data Source', _dataSourceName(AppConfig.dataSource)),
        _buildInfoRow('API Base URL', AppConfig.apiBaseUrl),
        _buildInfoRow('Mock Enabled', AppConfig.isMockEnabled ? 'Yes' : 'No'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  String _environmentName(Environment env) {
    switch (env) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  String _dataSourceName(DataSource source) {
    switch (source) {
      case DataSource.mock:
        return 'Mock Data';
      case DataSource.api:
        return 'Real API';
    }
  }

  void _restartApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings Saved'),
        content: const Text(
          'Your settings have been saved successfully! '
          'You can now close and reopen the app to see the changes take effect.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Settings'),
          content: const Text(
            'This will reset all developer settings to default values. '
            'Are you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  await AppConfig.reset();
                  if (mounted) {
                    setState(() {});
                    if (context.mounted) {
                      context.showSuccessToast('设置已重置为默认值');
                    }
                  }
                } catch (e) {
                  if (mounted && context.mounted) {
                    context.showErrorToast('重置设置失败: $e');
                  }
                }
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}
