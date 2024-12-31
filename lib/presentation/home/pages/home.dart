import 'package:flutter/material.dart';
import 'package:tesis_v2/common/helpers/is_dark_mode.dart';
import 'package:tesis_v2/core/configs/theme/app_colors.dart';
import 'package:tesis_v2/presentation/home/pages/app_info.dart';
import 'package:tesis_v2/presentation/home/widgets/home_top_card.dart';
class HomePage extends StatefulWidget {
  final String fullName;
  const HomePage({Key? key, required this.fullName}) : super(key: key);

    @override
  State<HomePage> createState() => _HomePageState();
}

  class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
    late TabController _tabController;
    
  @override
  void initState(){
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenid@ ${widget.fullName}'),
      ),
      body: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _tabs(),
                SizedBox(
                  height: 600,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      HomeTopCard(),
                      const AppInfo(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
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
        horizontal: 8
      ),
      tabs: const [
        Text(
          'Cuestionario de uso',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16
          ),
        ),
        Text(
          'Informacion de uso',
           style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16
          ),
        )
      ],
    );
  }

}