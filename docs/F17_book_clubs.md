# F17: 读书会 (Book Clubs)

## 概述
读书会功能允许用户创建和加入社区，参与讨论，并对特定主题（如选书）进行投票。

## 功能特性
- **创建读书会**：用户可以创建公开或私密的读书会。创建者自动成为管理员 ("admin")。
- **加入读书会**：
    - **公开 (Public)**：点击即可直接加入。
    - **私密 (Private)**：需申请加入（状态为 "pending"）。(*注：审批逻辑为后续规划，目前仅记录申请状态*)。
- **讨论区 (Threads)**：成员可以发布讨论帖。
- **投票 (Voting)**：成员可以对讨论帖进行投票（如：投票选书）。系统限制每人对每帖只能投一票。

## API 接口

### 读书会 (Clubs)

- `GET /api/v1/clubs`
    - **功能**：列出所有公开的读书会。
    - **响应**：`200 OK`, `[{id, name, description, is_private, owner_id}]`

- `POST /api/v1/clubs`
    - **功能**：创建一个新的读书会。
    - **请求体**：`{"club": {"name": "...", "description": "...", "is_private": boolean}}`
    - **响应**：`201 Created`, 返回读书会详情。

- `GET /api/v1/clubs/:id`
    - **功能**：获取特定读书会的详情。
    - **响应**：`200 OK`, 返回读书会详情。

- `POST /api/v1/clubs/:id/join`
    - **功能**：加入读书会。
    - **响应**：`201 Created`, `{"message": "Joined successfully request sent"}`

### 讨论帖 (Threads)

- `GET /api/v1/clubs/:id/threads`
    - **功能**：列出读书会内的所有讨论帖。
    - **响应**：`200 OK`, `[{id, title, content, vote_count, creator_id, inserted_at}]`

- `POST /api/v1/clubs/:id/threads`
    - **功能**：发布新的讨论帖。
    - **请求体**：`{"thread": {"title": "...", "content": "...", "vote_count": 0}}`
    - **响应**：`201 Created`, 返回帖子详情。

- `POST /api/v1/clubs/:id/threads/:thread_id/vote`
    - **功能**：对讨论帖进行投票。
    - **响应**：`200 OK`, `{"message": "Voted successfully"}`.
    - **错误**：若已投票，则返回 `409 Conflict` (当前 Changeset error 可能返回 422，但数据库约束已生效)。

## 数据库架构

- **clubs**: `name`, `description`, `is_private`, `owner_id`.
- **club_members**: `club_id`, `user_id`, `role` (admin/member), `status` (joined/pending).
- **club_threads**: `club_id`, `title`, `content`, `vote_count`, `creator_id`.
- **thread_votes**: `thread_id`, `user_id`. (联合唯一索引 `[thread_id, user_id]` 防止重复投票).
