class BrowseAllCategories {
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
  List<Subcategories> subcategories;

  BrowseAllCategories(
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
      this.updatedBy,
      this.subcategories});

  BrowseAllCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parent_id'];
    title = json['title'];
    slug = json['slug'];
    description = json['description'];
    image = json['image'];
    topSelling = json['top_selling'];
    featured = json['featured'].toString();
    orderBy = json['order_by'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    if (json['subcategories'] != null) {
      subcategories = <Subcategories>[];
      json['subcategories'].forEach((v) {
        subcategories.add(Subcategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['parent_id'] = parentId;
    data['title'] = title;
    data['slug'] = slug;
    data['description'] = description;
    data['image'] = image;
    data['top_selling'] = topSelling;
    data['featured'] = featured;
    data['order_by'] = orderBy;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    if (subcategories != null) {
      data['subcategories'] =
          subcategories.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Subcategories {
  int id;
  int parentId;
  String title;
  String slug;
  String description;
  String image;
  String topSelling;
  int featured;
  int orderBy;
  int status;
  String createdAt;
  String updatedAt;
  String createdBy;
  String updatedBy;

  Subcategories(
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

  Subcategories.fromJson(Map<String, dynamic> json) {
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['parent_id'] = parentId;
    data['title'] = title;
    data['slug'] = slug;
    data['description'] = description;
    data['image'] = image;
    data['top_selling'] = topSelling;
    data['featured'] = featured;
    data['order_by'] = orderBy;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    return data;
  }
}
