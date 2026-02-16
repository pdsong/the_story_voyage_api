# F23: 高级搜索与筛选 (Advanced Search)

## 功能概述
增强了书籍列表 API，支持多维度的筛选和排序功能，帮助用户更精确地查找书籍。

## API 端点

### `GET /api/v1/books`

#### 新增查询参数

| 参数名 | 类型 | 说明 | 示例 |
|---|---|---|---|
| `min_rating` | float | 最低评分 | `4.0` |
| `min_pages` | int | 最少页数 | `200` |
| `max_pages` | int | 最多页数 | `500` |
| `published_year_start` | int | 出版年份起 | `2000` |
| `published_year_end` | int | 出版年份止 | `2020` |
| `author_id` | int | 作者 ID | `1` |
| `sort_by` | string | 排序方式 | `top_rated` |

#### 排序选项 (`sort_by`)

*   `newest`: 最新出版 (`first_published` desc)
*   `oldest`: 最早出版 (`first_published` asc)
*   `top_rated`: 评分最高 (`average_rating` desc, `ratings_count` desc)
*   `most_reviewed`: 评论最多 (`ratings_count` desc)
*   *默认*: 最近添加 (`inserted_at` desc)

### 请求示例

**查找 2010-2020 年出版、评分 4.0 以上的科幻小说，按评分排序：**

```
GET /api/v1/books?genre_id=5&published_year_start=2010&published_year_end=2020&min_rating=4.0&sort_by=top_rated
```
