# F08 — 评分与评论

> **分支**: `feat/F08-reviews`
> **日期**: 2026-02-13 (Updated)
> **状态**: ✅ 已完成 (Remediated)
> **测试**: 99 tests (Total), 0 failures
> **依赖**: F01-F07

---

## 1. 本次变更概述 (F08 Remediation)

允许用户在追踪图书状态的同时，添加评分（**0.25 增量**）和撰写公开评论（标题+内容+**剧透标记**）。
提供了公开 API 来获取某本书的评论列表。
**自动聚合**：用户评分后，书籍的 `average_rating` 和 `ratings_count` 会自动更新。

---

## 2. API 变更

### Protected Routes (需要登录)

| 方法 | 路径 | 描述 | Body / Params |
|------|------|------|----------------|
| `POST` | `/api/v1/me/books` | 添加/更新图书状态及评论 | `review_title`, `review_content`, `review_contains_spoilers`, `rating`, `status`, `book_id` |

**示例 Body**:
```json
{
  "book_id": 1,
  "status": "read",
  "rating": 4.25,
  "review_title": "强烈推荐 (含剧透)",
  "review_content": "这本书结局...",
  "review_contains_spoilers": true
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
      "rating": 4.25,
      "title": "强烈推荐",
      "content": "这本书改变了我的人生...",
      "contains_spoilers": true,
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
- **Rating**: 修改为 `:float`，支持 0.25, 0.5, 0.75 等增量 (Range: 0.25 - 5.0).
- **Spoilers**: 新增 `review_contains_spoilers` (:boolean, default: false).
- 其他: `review_title` (max 100), `review_content` (max 2000).

### Logic: Aggregation
- `Accounts.track_book/3` 和 `untrack_book/2` 会触发 `recalculate_book_rating(book_id)`。
- **Recalculation**:
    - 计算该书所有非空评分的平均值 (`avg(rating)`) 和总数 (`count(id)`).
    - 更新 `books` 表的 `average_rating` 和 `ratings_count`。

### Context: `Accounts`
- `list_reviews_for_book(book_id)`: 查询具有非空 `review_content` 的记录，按更新时间倒序排列。

### Controllers
- `UserBookController`: 接收 `rating` (float) 和 `review_contains_spoilers`.
- `ReviewController`: 返回包含 `contains_spoilers` 的 JSON。

---

## 4. 后续计划
- [ ] F09: Basic Statistics (已完成)
- [ ] F10: Reading Challenges (Next)
