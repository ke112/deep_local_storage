import 'package:deep_local_storage/deep_local_storage.dart' show DeepLocalStorage;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deep Local Storage Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DeepLocalStorage _storage = DeepLocalStorage();

  String _deviceId = '';
  String _storedString = '';
  int _storedInt = 0;
  double _storedDouble = 0.0;
  bool _storedBool = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // 获取设备ID
      final deviceId = await _storage.getDeviceId();

      // 读取存储的数据
      final storedString = await _storage.readString('demo_string') ?? '';
      final storedInt = await _storage.readInt('demo_int') ?? 0;
      final storedDouble = await _storage.readDouble('demo_double') ?? 0.0;
      final storedBool = await _storage.readBool('demo_bool') ?? false;

      if (mounted) {
        setState(() {
          _deviceId = deviceId;
          _storedString = storedString;
          _storedInt = storedInt;
          _storedDouble = storedDouble;
          _storedBool = storedBool;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载数据失败: $e')),
        );
      }
    }
  }

  Future<void> _saveData() async {
    try {
      // 保存各种类型的数据
      await _storage.saveString('demo_string', 'Hello, Deep Local Storage!');
      await _storage.saveInt('demo_int', 42);
      await _storage.saveDouble('demo_double', 3.14159);
      await _storage.saveBool('demo_bool', true);

      // 保存一个复杂的对象
      final userData = {
        'name': '张三',
        'age': 30,
        'email': 'zhangsan@example.com',
        'preferences': ['music', 'sports', 'reading'],
      };
      await _storage.saveMap('user_data', userData);

      // 重新加载数据
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据保存成功！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存数据失败: $e')),
        );
      }
    }
  }

  Future<void> _clearData() async {
    try {
      await _storage.clear();
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据已清空')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清空数据失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deep Local Storage Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 设备ID显示
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                //复制设备ID到剪贴板
                await Clipboard.setData(ClipboardData(text: _deviceId));
                debugPrint('设备ID已复制到剪贴板: $_deviceId');
              },
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '设备ID (持久化)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _deviceId,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Android: 使用系统级Android ID\niOS/macOS: 使用Keychain存储\n删除应用后重装仍然保持不变',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 存储的数据显示
            const Text(
              '存储的数据',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            _buildDataCard('字符串', _storedString),
            _buildDataCard('整数', _storedInt.toString()),
            _buildDataCard('浮点数', _storedDouble.toString()),
            _buildDataCard('布尔值', _storedBool.toString()),

            const SizedBox(height: 16),

            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveData,
                    icon: const Icon(Icons.save),
                    label: const Text('保存示例数据'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearData,
                    icon: const Icon(Icons.clear),
                    label: const Text('清空数据'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 功能说明
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '功能特性',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• 支持字符串、整数、浮点数、布尔值存储'),
                    Text('• 支持字节数组、列表、Map和对象存储'),
                    Text('• 普通存储和安全凭据存储两种模式'),
                    Text('• 设备ID持久化，删除应用后仍可获取'),
                    Text('• 跨平台支持 (iOS、Android、macOS)'),
                    Text('• 基于rcache_flutter，提供底层安全存储'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
