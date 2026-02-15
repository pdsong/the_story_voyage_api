# F12 — Custom Tags

> **分支**: `feat/F12-custom-tags` (实际上仍在 `feat/F10-reading-challenges` 分支上开发，后续合并)
> **日期**: 2026-02-15
> **状态**: ✅ 已完成
> **测试**: 13 tests (ReadingTest, UserBookControllerTest)
> **依赖**: F07

---

## 1. 本次变更概述

实现了用户自定义标签功能，允许用户为自己的藏书添加任意标签（如 "favorite", "summer-2025"），并按标签筛选书籍。

---

## 2. API 变更

### Tags (标签)

| 方法 | 路径 | 描述 |
|------|------|------|
| `POST` | `/api/v1/me/books/:id/tags` | 为书籍添加标签 (201 Created) |
| `DELETE` | `/api/v1/me/books/:id/tags/:tag_name` | 移除标签 (204 No Content) |
| `GET` | `/api/v1/me/books/tags` | 获取当前用户使用过的所有唯一标签 |
| `GET` | `/api/v1/me/books?tag=xxx` | 按标签筛选藏书 |

---

## 3. 实现细节

### Schema
- `UserBookTag`: 关联 `UserBook`，存储 `tag_name`。
- `UserBook`: 新增 `has_many :tags` 关联。

### Context: `Reading`
- `add_tag/2`: 添加标签，自动转小写并去除首尾空格，防止重复 (`user_book_id` + `tag_name` 唯一)。
- `remove_tag/2`: 移除标签。
- `list_user_tags/1`: 聚合查询用户所有用过的标签。

### Context: `Accounts`
- `list_user_books/2`: 更新查询逻辑，支持 `tag` 参数进行 `join` 筛选。

### Note
- 标签仅限用户自己管理，无法查看他人的标签（MVP 阶段）。
