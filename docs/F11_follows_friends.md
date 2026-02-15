# F11 — Follows & Friends

> **分支**: `feat/F11-follow-friends` (实际上仍在 `feat/F10-reading-challenges` 分支上开发，后续合并)
> **日期**: 2026-02-15
> **状态**: ✅ 已完成
> **测试**: 11 tests (SocialTest, SocialControllerTest)
> **依赖**: F10

---

## 1. 本次变更概述

实现了完整的社交关系系统，包括单向关注、屏蔽用户及好友请求流程。
明确了屏蔽用户会自动取消关注并双向解除好友关系。

---

## 2. API 变更

### Follows (关注)

| 方法 | 路径 | 描述 |
|------|------|------|
| `POST` | `/api/v1/users/:id/follow` | 关注用户 (201 Created) |
| `DELETE` | `/api/v1/users/:id/follow` | 取消关注 (204 No Content) |
| `GET` | `/api/v1/me/followers` | 我的关注者列表 |
| `GET` | `/api/v1/me/following` | 我关注的用户列表 |

### Blocks (屏蔽)

| 方法 | 路径 | 描述 |
|------|------|------|
| `POST` | `/api/v1/users/:id/block` | 屏蔽用户 (自动取关、删好友) |
| `DELETE` | `/api/v1/users/:id/block` | 取消屏蔽 |

### Friends (好友)

| 方法 | 路径 | 描述 |
|------|------|------|
| `POST` | `/api/v1/users/:id/friend_request` | 发送好友请求 |
| `GET` | `/api/v1/me/friend_requests` | 查看待处理的好友请求 |
| `GET` | `/api/v1/me/friends` | 查看好友列表 |
| `PUT` | `/api/v1/friend_requests/:id/accept` | 接受请求 (自动双向关注) |
| `PUT` | `/api/v1/friend_requests/:id/reject` | 拒绝请求 |

---

## 3. 实现细节

### Schema
- `UserFollow`: 存储关注关系 (包含 `is_friend` 字段)。
- `UserBlock`: 存储屏蔽关系。
- `FriendRequest`: 存储请求状态 (`pending`, `accepted`, `rejected`)。

### Context: `Social`
- `block_user/2`: 事务操作，创建屏蔽记录的同时，**强制删除**双方的关注记录和好友请求记录。
- `accept_friend_request/2`: 事务操作，更新请求状态为 `accepted`，并**自动创建双向关注** (`is_friend=true`)。

### Note
- **内容过滤**: 屏蔽用户后的动态流过滤将在 **F13 Activity Feed** 中实现。当前仅处理关系层面的阻断。
