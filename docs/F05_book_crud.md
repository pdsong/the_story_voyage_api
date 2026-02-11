# F05 — 图书 CRUD

> **分支**: `feat/F05-book-crud`
> **日期**: 2026-02-12
> **状态**: ✅ 已完成
> **测试**: 66 tests, 0 failures (含 F01-F04)
> **依赖**: F04

---

## 1. 本次变更概述

实现图书的增删改查 (CRUD) 功能。普通用户可查看图书列表和详情，**管理员 (Admin) 和图书管理员 (Librarian)** 可创建和更新图书信息及关联 (Author, Genre, Mood)。

---

## 2. API 端点

### 2.1 公开访问

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/v1/books` | 获取图书列表 (分页) |
| GET | `/api/v1/books/:id` | 获取图书详情 (含关联信息) |

**分页参数**: `limit` (默认 20), `offset` (默认 0)

### 2.2 受限访问 (Admin / Librarian)

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/v1/books` | 创建图书 |
| PUT | `/api/v1/books/:id` | 更新图书 |

**Header**: `Authorization: Bearer <token>`

---

## 3. 数据关联处理

创建/更新图书时，可以通过 ID 列表关联现有实体：

**Request Body (示例):**
```json
{
  "book": {
    "title": "The Way of Kings",
    "description": "Epic fantasy novel...",
    "author_ids": [1, 2],
    "genre_ids": [5],
    "mood_ids": [3, 8]
  }
}
```

---

## 4. 权限控制 (RBAC)

- **AuthPlug**: 验证 User Token
- **RequireRole Plug**: 验证用户角色
    - 允许角色: `["admin", "librarian"]`
    - 禁止访问返回: `403 Forbidden`

---

## 5. 文件变更清单

### 新增文件

| 文件 | 说明 |
|------|------|
| `lib/.../controllers/book_controller.ex` | 图书控制器 |
| `lib/.../controllers/book_json.ex` | JSON 视图 |
| `lib/.../plugs/require_role.ex` | 角色验证插件 |
| `test/.../books_test.exs` | Context 测试 |
| `test/.../controllers/book_controller_test.exs` | Controller / RBAC 测试 |

### 修改文件

| 文件 | 变更 |
|------|------|
| `lib/.../books/book.ex` | 关联增加 `on_replace: :delete` |
| `lib/.../books/books.ex` | `create/update` 处理关联, 增加 `create_genre/mood` |
| `lib/.../router.ex` | 增加 `auth` pipeline, `book` 路由及权限管道 |

---

## 6. 测试覆盖 (新增 9 个)

| 测试文件 | 内容 |
|---------|------|
| `books_test.exs` | 关联创建/更新, 分页查询 |
| `book_controller_test.exs` | 公开接口访问, Admin创建成功, User创建失败(403), Anon创建失败(401) |

---

## 7. 已知待办 (下一步 F06)

- [ ] 图书搜索 (Search)
- [ ] 按 Genre/Mood 筛选
