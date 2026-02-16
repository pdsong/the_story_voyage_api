# F14 — Notifications

> **分支**: `feat/F14-notifications` (实际上仍在 `feat/F10-reading-challenges` 分支上开发，后续合并)
> **日期**: 2026-02-15
> **状态**: ✅ 已完成
> **测试**: NotificationsTest, NotificationControllerTest, SocialTest
> **依赖**: F11

---

## 1. 本次变更概述

实现了 **通知系统 (Notification System)**，在关键社交互动（被关注、收到好友请求、接受好友请求）发生时通知用户。同时包含简单的邮件通知逻辑（Mock 实现）。

---

## 2. API 变更

### Notifications (通知)

| 方法 | 路径 | 描述 |
|------|------|------|
| `GET` | `/api/v1/me/notifications` | 获取当前用户的通知列表 (默认按时间倒序) |
| `PUT` | `/api/v1/me/notifications/:id/read` | 将指定通知标记为已读 |
| `PUT` | `/api/v1/me/notifications/read-all` | 将所有未读通知标记为已读 |

**响应示例 (GET)**:
```json
{
  "data": [
    {
      "id": 201,
      "type": "new_follower",
      "data": {},
      "read_at": null,
      "inserted_at": "2026-02-15T...",
      "actor": { "id": 5, "username": "bob", ... }
    },
    {
      "id": 202,
      "type": "friend_request_received",
      "data": { "request_id": 10 },
      "read_at": "2026-02-14T...",
      "actor": { "id": 6, "username": "charlie", ... }
    }
  ]
}
```

---

## 3. 实现细节

### Schema: `Notification`
- `recipient_id`: 接收者。
- `actor_id`: 触发者 (如关注者)。
- `type`: `new_follower`, `friend_request_received`, `friend_request_accepted`。
- `data`: 额外数据 (如 `request_id`)。
- `read_at`: 已读时间戳。

### Context: `Notifications`
- `create_notification/1`: 创建并触发邮件发送。
- `list_notifications/2`: 分页查询。
- `mark_as_read/1`: 标记单个。
- `mark_all_as_read/1`: 批量标记。

### Integration
- **Social Context Updates**:
  - `follow_user`: 触发 `new_follower` 通知。
  - `send_friend_request`: 触发 `friend_request_received` 通知。
  - `accept_friend_request`: 触发 `friend_request_accepted` 通知。

### Email (Mock)
- `Notifications.Notifier`: 异步 Task 模拟发送邮件，记录日志。

### Test Coverage
- `NotificationsTest`: Context 逻辑（创建、列表、已读标记）。
- `NotificationControllerTest`: API 路由与响应验证。
- `SocialTest`: 验证社交操作正确触发通知生成。
