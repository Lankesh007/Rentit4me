class ViewAllLatestAdditiionModel {
  int id;
  String currency;
  String title;
  String boostPackagePosition;
  int boostPackageStatus;
  int price;
  String rentTypeName;
  String uploadBasePath;
  String fileName;
  String categoryTitle;

  ViewAllLatestAdditiionModel(
      {this.id,
      this.currency,
      this.title,
      this.boostPackagePosition,
      this.boostPackageStatus,
      this.price,
      this.rentTypeName,
      this.uploadBasePath,
      this.fileName,
      this.categoryTitle});

  ViewAllLatestAdditiionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currency = json['currency'];
    title = json['title'];
    boostPackagePosition = json['boost_package_position'];
    boostPackageStatus = json['boost_package_status'];
    price = json['price'];
    rentTypeName = json['rent_type_name'];
    uploadBasePath = json['upload_base_path'];
    fileName = json['file_name'];
    categoryTitle = json['category_title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['currency'] = currency;
    data['title'] = title;
    data['boost_package_position'] = boostPackagePosition;
    data['boost_package_status'] = boostPackageStatus;
    data['price'] = price;
    data['rent_type_name'] = rentTypeName;
    data['upload_base_path'] = uploadBasePath;
    data['file_name'] = fileName;
    data['category_title'] = categoryTitle;
    return data;
  }
}
