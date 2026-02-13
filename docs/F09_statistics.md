# F09 — 基础阅读统计

> **分支**: `feat/F09-statistics`
> **日期**: 2026-02-12
> **状态**: ✅ 已完成
> **测试**: 3 tests (Stats Calculation & Controller), 0 failures
> **依赖**: F01-F08

---

## 1. 本次变更概述

提供用户阅读数据的统计功能，包括已读书籍数量、正在阅读数量、累计阅读页数和平均评分。
为此在 `books` 表中添加了 `pages` 字段。

---

## 2. API 变更

### Public/Protected Routes

| 方法 | 路径 | 描述 | Params |
|------|------|------|--------|
| `GET` | `/api/v1/me/stats` | 获取当前用户的统计概览（主推荐，与 `/me` 资源保持一致） | - |
| `GET` | `/api/v1/stats` | `/me/stats` 的快捷别名 | - |

**Router Implementation**:
```elixir
scope "/api/v1", ... do
  pipe_through [:api, :auth]
  get "/me/stats", StatsController, :show
  get "/stats", StatsController, :show
end
```
Use as: `GET /api/v1/me/stats` (Standard) or `GET /api/v1/stats` (Shortcut).

**响应示例**:
```json
{
  "data": {
    "read_count": 12,
    "reading_count": 3,
    "total_pages_read": 3500,
    "average_rating": 4.5
  }
}
```

---

## 3. 实现细节

### Schema: `Book`
- 新增字段: `pages` (integer, > 0).

### Context: `Accounts.get_user_stats(user_id)`
- **read_count**: 统计 status="read" 的记录。
- **reading_count**: 统计 status="reading" 的记录。
- **total_pages_read**: 关联 `UserBook` -> `Book`，累加 status="read" 的书籍页数。
- **average_rating**: 统计所有已评分记录的平均值。

---

## 4. 已知限制
- 统计是实时查询计算的 (Live Calculation)。数据量大时可能需要在 F09+ 引入缓存或计数器列。
