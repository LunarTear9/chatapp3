import 'package:flutter/material.dart';

class ExpandableButton extends StatefulWidget {
  @override
  _ExpandableButtonState createState() => _ExpandableButtonState();
}

class _ExpandableButtonState extends State<ExpandableButton> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ElevatedButton(
          onPressed: toggleExpansion,
          child: Text('Press to Expand'),
        ),
        SizedBox(height: 20),
        AnimatedContainer(
          duration: Duration(milliseconds: 500),
          height: isExpanded ? 200 : 0,
          width: isExpanded ? 200 : 0,
          curve: Curves.easeInOut,
          child: isExpanded
              ? Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        option1Function();
                      },
                      child: Text('Option 1'),
                    ),
                    TextButton(
                      onPressed: () {
                        option2Function();
                      },
                      child: Text('Option 2'),
                    ),
                    TextButton(
                      onPressed: () {
                        option3Function();
                      },
                      child: Text('Option 3'),
                    ),
                  ],
                )
              : null,
        ),
      ],
    );
  }

  void toggleExpansion() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  void option1Function() {
    // Add functionality for option 1
    print('Option 1 selected');
  }

  void option2Function() {
    // Add functionality for option 2
    print('Option 2 selected');
  }

  void option3Function() {
    // Add functionality for option 3
    print('Option 3 selected');
  }
}
