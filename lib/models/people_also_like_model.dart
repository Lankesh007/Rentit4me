class PeopleAlsoMayLikeModel {
  int id;
  String adId;
  int userId;
  int userType;
  Null boostPackageId;
  Null boostPackagePosition;
  Null boostPackageStatus;
  Null boostPackageFromDate;
  Null boostPackageToDate;
  String title;
  String slug;
  String description;
  int security;
  int quantity;
  String currency;
  String negotiate;
  String countrycode;
  String mobile;
  String email;
  String mobileHidden;
  int review;
  Null tags;
  String country;
  String state;
  String city;
  String preferences;
  String locationAvailability;
  String address;
  int outOfStock;
  String termCondition;
  String productFor;
  Null rentType;
  String startDate;
  String endDate;
  Null expiryDate;
  Null featuredExpiryDate;
  int status;
  String latitude;
  String longitude;
  String adType;
  Null paymentStatus;
  String productType;
  String payment;
  String createdAt;
  String updatedAt;
  Null deletedAt;
  int createdBy;
  int updatedBy;
  int startingPrice;
  List<Images> images;

  PeopleAlsoMayLikeModel(
      {this.id,
      this.adId,
      this.userId,
      this.userType,
      this.boostPackageId,
      this.boostPackagePosition,
      this.boostPackageStatus,
      this.boostPackageFromDate,
      this.boostPackageToDate,
      this.title,
      this.slug,
      this.description,
      this.security,
      this.quantity,
      this.currency,
      this.negotiate,
      this.countrycode,
      this.mobile,
      this.email,
      this.mobileHidden,
      this.review,
      this.tags,
      this.country,
      this.state,
      this.city,
      this.preferences,
      this.locationAvailability,
      this.address,
      this.outOfStock,
      this.termCondition,
      this.productFor,
      this.rentType,
      this.startDate,
      this.endDate,
      this.expiryDate,
      this.featuredExpiryDate,
      this.status,
      this.latitude,
      this.longitude,
      this.adType,
      this.paymentStatus,
      this.productType,
      this.payment,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.createdBy,
      this.updatedBy,
      this.startingPrice,
      this.images});

  PeopleAlsoMayLikeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    adId = json['ad_id'];
    userId = json['user_id'];
    userType = json['user_type'];
    boostPackageId = json['boost_package_id'];
    boostPackagePosition = json['boost_package_position'];
    boostPackageStatus = json['boost_package_status'];
    boostPackageFromDate = json['boost_package_from_date'];
    boostPackageToDate = json['boost_package_to_date'];
    title = json['title'];
    slug = json['slug'];
    description = json['description'];
    security = json['security'];
    quantity = json['quantity'];
    currency = json['currency'];
    negotiate = json['negotiate'];
    countrycode = json['countrycode'];
    mobile = json['mobile'];
    email = json['email'];
    mobileHidden = json['mobile_hidden'];
    review = json['review'];
    tags = json['tags'];
    country = json['country'];
    state = json['state'];
    city = json['city'];
    preferences = json['preferences'];
    locationAvailability = json['location_availability'];
    address = json['address'];
    outOfStock = json['out_of_stock'];
    termCondition = json['term_condition'];
    productFor = json['product_for'];
    rentType = json['rent_type'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    expiryDate = json['expiry_date'];
    featuredExpiryDate = json['featured_expiry_date'];
    status = json['status'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    adType = json['ad_type'];
    paymentStatus = json['payment_status'];
    productType = json['product_type'];
    payment = json['payment'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    startingPrice = json['starting_price'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images.add( Images.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['ad_id'] = adId;
    data['user_id'] = userId;
    data['user_type'] = userType;
    data['boost_package_id'] = boostPackageId;
    data['boost_package_position'] = boostPackagePosition;
    data['boost_package_status'] = boostPackageStatus;
    data['boost_package_from_date'] = boostPackageFromDate;
    data['boost_package_to_date'] = boostPackageToDate;
    data['title'] = title;
    data['slug'] = slug;
    data['description'] = description;
    data['security'] = security;
    data['quantity'] = quantity;
    data['currency'] = currency;
    data['negotiate'] = negotiate;
    data['countrycode'] = countrycode;
    data['mobile'] = mobile;
    data['email'] = email;
    data['mobile_hidden'] = mobileHidden;
    data['review'] = review;
    data['tags'] = tags;
    data['country'] = country;
    data['state'] = state;
    data['city'] = city;
    data['preferences'] = preferences;
    data['location_availability'] = locationAvailability;
    data['address'] = address;
    data['out_of_stock'] = outOfStock;
    data['term_condition'] = termCondition;
    data['product_for'] = productFor;
    data['rent_type'] = rentType;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['expiry_date'] = expiryDate;
    data['featured_expiry_date'] = featuredExpiryDate;
    data['status'] = status;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['ad_type'] = adType;
    data['payment_status'] = paymentStatus;
    data['product_type'] = productType;
    data['payment'] = payment;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    data['starting_price'] = startingPrice;
    if (images != null) {
      data['images'] = images.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Images {
  int id;
  int postAdId;
  String fileName;
  String imageUrl;
  Null url;
  String uploadBasePath;
  String size;
  String duration;
  String type;
  String fileType;
  int isMain;
  String createdAt;
  String updatedAt;
  Null createdBy;
  Null updatedBy;

  Images(
      {this.id,
      this.postAdId,
      this.fileName,
      this.imageUrl,
      this.url,
      this.uploadBasePath,
      this.size,
      this.duration,
      this.type,
      this.fileType,
      this.isMain,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.updatedBy});

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postAdId = json['post_ad_id'];
    fileName = json['file_name'];
    imageUrl = json['image_url'];
    url = json['url'];
    uploadBasePath = json['upload_base_path'];
    size = json['size'];
    duration = json['duration'];
    type = json['type'];
    fileType = json['file_type'];
    isMain = json['is_main'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['post_ad_id'] = postAdId;
    data['file_name'] = fileName;
    data['image_url'] = imageUrl;
    data['url'] = url;
    data['upload_base_path'] = uploadBasePath;
    data['size'] = size;
    data['duration'] = duration;
    data['type'] = type;
    data['file_type'] = fileType;
    data['is_main'] = isMain;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    return data;
  }
}
