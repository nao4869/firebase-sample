/// ISO8601文字列を2020年10月10日の、フォーマットへ変換する関数
/// @param originalDatetime : フォーマット変換前のISO8601文字列
/// @return formattedYearToDay : フォーマット変換後の作成日文字列
extension CreatedAtFormatExtention on String {
  String setCreatedAtFormat(
    String originalDateTime, {
    bool isDisplayYear = true,
  }) {
    String yearToDay;
    if (originalDateTime != null && originalDateTime.length > 9) {
      yearToDay = originalDateTime.substring(0, 10);
    }
    if (yearToDay != null &&
        originalDateTime.length > 9 &&
        !originalDateTime.contains('年')) {
      final year = yearToDay.substring(0, 4);
      final month = yearToDay.substring(5, 7);
      final day = yearToDay.substring(8, 10);

      /// isDisplayYearの値に応じて、年月の表示を切り替え
      if (isDisplayYear) {
        final formattedYearToDay = year + '年' + month + '月' + day + '日';
        return formattedYearToDay;
      } else {
        final formattedYearToDay = month + '月' + day + '日';
        return formattedYearToDay;
      }
    }
    return originalDateTime;
  }
}
