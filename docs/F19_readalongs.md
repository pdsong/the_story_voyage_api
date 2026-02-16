# F19: 共读活动 (Readalongs)

## 功能概述
共读活动 (Readalongs) 是大型的、公开的阅读活动。与 Buddy Reads 不同，它没有人数上限，并且采用分章节解锁的模式来防止剧透。

## 主要特性
1.  **公开活动**: 无人数限制（设计支持 1000+ 人）。
2.  **进度管理**: 活动被划分为多个章节 (Section)，每个章节有特定的 `unlock_date`。
3.  **防剧透机制**: 在章节解锁日期到达之前，用户无法查看或发布该章节的讨论帖。
4.  **参与**: 用户点击加入后成为参与者。

## API 端点

### 1. 活动列表与详情
*   **URL**: `GET /api/v1/readalongs`
*   **描述**: 获取列表。
*   **URL**: `GET /api/v1/readalongs/:id`
*   **响应**:
    ```json
    {
      "data": {
        "id": 1,
        "title": "Spring Readalong",
        "book": { "id": 101, "title": "Dune" },
        "sections": [
          {
            "id": 10,
            "title": "Week 1: Chapters 1-5",
            "unlock_date": "2026-04-01T10:00:00Z"
          }
        ]
      }
    }
    ```

### 2. 创建活动 (Create)
*   **URL**: `POST /api/v1/readalongs`
*   **Body**:
    ```json
    {
      "readalong": {
        "title": "Dune Readalong",
        "book_id": 101,
        "start_date": "2026-04-01",
        "sections": [
          { "title": "Part 1", "unlock_date": "2026-04-01T10:00:00Z" },
          { "title": "Part 2", "unlock_date": "2026-04-08T10:00:00Z" }
        ]
      }
    }
    ```

### 3. 加入活动
*   **URL**: `POST /api/v1/readalongs/:id/join`
*   **响应**: `201 Created`

### 4. 章节讨论 (Section Posts)
*   **URL**: `GET /api/v1/readalong_sections/:section_id/posts`
*   **URL**: `POST /api/v1/readalong_sections/:section_id/posts`
*   **Body**: `{ "post": { "content": "Here is my thought..." } }`
*   **限制**: 若当前时间 < `unlock_date`，API 返回 `423 Locked`。

## 数据库设计
*   **Readalong**: 活动主体。
*   **ReadalongSection**: 章节划分，包含解锁时间。
*   **ReadalongParticipant**: 参与者关联。
*   **ReadalongPost**: 绑定到章节的讨论。
