# F25: API 文档 (API Documentation)

## 功能概述
使用 `open_api_spex` 自动生成符合 OpenAPI 3.0 标准的 API 文档，并提供 Swagger UI 进行在线交互。

## 访问地址

### Swagger UI
*   **URL**: `/api/swagger`
*   **功能**: 在浏览器中查看 API 定义、Schema 模型，并可直接发送请求测试接口。

### OpenAPI Spec (JSON)
*   **URL**: `/api/openapi`
*   **功能**: 获取 JSON 格式的 API 定义，用于导入 Postman 或其他工具。

## 目前覆盖的模块
*   `Auth`: 注册、登录
*   `Books`: 书籍列表、书籍详情

## 开发指南
在 Controller 中使用 `OpenApiSpex` 宏进行注解即可自动生成文档。

```elixir
  operation :index,
    summary: "List items",
    responses: %{
      200 => {"List", "application/json", MySchema}
    }
```
