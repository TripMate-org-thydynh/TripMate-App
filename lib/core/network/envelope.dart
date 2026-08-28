/// Nguồn sự thật DUY NHẤT cho việc bóc envelope response của backend.
///
/// BE (NestJS `TransformInterceptor`) bọc mọi response trong
/// `{ success, data, timestamp }`. Cả `ApiClient` và `ApiService` đều dùng
/// hàm này để trả về đúng phần `data` — tránh mỗi nơi tự viết một kiểu.
dynamic unwrapEnvelope(dynamic body) {
  if (body is Map && body.containsKey('success') && body.containsKey('data')) {
    return body['data'];
  }
  return body;
}
