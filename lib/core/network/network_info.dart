// بررسی‌کننده اتصال شبکه برای تشخیص آنلاین/آفلاین بودن
// مرتبط با: auth_repository_impl.dart, soap_client.dart

// کلاس انتزاعی NetworkInfo - رابط برای بررسی وضعیت شبکه
abstract class NetworkInfo {
  // getter isConnected - آیا دستگاه به اینترنت متصل است
  // برمی‌گرداند: true اگر متصل باشد، false در غیر این صورت
  Future<bool> get isConnected;
}
