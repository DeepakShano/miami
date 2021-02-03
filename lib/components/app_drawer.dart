import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_taxi_miami/models/app_user.dart';
import 'package:water_taxi_miami/providers/app_user_provider.dart';
import 'package:water_taxi_miami/screens/booking_list_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppUser user = context.watch<AppUserProvider>().appUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(user?.name ?? '-'),
            accountEmail: Text(user?.phone ?? user?.email ?? '-'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                  ? Colors.blue
                  : Colors.white,
              child: Text(
                "${user?.name?.characters?.first ?? 'U'}",
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          // ListTile(
          //   leading: Icon(Icons.edit_outlined),
          //   title: Text('Edit Ticket'),
          //   onTap: () {},
          // ),
          ListTile(
            leading: Icon(Icons.list_outlined),
            title: Text('Ticket List'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingListScreen(),
                ),
              );
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.fiber_pin_outlined),
          //   title: Text('Set Pin'),
          //   onTap: () {},
          // ),
        ],
      ),
    );
  }
}
