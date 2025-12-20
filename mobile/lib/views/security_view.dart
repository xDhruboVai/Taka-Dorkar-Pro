import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/security_controller.dart';
import '../models/spam_message.dart';
import 'package:intl/intl.dart';
import '../widgets/app_theme.dart';

class SecurityView extends StatefulWidget {
  const SecurityView({super.key});

  @override
  State<SecurityView> createState() => _SecurityViewState();
}

class _SecurityViewState extends State<SecurityView> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SecurityController>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<SecurityController>(
        builder: (context, controller, child) {
          final isProtected = controller.isMonitoring && controller.isModelLoaded;
          
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(isProtected, controller),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainStats(controller),
                      const SizedBox(height: 24),
                      _buildDiagnosticSection(controller),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Incoming Messages',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1C1E),
                            ),
                          ),
                          TextButton(
                            onPressed: () => controller.loadData(forceRefresh: true),
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.messages.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Your inbox is clean',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildMessageCard(context, controller.messages[index], controller),
                      childCount: controller.messages.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(bool isProtected, SecurityController controller) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: isProtected ? AppTheme.primaryColor : Colors.grey[800],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isProtected
                  ? [AppTheme.primaryColor, AppTheme.accentColor]
                  : [Colors.grey[800]!, Colors.grey[900]!],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildShieldIcon(isProtected),
              const SizedBox(height: 16),
              Text(
                isProtected ? 'Active Protection' : 'Protection Disabled',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isProtected 
                  ? 'Your SMS are being monitored by AI'
                  : 'Enable monitoring to stay secure',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => controller.toggleMonitoring(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isProtected ? Colors.white : AppTheme.primaryColor,
                  foregroundColor: isProtected ? AppTheme.primaryColor : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(isProtected ? 'Turn Off' : 'Turn On Shield'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShieldIcon(bool active) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        Icon(
          active ? Icons.shield : Icons.shield_outlined,
          size: 60,
          color: Colors.white,
        ),
        if (active)
          const Positioned(
            right: 0,
            bottom: 0,
            child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 24),
          ),
      ],
    );
  }

  Widget _buildMainStats(SecurityController controller) {
    final stats = controller.stats;
    if (stats == null) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'High Threat',
            stats.highThreat.toString(),
            Icons.gpp_maybe,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Blocked',
            stats.total.toString(),
            Icons.block,
            Colors.grey[800]!,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1E),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticSection(SecurityController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        title: const Text(
          'Diagnostic Center',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Model Status: ${controller.isModelLoaded ? "Ready" : "Loading..."}',
          style: TextStyle(fontSize: 12, color: controller.isModelLoaded ? Colors.green : Colors.orange),
        ),
        leading: Icon(
          Icons.analytics_outlined,
          color: AppTheme.primaryColor,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _buildDiagnosticRow('AI Model Loaded', controller.isModelLoaded),
                _buildDiagnosticRow('SMS Monitoring', controller.isMonitoring),
                FutureBuilder<bool>(
                  future: controller.hasSmsPermission,
                  builder: (context, snapshot) => _buildDiagnosticRow('SMS Permission', snapshot.data ?? false),
                ),
                FutureBuilder<bool>(
                  future: controller.hasNotificationPermission,
                  builder: (context, snapshot) => _buildDiagnosticRow('Notification Permission', snapshot.data ?? false),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => controller.loadData(forceRefresh: true),
                    child: const Text('Run Heartbeat Check'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticRow(String label, bool success) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Icon(
            success ? Icons.check_circle : Icons.error,
            size: 18,
            color: success ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context, SpamMessage msg, SecurityController controller) {
    final severityColor = msg.threatLevel == 'high' 
        ? Colors.red 
        : msg.threatLevel == 'medium' ? Colors.orange : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: severityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.warning_amber_rounded, color: severityColor),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                msg.phoneNumber,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (!msg.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              msg.messageText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[800], fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  DateFormat('MMM d, h:mm a').format(msg.detectedAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    msg.threatLevel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: severityColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'read', child: Text('Mark as Read')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) {
            if (value == 'read') controller.markAsRead(msg.id!);
            if (value == 'delete') controller.deleteMessage(msg.id!);
          },
        ),
      ),
    );
  }
}
