# Profile Trophy Action

[![GitHub](https://img.shields.io/badge/GitHub-soulteary%2Fgithub--profile--trophy--action-blue)](https://github.com/soulteary/github-profile-trophy-action)

## Languages / 语言 / Sprachen / Lingue / 언어 / 言語

- [English](README.md)
- [简体中文](README.zh.md)
- [Deutsch](README.de.md)
- [Italiano](README.it.md)
- [한국어](README.kr.md)
- [日本語](README.ja.md)

Generieren Sie [GitHub Profile Trophy](https://github.com/soulteary/github-profile-trophy) Karten in Ihrem GitHub Actions Workflow, committen Sie sie in Ihr Profil-Repository und betten Sie sie direkt von dort ein.

Diese Action verwendet die Go-Implementierung des `github-profile-trophy` Dienstes, lädt vorkompilierte Binärdateien von GitHub Releases herunter und ruft sie über CLI auf, um Trophy-Karten zu generieren.

## Schnellstart

```yaml
name: Update README trophy

on:
  schedule:
    - cron: "0 0 * * *" # Läuft täglich um Mitternacht
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v4

      - name: Generate trophy card
        uses: soulteary/github-profile-trophy-action@v1.2.0
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

Dann in Ihrem Profil-README einbetten:

```md
![Trophy](./profile/trophy.svg)
```

## Deployment-Optionen

Diese Action ist eine empfohlene Deployment-Option. Sie können auch auf Vercel oder anderen Plattformen deployen. Siehe das [GitHub Profile Trophy README](https://github.com/soulteary/github-profile-trophy#deploy-on-your-own).

## Eingaben

- `options`: Optionen für die Trophy-Karte als Query-String (`key=value&...`) oder JSON. Wenn `username` weggelassen wird, verwendet die Action den Repository-Besitzer.
- `path`: Ausgabepfad für die SVG-Datei. Standard: `profile/trophy.svg`.
- `token`: GitHub Token (PAT oder `GITHUB_TOKEN`). Für private Repository-Statistiken verwenden Sie ein [PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) mit `repo` und `read:user` Berechtigungen.
- `version`: Version der github-profile-trophy Binärdatei (z.B. `v1.0.0`). Standard: `v1.0.0`. Verwenden Sie `latest` für die neueste Version.
- `repo`: GitHub Repository im Format `owner/repo`. Standard: `soulteary/github-profile-trophy`.

## Ausgaben

- `path`: Pfad, wo die SVG-Datei geschrieben wurde.

## Options-Parameter

Die `options` Eingabe akzeptiert folgende Parameter:

- `username` (erforderlich) - GitHub Benutzername
- `theme` - Themenname (Standard: "default")
- `column` - Maximale Anzahl von Spalten (Standard: 8, verwenden Sie `-1` für adaptiv)
- `row` - Maximale Anzahl von Zeilen (Standard: 3)
- `margin-w` - Horizontaler Abstand zwischen Trophäen (Standard: 0)
- `margin-h` - Vertikaler Abstand zwischen Trophäen (Standard: 0)
- `title` - Nach Trophäen-Titeln filtern (kommagetrennt, verwenden Sie `-` Präfix zum Ausschließen)
- `rank` - Nach Rängen filtern (kommagetrennt, verwenden Sie `-` Präfix zum Ausschließen)
- `no-bg` - Transparenter Hintergrund (Standard: false)
- `no-frame` - Rahmen ausblenden (Standard: false)

## 📖 Verwendungsbeispiele

### Basis Trophy-Karte

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.2.0
  with:
    options: 'username=${{ github.repository_owner }}'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

![Basis Trophy](.github/assets/trophy-basic.svg)

### Mit Theme

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.2.0
  with:
    options: 'username=${{ github.repository_owner }}&theme=onedark'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

![Themed Trophy](.github/assets/trophy-themed.svg)

### Nach Titeln Filtern

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.2.0
  with:
    options: 'username=${{ github.repository_owner }}&title=Stars,Followers'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

![Nach Titeln gefiltert](.github/assets/trophy-filtered-titles.svg)

### Nach Rängen Filtern

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.2.0
  with:
    options: 'username=${{ github.repository_owner }}&rank=S,AAA'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

![Nach Rängen gefiltert](.github/assets/trophy-filtered-ranks.svg)

### Benutzerdefiniertes Layout

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.2.0
  with:
    options: 'username=${{ github.repository_owner }}&column=3&row=2&margin-w=15&margin-h=15'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

![Benutzerdefiniertes Layout](.github/assets/trophy-custom-layout.svg)

### Transparenter Hintergrund

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.2.0
  with:
    options: 'username=${{ github.repository_owner }}&theme=gruvbox&no-bg=true&no-frame=true'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

### JSON Optionen

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.2.0
  with:
    options: '{"username":"${{ github.repository_owner }}","theme":"gruvbox","column":7,"margin-w":15,"margin-h":15}'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

### Version Angeben

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.2.0
  with:
    options: 'username=${{ github.repository_owner }}&theme=gruvbox'
    path: profile/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
    version: v1.0.0  # Verwenden Sie spezifische Version
    # version: latest  # Oder verwenden Sie neueste Version
```

## 🎨 Verfügbare Themen

Wählen Sie aus über 20 schönen Themen! Alle Themen des ursprünglichen Projekts werden unterstützt.

<details>
<summary>Klicken Sie, um alle Themen anzuzeigen</summary>

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

## Trophy-Typen

### Basis-Trophäen
- Stars, Commits, Followers, Issues, Pull Requests, Repositories, Reviews

### Geheime Trophäen
- MultiLanguage (10+ Sprachen)
- AllSuperRank (alle Basis-Trophäen sind S-Rang oder höher)
- LongTimeUser (10+ Jahre)
- AncientUser (vor 2010)
- OGUser (vor 2008)
- Joined2020 (2020 beigetreten)
- Organizations (3+ Organisationen)
- Experience (Kontodauer)

## Rang-System

Ränge sind: `SECRET`, `SSS`, `SS`, `S`, `AAA`, `AA`, `A`, `B`, `C`, `UNKNOWN`

## Funktionsweise

Diese Action funktioniert durch:

1. **Plattform-Erkennung**: Automatische Erkennung des Betriebssystems (Linux/macOS) und der Architektur (amd64/arm64)
2. **Binärdatei herunterladen**: Herunterladen der vorkompilierten Binärdatei von GitHub Releases für die angegebene Version
3. **CLI aufrufen**: Aufruf des Go-Binärdatei CLI-Modus mit den bereitgestellten Optionen
4. **Datei speichern**: Schreiben des generierten SVG in den angegebenen Pfad

## Unterschiede zur Originalversion

| Funktion | Originalversion | Diese Version |
|---------|----------------|---------------|
| Implementierung | Node.js | Bash |
| Service-Aufruf | Direkter Bibliotheksfunktionsaufruf | CLI-Aufruf an Go-Binärdatei |
| Abhängigkeiten | Node.js + npm Paket | curl (vorinstalliert) |
| Build | npm install | Von Releases herunterladen |
| Binärdatei-Quelle | npm Paket | GitHub Releases |

## Unterstützte Plattformen

- Linux (amd64, arm64)
- macOS (amd64, arm64)

Die Action erkennt automatisch die Plattform Ihres Runners und lädt die entsprechende Binärdatei herunter.

## Hinweise

- Diese Action verwendet dieselben Renderer und Fetcher wie [soulteary/github-profile-trophy](https://github.com/soulteary/github-profile-trophy).
- Keine Go-Umgebung erforderlich - Binärdateien sind vorkompiliert und werden von Releases heruntergeladen.
- Die Service-Binärdatei wird während der Action-Ausführung temporär heruntergeladen und ausgeführt.
- Für beste Leistung geben Sie eine Version an, anstatt `latest` zu verwenden, um API-Aufrufe zu vermeiden.

## Lizenz

MIT License
