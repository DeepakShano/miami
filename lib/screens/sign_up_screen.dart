import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Text(
              'Water Taxi Miami',
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  .copyWith(color: Colors.black87),
            ),
            SizedBox(height: 40),
            Text(
              'SIGN UP',
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .copyWith(color: Colors.black87),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: signUpForm(context),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: RaisedButton(
                  child: Text('Sign Up'),
                  onPressed: () {},
                  textColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: FlatButton(
                  child: Text('Go Back'),
                  onPressed: () {
                   Navigator.pop(context);
                  },
                  textColor: Theme.of(context).primaryColor,
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget signUpForm(BuildContext context) {

    final node = FocusScope.of(context);

    return Form(
      child: Column(
        children: [
          TextField(
            controller: _firstNameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Full Name',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).hintColor,
                  width: 1,
                ),
              ),
            ),
            textInputAction: TextInputAction.next,
            onEditingComplete: () => node.nextFocus(),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Phone Number',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).hintColor,
                  width: 1,
                ),
              ),
            ),
            textInputAction: TextInputAction.next,
            onEditingComplete: () => node.nextFocus(),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Email Address',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Theme.of(context).hintColor,
                  width: 1,
                ),
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => node.unfocus(),
          ),
        ],
      ),
    );
  }
}
