# F01 — 数据库基础 & 种子数据

> **分支**: `feat/F01-database-setup`
> **日期**: 2026-02-11
> **状态**: ✅ 已完成
> **测试**: 27 tests, 0 failures

---

## 1. 本次变更概述

建立 TheStoryVoyage 核心数据库架构，包含 15 张数据表、10 个 Ecto Schema、2 个 Context 模块，以及预置的种子数据（46 genres、14 moods、27 content warnings）。

---

## 2. 数据库 ER 关系

```
users ──< user_follows (follower_id, followed_id)
users ──< user_blocks  (blocker_id, blocked_id)

authors >──< books       (通过 book_authors)
series  ──< books
books   ──< editions     ──< edition_narrators
books   >──< genres      (通过 book_genres)
books   >──< moods       (通过 book_moods)
books   >──< content_warnings (通过 book_content_warnings, 含 reported_by_user_id)
genres  ──< genres       (parent_id 自引用, 层级分类)
```

---

## 3. 数据表清单

### 3.1 用户域

| 表 | 主要字段 | 索引 |
|----|---------|------|
| `users` | username, email, password_hash, display_name, bio, avatar_url, location, privacy_level, role | unique(username), unique(email) |
| `user_follows` | follower_id, followed_id, is_friend | unique(follower_id, followed_id) |
| `user_blocks` | blocker_id, blocked_id | unique(blocker_id, blocked_id) |

### 3.2 图书域

| 表 | 主要字段 | 索引 |
|----|---------|------|
| `authors` | name, bio, photo_url, born_date, nationality | index(name) |
| `series` | name, description | index(name) |
| `books` | title, original_title, description, pace, character_or_plot, average_rating, ratings_count, first_published, series_id, series_position | index(title), index(series_id) |
| `editions` | book_id, isbn_10, isbn_13, format, page_count, audio_duration_minutes, publisher, publication_date, language, cover_image_url | index(book_id, isbn_10, isbn_13) |
| `edition_narrators` | edition_id, name | unique(edition_id, name) |

### 3.3 元数据 & 关联表

| 表 | 主要字段 | 索引 |
|----|---------|------|
| `genres` | name, slug, parent_id | unique(name), unique(slug) |
| `moods` | name, slug | unique(name), unique(slug) |
| `content_warnings` | name, slug, category | unique(name), unique(slug) |
| `book_authors` | book_id, author_id, role | unique(book_id, author_id) |
| `book_genres` | book_id, genre_id, vote_count | unique(book_id, genre_id) |
| `book_moods` | book_id, mood_id, vote_count | unique(book_id, mood_id) |
| `book_content_warnings` | book_id, content_warning_id, reported_by_user_id | unique(book_id, cw_id, user_id) |

---

## 4. 文件变更清单

### 4.1 Migrations (`priv/repo/migrations/`)

```
20260211100001_create_users.exs
20260211100002_create_user_follows.exs
20260211100003_create_user_blocks.exs
20260211100004_create_authors.exs
20260211100005_create_series.exs
20260211100006_create_books.exs
20260211100007_create_editions.exs
20260211100008_create_book_authors.exs
20260211100009_create_genres.exs
20260211100010_create_moods.exs
20260211100011_create_content_warnings.exs
20260211100012_create_book_genres.exs
20260211100013_create_book_moods.exs
20260211100014_create_book_content_warnings.exs
20260211100015_create_edition_narrators.exs
```

### 4.2 Schemas (`lib/the_story_voyage_api/`)

| 文件路径 | 模块 | 说明 |
|---------|------|------|
| `accounts/user.ex` | `Accounts.User` | 含 `changeset/2` + `registration_changeset/2` |
| `accounts/user_follow.ex` | `Accounts.UserFollow` | 关注/好友关系 |
| `accounts/user_block.ex` | `Accounts.UserBlock` | 屏蔽关系 |
| `books/book.ex` | `Books.Book` | 核心图书实体, many_to_many authors/genres/moods |
| `books/author.ex` | `Books.Author` | 作者 |
| `books/series.ex` | `Books.Series` | 系列 |
| `books/edition.ex` | `Books.Edition` | 版本 (ISBN/格式) |
| `books/genre.ex` | `Books.Genre` | 类型 (层级结构 parent_id) |
| `books/mood.ex` | `Books.Mood` | 阅读情绪标签 |
| `books/content_warning.ex` | `Books.ContentWarning` | 内容警告 |

