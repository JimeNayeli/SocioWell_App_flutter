import 'package:flutter/material.dart';
import 'package:tesis_v2/common/helpers/is_dark_mode.dart';
import 'package:tesis_v2/core/configs/theme/app_colors.dart';
import 'package:tesis_v2/presentation/home/widgets/Instagram.dart';
import 'package:tesis_v2/presentation/home/widgets/facebook.dart';
import 'package:tesis_v2/presentation/home/widgets/tiktok.dart';
class AppInfo extends StatefulWidget {
  const AppInfo({Key? key}) : super(key: key);

  @override
  State<AppInfo> createState() => _AppInfoState();
}

class _AppInfoState extends State<AppInfo> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _tabs(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                  child: Text(
                    'A continuación, observarás información de tu uso en redes sociales de los últimos 4 días',
                    style: TextStyle(
                      color: context.isDarkMode ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: const [
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Facebook(),
                        SizedBox(height: 20), // Espacio adicional al final
                      ],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Instagram(),
                        SizedBox(height: 20), // Espacio adicional al final
                      ],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Tiktok(),
                        SizedBox(height: 20), // Espacio adicional al final
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _tabs() {
    return Container(
      margin: const EdgeInsets.only(top: 10), // Margen superior adicional
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: context.isDarkMode ? Colors.white : Colors.black,
        indicatorColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          vertical: 25,
          horizontal: 10
        ),
        tabs: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Facebook',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Instagram',
               style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Tiktok',
               style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15
              ),
            ),
          ),
        ],
      ),
    );
  }
}