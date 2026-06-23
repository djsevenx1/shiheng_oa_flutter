part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const SPLASH = _Paths.SPLASH;
  static const LOGIN = _Paths.LOGIN;
  static const HOME = _Paths.HOME;
  static const WORKFLOW = _Paths.WORKFLOW;
  static const WORKFLOW_DETAIL = _Paths.WORKFLOW_DETAIL;
  static const WORKFLOW_FORM = _Paths.WORKFLOW_FORM;
  static const REPORT = _Paths.REPORT;
  static const STOCK_REPORT = _Paths.STOCK_REPORT;
  static const ATTENDANCE = _Paths.ATTENDANCE;
  static const CRM = _Paths.CRM;
  static const CRM_CLIENT_DETAIL = _Paths.CRM_CLIENT_DETAIL;
  static const PROJECT = _Paths.PROJECT;
  static const PROJECT_DETAIL = _Paths.PROJECT_DETAIL;
  static const SETTINGS = _Paths.SETTINGS;
  static const MAP = _Paths.MAP;
}

abstract class _Paths {
  _Paths._();

  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const WORKFLOW = '/workflow';
  static const WORKFLOW_DETAIL = '/workflow/detail';
  static const WORKFLOW_FORM = '/workflow/form';
  static const REPORT = '/report';
  static const STOCK_REPORT = '/report/stock';
  static const ATTENDANCE = '/attendance';
  static const CRM = '/crm';
  static const CRM_CLIENT_DETAIL = '/crm/client/detail';
  static const PROJECT = '/project';
  static const PROJECT_DETAIL = '/project/detail';
  static const SETTINGS = '/settings';
  static const MAP = '/map';
}
