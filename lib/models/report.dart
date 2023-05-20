// To parse this JSON data, do
//
//     final report = reportFromJson(jsonString);

import 'dart:convert';

Report reportFromJson(String str) => Report.fromJson(json.decode(str));

String reportToJson(Report data) => json.encode(data.toJson());

class Report {
    String? uid;
    String? image;
    String? description;
    String? clientUid;
    String? syndicUid;
    String? longitude;
    String? latitude;

    Report({
        this.uid,
        this.image,
        this.description,
        this.clientUid,
        this.syndicUid,
        this.longitude,
        this.latitude,
    });

    factory Report.fromJson(Map<String, dynamic> json) => Report(
        uid: json["uid"],
        image: json["image"],
        description: json["description"],
        clientUid: json["client_uid"],
        syndicUid: json["syndic_uid"],
        longitude: json["longitude"],
        latitude: json["latitude"],
    );

    Map<String, dynamic> toJson() => {
        "uid": uid,
        "image": image,
        "description": description,
        "client_uid": clientUid,
        "syndic_uid": syndicUid,
        "longitude": longitude,
        "latitude": latitude,
    };
}
