import 'package:flutter/material.dart';
import 'package:ft_chat/pages/profile_page.dart';
import 'package:ft_chat/pages/recent_conversations_page.dart';
import 'package:ft_chat/pages/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late double height;
  late double width;
  _HomePageState() {
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: _tabBarPages(),
      appBar: _buildAppBar(),
      // bottomNavigationBar:  TODO you can  add here tabs
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        "Chat",
        style: TextStyle(fontSize: 16),
      ),
      centerTitle: true,
      bottom: _buildTabBar(),
    );
  }

  TabBar _buildTabBar() {
    return TabBar(
      unselectedLabelColor: Colors.grey,
      indicatorColor: Colors.blue,
      labelColor: Colors.blue,
      controller: _tabController,
      tabs: [
        Tab(
          icon: Icon(
            Icons.people_alt_outlined,
            size: 25,
          ),
        ),
        Tab(
          icon: Icon(
            Icons.chat_bubble_outline,
            size: 25,
          ),
        ),
        Tab(
          icon: Icon(
            Icons.person_outlined,
            size: 25,
          ),
        )
      ],
    );
  }

  Widget _tabBarPages() {
    return TabBarView(controller: _tabController, children: [
      SearchPage(width: width, height: height),
      RecentConversationsPage(width: width, height: height),
      ProfilePage(width: width, height: height),
    ]);
  }
}
