class SearchProductModel {
  int id;
  String currency;
  String boostPackageStatus;
  String title;
  int price;
  String rentTypeName;
  String uploadBasePath;
  String fileName;

  SearchProductModel(
      {this.id,
      this.currency,
      this.boostPackageStatus,
      this.title,
      this.price,
      this.rentTypeName,
      this.uploadBasePath,
      this.fileName});

  SearchProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currency = json['currency'];
    boostPackageStatus = json['boost_package_status']??"";
    title = json['title'];
    price = json['price'];
    rentTypeName = json['rent_type_name'];
    uploadBasePath = json['upload_base_path'];
    fileName = json['file_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['currency'] = currency;
    data['boost_package_status'] = boostPackageStatus;
    data['title'] = title;
    data['price'] = price;
    data['rent_type_name'] = rentTypeName;
    data['upload_base_path'] = uploadBasePath;
    data['file_name'] = fileName;
    return data;
  }
}
