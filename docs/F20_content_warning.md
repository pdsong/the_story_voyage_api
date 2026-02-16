# F20: 内容警告系统 (Content Warning System)

## 功能概述
允许用户为书籍添加内容警告标签（如 "Violence", "Self-harm"），帮助其他读者规避敏感内容。

## 主要特性
1.  **添加警告**: 认证用户可以为书籍添加系统预置的警告标签。
2.  **展示警告**: 书籍详情页会展示所有已添加的警告标签。
3.  **受控标签**: 用户只能从系统预置的 `content_warnings` 列表中选择，不能创建新标签（防止随意输入）。

## API 端点

### 1. 添加警告
*   **URL**: `POST /api/v1/books/:id/content_warnings`
*   **权限**: 需登录
*   **Body**:
    ```json
    {
      "content_warning_id": 1
    }
    ```
*   **响应**: `201 Created`

### 2. 查看警告
*   **URL**: `GET /api/v1/books/:id`
*   **响应**: 书籍详情中包含 `content_warnings` 字段：
    ```json
    {
      "data": {
        "id": 101,
        "title": "Dune",
        "content_warnings": [
          { "id": 1, "name": "War", "category": "violence" }
        ]
      }
    }
    ```

## 数据库设计
*   **ContentWarning**: 预置的警告标签库。
*   **BookContentWarning**: 关联表 (`book_id`, `content_warning_id`, `reported_by_user_id`)。
