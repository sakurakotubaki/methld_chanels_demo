import 'package:talker/talker.dart';
/// https://pub.dev/packages/talker
/// log出力用のモジュール
Talker talker = Talker(
  /// ログの種類で色を変える
  settings: TalkerSettings(
    colors: {
      TalkerLogType.debug.key: AnsiPen()..green(),
      TalkerLogType.error.key: AnsiPen()..red(),
      TalkerLogType.warning.key: AnsiPen()..yellow(),
      TalkerLogType.info.key: AnsiPen()..blue(),
    }
  )
);