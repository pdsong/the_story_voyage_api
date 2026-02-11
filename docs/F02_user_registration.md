# F02 — 用户注册

> **分支**: `feat/F02-user-registration`
> **日期**: 2026-02-11
> **状态**: ✅ 已完成
> **测试**: 41 tests, 0 failures (含 F01)
> **依赖**: F01

---

## 1. 本次变更概述

实现用户注册功能：通过 `POST /api/v1/auth/register` 端点，用户可使用 username + email + password 完成注册。密码使用 `bcrypt` 进行安全哈希存储。

---

## 2. API 端点

### POST `/api/v1/auth/register`

**请求体：**
```json
{
  "user": {
    "username": "elixir_dev",
    "email": "dev@example.com",
    "password": "password123"
  }
}
```

**成功响应 (201)：**
```json
{
  "user": {
    "id": 1,
    "username": "elixir_dev",
    "email": "dev@example.com",
    "display_name": null,
    "role": "user",
    "inserted_at": "2026-02-11T14:00:00Z"
  }
}
```

**失败响应 (422)：**
```json
{
  "errors": {
    "email": ["has already been taken"],
    "password": ["should be at least 8 character(s)"]
  }
}
```

### 验证规则

| 字段 | 验证 |
|------|------|
| `username` | 必填, 3-30 字符, 唯一 |
| `email` | 必填, 有效格式, 唯一 |
| `password` | 必填, 8-100 字符, bcrypt 哈希存储 |

---

## 3. 文件变更清单

### 新增文件

| 文件 | 说明 |
|------|------|
| `lib/.../controllers/auth_controller.ex` | 注册端点, 参数验证, 错误格式化 |
| `lib/.../controllers/fallback_controller.ex` | 统一错误处理 (changeset/not_found/unauthorized) |
| `test/.../controllers/auth_controller_test.exs` | 8 个集成测试 |

### 修改文件

| 文件 | 变更 |
|------|------|
| `mix.exs` | 添加 `{:bcrypt_elixir, "~> 3.0"}` 依赖 |
| `lib/.../accounts/user.ex` | `registration_changeset` 使用 `Bcrypt.hash_pwd_salt/1` |
| `lib/.../accounts/accounts.ex` | 新增 `register_user/1` 函数 |
| `lib/.../router.ex` | 添加 `POST /api/v1/auth/register` 路由, scope 改为 `/api/v1` |
| `test/.../accounts/user_test.exs` | 扩展: bcrypt 验证 + `register_user/1` 集成测试 (共14个) |

### 新增依赖

| 包名 | 版本 | 用途 |
|------|------|------|
| `bcrypt_elixir` | 3.3.2 | 密码哈希 (bcrypt 算法) |
| `comeonin` | 5.5.1 | bcrypt_elixir 的依赖 |

---

## 4. 前端对接说明

### 注册流程

```
1. 前端收集 username, email, password
2. POST /api/v1/auth/register  body: { user: { ... } }
3. 成功 → 201, 获取 user 对象
4. 失败 → 422, 解析 errors 对象, 展示在对应字段下方
```

### 错误处理

- `errors` 对象的 key 是字段名 (`username`, `email`, `password`)
- 每个 key 的 value 是错误信息数组
- 前端应根据 key 将错误显示在对应表单字段旁

### 注意事项

- 当前不返回 JWT token（将在 F03 实现）
- 密码以 `$2b$` 前缀的 bcrypt hash 存储
- 所有新用户默认 `role: "user"`, `privacy_level: "public"`

---

## 5. 测试覆盖

| 测试文件 | 测试数 | 覆盖场景 |
|---------|--------|---------|
| `user_test.exs` | 14 | changeset 验证 + bcrypt 哈希 + register_user 集成 |
| `auth_controller_test.exs` | 8 | 201 成功 / 422 重复邮箱 / 422 重复用户名 / 422 缺字段 / 422 密码太短 / 422 邮箱格式 / 422 缺 user 参数 / 数据库 hash 验证 |

---

## 6. 已知待办 (下一步 F03)

- [ ] 实现 `POST /api/v1/auth/login` → 返回 JWT token
- [ ] 实现 `AuthPlug` 中间件验证 Bearer token
- [ ] 注册成功后也返回 JWT token
