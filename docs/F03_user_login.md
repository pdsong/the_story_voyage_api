# F03 — 用户登录 & JWT

> **分支**: `feat/F03-user-login`
> **日期**: 2026-02-12
> **状态**: ✅ 已完成
> **测试**: 49 tests, 0 failures (含 F01/F02)
> **依赖**: F02

---

## 1. 本次变更概述

实现基于 JWT 的用户登录认证机制。用户通过邮箱密码换取 Token，API 通过 Bearer Token 识别用户身份。

---

## 2. API 端点

### POST `/api/v1/auth/login`

**请求体：**
```json
{
  "email": "dev@example.com",
  "password": "password123"
}
```

**成功响应 (200)：**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "elixir_dev",
    "email": "dev@example.com",
    "display_name": null,
    "role": "user"
  }
}
```

**失败响应 (401)：**
```json
{
  "errors": {
    "detail": "Unauthorized"
  }
}
```

---

## 3. 认证机制 (AuthPlug)

- **Header**: `Authorization: Bearer <token>`
- **验证逻辑**:
    1. 提取 Token
    2. `Token.verify_token/1` 验证签名和有效期 (2天)
    3. `user_id` 必须存在于 Claims
    4. 数据库查询用户是否存在
    5. 成功 -> `assign(conn, :current_user, user)`
    6. 失败 -> `401 Unauthorized` + halt

---

## 4. 文件变更清单

### 新增文件

| 文件 | 说明 |
|------|------|
| `lib/the_story_voyage_api/token.ex` | Joken 封装 (生成/验证) |
| `lib/.../plugs/auth_plug.ex` | 认证中间件 |
| `test/.../token_test.exs` | Token 单元测试 |
| `test/.../plugs/auth_plug_test.exs` | Plug 单元测试 |

### 修改文件

| 文件 | 变更 |
|------|------|
| `mix.exs` | 添加 `{:joken, "~> 2.6"}` |
| `config/config.exs` | 配置 Joken signer |
| `lib/.../accounts/accounts.ex` | 新增 `authenticate_user/2` |
| `lib/.../controllers/auth_controller.ex` | 新增 `login/2` Action |
| `lib/.../router.ex` | 新增 `POST /auth/login` 路由 |

---

## 5. Token Payload (Claims)

```json
{
  "iss": "TheStoryVoyageApi",
  "aud": "TheStoryVoyageApp",
  "exp": 1740000000,
  "user_id": 1,
  "role": "user"
}
```

---

## 6. 测试覆盖 (新增 8 个)

| 测试文件 | 内容 |
|---------|------|
| `token_test.exs` | 生成/验证 Token, 检查 Claims (user_id, role) |
| `auth_plug_test.exs` | 有效 Token ( assigns user ), 无效 Token (401), 缺失 Token (401) |
| `auth_controller_test.exs` | 登录成功 (返回 token+user), 密码错误 (401), 邮箱不存在 (401) |

---

## 7. 已知待办 (下一步 F04)

- [ ] 实现密码重置流程 (Request Reset -> Email -> Reset Password)
