import 'package:flutter/material.dart';
import 'package:positive_now/app/home.dart';
import 'package:positive_now/models/models.dart';
import 'package:positive_now/providers/afirmacao_provider.dart';
import 'package:positive_now/theme/app_theme.dart';
import 'package:positive_now/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class BibliotecaPage extends StatefulWidget {
  const BibliotecaPage({super.key});

  @override
  State<BibliotecaPage> createState() => _BibliotecaPageState();
}

class _BibliotecaPageState extends State<BibliotecaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  final List<String> _categorias = [
    'todos',
    'anxiety',
    'self_esteem',
    'gratitude',
    'motivation',
    'inner_peace',
    'self_love',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AfirmacaoProvider>(context);
    final localizations = AppLocalizations.of(context);

    debugPrint('📚 BibliotecaPage - Total: ${provider.afirmacoes.length}');
    debugPrint('📚 BibliotecaPage - Favoritos: ${provider.favoritos.length}');
    debugPrint('📚 BibliotecaPage - Histórico: ${provider.historico.length}');

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('library')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: localizations.translate('categories')),
            Tab(text: localizations.translate('favorites')),
            Tab(text: localizations.translate('history')),
          ],
          indicatorColor: AppColors.darkPink,
          labelColor: AppColors.darkPink,
          unselectedLabelColor: AppColors.greyMedium,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCategoriasTab(localizations),
          _buildFavoritosTab(localizations),
          _buildHistoricoTab(provider, localizations),
        ],
      ),
    );
  }

  Widget _buildCategoriasTab(AppLocalizations localizations) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: localizations.translate('search'),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).cardTheme.color,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _categorias.length - 1,
            itemBuilder: (context, index) {
              return _buildCategoriaCard(_categorias[index + 1], localizations);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriaCard(String categoria, AppLocalizations localizations) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoriaDetailPage(categoria: categoria),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryPink, AppColors.lightPink],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                Icons.spa,
                size: 80,
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForCategoria(categoria),
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    localizations.translate(categoria),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Consumer<AfirmacaoProvider>(
                    builder: (context, provider, child) {
                      final count = provider.afirmacoes
                          .where((a) => a.categoria.toLowerCase() == categoria)
                          .length;
                      return Text(
                        '$count ${localizations.translate('affirmations')}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritosTab(AppLocalizations localizations) {
    final provider = Provider.of<AfirmacaoProvider>(context);
    final favoritos = provider.favoritos;

    if (favoritos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: AppColors.greyMedium),
            const SizedBox(height: 16),
            Text(
              localizations.translate('no_favorites'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.translate('no_favorites_subtitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoritos.length,
      itemBuilder: (context, index) {
        final afirmacao = favoritos[index];
        return GestureDetector(
          onTap: () {
            _mostrarAfirmacaoDetalhada(context, afirmacao, provider);
          },
          child: _buildAfirmacaoCard(afirmacao, localizations),
        );
      },
    );
  }

  Widget _buildHistoricoTab(AfirmacaoProvider provider, AppLocalizations localizations) {
    final historico = provider.historico;

    if (historico.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: AppColors.greyMedium),
            const SizedBox(height: 16),
            Text(
              localizations.translate('no_history'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.translate('no_history_subtitle'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: historico.length,
      itemBuilder: (context, index) {
        final item = historico[index];
        return GestureDetector(
          onTap: () {
            _mostrarAfirmacaoDetalhada(context, item.afirmacao, provider);
          },
          child: Container(
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.history, color: AppColors.darkPink),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.translate(item.afirmacao.categoria.toLowerCase()),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.darkPink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '"${item.afirmacao.texto.length > 50 ? '${item.afirmacao.texto.substring(0, 50)}...' : item.afirmacao.texto}"',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${localizations.translate('viewed')} ${_formatarTempo(item.dataVista, localizations)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.greyMedium),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatarTempo(DateTime data, AppLocalizations localizations) {
    final now = DateTime.now();
    final difference = now.difference(data);

    if (difference.inDays > 0) {
      return '${localizations.translate('ago')} ${difference.inDays} ${difference.inDays == 1 ? localizations.translate('day') : localizations.translate('days')}';
    } else if (difference.inHours > 0) {
      return '${localizations.translate('ago')} ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inMinutes > 0) {
      return '${localizations.translate('ago')} ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'agora mesmo';
    }
  }

  void _mostrarAfirmacaoDetalhada(
    BuildContext context,
    Afirmacao afirmacao,
    AfirmacaoProvider provider,
  ) {
    provider.adicionarAoHistorico(afirmacao);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: AfirmacaoDetalhePage(
          afirmacaoInicial: afirmacao,
          provider: provider,
        ),
      ),
    );
  }

  Widget _buildAfirmacaoCard(Afirmacao afirmacao, AppLocalizations localizations) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  localizations.translate(afirmacao.categoria.toLowerCase()),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkPink,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  afirmacao.isFavorita ? Icons.favorite : Icons.favorite_border,
                  color: afirmacao.isFavorita ? Colors.red : AppColors.greyMedium,
                  size: 20,
                ),
                onPressed: () {
                  final provider = Provider.of<AfirmacaoProvider>(
                    context,
                    listen: false,
                  );
                  provider.toggleFavorito(afirmacao);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"${afirmacao.texto}"',
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategoria(String categoria) {
    switch (categoria) {
      case 'anxiety':
        return Icons.psychology_outlined;
      case 'self_esteem':
        return Icons.favorite_outline;
      case 'gratitude':
        return Icons.volunteer_activism;
      case 'motivation':
        return Icons.rocket_launch;
      case 'inner_peace':
        return Icons.spa;
      case 'self_love':
        return Icons.self_improvement;
      default:
        return Icons.star_outline;
    }
  }
}

class CategoriaDetailPage extends StatefulWidget {
  final String categoria;

  const CategoriaDetailPage({super.key, required this.categoria});

  @override
  State<CategoriaDetailPage> createState() => _CategoriaDetailPageState();
}

class _CategoriaDetailPageState extends State<CategoriaDetailPage> {
  List<Afirmacao> _afirmacoes = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AfirmacaoProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.translate(widget.categoria))),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkPink),
              ),
            )
          : _afirmacoes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 60,
                        color: AppColors.greyMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma afirmação encontrada',
                        style: TextStyle(color: AppColors.greyMedium, fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          
                          final resultados = await provider.buscarPorCategoria(widget.categoria);
                          
                          setState(() {
                            _afirmacoes = resultados;
                            _isLoading = false;
                          });
                          
                          if (resultados.isNotEmpty && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${resultados.length} ${localizations.translate('affirmations')} encontradas!'),
                                backgroundColor: AppColors.darkPink,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(localizations.translate('api_no_results')),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkPink,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Buscar da API'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _afirmacoes.length,
                  itemBuilder: (context, index) {
                    final afirmacao = _afirmacoes[index];
                    return GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(30),
                              ),
                            ),
                            child: AfirmacaoDetalhePage(
                              afirmacaoInicial: afirmacao,
                              provider: provider,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryPink.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '"${afirmacao.texto}"',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '- ${afirmacao.autor ?? 'Desconhecido'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.darkPink,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                afirmacao.isFavorita ? Icons.favorite : Icons.favorite_border,
                                color: afirmacao.isFavorita ? Colors.red : AppColors.greyMedium,
                              ),
                              onPressed: () {
                                provider.toggleFavorito(afirmacao);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}