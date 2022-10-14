import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentit4me_new/blocs/network_bloc/network_event.dart';
import 'package:rentit4me_new/blocs/network_bloc/network_state.dart';

class InternetBloc extends Bloc<InternetEvent, InternetState> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription _streamSubscription;

  InternetBloc() : super(ConnectivityInitialState()) {
    on<ConnectivitySuccessEvent>(
        (event, emit) => emit(ConnectivitySuccessState()));
    on<ConnectivityFailEvent>((event, emit) => emit(ConnectivityFailState()));

    _streamSubscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi) {
        add(ConnectivitySuccessEvent());
      } else {
        add(ConnectivityFailEvent());
      }
    });
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
