import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:game_complete/color_constants/color_constants.dart';
import 'package:game_complete/custom_ui/gradient_appbar.dart';
import 'package:game_complete/custom_ui/loading_progress.dart';
import 'package:game_complete/custom_ui/raised_gradient_button.dart';
import 'package:game_complete/model/game_complete_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home_screen_bloc.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeScreenBloc _homeScreenBloc = HomeScreenBloc(HomeScreenInitial());

  final _key = new GlobalKey<_HomeScreenState>();
  LinearGradient _mainCardGradient = LinearGradient(colors: [
    ColorConstants.gameDarkGradient,
    ColorConstants.gameLightGradient,
  ]);
  bool _isLoading = false;
  GameCompleteModel _gameCompleteModel;
  ScreenshotController _screenshotController = ScreenshotController();
  var _imageFile;
  final String _fbUrl = 'fb://profile/';
  final String _fbUrlFallback = 'https://www.facebook.com';

  final String _twitterUrl = 'twitter://profile/';
  final String _twitterUrlFallback = 'https://www.twitter.com';

  final String _instaUrl = 'insta://profile/';
  final String _instaUrlFallback = 'https://www.instagram.com';

  final String _pIntrestUrlFallback = 'https://www.pinterest.com';

  @override
  void initState() {
    _homeScreenBloc.add(LoadQuestionEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
        controller: _screenshotController,
        child: Scaffold(
            key: _key,
            backgroundColor: ColorConstants.backgroundColor,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: GradientAppBar('Continents', false),
            ),
            body: _baseScreen()));
  }

  Widget _baseScreen() {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: MediaQuery
          .of(context)
          .size
          .height,
      color: ColorConstants.backgroundColor,
      child: BlocProvider(
        create: (_) => _homeScreenBloc,
        child: BlocListener<HomeScreenBloc, HomeScreenState>(
          listener: (context, state) {
            if (state is Loading) {
              setState(() {
                _isLoading = true;
              });
            }
            if (state is Loaded) {
              setState(() {
                _isLoading = false;
                _gameCompleteModel = _homeScreenBloc.gameCompleteModel;
              });
            }
          },
          child: _isLoading || _gameCompleteModel == null
              ? Center(
            child: Container(
              child: LoadingProgress(
                color: ColorConstants.darkGradient,
              ),
            ),
          )
              : Container(
              margin:
              EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              child: Card(
                  elevation: 5,
                  child: Container(
                    decoration: BoxDecoration(gradient: _mainCardGradient),
                    child: Stack(children: [
                      if (!_gameCompleteModel.quizFailed)
                        Container(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.5,
                          child: Image.asset(
                            'assets/images/star_background.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                      if (_gameCompleteModel.quizFailed)
                        Container(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.34,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          child: Image.asset(
                            'assets/images/circles.png',
                            fit: BoxFit.fill,
                          ),
                        ),

                      if (_gameCompleteModel.scorePercent == 100)
                        Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: MediaQuery
                                      .of(context)
                                      .size
                                      .height *
                                      0.11),
                              height:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.19,
                              width:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.8,
                              child: Image.asset(
                                'assets/images/trophy.png',
                                fit: BoxFit.fill,
                                // color: Colors.black,
                              ),
                            )),
                      _mainCard(_gameCompleteModel),
                      //Other inner cards
                    ]),
                  ))),
        ),
      ),
    );
  }

  Widget _mainCard(GameCompleteModel model) {
    int scorePercent = model.scorePercent.round();
    return Container(
        child: Container(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                    top: 10, bottom: MediaQuery
                    .of(context)
                    .size
                    .height * 0.22),
                child: Text(
                  model.scorePercent == 100 ? '${model.congratsText}' : model
                      .scorePercent <= 20 ? '${model.failedText}':'${model.wellDoneText}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      color: ColorConstants.darkGradient,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.25),
                ),
              ),

              //you score
              Container(
                margin: EdgeInsets.only(top: 5),
                child: Text(
                  '${model.yourScoreText}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      color: model.quizFailed
                          ? Colors.red.shade300
                          : Colors.green.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.25),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 2),
                child: Text(
                  '${scorePercent}%',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                      color: model.quizFailed
                          ? Colors.red.shade300
                          : Colors.green.shade300,
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.25),
                ),
              ),
              _otherScoreCards(_gameCompleteModel),

              //share achievements
              Visibility(
                visible: !model.quizFailed,
                child: Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Text(
                    '${model.achievementShareText}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                        color: ColorConstants.darkGradient,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.25),
                  ),
                ),
              ),
              Visibility(
                  visible: !model.quizFailed,
                  replacement: SizedBox(
                    height: 80,
                  ),
                  child: GestureDetector(
                      onTap: () {
                        _takeScreenshot();
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Image(
                          image: AssetImage('assets/images/share.png'),
                          height: 20.0,
                          width: 20.0,
                          color: ColorConstants.darkGradient,
                        ),
                      ))),

              //options available for different modes
              if (!model.quizFailed) _socialMediaButtons(),
              if (model.quizFailed) _tryAgainButton(),
              _doneButtonWidget(),
            ],
          ),
        ));
  }

  Widget _otherScoreCards(GameCompleteModel model) {
    return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(top: 40),
              child: Card(
                elevation: 5,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          '${model.correctText}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              color: Colors.green.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.25),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: Text(
                          '${model.correctPoints}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              color: Colors.green.shade600,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.25),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              // width: 90,
              // height: 110,
              margin: EdgeInsets.only(top: 15, left: 10),
              child: Card(
                elevation: 5,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        child: Text(
                          '${model.totalQuestionsText}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              color: ColorConstants.darkGradient,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.25),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: Text(
                          '${model.totalQuestions}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              color: ColorConstants.darkGradient,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.25),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              // width: 90,
              // height: 110,
              margin: EdgeInsets.only(top: 40, left: 10),
              child: Card(
                elevation: 5,
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Text(
                          '${model.incorrectText}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.25),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: Text(
                          '${model.incorrectPoint}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              color: Colors.red,
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.25),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }


  Widget _socialMediaButtons() {
    return Container(
      margin: EdgeInsets.only(top: 15, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              _launchSocial(_fbUrl, _fbUrlFallback);
            },
            child: Container(
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/facebook.png',
                    height: 40,
                    width: 40,
                  ),
                )),
          ),
          GestureDetector(
              onTap: () {
                _launchSocial(_twitterUrl, _twitterUrlFallback);
              },
              child: Container(
                margin: EdgeInsets.only(left: 20),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/twitter.png',
                    height: 40,
                    width: 40,
                  ),
                ),
              )),
          GestureDetector(
              onTap: () {
                _launchSocial(_instaUrl, _instaUrlFallback);
              },
              child: Container(
                margin: EdgeInsets.only(left: 20),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/instagram.png',
                    height: 40,
                    width: 40,
                  ),
                ),
              )),
          GestureDetector(
              onTap: () {
                _launchSocial(_pIntrestUrlFallback, _pIntrestUrlFallback);
              },
              child: Container(
                margin: EdgeInsets.only(left: 20),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/pinterest.png',
                    height: 40,
                    width: 40,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _doneButtonWidget() {
    return GestureDetector(
      onTap: () {},
      child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.4,
          height: 40,
          margin: EdgeInsets.only(
            left: 30,
            right: 30,
          ),
          child: RaisedGradientButton(
            onPressed: () {},
            child: Text(
              "DONE",
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1),
            ),
            gradient: LinearGradient(
                colors: [
                  ColorConstants.darkGradient,
                  ColorConstants.lightGradient
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.5, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          )),
    );
  }

  Widget _tryAgainButton() {
    return GestureDetector(
        onTap: () {},
        child: Container(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.4,
            height: 40,
            margin: EdgeInsets.only(left: 30, right: 30, bottom: 10, top: 10),
            child: RaisedGradientButton(
              onPressed: () {},
              child: Text(
                "TRY AGAIN",
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1),
              ),
              gradient: LinearGradient(
                  colors: [Colors.green.shade500, Colors.green.shade300],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(0.5, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
            )));
  }

  //Take app screenshot and share socially
  void _takeScreenshot() async {
    _screenshotController.capture().then((Uint8List image) async {
      //Screenshot captured
      _imageFile = image;

      //Getting path for directory
      Directory appDocumentsDirectory =
      await getApplicationDocumentsDirectory();
      String appDocumentsPath = appDocumentsDirectory.path;
      //Saving image to local
      File imgFile = File('$appDocumentsPath/screenshot.png');
      await imgFile.writeAsBytes(_imageFile);

      //sharing image over social apps
      Share.file("GameComplete", 'screenshot.png', _imageFile, 'image/png');
    }).catchError((onError) {
      print(onError);
    });
  }

  //launch social app if app not avail then fallback url work to open in browser
  void _launchSocial(String url, String fallbackUrl) async {
    try {
      bool launched =
      await launch(url, forceSafariVC: false, forceWebView: false);
      if (!launched) {
        await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
    }
  }
}
