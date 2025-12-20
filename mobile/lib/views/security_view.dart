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
    // Load data when view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SecurityController>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<SecurityController>().loadData(),
          ),
        ],
      ),
      body: Consumer<SecurityController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: controller.loadData,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (controller.stats != null) _buildStatsCard(controller.stats!),
                const SizedBox(height: 20),
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (controller.messages.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('No security threats detected'),
                    ),
                  )
                else
                  ...controller.messages.map((msg) => _buildMessageTile(context, msg, controller)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(SecurityStats stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', stats.total.toString(), Colors.blue),
                _buildStatItem('High Risk', stats.highThreat.toString(), Colors.red),
                _buildStatItem('Today', stats.today.toString(), Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageTile(BuildContext context, SpamMessage msg, SecurityController controller) {
    Color riskColor;
    switch (msg.threatLevel.toLowerCase()) {
      case 'high':
        riskColor = Colors.red;
        break;
      case 'medium':
        riskColor = Colors.orange;
        break;
      default:
        riskColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: riskColor.withOpacity(0.1),
          child: Icon(Icons.security, color: riskColor),
        ),
        title: Text(
          msg.phoneNumber,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.messageText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM d, h:mm a').format(msg.detectedAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => controller.deleteMessage(msg.id!),
        ),
        isThreeLine: true,
      ),
    );
  }
}
