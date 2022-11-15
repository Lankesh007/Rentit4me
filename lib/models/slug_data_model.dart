class SlugDataModel {
  int id;
  String currency;
  String boostPackageStatus;
  String title;
  int price;
  String rentTypeName;
  String uploadBasePath;
  String fileName;

  SlugDataModel(
      {this.id,
      this.currency,
      this.boostPackageStatus,
      this.title,
      this.price,
      this.rentTypeName,
      this.uploadBasePath,
      this.fileName});

  SlugDataModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currency = json['currency'];
    boostPackageStatus = json['boost_package_status'];
    title = json['title'];
    price = json['price'];
    rentTypeName = json['rent_type_name'];
    uploadBasePath = json['upload_base_path'];
    fileName = json['file_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['currency'] = this.currency;
    data['boost_package_status'] = this.boostPackageStatus;
    data['title'] = this.title;
    data['price'] = this.price;
    data['rent_type_name'] = this.rentTypeName;
    data['upload_base_path'] = this.uploadBasePath;
    data['file_name'] = this.fileName;
    return data;
  }
}
