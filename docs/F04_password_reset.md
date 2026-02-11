# F04 — 密码重置

> **分支**: `feat/F04-password-reset`
> **日期**: 2026-02-12
> **状态**: ✅ 已完成
> **测试**: 57 tests, 0 failures (含 F01-F03)
> **依赖**: F03

---

## 1. 本次变更概述

实现标准的"忘记密码"流程：用户请求重置 -> 系统生成 Token 并发送邮件 -> 用户凭 Token 重置密码。

---

## 2. API 端点

### 2.1 请求重置 (Request Reset)

**POST** `/api/v1/auth/request_reset`

**请求体：**
```json
{
  "email": "dev@example.com"
}
```

**响应 (202 Accepted)：**
```json
{
  "message": "If your email is in our system, you will receive instructions to reset your password."
}
```
*注：无论邮箱是否存在，都返回 202，防止邮箱枚举攻击。*

### 2.2 重置密码 (Reset Password)

**POST** `/api/v1/auth/reset_password`

**请求体：**
```json
{
  "token": "bCJP__rkGhykUbV0RQ9wWFLW4jYtN06FCrGaLxIJR2k",
  "password": "newpassword123"
}
```

**成功响应 (200 OK)：**
```json
{
  "message": "Password reset successfully."
}
```

**失败响应 (404/422)：**
```json
{
  "errors": {
    "detail": "Invalid or expired token"
  }
}
```

---

## 3. 数据库变更

### `users` 表新增字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `reset_password_token` | `string` | 32字节随机Base64字符串, 唯一索引 |
| `reset_password_sent_at` | `datetime` | Token 发送时间, 用于判断过期 (默认1小时) |

---

## 4. 邮件通知 (Dev 环境)

- 使用 `Swoosh` Local Adapter
- 开发环境邮件可在终端日志或 `/dev/mailbox` (需配置 UI) 查看
- 邮件内容包含 Token，生产环境应发送前端重置页面的 URL

---

## 5. 文件变更清单

### 新增文件

| 文件 | 说明 |
|------|------|
| `priv/repo/migrations/...add_reset_password...` | 数据库迁移 |
| `lib/.../accounts/user_notifier.ex` | 邮件发送模块 |
| `lib/.../controllers/password_reset_controller.ex` | 重置流程控制器 |
| `test/.../accounts/reset_test.exs` | Context 单元测试 |
| `test/.../controllers/password_reset_controller_test.exs` | 集成测试 |

### 修改文件

| 文件 | 变更 |
|------|------|
| `lib/.../accounts/user.ex` | Schema 字段 + `password_changeset` |
| `lib/.../accounts/accounts.ex` | `create_reset_token`, `reset_password` |
| `lib/.../router.ex` | 新路由 |

---

## 6. 测试覆盖 (新增 8 个)

| 测试文件 | 内容 |
|---------|------|
| `reset_test.exs` | Token 生成/保存, 密码重置+Token 清除 |
| `password_reset_controller_test.exs` | 邮件发送断言, 完整重置流程, 无效/过期 Token 处理, 密码强度验证 |

---

## 7. 已知待办 (下一步 F05)

- [ ] 实现图书 CRUD (Admin/Librarian 权限)
- [ ] 关联 Author, Genre, Mood 等
