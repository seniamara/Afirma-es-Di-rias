import 'package:flutter/material.dart';
import 'package:positive_now/app/biblioteca.dart';
import 'package:positive_now/app/perfil.dart';
import 'package:positive_now/app/progresso.dart';
import 'package:positive_now/models/models.dart';
import 'package:positive_now/providers/afirmacao_provider.dart';
import 'package:positive_now/theme/app_theme.dart';
import 'package:positive_now/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomePage(),
    const BibliotecaPage(),
    const ProgressoPage(),
    const PerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).cardTheme.color,
          selectedItemColor: AppColors.darkPink,
          unselectedItemColor: AppColors.greyMedium,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Biblioteca',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Progresso',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int? _selectedHumor;
  bool _showCheckin = true;
  Timer? _timer;

  final List<Map<String, dynamic>> _emojis = [
    {'emoji': '😊', 'label': 'happy', 'color': AppColors.happyYellow},
    {'emoji': '😌', 'label': 'calm', 'color': AppColors.calmBlue},
    {'emoji': '😐', 'label': 'neutral', 'color': AppColors.neutralGrey},
    {'emoji': '😔', 'label': 'sad', 'color': AppColors.sadPurple},
    {'emoji': '😰', 'label': 'anxious', 'color': AppColors.anxiousOrange},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _timer = Timer.periodic(const Duration(hours: 1), (timer) {
      if (mounted) {
        _checkTodayCheckin();
      }
    });
  }

  void _checkTodayCheckin() {
    if (!mounted) return;
    
    try {
      final provider = Provider.of<AfirmacaoProvider>(context, listen: false);
      final hoje = DateTime.now().day;
      final registrosHoje = provider.registrosHumor.where((r) => 
        r.data.day == hoje && 
        r.data.month == DateTime.now().month && 
        r.data.year == DateTime.now().year
      ).toList();
      
      setState(() {
        _showCheckin = registrosHoje.isEmpty;
      });
    } catch (e) {
      debugPrint('Provider não disponível ainda: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkTodayCheckin();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final afirmacaoProvider = Provider.of<AfirmacaoProvider>(context);
    final localizations = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    if (afirmacaoProvider.isLoading && afirmacaoProvider.afirmacaoDoDia == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkPink),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Início'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await afirmacaoProvider.refreshFromApi();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(localizations.translate('affirmations_updated')),
                    backgroundColor: AppColors.darkPink,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saudação
            Text(
              localizations.translate('hello'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              localizations.translate('how_feeling'),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            
            const SizedBox(height: 24),
            
            // Afirmação do dia
            if (afirmacaoProvider.afirmacaoDoDia != null)
              GestureDetector(
                onTap: () {
                  _mostrarAfirmacaoDetalhada(
                    context, 
                    afirmacaoProvider.afirmacaoDoDia!,
                    afirmacaoProvider,
                    localizations
                  );
                },
                child: _buildAfirmacaoCard(afirmacaoProvider.afirmacaoDoDia!, size, afirmacaoProvider),
              ),
            
            const SizedBox(height: 24),
            
            // Check-in de humor
            if (_showCheckin)
              _buildCheckinCard(afirmacaoProvider, localizations),
            
            const SizedBox(height: 24),
            
            // Próxima afirmação
            _buildProximaAfirmacao(afirmacaoProvider, localizations),
            
            const SizedBox(height: 24),
            
            // Categorias populares
            Text(
              localizations.translate('popular_categories'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildCategoriasGrid(afirmacaoProvider, localizations),
          ],
        ),
      ),
    );
  }

  void _mostrarAfirmacaoDetalhada(
    BuildContext context, 
    Afirmacao afirmacao, 
    AfirmacaoProvider provider,
    AppLocalizations localizations
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
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyMedium,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: AfirmacaoDetalhePage(
                afirmacaoInicial: afirmacao,
                provider: provider,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAfirmacaoCard(Afirmacao afirmacao, Size size, AfirmacaoProvider provider) {
    final localizations = AppLocalizations.of(context);
    
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryPink,
                    AppColors.darkPink,
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          localizations.translate('affirmation_of_day'),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          afirmacao.isFavorita
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          provider.toggleFavorito(afirmacao);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '"${afirmacao.texto}"',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.spa,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        localizations.translate(afirmacao.categoria.toLowerCase()),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckinCard(AfirmacaoProvider provider, AppLocalizations localizations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
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
            children: [
              Expanded(
                child: Text(
                  localizations.translate('feeling'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _showCheckin = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _emojis.map((emojiData) {
              final index = _emojis.indexOf(emojiData);
              final isSelected = _selectedHumor == index;
              
              return GestureDetector(
                onTap: () async {
                  setState(() {
                    _selectedHumor = index;
                  });
                  
                  await provider.registrarHumor(index + 1);
                  
                  setState(() {
                    _showCheckin = false;
                  });
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${localizations.translate('mood_registered')}: ${localizations.translate(emojiData['label'])}'),
                        backgroundColor: AppColors.primaryPink,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.8, end: 1),
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  curve: Curves.elasticOut,
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: isSelected ? 1.2 : value,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? (emojiData['color'] as Color).withOpacity(0.2)
                              : Colors.transparent,
                        ),
                        child: Text(
                          emojiData['emoji'] as String,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProximaAfirmacao(AfirmacaoProvider provider, AppLocalizations localizations) {
    return GestureDetector(
      onTap: () {
        provider.gerarProximaAfirmacao();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.translate('new_affirmation')),
            backgroundColor: AppColors.darkPink,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryPink.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryPink.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.timer_outlined,
                color: AppColors.darkPink,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('next_affirmation'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizations.translate('tap_to_generate'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkPink,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.greyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriasGrid(AfirmacaoProvider provider, AppLocalizations localizations) {
    final categorias = [
      'anxiety',
      'self_esteem',
      'gratitude',
      'motivation',
      'inner_peace',
      'self_love',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categorias.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoriaDetailPage(categoria: categorias[index]),
              ),
            );
          },
          child: Container(
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
                    color: AppColors.primaryPink.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForCategoria(categorias[index]),
                    color: AppColors.darkPink,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  localizations.translate(categorias[index]),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

class AfirmacaoDetalhePage extends StatefulWidget {
  final Afirmacao afirmacaoInicial;
  final AfirmacaoProvider provider;

  const AfirmacaoDetalhePage({
    super.key,
    required this.afirmacaoInicial,
    required this.provider,
  });

  @override
  State<AfirmacaoDetalhePage> createState() => _AfirmacaoDetalhePageState();
}

class _AfirmacaoDetalhePageState extends State<AfirmacaoDetalhePage> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late List<Afirmacao> _afirmacoesDaCategoria;
  int _currentIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _carregarAfirmacoesDaCategoria();
  }

  void _carregarAfirmacoesDaCategoria() {
    _afirmacoesDaCategoria = widget.provider.afirmacoes
        .where((a) => a.categoria.toLowerCase() == widget.afirmacaoInicial.categoria.toLowerCase())
        .toList();
    
    if (_afirmacoesDaCategoria.isEmpty) {
      _afirmacoesDaCategoria = [widget.afirmacaoInicial];
    }
    
    _currentIndex = _afirmacoesDaCategoria.indexWhere(
      (a) => a.id == widget.afirmacaoInicial.id
    );
    if (_currentIndex == -1) _currentIndex = 0;
  }

  void _proximaAfirmacao() {
    if (_currentIndex < _afirmacoesDaCategoria.length - 1) {
      _animationController.forward(from: 0).then((_) {
        setState(() {
          _currentIndex++;
        });
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _afirmacaoAnterior() {
    if (_currentIndex > 0) {
      _animationController.forward(from: 0).then((_) {
        setState(() {
          _currentIndex--;
        });
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    if (_afirmacoesDaCategoria.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: AppColors.greyMedium),
            const SizedBox(height: 16),
            Text(
              'Nenhuma afirmação encontrada',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.greyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  localizations.translate(_afirmacoesDaCategoria[_currentIndex].categoria.toLowerCase()),
                  style: const TextStyle(
                    color: AppColors.darkPink,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _afirmacoesDaCategoria[_currentIndex].isFavorita
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: _afirmacoesDaCategoria[_currentIndex].isFavorita
                          ? Colors.red
                          : AppColors.darkPink,
                    ),
                    onPressed: () {
                      widget.provider.toggleFavorito(
                        _afirmacoesDaCategoria[_currentIndex]
                      );
                      setState(() {});
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: AppColors.darkPink),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Compartilhar em breve!'),
                          backgroundColor: AppColors.darkPink,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _afirmacoesDaCategoria.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final afirmacao = _afirmacoesDaCategoria[index];
              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.9 + (_animationController.value * 0.1),
                    child: Opacity(
                      opacity: 0.8 + (_animationController.value * 0.2),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryPink,
                        AppColors.darkPink,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkPink.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(
                        '"${afirmacao.texto}"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentIndex > 0)
                ElevatedButton(
                  onPressed: _afirmacaoAnterior,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColors.darkPink,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: AppColors.darkPink),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back, size: 20),
                      const SizedBox(width: 4),
                      Text(localizations.translate('back')),
                    ],
                  ),
                )
              else
                const SizedBox(width: 100),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '${_currentIndex + 1} de ${_afirmacoesDaCategoria.length}',
                  style: const TextStyle(
                    color: AppColors.darkPink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              if (_currentIndex < _afirmacoesDaCategoria.length - 1)
                ElevatedButton(
                  onPressed: _proximaAfirmacao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(localizations.translate('next')),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                )
              else
                const SizedBox(width: 100),
            ],
          ),
        ),
      ],
    );
  }
}