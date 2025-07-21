import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pipe_code_flutter/repositories/spareqr_repository.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_state.dart';
import '../bloc/user/user_event.dart';
import '../bloc/project/project_bloc.dart';
import '../bloc/project/project_state.dart';
import '../bloc/project/project_event.dart';
import '../pages/home/home_page.dart';
import '../pages/records/records_list_page.dart';
import '../pages/profile/profile_page.dart';
import '../bloc/records/records_bloc.dart';
import '../repositories/records_repository.dart';
import 'package:get_it/get_it.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // 控制界面是否准备好显示 TabBar
  bool _isReady = false;
  
  // 当前用户状态
  bool _isStorekeeper = false;
  AuthState? _currentAuthState;
  ProjectState? _currentProjectState;

  final List<Widget> _pages = [
    // const HomePage(),
    RepositoryProvider(
      create: (context) => (GetIt.instance<SpareqrRepository>()),
      child: const HomePage(),
    ),
    BlocProvider(
      create: (context) => RecordsBloc(GetIt.instance<RecordsRepository>()),
      child: const RecordsListPage(),
    ),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // 初始化项目状态管理
    _initializeProjectState();
  }

  void _initializeProjectState() {
    // 初始化当前状态
    final authState = context.read<AuthBloc>().state;
    final projectState = context.read<ProjectBloc>().state;
    
    print('MainPage._initializeProjectState: AuthState=${authState.runtimeType}, ProjectState=${projectState.runtimeType}');
    
    setState(() {
      _currentAuthState = authState;
      _currentProjectState = projectState;
    });
    
    // 检查认证状态并加载用户数据
    if (authState is AuthLoginSuccess) {
      print('MainPage: AuthLoginSuccess detected in init');
      // 触发用户数据加载
      context.read<UserBloc>().add(UserSetData(wxLoginVO: authState.wxLoginVO));
    } else if (authState is AuthStorekeeperAuthenticated) {
      print('MainPage: AuthStorekeeperAuthenticated detected in init');
      // 仓管员模式，设置状态并加载用户数据
      setState(() {
        _isStorekeeper = true;
        _isReady = true;
      });
      context.read<UserBloc>().add(UserSetData(wxLoginVO: authState.wxLoginVO));
    }
    
    // 更新准备状态
    _updateReadyState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // 监听用户状态变化，触发项目列表加载
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserLoaded && !_isStorekeeper) {
              // 只有非仓管员用户才需要加载项目数据
              context.read<ProjectBloc>().add(
                ProjectLoadUserProjects(wxLoginVO: state.wxLoginVO),
              );
            }
          },
        ),
        // 监听认证状态变化
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            print('MainPage AuthBloc Listener: ${state.runtimeType}');
            setState(() {
              _currentAuthState = state;
            });
            
            if (state is AuthLoginSuccess || state is AuthIdentitySelectionRequired) {
              // 登录成功或需要身份选择，都设置用户数据
              final wxLoginVO = state is AuthLoginSuccess
                  ? state.wxLoginVO
                  : (state as AuthIdentitySelectionRequired).wxLoginVO;
              context.read<UserBloc>().add(
                UserSetData(wxLoginVO: wxLoginVO),
              );
            } else if (state is AuthStorekeeperAuthenticated) {
              // 仓管员认证完成，设置仓管员状态
              print('MainPage: Setting storekeeper state');
              setState(() {
                _isStorekeeper = true;
                _isReady = true;
              });
              context.read<UserBloc>().add(
                UserSetData(wxLoginVO: state.wxLoginVO),
              );
            } else if (state is AuthUnauthenticated) {
              // 用户未认证，清除所有状态并跳转到登录页面
              context.read<UserBloc>().add(const UserClearData());
              context.read<ProjectBloc>().add(const ProjectClearData());
              context.go('/login');
            }
            
            _updateReadyState();
          },
        ),
        // 监听项目状态变化
        BlocListener<ProjectBloc, ProjectState>(
          listener: (context, state) {
            print('MainPage ProjectBloc Listener: ${state.runtimeType}');
            setState(() {
              _currentProjectState = state;
            });
            _updateReadyState();
          },
        ),
      ],
      child: _buildPageContent(),
    );
  }

  /// 更新界面准备状态
  void _updateReadyState() {
    bool newReadyState = false;
    
    // 仓管员状态优先级最高
    if (_isStorekeeper) {
      newReadyState = true;
    } else if (_currentAuthState is AuthIdentitySelectionRequired) {
      // 需要身份选择，不显示 TabBar
      newReadyState = false;
    } else if (_currentAuthState is AuthLoginSuccess) {
      // 普通用户需要等待项目状态确定
      if (_currentProjectState is ProjectRoleInfoLoaded) {
        newReadyState = true;
      }
    }
    
    if (newReadyState != _isReady) {
      setState(() {
        _isReady = newReadyState;
      });
    }
  }

  /// 构建页面内容
  Widget _buildPageContent() {
    // Debug 日志
    print('MainPage._buildPageContent: AuthState=${_currentAuthState.runtimeType}, ProjectState=${_currentProjectState.runtimeType}, isStorekeeper=$_isStorekeeper, isReady=$_isReady');
    
    // 1. 仓管员身份选择状态 - 最高优先级，在 MainPage 中处理
    if (_currentAuthState is AuthIdentitySelectionRequired) {
      print('MainPage: Showing identity selection page');
      return _buildIdentitySelectionPage();
    }
    
    // 2. 普通用户等待项目选择 - 在 MainPage 中处理
    if (_currentAuthState is AuthLoginSuccess && 
        _currentProjectState is ProjectListLoaded) {
      print('MainPage: Showing project selection page');
      return _buildProjectSelectionPage();
    }
    
    // 2.1 普通用户无项目 - 显示无项目提示
    if (_currentAuthState is AuthLoginSuccess && 
        _currentProjectState is ProjectEmpty) {
      print('MainPage: Showing no projects page');
      return _buildNoProjectsPage();
    }
    
    // 3. 仓管员已认证状态 - 显示主界面
    if (_currentAuthState is AuthStorekeeperAuthenticated) {
      print('MainPage: Showing storekeeper main interface');
      return _buildMainInterface();
    }
    
    // 4. 普通用户完整状态 - 显示主界面
    if (_currentAuthState is AuthLoginSuccess && 
        _currentProjectState is ProjectRoleInfoLoaded) {
      print('MainPage: Showing normal user main interface');
      return _buildMainInterface();
    }
    
    // 5. 项目加载错误
    if (_currentProjectState is ProjectError) {
      print('MainPage: Project error');
      return _buildErrorPage((_currentProjectState as ProjectError).message);
    }
    
    // 6. 默认加载状态
    print('MainPage: Default loading state');
    return _buildLoadingPage();
  }

  /// 构建主界面
  Widget _buildMainInterface() {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            _animationController.reset();
            setState(() {
              _currentIndex = index;
            });
            _animationController.forward();
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: '记录'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }

  /// 构建加载页面
  Widget _buildLoadingPage({String? content}) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (content != null) ...[
              const SizedBox(height: 16),
              Text(
                content,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建错误页面
  Widget _buildErrorPage(String message) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text('加载项目信息失败: $message'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 重新加载项目数据
                final userState = context.read<UserBloc>().state;
                if (userState is UserLoaded) {
                  context.read<ProjectBloc>().add(
                    ProjectLoadUserProjects(
                      wxLoginVO: userState.wxLoginVO,
                    ),
                  );
                }
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建身份选择页面
  Widget _buildIdentitySelectionPage() {
    final authState = _currentAuthState as AuthIdentitySelectionRequired;
    final wxLoginVO = authState.wxLoginVO;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择登录身份'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 顶部用户信息
            _buildUserInfoCard(wxLoginVO),
            const SizedBox(height: 40),
            
            // 身份选择提示
            _buildSelectionTitle(),
            const SizedBox(height: 30),
            
            // 身份选择卡片
            Expanded(
              child: Column(
                children: [
                  _buildProjectModeCard(),
                  const SizedBox(height: 20),
                  _buildStorekeeperModeCard(),
                ],
              ),
            ),
            
            // 底部说明
            _buildSelectionNote(),
          ],
        ),
      ),
    );
  }

  /// 构建项目选择页面
  Widget _buildProjectSelectionPage() {
    final authState = _currentAuthState as AuthLoginSuccess;
    final projectState = _currentProjectState as ProjectListLoaded;
    final wxLoginVO = authState.wxLoginVO;
    final projects = projectState.availableProjects;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择项目'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 顶部用户信息
            _buildProjectUserInfoCard(wxLoginVO),
            const SizedBox(height: 24),
            
            // 项目选择提示
            _buildProjectSelectionTitle(),
            const SizedBox(height: 24),
            
            // 项目列表
            Expanded(
              child: projects.isEmpty 
                ? _buildNoProjectsView()
                : _buildProjectsList(projects),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(dynamic wxLoginVO) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Text(
              wxLoginVO.name.isNotEmpty ? wxLoginVO.name[0] : 'U',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wxLoginVO.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '仓管员账户',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionTitle() {
    return const Column(
      children: [
        Text(
          '请选择登录身份',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: 8),
        Text(
          '根据您的工作需要选择合适的身份模式',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF7F8C8D),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectModeCard() {
    return _buildModeCard(
      title: '项目参与方',
      subtitle: '参与具体项目的工作',
      description: '• 查看和管理项目信息\n• 执行角色相关的业务操作\n• 与团队协作完成项目任务',
      icon: Icons.business,
      color: const Color(0xFF3498DB),
      onTap: _selectProjectMode,
    );
  }

  Widget _buildStorekeeperModeCard() {
    return _buildModeCard(
      title: '独立仓管员',
      subtitle: '专注库存管理工作',
      description: '• 管理库存物料和设备\n• 处理入库、出库、调拨\n• 进行库存盘点和统计',
      icon: Icons.inventory_2,
      color: const Color(0xFF27AE60),
      onTap: _selectStorekeeperMode,
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5D6D7E),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF6C757D), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '每次登录都需要重新选择身份，确保符合当前工作需要',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6C757D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectProjectMode() {
    context.read<AuthBloc>().add(const AuthProjectModeRequested());
  }

  void _selectStorekeeperMode() {
    context.read<AuthBloc>().add(const AuthStorekeeperModeRequested());
  }

  /// 构建项目选择用户信息卡片
  Widget _buildProjectUserInfoCard(dynamic wxLoginVO) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Text(
              wxLoginVO.name.isNotEmpty ? wxLoginVO.name[0] : 'U',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wxLoginVO.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '手机: ${wxLoginVO.phone}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建项目选择标题
  Widget _buildProjectSelectionTitle() {
    return const Column(
      children: [
        Text(
          '选择参与的项目',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: 8),
        Text(
          '请从以下项目中选择您要参与的项目',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF7F8C8D),
          ),
        ),
      ],
    );
  }

  /// 构建项目列表
  Widget _buildProjectsList(List<dynamic> projects) {
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectCard(project, index);
      },
    );
  }

  /// 构建项目卡片
  Widget _buildProjectCard(dynamic project, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _selectProject(project),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF3498DB).withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business,
                  size: 28,
                  color: Color(0xFF3498DB),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.projectName ?? '未知项目',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '项目编号: ${project.projectCode ?? '未知'}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    if (project.orgName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '机构: ${project.orgName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7F8C8D),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF7F8C8D),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建无项目视图
  Widget _buildNoProjectsView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_center_outlined,
            size: 64,
            color: Color(0xFF95A5A6),
          ),
          SizedBox(height: 16),
          Text(
            '暂无可参与的项目',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7F8C8D),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '请联系管理员为您分配项目权限',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF95A5A6),
            ),
          ),
        ],
      ),
    );
  }

  /// 选择项目
  void _selectProject(dynamic project) {
    print('MainPage: Selecting project ${project.projectName}');
    context.read<ProjectBloc>().add(
      ProjectSelectProject(
        projectId: project.projectId,
      ),
    );
  }

  /// 构建无项目页面
  Widget _buildNoProjectsPage() {
    final authState = _currentAuthState as AuthLoginSuccess;
    final wxLoginVO = authState.wxLoginVO;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('项目信息'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 顶部用户信息
            _buildProjectUserInfoCard(wxLoginVO),
            const SizedBox(height: 40),
            
            // 无项目提示
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF95A5A6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: const Icon(
                        Icons.business_center_outlined,
                        size: 60,
                        color: Color(0xFF95A5A6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '暂无可参与的项目',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '您当前没有被分配到任何项目',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF95A5A6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '请联系项目管理员为您分配项目权限',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF95A5A6),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // 联系管理员按钮
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton.icon(
                        onPressed: () => _showContactInfo(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3498DB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.contact_support),
                        label: const Text(
                          '联系管理员',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 退出登录按钮
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      child: OutlinedButton.icon(
                        onPressed: () => _logout(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF7F8C8D),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFF7F8C8D)),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          '退出登录',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
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

  /// 显示联系信息
  void _showContactInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('联系管理员'),
        content: const Text('请联系您的项目管理员或系统管理员，申请项目参与权限。\n\n如需技术支持，请联系系统客服。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  /// 退出登录
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出当前账户吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}
