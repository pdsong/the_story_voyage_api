# F07 补充 — Debug 全过程记录

> **日期**: 2026-02-12
> **类型**: 问题排查与复盘 (Post-Mortem)
> **目的**: 记录 F07 开发过程中遇到的测试与环境问题，分析原因及解决方案。

---

## 1. 为了运行测试遇到的连环问题

### 问题 1：缺少 `AccountsFixtures` 模块
- **现象**: 运行 `mix test` 时报错 `module TheStoryVoyageApi.AccountsFixtures is not loaded`。
- **原因**: 集成测试 (`UserBookControllerTest`) 试图导入 Fixtures 模块，但该模块并未定义。之前的功能测试 (`UserTest`) 是直接调用 `Accounts.register_user`，没有使用 Fixtures。
- **尝试**:
    1. 搜索 `user_fixture` 定义 -> **未找到**。
    2. 查看 `test/support` 目录 -> 仅有 `conn_case.ex` 和 `data_case.ex`。
- **解决**: 在 `test/support/fixtures/` 下新建了 `accounts_fixtures.ex` 和 `books_fixtures.ex`。

### 问题 2：Fixtures 文件未被编译/加载
- **现象**: 创建了文件后，测试依然报错 `undefined function user_fixture/0`。
- **原因**: 
    1. `test/support/fixtures` 目录默认不在 `mix.exs` 的 `elixirc_paths` 编译路径中（通常只包含 `lib` 和 `test/support`）。
    2. `elixirc_paths` 不会自动递归编译子目录。
    3. `test_helper.exs` 中也没有手动 require 这些文件。
- **尝试**: 检查 `mix.exs` 和 `test_helper.exs`，确认配置未覆盖子目录。
- **解决**: 将文件直接移动到 `test/support/` 根目录下 (`mv test/support/fixtures/* test/support/`)，使其符合默认编译路径配置。

### 问题 3：集成测试中的 Setup 模式匹配错误
- **现象**: `UserBookControllerTest` 报错 `Protocol.UndefinedError: protocol String.Chars not implemented for {:ok, ...}`。
- **位置**: `put_req_header(conn, "authorization", "Bearer #{token}")`
- **原因**: 
    - 代码写为 `token = Token.generate_token(user)`。
    - 但 `generate_token` 返回的是 tuple `{:ok, token_string, claims}`。
    - 导致 `token` 变量绑定了整个 tuple，插入字符串时崩溃。
- **解决**: 修改 Setup 块为 correct pattern matching:
    ```elixir
    {:ok, token, _claims} = Token.generate_token(user)
    ```

---

## 2. API 响应结构与测试断言不匹配

### 问题 4：JSON 结构路径错误
- **现象**: 测试失败 `MatchError`。
- **代码**: `assert %{...} = json_response(conn, 201)["data"]["book"]`
- **原因**: 
    - 我预期的 JSON 结构是 `data: { book: { ... } }`。
    - 实际 `UserBookJSON` 渲染的是扁平结构 `data: { status: "...", book_id: ..., book: { ... } }`。
    - "book" 字段是 `data` 下的一个属性，而不是 `data` 的 wrapper。
- **解决**: 修正测试断言路径为 `json_response(...)["data"]`。

### 问题 5：关联未加载导致 JSON 渲染崩溃
- **现象**: `Protocol.UndefinedError: protocol Enumerable not implemented for #Ecto.Association.NotLoaded`。
- **位置**: `BookJSON.data/1` 试图遍历 `book.moods`。
- **原因**: 
    - `BookJSON` 是为完整展示书本设计的，假设 `moods` 已加载。
    - `Accounts.list_user_books` 查询时只 preload 了 `[:authors, :genres]`，漏了 `:moods`。
    - 当 `UserBookJSON` 调用 `BookJSON` 渲染关联的书时，访问 `book.moods` 触发了 NotLoaded 错误。
- **解决**: 修改 `Accounts.list_user_books` 的 preload 列表，加上 `:moods`。

---

## 3. 总结

本次 F07 开发中，核心逻辑（Schema/Context）一次性通过，但 **测试基础设施 (Fixtures)** 和 **集成细节 (Preloads/JSON Structure)** 消耗了大量时间。

**改进措施**:
- ✅ **统一测试数据工厂**: 既然建立了 `test/support/*_fixtures.ex`，后续功能 (F08) 应直接复用。
- ✅ **JSON View 健壮性**: 在设计 JSON View 时，明确字段的 Nullability，或者在 Context 层确保 Preload 完整性。
