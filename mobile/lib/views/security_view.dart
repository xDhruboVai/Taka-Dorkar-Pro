import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/security_controller.dart';
import '../models/spam_message.dart';
import 'package:intl/intl.dart';

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
          final isProtected = controller.isMonitoring;

          return CustomScrollView(
            slivers: [
              _buildAppBar(isProtected, controller),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAiStatusCard(isProtected),
                      const SizedBox(height: 24),
                      _buildStatsGrid(controller),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Activity',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1C1E),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () =>
                                controller.loadData(forceRefresh: true),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.messages.isEmpty)
                _buildEmptyState()
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildMessageCard(
                        context,
                        controller.messages[index],
                      ),
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

  Widget _buildAppBar(bool isProtected, SecurityController controller) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: true,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: isProtected
          ? const Color(0xFF006C4C)
          : const Color(0xFFB3261E),
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          children: [
            Icon(
              isProtected ? Icons.gpp_good : Icons.gpp_bad,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text('Security Center'),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isProtected
                  ? [const Color(0xFF006C4C), const Color(0xFF008F64)]
                  : [const Color(0xFFB3261E), const Color(0xFFDC362E)],
            ),
          ),
        ),
      ),
      actions: [
        Switch(
          value: isProtected,
          onChanged: (_) => controller.toggleMonitoring(),
          activeThumbColor: Colors.white,
          activeTrackColor: Colors.white.withValues(alpha: 0.3),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildAiStatusCard(bool isProtected) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.psychology,
              color: Color(0xFF006C4C),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isProtected ? 'Local AI Active' : 'Protection Paused',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C1E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isProtected
                      ? 'Hybrid detection enabled. Scanning for threats in real-time.'
                      : 'Enable monitoring to protect your inbox.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(SecurityController controller) {
    final stats = controller.stats;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Scanned',
            '${stats?.totalScanned ?? 0}',
            Icons.radar,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Threats',
            '${stats?.threatsBlocked ?? 0}',
            Icons.block,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1E),
            ),
          ),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No threats detected',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(BuildContext context, SpamMessage message) {
    final isHighRisk = message.threatLevel == 'high';
    final color = isHighRisk ? Colors.red : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(
            isHighRisk ? Icons.warning_amber : Icons.info_outline,
            color: color,
          ),
        ),
        title: Text(
          message.phoneNumber,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message.messageText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    message.threatLevel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM d, h:mm a').format(message.detectedAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Full Message:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(message.messageText),
                const SizedBox(height: 16),
                const Text(
                  'AI Analysis:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Confidence: ${(message.mlConfidence! * 100).toStringAsFixed(1)}%',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                // If we had a reason field in SpamMessage, we would show it here
              ],
            ),
          ),
        ],
      ),
    );
  }
}
