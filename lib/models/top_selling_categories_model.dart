class TopSellingCatgegoriesModel {
  int id;
  int parentId;
  String title;
  String slug;
  String description;
  String image;
  int topSelling;
  String featured;
  int orderBy;
  int status;
  String createdAt;
  String updatedAt;
  String createdBy;
  String updatedBy;

  TopSellingCatgegoriesModel(
      {this.id,
      this.parentId,
      this.title,
      this.slug,
      this.description,
      this.image,
      this.topSelling,
      this.featured,
      this.orderBy,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.updatedBy});

  TopSellingCatgegoriesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parent_id'];
    title = json['title'];
    slug = json['slug'];
    description = json['description'];
    image = json['image'];
    topSelling = json['top_selling'];
    featured = json['featured'];
    orderBy = json['order_by'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['parent_id'] = this.parentId;
    data['title'] = this.title;
    data['slug'] = this.slug;
    data['description'] = this.description;
    data['image'] = this.image;
    data['top_selling'] = this.topSelling;
    data['featured'] = this.featured;
    data['order_by'] = this.orderBy;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['created_by'] = this.createdBy;
    data['updated_by'] = this.updatedBy;
    return data;
  }
}
