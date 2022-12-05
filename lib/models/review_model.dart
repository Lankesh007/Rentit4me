class ReviewModel {
  int id;
  int postAdId;
  int orderId;
  int renterId;
  int postAdRating;
  int userRating;
  String feedback;
  String createdAt;
  String updatedAt;

  ReviewModel(
      {this.id,
      this.postAdId,
      this.orderId,
      this.renterId,
      this.postAdRating,
      this.userRating,
      this.feedback,
      this.createdAt,
      this.updatedAt});

  ReviewModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postAdId = json['post_ad_id'];
    orderId = json['order_id'];
    renterId = json['renter_id'];
    postAdRating = json['post_ad_rating'];
    userRating = json['user_rating'];
    feedback = json['feedback'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['post_ad_id'] = postAdId;
    data['order_id'] = orderId;
    data['renter_id'] = renterId;
    data['post_ad_rating'] = postAdRating;
    data['user_rating'] = userRating;
    data['feedback'] = feedback;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
