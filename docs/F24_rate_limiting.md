# F24: API 限流 (Rate Limiting)

## 功能概述
为了保护 API 免受滥用，系统实现了基于 IP 的请求速率限制。

## 限制规则
*   **标识**: 客户端 IP 地址
*   **额度**: 每个 IP 每 60 秒最多允许 100 次请求
*   **范围**: 适用于所有 `/api/v1/*` 接口

## 响应
当请求超过限制时，API 将返回 `429 Too Many Requests` 状态码。

### 响应示例
**Status**: `429 Too Many Requests`

```json
{
  "errors": {
    "detail": "Rate limit exceeded"
  }
}
```

## 配置
限流参数可在 `TheStoryVoyageApiWeb.Plugs.RateLimiter` 模块中配置：
*   `@params.limit`: 最大请求数 (默认 100)
*   `@params.window`: 时间窗口 (默认 60000ms)
