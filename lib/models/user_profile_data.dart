class UserProfileData {
  int errorCode;
  String errorMessage;
  ProfileResponse response;

  UserProfileData({this.errorCode, this.errorMessage, this.response});

  UserProfileData.fromJson(Map<String, dynamic> json) {
    errorCode = json['ErrorCode'];
    errorMessage = json['ErrorMessage'];
    response = json['Response'] != null
        ? ProfileResponse.fromJson(json['Response'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['ErrorCode'] = errorCode;
    data['ErrorMessage'] = errorMessage;
    if (response != null) {
      data['ProfileResponse'] = response.toJson();
    }
    return data;
  }
}

class ProfileResponse {
  int id;
  int userType;
  String username;
  String businessName;
  String name;
  String email;
  int isVerified;
  String countrycode;
  String mobile;
  String alternateMobile;
  int mobileHidden;
  int kyc;
  int trustedBadge;
  String trustedBadgeApproval;
  int personalDetails;
  int businessDetails;
  int paymentStatus;
  String preferences;
  String address;
  String about;
  String bankName;
  String branchName;
  String ifsc;
  String accountNo;
  String accountType;
  String gstNo;
  String panNo;
  String adhaarNo;
  String gstDoc;
  String panDoc;
  String adhaarDoc;
  String avatarPath;
  String avatarBaseUrl;
  String facebookUrl;
  String twitterUrl;
  String googlePlusUrl;
  String instagramUrl;
  String linkedinUrl;
  String youtubeUrl;
  int otp;
  String otpVerify;
  String website;
  int emailOtp;
  String emailVerify;
  String mobileVerify;
  String authKey;
  String accessToken;
  String passwordHash;
  String keyHash;
  String oauthClient;
  String oauthClientUserId;
  String facebookClinetUserId;
  int status;
  String deviceType;
  String devicetoken;
  String deviceid;
  String quickbloxId;
  String quickbloxUsername;
  String quickbloxEmail;
  String quickbloxPassword;
  String registerFrom;
  String socialToken;
  String socialType;
  String packageId;
  int country;
  int state;
  String city;
  String pincode;
  String currency;
  String adCount;
  String featuredAdCount;
  String newsletter;
  String terms;
  String emailVerifiedAt;
  String createdAt;
  String updatedAt;
  String deletedAt;
  int loggedAt;

  ProfileResponse(
      {
        this.id,
        this.userType,
        this.username,
        this.businessName,
        this.name,
        this.email,
        this.isVerified,
        this.countrycode,
        this.mobile,
        this.alternateMobile,
        this.mobileHidden,
        this.kyc,
        this.trustedBadge,
        this.trustedBadgeApproval,
        this.personalDetails,
        this.businessDetails,
        this.paymentStatus,
        this.preferences,
        this.address,
        this.about,
        this.bankName,
        this.branchName,
        this.ifsc,
        this.accountNo,
        this.accountType,
        this.gstNo,
        this.panNo,
        this.adhaarNo,
        this.gstDoc,
        this.panDoc,
        this.adhaarDoc,
        this.avatarPath,
        this.avatarBaseUrl,
        this.facebookUrl,
        this.twitterUrl,
        this.googlePlusUrl,
        this.instagramUrl,
        this.linkedinUrl,
        this.youtubeUrl,
        this.otp,
        this.otpVerify,
        this.website,
        this.emailOtp,
        this.emailVerify,
        this.mobileVerify,
        this.authKey,
        this.accessToken,
        this.passwordHash,
        this.keyHash,
        this.oauthClient,
        this.oauthClientUserId,
        this.facebookClinetUserId,
        this.status,
        this.deviceType,
        this.devicetoken,
        this.deviceid,
        this.quickbloxId,
        this.quickbloxUsername,
        this.quickbloxEmail,
        this.quickbloxPassword,
        this.registerFrom,
        this.socialToken,
        this.socialType,
        this.packageId,
        this.country,
        this.state,
        this.city,
        this.pincode,
        this.currency,
        this.adCount,
        this.featuredAdCount,
        this.newsletter,
        this.terms,
        this.emailVerifiedAt,
        this.createdAt,
        this.updatedAt,
        this.deletedAt,
        this.loggedAt});

  ProfileResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userType = json['user_type'];
    username = json['username'];
    businessName = json['business_name'];
    name = json['name'];
    email = json['email'];
    isVerified = json['is_verified'];
    countrycode = json['countrycode'];
    mobile = json['mobile'];
    alternateMobile = json['alternate_mobile'];
    mobileHidden = json['mobile_hidden'];
    kyc = json['kyc'];
    trustedBadge = json['trusted_badge'];
    trustedBadgeApproval = json['trusted_badge_approval'];
    personalDetails = json['personal_details'];
    businessDetails = json['business_details'];
    paymentStatus = json['payment_status'];
    preferences = json['preferences'];
    address = json['address'];
    about = json['about'];
    bankName = json['bank_name'];
    branchName = json['branch_name'];
    ifsc = json['ifsc'];
    accountNo = json['account_no'];
    accountType = json['account_type'];
    gstNo = json['gst_no'];
    panNo = json['pan_no'];
    adhaarNo = json['adhaar_no'];
    gstDoc = json['gst_doc'];
    panDoc = json['pan_doc'];
    adhaarDoc = json['adhaar_doc'];
    avatarPath = json['avatar_path'];
    avatarBaseUrl = json['avatar_base_url'];
    facebookUrl = json['facebook_url'];
    twitterUrl = json['twitter_url'];
    googlePlusUrl = json['google_plus_url'];
    instagramUrl = json['instagram_url'];
    linkedinUrl = json['linkedin_url'];
    youtubeUrl = json['youtube_url'];
    otp = json['otp'];
    otpVerify = json['otp_verify'];
    website = json['website'];
    emailOtp = json['email_otp'];
    emailVerify = json['email_verify'];
    mobileVerify = json['mobile_verify'];
    authKey = json['auth_key'];
    accessToken = json['access_token'];
    passwordHash = json['password_hash'];
    keyHash = json['key_hash'];
    oauthClient = json['oauth_client'];
    oauthClientUserId = json['oauth_client_user_id'];
    facebookClinetUserId = json['facebook_clinet_user_id'];
    status = json['status'];
    deviceType = json['device_type'];
    devicetoken = json['devicetoken'];
    deviceid = json['deviceid'];
    quickbloxId = json['quickblox_id'];
    quickbloxUsername = json['quickblox_username'];
    quickbloxEmail = json['quickblox_email'];
    quickbloxPassword = json['quickblox_password'];
    registerFrom = json['register_from'];
    socialToken = json['social_token'];
    socialType = json['social_type'];
    packageId = json['package_id'];
    country = json['country'];
    state = json['state'];
    city = json['city'];
    pincode = json['pincode'];
    currency = json['currency'];
    adCount = json['ad_count'];
    featuredAdCount = json['featured_ad_count'];
    newsletter = json['newsletter'];
    terms = json['terms'];
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    loggedAt = json['logged_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['user_type'] = userType;
    data['username'] = username;
    data['business_name'] = businessName;
    data['name'] = name;
    data['email'] = email;
    data['is_verified'] = isVerified;
    data['countrycode'] = countrycode;
    data['mobile'] = mobile;
    data['alternate_mobile'] = alternateMobile;
    data['mobile_hidden'] = mobileHidden;
    data['kyc'] = kyc;
    data['trusted_badge'] = trustedBadge;
    data['trusted_badge_approval'] = trustedBadgeApproval;
    data['personal_details'] = personalDetails;
    data['business_details'] = businessDetails;
    data['payment_status'] = paymentStatus;
    data['preferences'] = preferences;
    data['address'] = address;
    data['about'] = about;
    data['bank_name'] = bankName;
    data['branch_name'] = branchName;
    data['ifsc'] = ifsc;
    data['account_no'] = accountNo;
    data['account_type'] = accountType;
    data['gst_no'] = gstNo;
    data['pan_no'] = panNo;
    data['adhaar_no'] = adhaarNo;
    data['gst_doc'] = gstDoc;
    data['pan_doc'] = panDoc;
    data['adhaar_doc'] = adhaarDoc;
    data['avatar_path'] = avatarPath;
    data['avatar_base_url'] = avatarBaseUrl;
    data['facebook_url'] = facebookUrl;
    data['twitter_url'] = twitterUrl;
    data['google_plus_url'] = googlePlusUrl;
    data['instagram_url'] = instagramUrl;
    data['linkedin_url'] = linkedinUrl;
    data['youtube_url'] = youtubeUrl;
    data['otp'] = otp;
    data['otp_verify'] = otpVerify;
    data['website'] = website;
    data['email_otp'] = emailOtp;
    data['email_verify'] = emailVerify;
    data['mobile_verify'] = mobileVerify;
    data['auth_key'] = authKey;
    data['access_token'] = accessToken;
    data['password_hash'] = passwordHash;
    data['key_hash'] = keyHash;
    data['oauth_client'] = oauthClient;
    data['oauth_client_user_id'] = oauthClientUserId;
    data['facebook_clinet_user_id'] = facebookClinetUserId;
    data['status'] = status;
    data['device_type'] = deviceType;
    data['devicetoken'] = devicetoken;
    data['deviceid'] = deviceid;
    data['quickblox_id'] = quickbloxId;
    data['quickblox_username'] = quickbloxUsername;
    data['quickblox_email'] = quickbloxEmail;
    data['quickblox_password'] = quickbloxPassword;
    data['register_from'] = registerFrom;
    data['social_token'] = socialToken;
    data['social_type'] = socialType;
    data['package_id'] = packageId;
    data['country'] = country;
    data['state'] = state;
    data['city'] = city;
    data['pincode'] = pincode;
    data['currency'] = currency;
    data['ad_count'] = adCount;
    data['featured_ad_count'] = featuredAdCount;
    data['newsletter'] = newsletter;
    data['terms'] = terms;
    data['email_verified_at'] = emailVerifiedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['logged_at'] = loggedAt;
    return data;
  }
}