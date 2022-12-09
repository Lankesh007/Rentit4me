class ReviewModel {
  String name;
  String avatarPath;
  int postAdRating;
  int userRating;
  String feedback;

  ReviewModel(
      {this.name,
      this.avatarPath,
      this.postAdRating,
      this.userRating,
      this.feedback});

  ReviewModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    avatarPath = json['avatar_path'];
    postAdRating = json['post_ad_rating'];
    userRating = json['user_rating'];
    feedback = json['feedback'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['avatar_path'] = avatarPath;
    data['post_ad_rating'] = postAdRating;
    data['user_rating'] = userRating;
    data['feedback'] = feedback;
    return data;
  }
}
