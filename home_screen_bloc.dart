import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:game_complete/model/game_complete_model.dart';
import 'package:game_complete/repository/home_repository/home_repository.dart';
import 'package:meta/meta.dart';


part 'home_screen_event.dart';
part 'home_screen_state.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  HomeScreenBloc(HomeScreenInitial initial) : super(HomeScreenInitial());
  HomeRepository _homeRepository = HomeRepository();

  GameCompleteModel gameCompleteModel;
  var image;

  @override
  Stream<HomeScreenState> mapEventToState(
    HomeScreenEvent event,
  ) async* {
    //on check event perform functionality
    if(event is LoadQuestionEvent){
      yield Loading();
      gameCompleteModel = await _homeRepository.getAnswerText();
      //check for data availability must be not null
      if(gameCompleteModel != null) {
        yield Loaded();
      }else{
        yield Failed();
      }
    }

  }


}
