class LatestAdditionsModel {
  int id;
  String title;
  String slug;
  String currency;
  String fileName;
  String uploadBasePath;
  List<Prices> prices;

  LatestAdditionsModel(
      {this.id,
      this.title,
      this.slug,
      this.currency,
      this.fileName,
      this.uploadBasePath,
      this.prices});

  LatestAdditionsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    currency = json['currency'];
    fileName = json['file_name'];
    uploadBasePath = json['upload_base_path'];
    if (json['prices'] != null) {
      prices = <Prices>[];
      json['prices'].forEach((v) {
        prices.add(Prices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['slug'] = slug;
    data['currency'] = currency;
    data['file_name'] = fileName;
    data['upload_base_path'] = uploadBasePath;
    if (prices != null) {
      data['prices'] = prices.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Prices {
  int id;
  int postAdId;
  int rentTypeId;
  String rentTypeName;
  String rentTypeAlias;
  int price;
  int status;
  String createdAt;
  String updatedAt;

  Prices(
      {this.id,
      this.postAdId,
      this.rentTypeId,
      this.rentTypeName,
      this.rentTypeAlias,
      this.price,
      this.status,
      this.createdAt,
      this.updatedAt});

  Prices.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postAdId = json['post_ad_id'];
    rentTypeId = json['rent_type_id'];
    rentTypeName = json['rent_type_name'];
    rentTypeAlias = json['rent_type_alias'];
    price = json['price'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['post_ad_id'] = postAdId;
    data['rent_type_id'] = rentTypeId;
    data['rent_type_name'] = rentTypeName;
    data['rent_type_alias'] = rentTypeAlias;
    data['price'] = price;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
