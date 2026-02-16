# F21: 推荐引擎 (Recommendation Engine)

## 功能概述
基于内容的推荐系统，根据用户的阅读历史（高分书籍）推荐相似书籍。对于新用户，提供热门书籍作为冷启动方案。

## 推荐逻辑

### 1. 用户偏好分析
*   选取用户评分 `≥ 4.0` 的书籍作为种子。
*   提取这些书籍的 `Genres` 和 `Moods`。

### 2. 匹配与过滤
*   查询包含相同 Genre 或 Mood 的书籍。
*   **排除**用户已收藏/阅读/在读的书籍（UserBook 表中存在的任何记录）。
*   按 `average_rating` 降序排列。
*   限制返回 20 本。

### 3. 冷启动 (Cold Start)
*   若用户没有评分 `≥ 4.0` 的书籍：
    *   返回全站评分最高 (`average_rating` 降序) 且评论数 `≥ 5` 的书籍。
    *   同样排除用户已收藏的书籍。

## API 端点

### 获取推荐
*   **URL**: `GET /api/v1/recommendations`
*   **权限**: 需登录
*   **响应**: 返回书籍列表 (BookJSON 格式)。

### 响应示例
```json
{
  "data": [
    {
      "id": 101,
      "title": "Project Hail Mary",
      "authors": [
        { "id": 1, "name": "Andy Weir" }
      ],
      "genres": [
        { "id": 5, "name": "Science Fiction", "slug": "science-fiction" }
      ],
      "moods": [
        { "id": 2, "name": "Adventurous", "slug": "adventurous" }
      ],
      "content_warnings": [],
      "average_rating": 4.8,
      "ratings_count": 1500
    }
  ]
}
```

## 数据隐私
*   推荐计算实时进行，不存储额外的用户画像数据，仅基于现有的评分记录。
