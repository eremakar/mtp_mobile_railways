import 'package:equatable/equatable.dart';
import 'package:passflow_app/data/models/boarding_model.dart';
import 'package:passflow_app/data/models/ticket_model.dart';
import 'package:passflow_app/data/models/tickets_search_entry_model.dart';

abstract class BoardingsListEvent extends Equatable {
  const BoardingsListEvent();

  @override
  List<Object?> get props => [];
}

class LoadTicketsEvent extends BoardingsListEvent {
  // final TicketsSearchModel searchModel;

  // const LoadTicketsEvent(this.searchModel);

  // @override
  // List<Object?> get props => [searchModel];
}

class ClearErrorEvent extends BoardingsListEvent {
  const ClearErrorEvent();
}

class LoadTicketsByFilterEvent extends BoardingsListEvent {
  final Map<String, dynamic> searchModel;
  final String? historyKey;

  const LoadTicketsByFilterEvent(this.searchModel, {this.historyKey});

  @override
  List<Object?> get props => [searchModel, historyKey];
}

class PressBoardingEvent extends BoardingsListEvent {
  final TicketModel model;

  const PressBoardingEvent(this.model);

  @override
  List<Object?> get props => [model];
}

class WatchTicketsEvent extends BoardingsListEvent {}

class InitTicketsEvent extends BoardingsListEvent {}

class _TicketsBoxUpdated extends BoardingsListEvent {
  final List<TicketModel> tickets;
  _TicketsBoxUpdated(this.tickets);
}

class ClearBoardingSuccessEvent extends BoardingsListEvent {}

class RegisterBoardingEvent extends BoardingsListEvent {
  final TicketModel model;
  RegisterBoardingEvent(this.model);
}

class CancelBoardingEvent extends BoardingsListEvent {
  final TicketModel model;
  CancelBoardingEvent(this.model);
}

class DenyBoardingEvent extends BoardingsListEvent {
  final TicketModel model;
  DenyBoardingEvent(this.model);
}

class SaveSearchToHistoryEvent extends BoardingsListEvent {
  final TicketSearchEntryModel entry;
  final List<TicketModel> ticketsSnapshot; // чтобы офлайн был список
  SaveSearchToHistoryEvent(this.entry, this.ticketsSnapshot);
}

class LoadSearchHistoryEvent extends BoardingsListEvent {}

class SelectHistoryEntryEvent extends BoardingsListEvent {
  final TicketSearchEntryModel entry;
  SelectHistoryEntryEvent(this.entry);
}

class ClearSearchHistoryEvent extends BoardingsListEvent {}
