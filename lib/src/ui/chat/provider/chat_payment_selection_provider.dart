import 'package:flutter/material.dart';

import '../../../apis/dic_params.dart';
import '../../paymentSetting/model/res_card_listing.dart';

class ChatPaymentSelectionProvider extends ChangeNotifier {
  ChatPaymentSelectionProvider();

  String _selectedRadioValue = DicParams.wallet;
  int _tempSelectedCard = 0;
  int _selectedCard = 0;
  List<CardDetails> _cardList = <CardDetails>[];

  void setSelectedRadioValue(String value) {
    _selectedRadioValue = value;
    notifyListeners();
  }

  void setSelectedCardId(int value) {
    _selectedCard = value;
    notifyListeners();
  }

  void setTemoSelectedCard(int value) {
    _tempSelectedCard = value;
    notifyListeners();
  }

  void setCardList(List<CardDetails> cards) {
    _cardList = cards;
    notifyListeners();
  }

  String getSelectedRadioValue() => _selectedRadioValue;

  int getSelectedCardId() => _selectedCard;

  int getTempSelectedCard() {
    return _tempSelectedCard;
  }

  List<CardDetails> getCardDetails() => _cardList;

  CardDetails getSelectedCard() {
    var cardDetail = CardDetails();
    for (var card in _cardList) {
      if (_selectedCard != 0) {
        if (card.id == _selectedCard) {
          cardDetail = card;
        }
      } else if (card.isDefault == 1) {
        cardDetail = card;
      }
    }
    return cardDetail;
  }
}
