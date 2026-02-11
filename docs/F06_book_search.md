# F06 — 图书搜索与过滤

> **分支**: `feat/F06-book-search`
> **日期**: 2026-02-12
> **状态**: ✅ 已完成
> **测试**: 11 tests (search specific), 0 failures (总 F01-F06 覆盖)
> **依赖**: F05

---

## 1. 本次变更概述

在现有的图书列表 API (`GET /api/v1/books`) 上增加了搜索和过滤功能。支持按标题或描述的关键词搜索，以及按 Genre (分类) 和 Mood (氛围) 过滤。

---

## 2. API 变更

### `GET /api/v1/books`

新增 Query Parameters 支持：

| 参数 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `q` | string | 关键词搜索 (标题或描述) | `Harry Potter` |
| `genre_id` | integer | 按 Genre ID 过滤 | `1` |
| `mood_id` | integer | 按 Mood ID 过滤 | `5` |
| `limit` | integer | 每页数量 (默认 20) | `10` |
| `offset` | integer | 偏移量 (默认 0) | `0` |

**示例请求**:
```http
GET /api/v1/books?q=Fantasy&genre_id=1&mood_id=2
```

---

## 3. 实现细节

### Books Context (`list_books/1`)

使用了 Ecto 的可组合查询 (Composable Queries) 模式：

```elixir
Book
|> search_by_keyword(params["q"])
|> filter_by_genre(params["genre_id"])
|> filter_by_mood(params["mood_id"])
|> limit(...)
```

**注意**:
- `search_by_keyword`: 使用 `like` (SQLite 兼容) 进行模糊匹配。
- `filter_by_genre/mood`: 使用 `join` 关联查询。

---

## 4. 测试覆盖

在 `books_test.exs` 和 `book_controller_test.exs` 中增加了相关测试用例：
- 关键词搜索 (含大小写, 模糊)
- Genre 过滤
- Mood 过滤
- 组合查询 (Search + Filter)

---

## 5. 已知待办 (下一步 F07)

- [ ] Reading Status Tracking (Want to Read, Reading, Read)
- [ ] User Progress
