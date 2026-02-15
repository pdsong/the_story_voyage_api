# F13 — Activity Feed

> **分支**: `feat/F13-activity-feed` (实际上仍在 `feat/F10-reading-challenges` 分支上开发，后续合并)
> **日期**: 2026-02-15
> **状态**: ✅ 已完成 (待测试通过确认)
> **测试**: SocialTest, ActivityControllerTest
> **依赖**: F11

---

## 1. 本次变更概述

实现了 **Activity Feed (动态流)** 功能，允许用户查看其关注好友的阅读动态（如开始阅读、完成阅读、评分、写书评）。

---

## 2. API 变更

### Feed (动态)

| 方法 | 路径 | 描述 |
|------|------|------|
| `GET` | `/api/v1/me/feed` | 获取关注用户的最新动态列表 (分页, 默认 20 条) |

**响应示例**:
```json
{
  "data": [
    {
      "id": 101,
      "type": "finished_book",
      "data": { "book_id": 55 },
      "inserted_at": "...",
      "user": { "id": 2, "username": "alice", ... },
      "book": { "id": 55, "title": "Dune", ... }
    }
  ]
}
```

---

## 3. 实现细节

### Schema: `Activity`
- `user_id`: 触发动作的用户。
- `type`: `started_book`, `finished_book`, `rated_book`, `reviewed_book`。
- `data`: JSONB，存储关联数据（如 `book_id`, `rating`）。
- `book_id`: 冗余字段，方便 Ecto 关联查询图书详情。

### Context: `Social`
- `create_activity/3`: 创建动态。
- `list_feed/2`: 查询关注用户的动态。
    - **过滤逻辑**: 仅包含 `UserFollow` 表中存在的关注关系。
    - **屏蔽处理**: 由于屏蔽操作 (`block_user`) 会自动移除双向关注关系，因此 `list_feed` 天然过滤了已屏蔽用户的动态，无需额外查询 `UserBlock` 表。

### Integration: `Accounts`
- `track_book/3`: 当书籍状态变更、评分或写书评时，自动生成相应的 Activity。
  - `reading` -> `started_book`
  - `read` -> `finished_book`
  - `rating` -> `rated_book`
  - `review_content` -> `reviewed_book`

### Test Coverage
- `ActivityControllerTest`: 验证 API 响应结构及关注/未关注逻辑。
- `SocialTest`: 验证动态创建、列表查询及时间排序。
