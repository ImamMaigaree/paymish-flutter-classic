import 'package:flutter/material.dart';

import '../model/res_bank_details.dart';
import '../model/res_card_listing.dart';

class BankDetailsProvider extends ChangeNotifier {
  BankDetailsProvider();

  List<BankDetail> list = <BankDetail>[];
  List<CardDetails> cardList = <CardDetails>[];

  List<BankDetail> getList() => list;

  List<CardDetails> getCardList() => cardList;

  void removeBankFromList(List<BankDetail> bankList, BankDetail bankDetail) {
    list = bankList;
    list.remove(bankDetail);
    notifyListeners();
  }

  void removeCardFromList(List<CardDetails> cardLists, CardDetails cardDetail) {
    cardList = cardLists;
    cardList.remove(cardDetail);
    notifyListeners();
  }
}
