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
  void initState(){
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
      children: [
        Expanded(
          child: Column(
              children: [
                _tabs(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8), // Ajusta los valores según lo necesario
                  child: Text(
                    'A continuación, observarás información de tu uso en redes sociales en un promedio de 7 días',
                    style: TextStyle(
                      color: context.isDarkMode ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      Facebook(),
                      Instagram(),
                      Tiktok(),
                    ],
                  ),
                ),
              ],
            ),
        ),
      ],
    ),
//AppUsageWidget()//FacebookPostsWidget(),
    );
  }
  
    Widget _tabs() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: context.isDarkMode ? Colors.white : Colors.black,
      indicatorColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 10
      ),
      tabs: const [
        Text(
          'Facebook',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16
          ),
        ),
        Text(
          'Instagram',
           style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16
          ),
        ),
        Text(
          'Tiktok',
           style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16
          ),
        )
      ],
    );
  }

}