### 4.3 Context 模块

| 文件路径 | 提供的函数 |
|---------|-----------|
| `accounts/accounts.ex` | `get_user/1`, `get_user_by_email/1`, `get_user_by_username/1`, `create_user/1`, `update_user/2`, `list_users/0` |
| `books/books.ex` | `get_book/1`, `list_books/1`, `create_book/1`, `update_book/2`, `get_author/1`, `create_author/1`, `list_genres/0`, `list_moods/0`, `list_content_warnings/0`, `get_series/1`, `create_series/1`, `get_edition/1`, `create_edition/1`, `list_editions_for_book/1` |

### 4.4 Seeds

`priv/repo/seeds.exs` — 幂等写入 (`on_conflict: :nothing`)

### 4.5 Tests

| 文件 | 覆盖 | Tests |
|------|------|-------|
| `test/.../accounts/user_test.exs` | User changeset 验证 + registration_changeset 密码哈希 | 8 |
| `test/.../books/book_test.exs` | Book/Genre/Mood/ContentWarning changeset 验证 | 8 |
| `test/.../seeds_test.exs` | seed 数据数量、slug 唯一性、幂等性 | 7 |

---

## 5. 种子数据概览

### Genres (46)

| 分类 | 内容 |
|------|------|
| 技术与编程 (13) | Programming, Web Development, Mobile Development, Systems Programming, DevOps & Cloud, Databases, Algorithms & Data Structures, Software Engineering, Software Architecture, Operating Systems, Networking, Security & Cryptography, Compilers & Languages |
| 数学 (7) | Mathematics, Linear Algebra, Calculus & Analysis, Probability & Statistics, Discrete Mathematics, Number Theory, Topology & Geometry |
| 科学 (5) | Physics, Chemistry, Biology, Astronomy, Earth Science |
| AI & 数据科学 (7) | Artificial Intelligence, Machine Learning, Deep Learning, Data Science, NLP, Computer Vision, Robotics |
| 通识与人文 (14) | Science Fiction, Fantasy, Fiction, Nonfiction, Popular Science, Biography, History, Philosophy, Psychology, Business & Management, Economics, Self-Help, Education, Essays |

### Moods (14)

Mind-Expanding · Practical · Challenging · Beginner-Friendly · Inspiring · Systematic · Cutting-Edge · Classic · Lighthearted · In-Depth · Engaging · Reflective · Adventurous · Tense

### Content Warnings (27)

- **violence** (5): Graphic violence, War, Gore, Torture, Gun violence
- **sexual** (3): Sexual content, Sexual assault, Rape
- **mental_health** (6): Suicide, Self-harm, Depression, Anxiety, Eating disorders, Mental illness
- **substance** (2): Drug use, Alcoholism
- **discrimination** (4): Racism, Homophobia, Sexism, Ableism
- **other** (7): Death, Grief, Child abuse, Domestic violence, Animal cruelty, Kidnapping, Stalking

---

## 6. 前端对接说明

### 枚举值约定

| 字段 | 可用值 |
|------|-------|
| `users.role` | `user`, `librarian`, `admin` |
| `users.privacy_level` | `public`, `friends_only`, `private` |
| `books.pace` | `slow`, `medium`, `fast` |
| `books.character_or_plot` | `character`, `plot`, `both` |
| `editions.format` | `paperback`, `hardcover`, `ebook`, `audiobook` |
| `book_authors.role` | `author` (默认), 可扩展 `translator`, `editor` 等 |

### 评分规则

- 范围: `0.0` ~ `5.0`
- 增量: `0.25` (由 F08 实现)
- `books.average_rating` 和 `books.ratings_count` 自动聚合

---

## 7. 已知待办 (下一步 F02)

- [ ] 添加 `bcrypt_elixir` 依赖，替换 `User.registration_changeset` 中的 SHA256 占位哈希
- [ ] 实现 `POST /api/v1/auth/register` 端点
