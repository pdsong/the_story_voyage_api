# F10 — Reading Challenges & Goals

> **分支**: `feat/F10-reading-challenges`
> **日期**: 2026-02-13
> **状态**: ✅ 已完成
> **测试**: 10 new tests (Total 97), 0 failures
> **依赖**: F09

---

## 1. 本次变更概述

实现了阅读挑战系统，包括年度阅读目标设定和参与官方挑战（Prompt-based）。

---

## 2. API 变更

### Protected Routes (需要登录)

| 方法 | 路径 | 描述 |
|------|------|------|
| `GET` | `/api/v1/reading_goals` | 获取当前用户的年度目标列表 |
| `POST` | `/api/v1/reading_goals` | 设定或更新年度目标 (Year, Target) |
| `GET` | `/api/v1/challenges` | 获取所有官方挑战列表 |
| `GET` | `/api/v1/challenges/:id` | 获取特定挑战详情 (含 Prompts) |
| `POST` | `/api/v1/challenges/:id/join` | 参与挑战 |
| `POST` | `/api/v1/challenges/:id/entries` | 添加挑战条目 (关联 UserBook 到 Prompt) |

**1. 设定年度目标 (`POST /reading_goals`)**:
```json
{
  "reading_goal": {
    "year": 2026,
    "target": 50
  }
}
```
**Response**:
```json
{
  "data": {
    "id": 1,
    "year": 2026,
    "target": 50,
    "progress": 5,  // 动态计算已读书籍数量
    "user_id": 10
  }
}
```

**2. 参与挑战 (`POST /challenges/:id/join`)**:
```json
// No body required
```
**Response**:
```json
{
  "data": {
    "id": 5,
    "status": "joined",
    "challenge_id": 1,
    "challenge": { ... }
  }
}
```

**3. 完成挑战提示 (`POST /challenges/:id/entries`)**:
```json
{
  "entry": {
    "prompt_id": 12,
    "user_book_id": 45
  }
}
```

---

## 3. 实现细节

### Schemas
- `ReadingGoal`: 存储用户每年的目标数。
- `Challenge`: 挑战本身 (Title, Prompts)。
- `UserChallenge`: 用户参与记录。
- `UserChallengeEntry`: 用户完成 Prompt 的记录 (关联 UserBook)。

### Context: `Challenges`
- 负责管理目标、挑战逻辑。
- `add_entry/3` 会严重 `joined` 状态。

---

## 4. 后续计划
- [ ] F11: 关注与好友系统 (User Follows & Friends)
