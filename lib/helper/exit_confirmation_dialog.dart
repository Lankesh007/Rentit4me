
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rentit4me_new/themes/constant.dart';

class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildChild(context),
    );
  }

  _buildChild(BuildContext context) => Container(
        height: 250,
        decoration: BoxDecoration(
            color: kPrimaryColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12))),
              child: Padding(
                padding:  EdgeInsets.all(12.0),
                child: Image.asset('assets/images/logo.png',
                    height: 60, width: 60, fit: BoxFit.fitHeight),
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Text(
              'Are you sure?',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 8,
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16, left: 16),
              child: Text(
                'Do you really want to exit from application?',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 24,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ignore: deprecated_member_use
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    
                    child: Text('No')),
                SizedBox(width: 8),
                // ignore: deprecated_member_use
                ElevatedButton(
                    onPressed: () {
                      SystemNavigator.pop();
                      //return Navigator.of(context).pop(true);
                    },
                   
                    child: Text('Yes'))
              ],
            )
          ],
        ),
      );
}
