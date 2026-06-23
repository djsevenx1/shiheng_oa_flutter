part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const SPLASH = _Paths.SPLASH;
  static const LOGIN = _Paths.LOGIN;
  static const HOME = _Paths.HOME;
  static const WORKFLOW = _Paths.WORKFLOW;
  static const REPORT = _Paths.REPORT;
  static const STOCK_REPORT = _Paths.STOCK_REPORT;
  static const ATTENDANCE = _Paths.ATTENDANCE;
  static const CRM = _Paths.CRM;
  static const SETTINGS = _Paths.SETTINGS;
}

abstract class _Paths {
  _Paths._();

  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const WORKFLOW = '/workflow';
  static const REPORT = '/report';
  static const STOCK_REPORT = '/report/stock';
  static const ATTENDANCE = '/attendance';
  static const CRM = '/crm';
  static const SETTINGS = '/settings';
}
