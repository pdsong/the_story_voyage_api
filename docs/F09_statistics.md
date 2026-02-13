# F09 — 基础统计

> **分支**: `feat/F09-basic-stats` (Remediated)
> **日期**: 2026-02-13
> **状态**: ✅ 已完成
> **测试**: 87 tests (Total), 0 failures
> **依赖**: F07, F08

---

## 1. 本次变更概述

实现了用户阅读数据的统计功能，包括总览、年度统计和分布统计。
**Remediation**: 补全了 `development_management.md` 中缺失的细分统计端点。

---

## 2. API 变更

### Protected Routes (需要登录)

| 方法 | 路径 | 描述 |
|------|------|------|
| `GET` | `/api/v1/stats` | 获取阅读总览 (Total Read, Pages, Avg Rating) |
| `GET` | `/api/v1/stats/year/:year` | 获取年度统计 (含月度时间线) |
| `GET` | `/api/v1/stats/genres` | 获取类型分布 (Genre Distribution) |
| `GET` | `/api/v1/stats/moods` | 获取情绪分布 (Mood Distribution) |

**1. 总览 (`/stats`)**:
```json
{
  "data": {
    "read_count": 12,
    "reading_count": 2,
    "want_to_read_count": 5,
    "total_pages_read": 3450,
    "average_rating": 4.25
  }
}
```

**2. 年度统计 (`/stats/year/2026`)**:
```json
{
  "data": {
    "year": 2026,
    "book_count": 5,
    "page_count": 1200,
    "average_rating": 4.5,
    "monthly_timeline": [
      {"month": 1, "count": 2},
      {"month": 2, "count": 0},
      ...
    ]
  }
}
```

**3. 类型分布 (`/stats/genres`)**:
```json
{
  "data": [
    {"name": "Sci-Fi", "count": 5, "percentage": 41.6},
    {"name": "Fantasy", "count": 3, "percentage": 25.0}
  ]
}
```

---

## 3. 实现细节

### Context: `Stats`
- 独立于 `Accounts`，专门处理聚合查询。
- **Aggregation**: 使用 Ecto `group_by` 和 `count` / `sum` / `avg`。
- **Timeline**: 暂时通过 Elixir 处理月度聚合 (MVP)，未来可优化为 SQL `date_trunc`。

### Schema Changes
- `books`: 在 F09 早期已添加 `pages` 字段。

---

## 4. 后续计划
- [ ] F10: Reading Challenges
