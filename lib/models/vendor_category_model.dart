class VendorCategoryModel {
  List<dynamic>? reviewAttributes;
  String? photo;
  String? description;
  String? id;
  String? title;
  bool? isActive;

  VendorCategoryModel({this.reviewAttributes, this.photo, this.description, this.id, this.title, this.isActive});

  VendorCategoryModel.fromJson(Map<String, dynamic> json) {
    reviewAttributes = json['review_attributes'] ?? [];
    photo = json['photo'] ?? "";
    description = json['description'] ?? '';
    id = json['id'] ?? "";
    title = json['title'] ?? "";
    isActive = json['isActive'] ?? true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['review_attributes'] = reviewAttributes;
    data['photo'] = photo;
    data['description'] = description;
    data['id'] = id;
    data['title'] = title;
    data['isActive'] = isActive;
    return data;
  }
}
