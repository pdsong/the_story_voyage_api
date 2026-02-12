# F08 — 评分与评论

> **分支**: `feat/F08-reviews`
> **日期**: 2026-02-12
> **状态**: ✅ 已完成
> **测试**: 9 tests (Context & Controller), 0 failures
> **依赖**: F01-F07

---

## 1. 本次变更概述

允许用户在追踪图书状态的同时，添加评分（1-5）和撰写公开评论（标题+内容）。
提供了公开 API 来获取某本书的评论列表。

---

## 2. API 变更

### Protected Routes (需要登录)

| 方法 | 路径 | 描述 | Body / Params |
|------|------|------|----------------|
| `POST` | `/api/v1/me/books` | 添加/更新图书状态及评论 | `review_title`, `review_content`, `rating`, `status`, `book_id` |

**示例 Body**:
```json
{
  "book_id": 1,
  "status": "read",
  "rating": 5,
  "review_title": "强烈推荐",
  "review_content": "这本书改变了我的人生..."
}
```

### Public Routes (无需登录)

| 方法 | 路径 | 描述 | Params |
|------|------|------|--------|
| `GET` | `/api/v1/books/:book_id/reviews` | 获取某本书的评论列表 | - |

**响应示例**:
```json
{
  "data": [
    {
      "id": 101,
      "rating": 5,
      "title": "强烈推荐",
      "content": "这本书改变了我的人生...",
      "user": {
        "id": 1,
        "username": "elixir_fan"
      },
      "updated_at": "2026-02-12T10:00:00Z"
    }
  ]
}
```

---

## 3. 实现细节

### Schema: `UserBook`
- 新增字段: `review_title` (max 100 chars), `review_content` (max 2000 chars)。
- 复用 `rating` 字段。

### Context: `Accounts`
- `list_reviews_for_book(book_id)`: 查询具有非空 `review_content` 的记录，按更新时间倒序排列。

### Controllers
- `UserBookController`: 更新 `create` action 以接收 review 参数。
- `ReviewController`: 新增 `index` action 处理公开评论查询。

---

## 4. 已知待办 (下一步 F09)
- [ ] Basic Statistics (阅读统计)
