import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:positive_now/models/models.dart';
import 'package:positive_now/theme/app_theme.dart';
import 'package:positive_now/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/afirmacao_provider.dart';

class ProgressoPage extends StatefulWidget {
  const ProgressoPage({super.key});

  @override
  State<ProgressoPage> createState() => _ProgressoPageState();
}

class _ProgressoPageState extends State<ProgressoPage> {
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  String _selectedPeriod = 'month';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AfirmacaoProvider>(context);
    final localizations = AppLocalizations.of(context);
    final registros = _getRegistrosPorPeriodo(provider);
    final streak = provider.streakAtual;
    final categoriasMaisUsadas = provider.categoriasMaisUsadas;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('my_progress')),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: _selecionarMes,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seletor de período
            _buildPeriodSelector(localizations),
            
            const SizedBox(height: 24),
            
            // Streak Card
            _buildStreakCard(streak, localizations),
            
            const SizedBox(height: 24),
            
            // Gráfico de humor
            Text(
              localizations.translate('mood_evolution'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildHumorChart(registros, localizations),
            
            const SizedBox(height: 24),
            
            // Estatísticas
            Text(
              localizations.translate('statistics'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildStatisticsCards(registros, localizations),
            
            const SizedBox(height: 24),
            
            // Categorias mais usadas
            Text(
              localizations.translate('most_used_categories'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildCategoriasList(categoriasMaisUsadas, localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildPeriodOption(localizations.translate('week'), 'week'),
          _buildPeriodOption(localizations.translate('month'), 'month'),
          _buildPeriodOption(localizations.translate('year'), 'year'),
        ],
      ),
    );
  }

  Widget _buildPeriodOption(String label, String value) {
    final isSelected = _selectedPeriod == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [AppColors.primaryPink, AppColors.darkPink],
                  )
                : null,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  List<RegistroHumor> _getRegistrosPorPeriodo(AfirmacaoProvider provider) {
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return provider.registrosHumor
            .where((r) => r.data.isAfter(weekAgo))
            .toList();
      case 'month':
        final monthAgo = DateTime(now.year, now.month, 1);
        return provider.registrosHumor
            .where((r) => r.data.isAfter(monthAgo))
            .toList();
      case 'year':
        final yearAgo = DateTime(now.year - 1, now.month, now.day);
        return provider.registrosHumor
            .where((r) => r.data.isAfter(yearAgo))
            .toList();
      default:
        return provider.getRegistrosHumorDoMes();
    }
  }

  Widget _buildStreakCard(int streak, AppLocalizations localizations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange,
            Colors.deepOrange,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.translate('current_streak'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '$streak',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    streak == 1 
                        ? localizations.translate('day')
                        : localizations.translate('days'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Text(
                localizations.translate('consecutive'),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHumorChart(List<RegistroHumor> registros, AppLocalizations localizations) {
    if (registros.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart,
                size: 60,
                color: AppColors.greyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                localizations.translate('no_mood_data'),
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.greyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final Map<String, double> humorPorData = {};
    final dateFormat = DateFormat(_selectedPeriod == 'year' ? 'MMM' : 'dd/MM');
    
    for (var registro in registros) {
      final dataKey = dateFormat.format(registro.data);
      humorPorData[dataKey] = registro.humor.toDouble();
    }

    final spots = humorPorData.entries.map((e) {
      return FlSpot(
        humorPorData.keys.toList().indexOf(e.key).toDouble(),
        e.value,
      );
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryPink.withOpacity(0.1),
            AppColors.darkPink.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.greyLight.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: AppColors.greyLight.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 1: return const Text('😰', style: TextStyle(fontSize: 12));
                    case 2: return const Text('😔', style: TextStyle(fontSize: 12));
                    case 3: return const Text('😐', style: TextStyle(fontSize: 12));
                    case 4: return const Text('😌', style: TextStyle(fontSize: 12));
                    case 5: return const Text('😊', style: TextStyle(fontSize: 12));
                    default: return const Text('');
                  }
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < humorPorData.keys.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        humorPorData.keys.elementAt(value.toInt()),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: AppColors.greyLight.withOpacity(0.3)),
          ),
          minX: 0,
          maxX: (humorPorData.length - 1).toDouble(),
          minY: 0.5,
          maxY: 5.5,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.darkPink,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.darkPink,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primaryPink.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(List<RegistroHumor> registros, AppLocalizations localizations) {
    if (registros.isEmpty) {
      return const SizedBox.shrink();
    }

    final mediaHumor = registros.map((r) => r.humor).reduce((a, b) => a + b) / registros.length;
    final humorMaisFrequente = _getHumorMaisFrequente(registros);
    final melhorHumor = registros.map((r) => r.humor).reduce((a, b) => a > b ? a : b);
    final piorHumor = registros.map((r) => r.humor).reduce((a, b) => a < b ? a : b);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          localizations.translate('average'),
          mediaHumor.toStringAsFixed(1),
          Icons.analytics,
          Colors.blue,
        ),
        _buildStatCard(
          localizations.translate('most_frequent'),
          humorMaisFrequente,
          Icons.emoji_emotions,
          Colors.green,
        ),
        _buildStatCard(
          localizations.translate('best_day'),
          _getHumorEmoji(melhorHumor),
          Icons.thumb_up,
          Colors.orange,
        ),
        _buildStatCard(
          localizations.translate('worst_day'),
          _getHumorEmoji(piorHumor),
          Icons.thumb_down,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriasList(Map<String, int> categorias, AppLocalizations localizations) {
    if (categorias.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.category,
                size: 60,
                color: AppColors.greyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                localizations.translate('no_categories'),
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.greyMedium,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final total = categorias.values.reduce((a, b) => a + b);
    final List<MapEntry<String, int>> sortedEntries = categorias.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries.map((entry) {
        final percentual = (entry.value / total * 100);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryPink,
                          AppColors.darkPink,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        localizations.translate(entry.key.toLowerCase())[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.translate(entry.key.toLowerCase()),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${entry.value} ${entry.value == 1 ? localizations.translate('times') : localizations.translate('times')}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${percentual.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkPink,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: entry.value / total,
                  minHeight: 8,
                  backgroundColor: AppColors.greyLight,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryPink,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getHumorMaisFrequente(List<RegistroHumor> registros) {
    final contagem = <int, int>{};
    for (var registro in registros) {
      contagem[registro.humor] = (contagem[registro.humor] ?? 0) + 1;
    }
    
    final maisFrequente = contagem.entries.reduce((a, b) => 
      a.value > b.value ? a : b
    ).key;
    
    return _getHumorEmoji(maisFrequente);
  }

  String _getHumorEmoji(int humor) {
    switch (humor) {
      case 1: return '😰';
      case 2: return '😔';
      case 3: return '😐';
      case 4: return '😌';
      case 5: return '😊';
      default: return '😐';
    }
  }

  Future<void> _selecionarMes() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, _selectedMonth),
      firstDate: DateTime(2024, 1),
      lastDate: DateTime(now.year, now.month),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.darkPink,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedMonth = selected.month;
        _selectedYear = selected.year;
      });
    }
  }
}