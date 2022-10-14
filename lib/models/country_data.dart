class CountryData {
  int errorCode;
  String errorMessage;
  Response response;

  CountryData({this.errorCode, this.errorMessage, this.response});

  CountryData.fromJson(Map<String, dynamic> json) {
    errorCode = json['ErrorCode'];
    errorMessage = json['ErrorMessage'];
    response = json['Response'] != null
        ?  Response.fromJson(json['Response'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['ErrorCode'] = errorCode;
    data['ErrorMessage'] = errorMessage;
    if (response != null) {
      data['Response'] = response.toJson();
    }
    return data;
  }
}

class Response {
  List<Countries> countries;

  Response({this.countries});

  Response.fromJson(Map<String, dynamic> json) {
    if (json['countries'] != null) {
      countries = <Countries>[];
      json['countries'].forEach((v) {
        countries.add( Countries.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (countries != null) {
      data['countries'] = countries.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Countries {
  String name;
  int id;

  Countries({this.name, this.id});

  Countries.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['name'] = name;
    data['id'] = id;
    return data;
  }
}
