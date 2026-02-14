import '../../../../apis/dic_params.dart';

class ResHomeScreen {
  ResHomeScreenData? data;

  ResHomeScreen({this.data});

  ResHomeScreen.fromJson(Map<String, dynamic> json) {
    data = json[DicParams.data] != null
        ? ResHomeScreenData.fromJson(json[DicParams.data])
        : null;
  }
}

class ResHomeScreenData {
  int? unreadCount;
  List<Utilities>? utilities;
  RecentContacts? recentContacts;
  int? isApprovedByAdmin;

  ResHomeScreenData(
      {this.unreadCount,
      this.utilities,
      this.recentContacts,
      this.isApprovedByAdmin});

  ResHomeScreenData.fromJson(Map<String, dynamic> json) {
    unreadCount = json[DicParams.unreadCount];
    if (json[DicParams.utilities] != null) {
      utilities = <Utilities>[];
      json[DicParams.utilities].forEach((v) {
        utilities!.add(Utilities.fromJson(v));
      });
    }
    recentContacts = json[DicParams.recentContacts] != null
        ? RecentContacts.fromJson(json[DicParams.recentContacts])
        : null;
    isApprovedByAdmin = json[DicParams.isApprovedByAdmin];
  }
}

class Utilities {
  int? id;
  String? identifier;
  String? name;
  List<Services>? services;

  Utilities({this.id, this.identifier, this.name, this.services});

  Utilities.fromJson(Map<String, dynamic> json) {
    id = json[DicParams.id];
    identifier = json[DicParams.identifier];
    name = json[DicParams.name];
    if (json[DicParams.services] != null) {
      services = <Services>[];
      json[DicParams.services].forEach((v) {
        services!.add(Services.fromJson(v));
      });
    }
  }
}

class Services {
  int? id;
  String? name;
  String? serviceID;
  String? identifier;
  int? convenienceFee;
  num? minimumAmount;
  num? maximumAmount;
  String? productType;
  String? image;

  Services(
      {this.id,
      this.name,
      this.serviceID,
      this.identifier,
      this.convenienceFee,
      this.minimumAmount,
      this.maximumAmount,
      this.productType,
      this.image});

  Services.fromJson(Map<String, dynamic> json) {
    id = json[DicParams.id];
    name = json[DicParams.name];
    serviceID = json[DicParams.serviceID];
    identifier = json[DicParams.identifier];
    convenienceFee = json[DicParams.convenienceFee];
    minimumAmount = json[DicParams.minimumAmount];
    maximumAmount = json[DicParams.maximumAmount];
    productType = json[DicParams.productType];
    image = json[DicParams.image];
  }
}

class RecentContacts {
  List<Contacts>? contacts;
  int? count;

  RecentContacts({this.contacts, this.count});

  RecentContacts.fromJson(Map<String, dynamic> json) {
    if (json[DicParams.contacts] != null) {
      contacts = <Contacts>[];
      json[DicParams.contacts].forEach((v) {
        contacts!.add(Contacts.fromJson(v));
      });
    }
    count = json[DicParams.count];
  }
}

class Contacts {
  String? firstName;
  String? lastName;
  String? profilePicture;
  int? id;

  Contacts({this.firstName, this.lastName, this.profilePicture, this.id});

  Contacts.fromJson(Map<String, dynamic> json) {
    firstName = json[DicParams.firstName];
    lastName = json[DicParams.lastName];
    profilePicture = json[DicParams.profilePicture];
    id = json[DicParams.id];
  }
}
