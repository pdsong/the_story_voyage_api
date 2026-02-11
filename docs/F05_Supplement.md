# F05 补充 — 用户角色管理工具

> **分支**: `feat/F05-supplement-role-tool`
> **日期**: 2026-02-12
> **类型**: 运维工具 (DevOps)

---

## 1. 概述

为了方便在开发和运营过程中管理用户权限（例如测试管理员功能），我们提供了一个 **Mix Task** 命令行工具，无需直接操作数据库 SQL 即可提升或降级用户角色。

---

## 2. 工具介绍

**命令**: `mix story_voyage.promote_user`
**位置**: `lib/mix/tasks/story_voyage/promote_user.ex`

此工具根据邮箱查找用户，并更新其 `role` 字段。

### 2.1 使用方法 (Usage)

在项目根目录下运行：

```bash
mix story_voyage.promote_user <email> <role>
```

- `<email>`: 用户注册邮箱
- `<role>`: 目标角色，支持 `admin` (管理员), `librarian` (图书管理员), `user` (普通用户)

### 2.2 示例 (Examples)

**场景 1: 提升某用户为超级管理员**
```bash
mix story_voyage.promote_user songpeidong@gmail.com admin
# Output: Successfully promoted songpeidong@gmail.com to admin.
```

**场景 2: 降级为普通用户**
```bash
mix story_voyage.promote_user bad_actor@example.com user
# Output: Successfully promoted bad_actor@example.com to user.
```

**场景 3: 用户不存在**
```bash
mix story_voyage.promote_user nobody@example.com admin
# Output: User with email nobody@example.com not found.
```

---

## 3. 实现细节

- **模块**: `Mix.Tasks.StoryVoyage.PromoteUser`
- **逻辑**:
    1. 启动应用 (`Mix.Task.run("app.start")`) 以加载 Repo。
    2. 调用 `Accounts.get_user_by_email/1` 查找用户。
    3. 调用 `Accounts.update_user/2` 更新角色。
    4. 打印操作结果 (Info 或 Error)。

---

## 4. 为什么使用此工具？

- **安全性**: 避免直接连接生产数据库执行 `UPDATE users SET ...`，减少误操作风险。
- **便捷性**: 开发测试 F05 等需要权限的功能时，可以快速生成测试账号。
- **规范性**: 将运维操作代码化，纳入版本控制。
