# F10 — User Profile API

> **分支**: `feat/F10-user-profile` (实际上仍在 `feat/F10-reading-challenges` 分支上开发，后续合并)
> **日期**: 2026-02-15
> **状态**: ✅ 已完成
> **测试**: 6 tests (UserControllerTest)
> **依赖**: F03

---

## 1. 本次变更概述

实现了用户资料查看与编辑功能，包括当前用户（Protected）和公开资料（Public）。
修复了 API 路由顺序问题（`/users/me` vs `/users/:username`）。

---

## 2. API 变更

### Protected Routes (需要登录)

| 方法 | 路径 | 描述 |
|------|------|------|
| `GET` | `/api/v1/users/me` | 获取当前登录用户的完整资料 (含 email, settings) |
| `PUT` | `/api/v1/users/me` | 更新资料 (display_name, bio, location, privacy_level) |

**更新资料 (`PUT /users/me`)**:
```json
{
  "user": {
    "display_name": "New Name",
    "bio": "Hello World",
    "privacy_level": "private"
  }
}
```

### Public Routes (无需登录)

| 方法 | 路径 | 描述 |
|------|------|------|
| `GET` | `/api/v1/users/:username` | 获取公开用户资料 (不含敏感信息) |
| `GET` | `/api/v1/users/:username/books` | 获取用户的公开书架 (若 privacy=private 则 403) |

---

## 3. 实现细节

### Schemas
- `User`: 新增 `profile_changeset`，限制可编辑字段 (禁止修改 username, email, role 等)。

### Context: `Accounts`
- `update_user_profile/2`: 使用 `profile_changeset` 安全更新。
- `get_public_user/1`: 按用户名查找用户。

### Controllers
- `UserController`: 处理 profile 逻辑和隐私检查。
- `UserJSON`: 区分 `:private` (完整) 和 `:public` (脱敏) 视图。

---

## 4. 后续计划
- [ ] F11: 关注与好友系统 (User Follows & Friends)
