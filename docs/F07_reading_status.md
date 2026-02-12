# F07 — 阅读状态追踪

> **分支**: `feat/F07-reading-status`
> **日期**: 2026-02-12
> **状态**: ✅ 已完成
> **测试**: 10 tests (Context & Controller), 0 failures
> **依赖**: F01-F06

---

## 1. 本次变更概述

允许用户追踪图书的阅读状态（想读、在读、读过、弃书）。
引入了关联表 `user_books`，存储用户与书的关系、状态、评分（预留）和备注。

---

## 2. API 变更

### Protected Routes (需要登录)

| 方法 | 路径 | 描述 | Body / Params |
|------|------|------|----------------|
| `GET` | `/api/v1/me/books` | 获取当前用户的书单 | `?status=reading` (可选) |
| `POST` | `/api/v1/me/books` | 添加/更新图书状态 | `{"book_id": 1, "status": "reading"}` |
| `DELETE` | `/api/v1/me/books/:id` | 移除图书追踪 | - |

**Status 枚举**:
- `want_to_read`
- `reading`
- `read`
- `did_not_finish`

**响应示例 (POST/GET)**:
```json
{
  "data": {
    "status": "reading",
    "rating": null,
    "notes": null,
    "book_id": 1,
    "book": {
      "id": 1,
      "title": "Elixir in Action",
      "authors": [...]
    },
    ...
  }
}
```

---

## 3. 实现细节

### Schema: `UserBook`
- 复合主键/唯一索引: `(user_id, book_id)`，确保每个用户对每本书只有一条记录。
- 字段: `status`, `rating`, `notes`。

### Context: `Accounts`
- `track_book(user, book_id, attrs)`: 使用 Upsert 逻辑 (Insert or Update)。
- `list_user_books(user, params)`: 支持按 Status 过滤，预加载 Book 及关联 (Authors, Genres, Moods)。

### 测试
- `test/support/fixtures/*`: 创建了 `AccountsFixtures` 和 `BooksFixtures` 以支持测试。
- 单元测试: 验证 Upsert 逻辑和过滤。
- 集成测试: 验证 API 流程和权限。

---

## 4. 已知待办 (下一步 F08)

- [ ] Rating (评分) - F08
- [ ] Reviews (书评) - F08
