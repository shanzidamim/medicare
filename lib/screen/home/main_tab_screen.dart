import 'package:flutter/material.dart';
import 'package:medicare/common/color_extension.dart';
import 'package:medicare/common_widget/menu_row.dart';
import 'package:medicare/screen/home/home_tab_screen.dart';
import 'package:medicare/screen/home/medical_chat_app.dart';
import 'package:medicare/screen/home/user_account_edit_screen.dart';
import 'package:medicare/screen/shared_prefs_helper.dart';
import '../../services/api_service.dart';
import '../doctor_appointments_screen.dart';
import '../user_appointments_screen.dart';
import 'doctor_profile_edit_screen.dart';
import 'medical_shop/shop_profile_edit_screen.dart';

class MainTabScreen extends StatefulWidget {
  final String initialDivision;
  final int currentUserId;

  const MainTabScreen({
    super.key,
    required this.initialDivision,
    required this.currentUserId,
  });

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  int selectTab = 0;
  final GlobalKey<ScaffoldState> scaffoldStateKey = GlobalKey();

  String selectedDivision = "Dhaka";
  int userType = 1; // 1=user, 2=doctor, 3=shop
  String userName = "";
  bool loading = true;

  List menuArr = [];

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 3, vsync: this);
    controller.addListener(() => setState(() => selectTab = controller.index));
    _loadUser();
  }

  Future<void> _loadUser() async {
    final session = await SPrefs.readSession();

    // Apply access token again
    final token = session?['access_token'];
    if (token != null && token.isNotEmpty) {
      ApiService().setAccessToken(token);
    }

    setState(() {
      userType = session?['user_type'] ?? 1;
      userName = session?['name'] ?? "User"; // <-- Correct
      selectedDivision = session?['division_name'] ?? widget.initialDivision;
      loading = false;
    });

    // Menu setup based on role
    if (userType == 1) {
      menuArr = [
        {'name': 'My Appointments', 'icon': 'assets/image/appointment.png', 'action': '1'},
        {'name': 'Symptom Checker', 'icon': 'assets/image/chatbot.png', 'action': '2'},
        {'name': 'Account Settings', 'icon': 'assets/image/account_setting.png', 'action': '3'},
        {'name': 'Logout', 'icon': 'assets/image/logout.png', 'action': '4'},
      ];
    } else if (userType == 2) {
      menuArr = [
        {'name': 'My Appointments', 'icon': 'assets/image/appointment.png', 'action': '1'},
        {'name': 'Account Settings', 'icon': 'assets/image/account_setting.png', 'action': '3'},
        {'name': 'Logout', 'icon': 'assets/image/logout.png', 'action': '4'},
      ];
    } else {
      // Shop
      menuArr = [
        {'name': 'Account Settings', 'icon': 'assets/image/account_setting.png', 'action': '3'},
        {'name': 'Logout', 'icon': 'assets/image/logout.png', 'action': '4'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return SafeArea(
      child: Scaffold(
        key: scaffoldStateKey,
        drawer: Drawer(
          width: MediaQuery.of(context).size.width * 0.78,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: TColor.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () => scaffoldStateKey.currentState?.closeDrawer(),
                              icon: const Icon(Icons.close, size: 25, color: Colors.white),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                "assets/image/icons8-user-100.png",
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userType == 1
                                        ? "User - $userName"
                                        : userType == 2
                                        ? "Doctor - $userName"
                                        : "Shop - $userName",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    selectedDivision,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    var obj = menuArr[index];
                    return MenuRow(
                      obj: obj,
                      onPressed: () {
                        scaffoldStateKey.currentState?.closeDrawer();
                        _handleMenuAction(obj['action']);
                      },
                    );
                  },
                  separatorBuilder: (context, index) =>
                  const Divider(color: Colors.black12, height: 2),
                  itemCount: menuArr.length,
                ),
              ),
            ],
          ),
        ),

        appBar: AppBar(
          centerTitle: false,
          leading: IconButton(
            onPressed: () => scaffoldStateKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu, size: 35, color: Colors.white),
          ),
          title: const Text(
            "Medicare",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
          actions: [
            Container(
              alignment: Alignment.center,
              child: InkWell(
                onTap: _selectDivision,
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_outlined, color: TColor.primaryText, size: 15),
                      const SizedBox(width: 8),
                      Text(
                        selectedDivision,
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
                onPressed: () {},
                icon: Icon(Icons.notifications, color: TColor.primary)),
          ],
        ),

        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: controller,
                children: [
                  HomeTabScreen(
                    selectedDivision: selectedDivision,
                    currentUserId: widget.currentUserId,
                  ),
                  const Center(child: Text("Chat Section")),
                  const Center(child: Text("Settings")),
                ],
              ),
            ),
          ],
        ),

        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2))
            ],
          ),
          child: TabBar(
            controller: controller,
            indicatorColor: Colors.transparent,
            tabs: [
              Tab(
                  icon: Image.asset(
                    "assets/image/home_tab_icon.png",
                    width: 32,
                    color: selectTab == 0 ? TColor.primary : TColor.unselect,
                  )),
              Tab(
                  icon: Image.asset(
                    "assets/image/chat_tab_icon.png",
                    width: 32,
                    color: selectTab == 1 ? TColor.primary : TColor.unselect,
                  )),
              Tab(
                  icon: Image.asset(
                    "assets/image/setting_tab_icon.png",
                    width: 32,
                    color: selectTab == 2 ? TColor.primary : TColor.unselect,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDivision() async {
    final divisions = [
      "Dhaka",
      "Chattogram",
      "Rajshahi",
      "Khulna",
      "Barishal",
      "Sylhet",
      "Rangpur",
      "Mymensingh"
    ];
    String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Division"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: divisions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(divisions[index]),
                  onTap: () => Navigator.pop(context, divisions[index]),
                );
              },
            ),
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() => selectedDivision = result);
    }
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case '1':
        if (userType == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserAppointmentsScreen(userId: widget.currentUserId),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DoctorAppointmentsScreen(doctorId: widget.currentUserId),
            ),
          );
        }
        break;

      case '2':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => MedicalChatApp()));
        break;

      case '3':
        if (userType == 1) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const UserAccountEditScreen()));
        } else if (userType == 2) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const DoctorProfileEditScreen()));
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ShopProfileEditScreen()));
        }
        break;

      case '4':
        await SPrefs.clearSession();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        break;

      default:
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Feature coming soon")));
    }
  }
}
