enum Method {
  HEAD,
  GET,
  POST,
  PUT,
  PATCH,
  DELETE,
}

Method methodFromString(String method) {
  switch (method) {
    case 'HEAD':
      return Method.HEAD;
    case 'GET':
      return Method.GET;
    case 'POST':
      return Method.POST;
    case 'PUT':
      return Method.PUT;
    case 'PATCH':
      return Method.PATCH;
    case 'DELETE':
      return Method.DELETE;
  }
  throw Exception(
      'Method not found, please make sure it is either of the either of ${Method.values.map((e) => e.toString().replaceAll("Method.", "")).toList().join(", ")}');
}
