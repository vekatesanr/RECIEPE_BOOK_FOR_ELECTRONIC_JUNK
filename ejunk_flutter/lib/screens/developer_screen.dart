import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../models/component_model.dart';
import '../models/admin_model.dart';
import '../widgets/sidebar_drawer.dart';
import 'package:intl/intl.dart';

class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({super.key});

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
  final FirebaseService _service = FirebaseService();
  final AuthService _authService = AuthService();
  
  // Login standard controllers
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  // Create new admin controllers
  final _newAdminEmailController = TextEditingController();
  final _newAdminPassController = TextEditingController();

  bool _unlocked = false;
  bool _obscurePassword = true;
  bool _signingIn = false;
  String _error = '';

  // Dashboard state
  bool _showAdminsTab = false;
  bool _creatingAdmin = false;

  @override
  void initState() {
    super.initState();
    if (_authService.isLoggedIn) {
      _unlocked = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _newAdminEmailController.dispose();
    _newAdminPassController.dispose();
    super.dispose();
  }

  Future<void> _attemptUnlock() async {
    final email = _emailController.text.trim();
    final pass = _passController.text;
    
    if (email.isEmpty || pass.isEmpty) return;
    
    setState(() {
      _signingIn = true;
      _error = '';
    });

    try {
      await _authService.signInWithEmail(email, pass);
      if (mounted) {
        setState(() {
          _unlocked = true;
          _signingIn = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _signingIn = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    setState(() {
      _unlocked = false;
      _showAdminsTab = false;
    });
  }

  Future<void> _verifyComponent(BuildContext context, ComponentModel comp) async {
    try {
      await _service.verifyComponent(comp.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ "${comp.componentName}" approved & published!'),
            backgroundColor: const Color(0xFF10b981),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFef4444),
          ),
        );
      }
    }
  }

  Future<void> _handleCreateAdmin() async {
    final newEmail = _newAdminEmailController.text.trim();
    final newPass = _newAdminPassController.text;

    if (newEmail.isEmpty || newPass.length < 6) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email and 6+ char password'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _creatingAdmin = true);

    try {
      await _authService.createAdminAccount(newEmail: newEmail, newPassword: newPass);
      _newAdminEmailController.clear();
      _newAdminPassController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Admin account "$newEmail" created successfully!'), backgroundColor: const Color(0xFF10b981)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'), backgroundColor: const Color(0xFFef4444)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _creatingAdmin = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f172a),
      appBar: AppBar(
        title: Text(_showAdminsTab ? '🛡️ Admin Management' : '🛡️ Developer Panel'),
        actions: _unlocked
            ? [
                if (_authService.currentUser?.email == AuthService.masterEmail)
                  IconButton(
                    icon: Icon(_showAdminsTab ? Icons.dashboard_rounded : Icons.manage_accounts_rounded),
                    tooltip: 'Switch Tab',
                    onPressed: () => setState(() => _showAdminsTab = !_showAdminsTab),
                  ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: 'Logout',
                  onPressed: _handleLogout,
                ),
              ]
            : null,
      ),
      drawer: const SidebarDrawer(currentRoute: '/developer'),
      body: _unlocked 
          ? (_showAdminsTab ? _buildAdminManagement() : _buildDashboard())
          : _buildLockScreen(),
    );
  }

  // ─── LOGIN SCREEN ─────────────────────────────────────────────────────────

  Widget _buildLockScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10b981).withOpacity(0.1),
                border: Border.all(
                    color: const Color(0xFF10b981).withOpacity(0.3), width: 2),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, size: 40, color: Color(0xFF10b981)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Secure Admin Access',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Authorized personnel only',
              style: TextStyle(color: Color(0xFF64748b), fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Admin Email',
                hintText: 'venkatesanr9042@gmail.com',
                prefixIcon: Icon(Icons.alternate_email_rounded, color: Color(0xFF10b981), size: 20),
              ),
            ),
            const SizedBox(height: 14),

            // Password
            TextField(
              controller: _passController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.key_rounded, color: Color(0xFF10b981), size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                    color: const Color(0xFF64748b),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              onSubmitted: (_) => _attemptUnlock(),
            ),

            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFef4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFef4444).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Color(0xFFef4444), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_error, style: const TextStyle(color: Color(0xFFef4444), fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _signingIn ? null : _attemptUnlock,
                icon: _signingIn
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.lock_open_rounded),
                label: Text(_signingIn ? 'Verifying live credentials...' : 'Unlock Panel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10b981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ADMIN MANAGEMENT (MASTER ONLY) ───────────────────────────────────────

  Widget _buildAdminManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Admin',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'As the Master Admin, you can grant other users access to this developer panel. They will be able to verify components.',
            style: TextStyle(color: Color(0xFF94a3b8), fontSize: 13),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1e293b),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _newAdminEmailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'New Admin Email',
                    prefixIcon: Icon(Icons.email, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _newAdminPassController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Temporary Password (6+ chars)',
                    prefixIcon: Icon(Icons.password, size: 20),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: _creatingAdmin ? null : _handleCreateAdmin,
                    icon: _creatingAdmin 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Icon(Icons.person_add_rounded),
                    label: Text(_creatingAdmin ? 'Creating...' : 'Enroll Account as Admin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366f1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          const Text(
            'Current Admins',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          StreamBuilder<List<AdminModel>>(
            stream: _service.getAllAdmins(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF10b981)));
              }
              final admins = snapshot.data ?? [];
              if (admins.isEmpty) return const Text('No admin records found.', style: TextStyle(color: Colors.white54));

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: admins.length,
                itemBuilder: (context, index) {
                  final admin = admins[index];
                  final isMaster = admin.email == AuthService.masterEmail;
                  return Card(
                    color: const Color(0xFF0f172a),
                    shape: RoundedRectangleBorder(side: const BorderSide(color: Color(0xFF334155)), borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      leading: Icon(isMaster ? Icons.star_rounded : Icons.admin_panel_settings_rounded, 
                                    color: isMaster ? const Color(0xFFf59e0b) : const Color(0xFF10b981)),
                      title: Text(admin.email, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      subtitle: Text('Created by: ${admin.createdBy}', style: const TextStyle(color: Color(0xFF64748b), fontSize: 12)),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── DASHBOARD (VERIFICATION) ───────────────────────────────────────────

  Widget _buildDashboard() {
    return StreamBuilder<List<ComponentModel>>(
      stream: _service.getAllComponents(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? [];
        final pending = all.where((c) => !c.adminVerified).toList();
        final verified = all.where((c) => c.adminVerified).toList();
        final today = DateTime.now();
        final verifiedToday = verified.where((c) => c.timestamp.year == today.year && c.timestamp.month == today.month && c.timestamp.day == today.day).length;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_rounded, color: Color(0xFF10b981), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Content Moderation',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stats
                    Row(
                      children: [
                        _DevStatCard(label: 'Pending', value: pending.length.toString(), color: const Color(0xFFf59e0b), icon: Icons.pending_actions_rounded),
                        const SizedBox(width: 10),
                        _DevStatCard(label: 'Verified Today', value: verifiedToday.toString(), color: const Color(0xFF10b981), icon: Icons.task_alt_rounded),
                        const SizedBox(width: 10),
                        _DevStatCard(label: 'Total', value: all.length.toString(), color: const Color(0xFF6366f1), icon: Icons.inventory_2_rounded),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'PENDING APPROVAL',
                      style: TextStyle(color: Color(0xFF94a3b8), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            if (snapshot.connectionState == ConnectionState.waiting)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFF10b981))))
            else if (pending.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 56, color: Color(0xFF10b981)),
                      const SizedBox(height: 16),
                      const Text('All components verified!', style: TextStyle(color: Colors.white, fontSize: 16)),
                      Text('${verified.length} components published', style: const TextStyle(color: Color(0xFF64748b), fontSize: 13)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, index) {
                      final comp = pending[index];
                      return _PendingCard(component: comp, onApprove: () => _verifyComponent(context, comp));
                    },
                    childCount: pending.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      },
    );
  }
}

class _DevStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _DevStatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1e293b),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Color(0xFF64748b), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final ComponentModel component;
  final VoidCallback onApprove;

  const _PendingCard({required this.component, required this.onApprove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: component.mismatchStatus ? const Color(0xFFf59e0b).withOpacity(0.4) : const Color(0xFF334155),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  component.componentName,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              if (component.mismatchStatus)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFf59e0b).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFf59e0b).withOpacity(0.4)),
                  ),
                  child: const Text('⚠️ Mismatch', style: TextStyle(color: Color(0xFFf59e0b), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(Icons.precision_manufacturing_rounded, 'AI Label', component.aiLabel),
          _InfoRow(Icons.person_outline_rounded, 'User Description', component.userDescription),
          _InfoRow(Icons.device_hub_rounded, 'Origin', component.originSource),
          _InfoRow(Icons.calendar_today_rounded, 'Submitted', DateFormat('dd MMM yyyy, HH:mm').format(component.timestamp)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onApprove,
              icon: const Icon(Icons.verified_rounded, size: 18),
              label: const Text('Approve & Publish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10b981),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748b)),
          const SizedBox(width: 6),
          Text('$label: ', style: const TextStyle(color: Color(0xFF64748b), fontSize: 12)),
          Expanded(child: Text(value, style: const TextStyle(color: Color(0xFFcbd5e1), fontSize: 12), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
