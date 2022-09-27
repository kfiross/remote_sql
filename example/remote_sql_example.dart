import 'package:remote_sql/remote_sql.dart';

extension StringExtension on String {
  bool isOnlyHebrew(){
    final charset = ['א','ב','ג','ד','ה','ו','ז','ח','ט','י','כ','ל','מ','נ','ס','ע','פ','צ','ק','ר','ש','ת','ם','ן','ץ','ף','ך',];
    for(var c in split('')){
      if([' ', '-', '/'].contains(c)) continue;
      if(!charset.contains(c)){
        return false;
      }
    }
    return true;
  }
}

void main() {
  print("ישי-אור".isOnlyHebrew());
  print("ישי/אור".isOnlyHebrew());
}
