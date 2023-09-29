class MusicModel {
  String? url;
  String? artist;
  String? name;

  MusicModel({this.url, this.artist, this.name});

  MusicModel.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    artist = json['artist'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['artist'] = this.artist;
    data['url'] = this.url;
    data['name'] = this.name;
    return data;
  }
}
