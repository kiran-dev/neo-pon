enum PartyStatus { INVITED, DOWNLOADING, WATCHING, TYPING }

class PartyMember {
  String ID;
  PartyStatus status;

  PartyMember({
    required this.ID,
    required this.status,
  });

  PartyMember.NewInvite({ required this.ID }) : status = PartyStatus.INVITED;

  factory PartyMember.fromJson(Map<String, dynamic> json, { ID: "" }) {

    return PartyMember(
      ID: json['ID'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': ID,
      'status': status,
    };
  }
}
