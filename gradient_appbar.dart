import "package:flutter/material.dart";
import 'package:game_complete/color_constants/color_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientAppBar extends StatelessWidget {
  final String title;
  final double barHeight = 50;
  final bool backButton;

  //set the title and back navigation functionality
  GradientAppBar(this.title, this.backButton);

  @override
  Widget build(BuildContext context) {
    //set status bar height
    final double statusbarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: statusbarHeight),
      height: statusbarHeight + barHeight,
      child: Container(
        child: Row(
          children: [
            //check for back button required
            if (backButton)
              GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Container(
                margin: EdgeInsets.only(left: 5),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),),
            Container(
                margin: EdgeInsets.only(
                    left: backButton
                        ? MediaQuery.of(context).size.width * 0.25
                        : MediaQuery.of(context).size.width * 0.38),
                child: Text(
                  title,
                  style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.25),
                ))
          ],
        ),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [ColorConstants.darkGradient, ColorConstants.lightGradient],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.5, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
    );
  }
}
