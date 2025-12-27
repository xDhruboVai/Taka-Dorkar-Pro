import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mobile/controllers/analysis_controller.dart';
import 'package:mobile/controllers/transaction_controller.dart';
import 'package:mobile/controllers/account_controller.dart';

class AnalysisView extends StatefulWidget {
  const AnalysisView({super.key});

  @override
  State<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends State<AnalysisView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tx = context.read<TransactionController>().transactions;
      final accounts = context.read<AccountController>().accounts;
      context.read<AnalysisController>().updateData(
        transactions: tx,
        accounts: accounts,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final analysis = context.watch<AnalysisController>();
    final currency = NumberFormat.currency(symbol: '৳', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Analysis'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _RangeSelector(
              range: analysis.range,
              onChanged: analysis.setRange,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _KpiRow(
              income: currency.format(analysis.incomeTotal),
              expense: currency.format(analysis.expenseTotal),
              net: currency.format(analysis.netTotal),
              avgDaily: currency.format(analysis.averageDailyExpense),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Spend Trend',
              child: _LineTrend(
                expenseTrend: analysis.expenseTrend,
                range: analysis.range,
                currency: currency,
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Category Breakdown',
              child: _PieBreakdown(
                data: analysis.categoryBreakdown,
                currency: currency,
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Income vs Expense',
              child: _BarIncomeExpense(
                income: analysis.incomeTotal,
                expense: analysis.expenseTotal,
                currency: currency,
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Savings Progress',
              child: _SavingsProgress(
                savings: analysis.savingsTotal,
                spendable: analysis.spendableTotal,
                currency: currency,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.easeInOutBack,
            switchOutCurve: Curves.easeInOutBack,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  final TimeRange range;
  final ValueChanged<TimeRange> onChanged;
  const _RangeSelector({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _pill(context, 'Daily', TimeRange.daily),
          _pill(context, 'Weekly', TimeRange.weekly),
          _pill(context, 'Monthly', TimeRange.monthly),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, String label, TimeRange value) {
    final selected = range == value;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(6),
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected ? const Color(0xFFD30022) : Colors.grey.shade100,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onChanged(value),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final String income;
  final String expense;
  final String net;
  final String avgDaily;
  const _KpiRow({
    required this.income,
    required this.expense,
    required this.net,
    required this.avgDaily,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _kpiCard('Income', income, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _kpiCard('Expense', expense, Colors.red)),
      ],
    );
  }

  Widget _kpiCard(String label, String value, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.12), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _LineTrend extends StatelessWidget {
  final Map<DateTime, double> expenseTrend;
  final TimeRange range;
  final NumberFormat currency;
  const _LineTrend({
    required this.expenseTrend,
    required this.range,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    if (expenseTrend.isEmpty) {
      return const SizedBox(height: 180, child: Center(child: Text('No data')));
    }
    final keys = expenseTrend.keys.toList()..sort((a, b) => a.compareTo(b));
    final spots = <FlSpot>[];
    for (var i = 0; i < keys.length; i++) {
      spots.add(FlSpot(i.toDouble(), expenseTrend[keys[i]] ?? 0));
    }

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Text(
                      currency.format(value),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= keys.length)
                    return const SizedBox.shrink();
                  final d = keys[idx];
                  final label = range == TimeRange.monthly
                      ? '${d.day}'
                      : '${d.month}/${d.day}';
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(label, style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItems: (items) => items.map((s) {
                final d = keys[s.x.toInt()];
                return LineTooltipItem(
                  '${d.month}/${d.day}\n${currency.format(s.y)}',
                  const TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFFD30022),
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD30022).withValues(alpha: 0.30),
                    const Color(0xFFD30022).withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              dotData: FlDotData(show: true),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutQuart,
      ),
    );
  }
}

class _PieBreakdown extends StatelessWidget {
  final Map<String, double> data;
  final NumberFormat currency;
  const _PieBreakdown({required this.data, required this.currency});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No expenses')),
      );
    }
    final total = data.values.fold<double>(0, (s, v) => s + v);
    final sections = <PieChartSectionData>[];
    final colors = [
      Colors.teal,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.green,
      Colors.indigo,
    ];
    var i = 0;
    data.forEach((k, v) {
      final pct = (v / total) * 100;
      sections.add(
        PieChartSectionData(
          color: colors[i % colors.length],
          value: v,
          title: '${pct.toStringAsFixed(0)}%\n${currency.format(v)}',
          titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
          radius: 60,
        ),
      );
      i++;
    });

    return SizedBox(
      height: 240,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: sections,
        ),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutCubicEmphasized,
      ),
    );
  }
}

class _BarIncomeExpense extends StatelessWidget {
  final double income;
  final double expense;
  final NumberFormat currency;
  const _BarIncomeExpense({
    required this.income,
    required this.expense,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final label = value.toInt() == 0 ? 'Income' : 'Expense';
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(label),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: income,
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: expense,
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ],
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final label = group.x == 0 ? 'Income' : 'Expense';
                return BarTooltipItem(
                  '$label\n${currency.format(rod.toY)}',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutQuart,
      ),
    );
  }
}

class _SavingsProgress extends StatelessWidget {
  final double savings;
  final double spendable;
  final NumberFormat currency;
  const _SavingsProgress({
    required this.savings,
    required this.spendable,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final total = savings + spendable;
    final pct = total == 0 ? 0.0 : (savings / total);
    return SizedBox(
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    color: Colors.green,
                    value: savings,
                    title: '',
                  ),
                  PieChartSectionData(
                    color: Colors.grey.shade300,
                    value: spendable,
                    title: '',
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOutBack,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(pct * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text('${currency.format(savings)} / ${currency.format(total)}'),
            ],
          ),
        ],
      ),
    );
  }
}
