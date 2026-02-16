# F16 — Advanced Stats

> **分支**: `feat/F16-advanced-stats`
> **日期**: 2026-02-16
> **状态**: ✅ 已完成
> **测试**: StatsTest, StatsControllerTest
> **依赖**: F09 (Basic Stats)

---

## 1. 本次变更概述

扩展了统计模块，增加了高级分析功能：
1.  **时段对比**: 比较两个任意时间段的阅读表现。
2.  **年度对比**: 查看某一年份与上一年的对比数据。
3.  **热力图**: 提供每日阅读活跃度数据 (GitHub-style)。
4.  **Wrap-up**: 生成月度或年度阅读总结报告。

---

## 2. API 变更

### Stats (统计)

| 方法 | 路径 | 描述 | 参数 |
|------|------|------|------|
| `GET` | `/api/v1/stats/year/:year` | 获取年度统计 | `?compare=true` (可选) 返回与去年的对比 |
| `GET` | `/api/v1/stats/compare` | 比较两个时间段 | `from1, to1, from2, to2` (YYYY-MM-DD) |
| `GET` | `/api/v1/stats/heatmap` | 获取每日活跃数据 | `year` (可选，默认当年) |
| `GET` | `/api/v1/stats/wrap-up` | 获取总结报告 | `type` (month/year), `value` (e.g. "2025-02") |

**响应示例 (Check `StatsJSON` for details)**:

**Wrap-up Response**:
```json
{
  "data": {
    "period": "2025",
    "total_books": 50,
    "total_pages": 15000,
    "top_books": [...],
    "most_read_genre": { "name": "Sci-Fi", "count": 20 }
  }
}
```

---

## 3. 实现细节

### Context: `Stats`
- **`get_comparison/3`**: 核心对比逻辑，计算 diff。
- **`get_year_comparison/2`**: 封装 year vs year-1。
- **`get_heatmap_data/2`**: 按日聚合阅读记录 (finished_at / updated_at)。
- **`get_wrap_up/3`**: 聚合特定时段的高分书籍和类型分布。

### Controller & Views
- `StatsController`: 增加了相应的 action。
- `StatsJSON`: 增加了 `comparison`, `heatmap`, `wrap_up` 等渲染函数。

---

## 4. 测试
- `test/the_story_voyage_api/stats/stats_test.exs`: 验证聚合逻辑的正确性 (Unit)。
- `test/the_story_voyage_api_web/controllers/stats_controller_test.exs`: 验证 API 参数处理和响应 (Integration)。
