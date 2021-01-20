import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text('Joe Doe'),
            accountEmail: Text('joe@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                  ? Colors.blue
                  : Colors.white,
              child: Text(
                "J",
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),

          ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit Ticket'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.list_outlined),
            title: Text('Ticket List'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.fiber_pin_outlined),
            title: Text('Set Pin'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
