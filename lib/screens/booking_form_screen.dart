import 'package:flutter/material.dart';

enum BookingType {
  NEW_BOOKING,
  UPDATE_BOOKING,
}

class BookingFormScreen extends StatelessWidget {
  final BookingType bookingType;

  BookingFormScreen({Key key, this.bookingType}) : super(key: key);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _adultCountController = TextEditingController();
  final TextEditingController _minorCountController = TextEditingController();
  final TextEditingController _departureTimeController =
      TextEditingController();
  final TextEditingController _returnTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          bookingType == BookingType.NEW_BOOKING
              ? 'New Booking'
              : 'Update Booking',
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            children: [
              form(context),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width,
                child: RaisedButton(
                  child: Text('Submit'),
                  onPressed: () {},
                  textColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget form(BuildContext context) {
    final node = FocusScope.of(context);

    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Full Name',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          SizedBox(height: 10),
          TextField(
            controller: _nameController,
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
          Text(
            'Customer Phone Number',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          SizedBox(height: 10),
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
          Text(
            'Customer Email',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          SizedBox(height: 10),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Email',
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
          SizedBox(height: 20),
          Text(
            'Departing Time BS',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          SizedBox(height: 10),
          TextField(
            controller: _departureTimeController,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              hintText: '00:00 AM',
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
          SizedBox(height: 20),
          Text(
            'Departing Time MB',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          SizedBox(height: 10),
          TextField(
            controller: _returnTimeController,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              hintText: '00:00 AM',
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
            onSubmitted: (_) => node.nextFocus(),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adult(s)',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _adultCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
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
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minor(s)',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _minorCountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
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
              )
            ],
          ),
        ],
      ),
    );
  }
}
