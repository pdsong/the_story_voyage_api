# Seeds for TheStoryVoyage
#
#     mix run priv/repo/seeds.exs
#

alias TheStoryVoyageApi.Repo
alias TheStoryVoyageApi.Books.{Genre, Mood, ContentWarning}

# ========== Helper ==========

defmodule Seeds.Helper do
  def slugify(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/\s+/, "-")
    |> String.trim("-")
  end
end

# ========== Genres ==========

genres = [
  # 技术与编程
  "Programming",
  "Web Development",
  "Mobile Development",
  "Systems Programming",
  "DevOps & Cloud",
  "Databases",
  "Algorithms & Data Structures",
  "Software Engineering",
  "Software Architecture",
  "Operating Systems",
  "Networking",
  "Security & Cryptography",
  "Compilers & Languages",

  # 数学
  "Mathematics",
  "Linear Algebra",
  "Calculus & Analysis",
  "Probability & Statistics",
  "Discrete Mathematics",
  "Number Theory",
  "Topology & Geometry",

  # 科学
  "Physics",
  "Chemistry",
  "Biology",
  "Astronomy",
  "Earth Science",

  # AI 与数据科学
  "Artificial Intelligence",
  "Machine Learning",
  "Deep Learning",
  "Data Science",
  "Natural Language Processing",
  "Computer Vision",
  "Robotics",

  # 通识与人文
  "Science Fiction",
  "Fantasy",
  "Fiction",
  "Nonfiction",
  "Popular Science",
  "Biography",
  "History",
  "Philosophy",
  "Psychology",
  "Business & Management",
  "Economics",
  "Self-Help",
  "Education",
  "Essays"
]

IO.puts("Seeding #{length(genres)} genres...")

for name <- genres do
  slug = Seeds.Helper.slugify(name)

  Repo.insert!(
    %Genre{name: name, slug: slug},
    on_conflict: :nothing,
    conflict_target: :name
  )
end

# ========== Moods ==========

moods = [
  "Mind-Expanding",
  "Practical",
  "Challenging",
  "Beginner-Friendly",
  "Inspiring",
  "Systematic",
  "Cutting-Edge",
  "Classic",
  "Lighthearted",
  "In-Depth",
  "Engaging",
  "Reflective",
  "Adventurous",
  "Tense"
]

IO.puts("Seeding #{length(moods)} moods...")

for name <- moods do
  slug = Seeds.Helper.slugify(name)

  Repo.insert!(
    %Mood{name: name, slug: slug},
    on_conflict: :nothing,
    conflict_target: :name
  )
end

# ========== Content Warnings ==========

content_warnings = [
  # 暴力类
  {"Graphic violence", "violence"},
  {"War", "violence"},
  {"Gore", "violence"},
  {"Torture", "violence"},
  {"Gun violence", "violence"},

  # 性相关
  {"Sexual content", "sexual"},
  {"Sexual assault", "sexual"},
  {"Rape", "sexual"},

  # 心理健康
  {"Suicide", "mental_health"},
  {"Self-harm", "mental_health"},
  {"Depression", "mental_health"},
  {"Anxiety", "mental_health"},
  {"Eating disorders", "mental_health"},
  {"Mental illness", "mental_health"},

  # 物质滥用
  {"Drug use", "substance"},
  {"Alcoholism", "substance"},

  # 歧视类
  {"Racism", "discrimination"},
  {"Homophobia", "discrimination"},
  {"Sexism", "discrimination"},
  {"Ableism", "discrimination"},

  # 其他
  {"Death", "other"},
  {"Grief", "other"},
  {"Child abuse", "other"},
  {"Domestic violence", "other"},
  {"Animal cruelty", "other"},
  {"Kidnapping", "other"},
  {"Stalking", "other"}
]

IO.puts("Seeding #{length(content_warnings)} content warnings...")

for {name, category} <- content_warnings do
  slug = Seeds.Helper.slugify(name)

  Repo.insert!(
    %ContentWarning{name: name, slug: slug, category: category},
    on_conflict: :nothing,
    conflict_target: :name
  )
end

IO.puts("✅ Seed data complete!")
