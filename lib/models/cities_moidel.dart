class CitiesModel {
  int id;
  String countryId;
  String stateId;
  String name;
  String latitude;
  String longitude;
  String timeZone;
  String dmaId;
  String code;
  String createdAt;
  String updatedAt;
  Pivot pivot;

  CitiesModel(
      {this.id,
      this.countryId,
      this.stateId,
      this.name,
      this.latitude,
      this.longitude,
      this.timeZone,
      this.dmaId,
      this.code,
      this.createdAt,
      this.updatedAt,
      this.pivot});

  CitiesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    countryId = json['country_id'];
    stateId = json['state_id'];
    name = json['name'];
    latitude = json['Latitude'];
    longitude = json['Longitude'];
    timeZone = json['TimeZone'];
    dmaId = json['DmaId'];
    code = json['Code'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['country_id'] = countryId;
    data['state_id'] = stateId;
    data['name'] = name;
    data['Latitude'] = latitude;
    data['Longitude'] = longitude;
    data['TimeZone'] = timeZone;
    data['DmaId'] = dmaId;
    data['Code'] = code;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (pivot != null) {
      data['pivot'] = pivot.toJson();
    }
    return data;
  }
}

class Pivot {
  int postAdId;
  int cityId;
  String createdAt;
  String updatedAt;

  Pivot({this.postAdId, this.cityId, this.createdAt, this.updatedAt});

  Pivot.fromJson(Map<String, dynamic> json) {
    postAdId = json['post_ad_id'];
    cityId = json['city_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['post_ad_id'] = postAdId;
    data['city_id'] = cityId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
