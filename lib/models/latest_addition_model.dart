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
        prices.add(new Prices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['slug'] = this.slug;
    data['currency'] = this.currency;
    data['file_name'] = this.fileName;
    data['upload_base_path'] = this.uploadBasePath;
    if (this.prices != null) {
      data['prices'] = this.prices.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['post_ad_id'] = this.postAdId;
    data['rent_type_id'] = this.rentTypeId;
    data['rent_type_name'] = this.rentTypeName;
    data['rent_type_alias'] = this.rentTypeAlias;
    data['price'] = this.price;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
