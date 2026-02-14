import '../../../apis/dic_params.dart';

class ResTicketStatus {
  String? status;
  int? ticketId;

  ResTicketStatus({this.status, this.ticketId});

  ResTicketStatus.fromJson(Map<String, dynamic> json) {
    status = json[DicParams.status];
    ticketId = json[DicParams.ticketId];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data[DicParams.status] = status;
    data[DicParams.ticketId] = ticketId;
    return data;
  }
}
