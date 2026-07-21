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
  static const PROJECT = _Paths.PROJECT;
  static const PROJECT_DETAIL = _Paths.PROJECT_DETAIL;
  static const TASK = _Paths.TASK;
  static const TASK_DETAIL = _Paths.TASK_DETAIL;
  static const TASK_CREATE = _Paths.TASK_CREATE;
  static const TOPIC = _Paths.TOPIC;
  static const SH_REPORT = _Paths.SH_REPORT;
  static const ARCHIVE = _Paths.ARCHIVE;
  static const FAVORITE = _Paths.FAVORITE;
  static const HELP = _Paths.HELP;
  static const COMPANY = _Paths.COMPANY;
  static const VERSION = _Paths.VERSION;
  static const SETTINGS = _Paths.SETTINGS;
  static const NOTICE = _Paths.NOTICE;
  static const NOTICE_DETAIL = _Paths.NOTICE_DETAIL;
  static const CONTACTS = _Paths.CONTACTS;
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
  static const PROJECT = '/project';
  static const PROJECT_DETAIL = '/project/detail';
  static const TASK = '/task';
  static const TASK_DETAIL = '/task/detail';
  static const TASK_CREATE = '/task/create';
  static const TOPIC = '/topic';
  static const SH_REPORT = '/sh_report';
  static const ARCHIVE = '/archive';
  static const FAVORITE = '/favorite';
  static const HELP = '/help';
  static const COMPANY = '/company';
  static const VERSION = '/version';
  static const SETTINGS = '/settings';
  static const NOTICE = '/notice';
  static const NOTICE_DETAIL = '/notice/detail';
  static const CONTACTS = '/contacts';
}
