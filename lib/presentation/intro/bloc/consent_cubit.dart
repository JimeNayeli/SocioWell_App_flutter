import 'package:hydrated_bloc/hydrated_bloc.dart';

class ConsentCubit extends HydratedCubit<bool> {
  ConsentCubit() : super(false); // Estado inicial: consentimiento no otorgado

  void grantConsent() => emit(true); // Usuario otorga el consentimiento

  @override
  bool? fromJson(Map<String, dynamic> json) {
    return json['consent'] as bool? ?? false;
  }

  @override
  Map<String, dynamic>? toJson(bool state) {
    return {'consent': state};
  }
}
