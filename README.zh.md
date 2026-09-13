# Profile Trophy Action

[![GitHub](https://img.shields.io/badge/GitHub-soulteary%2Fgithub--profile--trophy--action-blue)](https://github.com/soulteary/github-profile-trophy-action)

## Languages / 语言 / Sprachen / Lingue / 언어 / 言語

- [English](README.md)
- [简体中文](README.zh.md)
- [Deutsch](README.de.md)
- [Italiano](README.it.md)
- [한국어](README.kr.md)
- [日本語](README.ja.md)

在 GitHub Actions 工作流中生成 [GitHub Profile Trophy](https://github.com/soulteary/github-profile-trophy) 卡片，提交到你的 profile 仓库，并直接从那里嵌入。

本 Action 使用 Go 版本的 `github-profile-trophy` 服务，从 GitHub Releases 下载预编译的二进制文件，通过 CLI 调用生成奖杯卡片。

## 快速开始

```yaml
name: Update README trophy

on:
  schedule:
    - cron: "0 0 * * *" # 每天午夜运行一次
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v4

      - name: Generate trophy card
        uses: soulteary/github-profile-trophy-action@v1.2.1
        with:
          options: 'username=${{ github.repository_owner }}&theme=gruvbox&column=7&margin-w=15&margin-h=15'
          path: profile/trophy.svg
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Commit trophy card
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git add profile/trophy.svg
          git commit -m "Update README trophy" || exit 0
          git push
```

然后在你的 profile README 中嵌入：

```md
![Trophy](./profile/trophy.svg)
```

## 部署选项

这是推荐的部署选项之一。你也可以在 Vercel 或其他平台上部署。参见 [GitHub Profile Trophy README](https://github.com/soulteary/github-profile-trophy#deploy-on-your-own)。

## 输入参数

- `options`: 奖杯卡片选项，可以是查询字符串格式 (`key=value&...`) 或 JSON 格式。如果省略 `username`，Action 会使用仓库所有者。
- `path`: SVG 文件的输出路径。默认为 `profile/trophy.svg`。
- `token`: GitHub token (PAT 或 `GITHUB_TOKEN`)。对于私有仓库统计，请使用具有 `repo` 和 `read:user` 权限的 [PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)。
- `version`: 要使用的 github-profile-trophy 二进制文件版本（例如：`v1.0.0`）。默认为 `v1.0.0`。使用 `latest` 获取最新版本。
- `repo`: GitHub 仓库，格式为 `owner/repo`。默认为 `soulteary/github-profile-trophy`。

## 输出参数

- `path`: 写入 SVG 文件的路径。

## 选项参数

`options` 输入接受以下参数：

- `username` (必需) - GitHub 用户名
- `theme` - 主题名称（默认: "default"）
- `column` - 最大列数（默认: 8，使用 `-1` 自适应）
- `row` - 最大行数（默认: 3）
- `margin-w` - 奖杯之间的水平边距（默认: 0）
- `margin-h` - 奖杯之间的垂直边距（默认: 0）
- `title` - 按奖杯标题过滤（逗号分隔，使用 `-` 前缀排除）
- `rank` - 按等级过滤（逗号分隔，使用 `-` 前缀排除）
- `no-bg` - 透明背景（默认: false）
- `no-frame` - 隐藏边框（默认: false）

## 📖 使用示例

### 基础奖杯卡片

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.2.1
  with:
    options: 'username=${{ github.repository_owner }}'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

![基础奖杯](.github/assets/trophy-basic.svg)

### 使用主题

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.2.1
  with:
    options: 'username=${{ github.repository_owner }}&theme=onedark'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

![主题奖杯](.github/assets/trophy-themed.svg)

### 按标题过滤

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.2.1
  with:
    options: 'username=${{ github.repository_owner }}&title=Stars,Followers'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

![按标题过滤](.github/assets/trophy-filtered-titles.svg)

### 按等级过滤

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.2.1
  with:
    options: 'username=${{ github.repository_owner }}&rank=S,AAA'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

![按等级过滤](.github/assets/trophy-filtered-ranks.svg)

### 自定义布局

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.2.1
  with:
    options: 'username=${{ github.repository_owner }}&column=3&row=2&margin-w=15&margin-h=15'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

![自定义布局](.github/assets/trophy-custom-layout.svg)

### 透明背景

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.2.1
  with:
    options: 'username=${{ github.repository_owner }}&theme=gruvbox&no-bg=true&no-frame=true'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

### JSON 选项

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.2.1
  with:
    options: '{"username":"${{ github.repository_owner }}","theme":"gruvbox","column":7,"margin-w":15,"margin-h":15}'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

### 指定版本

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.2.1
  with:
    options: 'username=${{ github.repository_owner }}&theme=gruvbox'
    path: profile/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
    version: v1.0.0  # 使用指定版本
    # version: latest  # 或使用最新版本
```

## 🎨 可用主题

从 20+ 精美主题中选择！支持原始项目的所有主题。

<details>
<summary>点击查看所有主题</summary>

### default

![default theme](.github/assets/theme-default.svg)

### flat

![flat theme](.github/assets/theme-flat.svg)

### onedark

![onedark theme](.github/assets/theme-onedark.svg)

### gruvbox

![gruvbox theme](.github/assets/theme-gruvbox.svg)

### dracula

![dracula theme](.github/assets/theme-dracula.svg)

### monokai

![monokai theme](.github/assets/theme-monokai.svg)

### chalk

![chalk theme](.github/assets/theme-chalk.svg)

### nord

![nord theme](.github/assets/theme-nord.svg)

### alduin

![alduin theme](.github/assets/theme-alduin.svg)

### darkhub

![darkhub theme](.github/assets/theme-darkhub.svg)

### juicyfresh

![juicyfresh theme](.github/assets/theme-juicyfresh.svg)

### oldie

![oldie theme](.github/assets/theme-oldie.svg)

### buddhism

![buddhism theme](.github/assets/theme-buddhism.svg)

### radical

![radical theme](.github/assets/theme-radical.svg)

### onestar

![onestar theme](.github/assets/theme-onestar.svg)

### discord

![discord theme](.github/assets/theme-discord.svg)

### algolia

![algolia theme](.github/assets/theme-algolia.svg)

### gitdimmed

![gitdimmed theme](.github/assets/theme-gitdimmed.svg)

### tokyonight

![tokyonight theme](.github/assets/theme-tokyonight.svg)

### matrix

![matrix theme](.github/assets/theme-matrix.svg)

### apprentice

![apprentice theme](.github/assets/theme-apprentice.svg)

### dark_dimmed

![dark_dimmed theme](.github/assets/theme-dark_dimmed.svg)

### dark_lover

![dark_lover theme](.github/assets/theme-dark_lover.svg)

### kimbie_dark

![kimbie_dark theme](.github/assets/theme-kimbie_dark.svg)

### aura

![aura theme](.github/assets/theme-aura.svg)

</details>

## 奖杯类型

### 基础奖杯
- Stars, Commits, Followers, Issues, Pull Requests, Repositories, Reviews

### 隐藏奖杯
- MultiLanguage (10+ 种语言)
- AllSuperRank (所有基础奖杯都是 S 级或更高)
- LongTimeUser (10+ 年)
- AncientUser (2010 年之前)
- OGUser (2008 年之前)
- Joined2020 (2020 年加入)
- Organizations (3+ 个组织)
- Experience (账户时长)

## 等级系统

等级包括：`SECRET`, `SSS`, `SS`, `S`, `AAA`, `AA`, `A`, `B`, `C`, `UNKNOWN`

## 工作原理

本 Action 的工作原理：

1. **检测平台**: 自动检测操作系统（Linux/macOS）和架构（amd64/arm64）
2. **下载二进制**: 从 GitHub Releases 下载指定版本的预编译二进制文件
3. **调用 CLI**: 使用提供的选项调用 Go 二进制文件的 CLI 模式
4. **保存文件**: 将生成的 SVG 写入指定路径

## 与原始版本的差异

| 特性 | 原始版本 | 本版本 |
|------|---------|--------|
| 实现语言 | Node.js | Bash |
| 服务调用 | 直接调用库函数 | 调用 Go 二进制 CLI |
| 依赖 | Node.js + npm 包 | curl（预装） |
| 构建 | npm install | 从 Releases 下载 |
| 二进制来源 | npm 包 | GitHub Releases |

## 支持的平台

- Linux (amd64, arm64)
- macOS (amd64, arm64)

Action 会自动检测运行器的平台并下载相应的二进制文件。

## 注意事项

- 本 Action 使用与 [soulteary/github-profile-trophy](https://github.com/soulteary/github-profile-trophy) 相同的渲染器和数据获取器。
- 无需 Go 环境 - 二进制文件已预编译并从 Releases 下载。
- 服务二进制文件在 Action 运行期间临时下载和执行。
- 为了获得最佳性能，建议指定版本而不是使用 `latest`，以避免 API 调用。

## 许可证

MIT License
