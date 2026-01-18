# Profile Trophy Action

[![GitHub](https://img.shields.io/badge/GitHub-soulteary%2Fgithub--profile--trophy--action-blue)](https://github.com/soulteary/github-profile-trophy-action)

## Languages / 语言 / Sprachen / Lingue / 언어 / 言語

- [English](README.md)
- [简体中文](README.zh.md)
- [Deutsch](README.de.md)
- [Italiano](README.it.md)
- [한국어](README.kr.md)
- [日本語](README.ja.md)

Genera carte [GitHub Profile Trophy](https://github.com/soulteary/github-profile-trophy) nel tuo workflow GitHub Actions, committale nel tuo repository del profilo e incorporale direttamente da lì.

Questa Action utilizza l'implementazione Go del servizio `github-profile-trophy`, scarica binari precompilati da GitHub Releases e li chiama tramite CLI per generare carte trofeo.

## Guida Rapida

```yaml
name: Update README trophy

on:
  schedule:
    - cron: "0 0 * * *" # Esegue una volta al giorno a mezzanotte
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v4

      - name: Generate trophy card
        uses: soulteary/github-profile-trophy-action@v1.0.0
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

Quindi incorpora dal tuo README del profilo:

```md
![Trophy](./profile/trophy.svg)
```

## Opzioni di Deployment

Questa action è un'opzione di deployment consigliata. Puoi anche deployare su Vercel o altre piattaforme. Vedi il [README di GitHub Profile Trophy](https://github.com/soulteary/github-profile-trophy#deploy-on-your-own).

## Input

- `options`: Opzioni per la carta trofeo come stringa di query (`key=value&...`) o JSON. Se `username` viene omesso, l'action utilizza il proprietario del repository.
- `path`: Percorso di output per il file SVG. Predefinito: `profile/trophy.svg`.
- `token`: Token GitHub (PAT o `GITHUB_TOKEN`). Per statistiche di repository private, usa un [PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) con scope `repo` e `read:user`.
- `version`: Versione del binario github-profile-trophy da utilizzare (es. `v1.0.0`). Predefinito: `v1.0.0`. Usa `latest` per ottenere l'ultima versione.
- `repo`: Repository GitHub nel formato `owner/repo`. Predefinito: `soulteary/github-profile-trophy`.

## Output

- `path`: Percorso dove è stato scritto il file SVG.

## Parametri Options

L'input `options` accetta i seguenti parametri:

- `username` (richiesto) - Nome utente GitHub
- `theme` - Nome del tema (predefinito: "default")
- `column` - Numero massimo di colonne (predefinito: 8, usa `-1` per adattivo)
- `row` - Numero massimo di righe (predefinito: 3)
- `margin-w` - Margine orizzontale tra i trofei (predefinito: 0)
- `margin-h` - Margine verticale tra i trofei (predefinito: 0)
- `title` - Filtra per titoli dei trofei (separati da virgola, usa prefisso `-` per escludere)
- `rank` - Filtra per ranghi (separati da virgola, usa prefisso `-` per escludere)
- `no-bg` - Sfondo trasparente (predefinito: false)
- `no-frame` - Nascondi cornici (predefinito: false)

## 📖 Esempi di Utilizzo

### Carta Trofeo Base

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.0.0
  with:
    options: 'username=${{ github.repository_owner }}'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

![Trofeo Base](.github/assets/trophy-basic.svg)

### Con Tema

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.0.0
  with:
    options: 'username=${{ github.repository_owner }}&theme=onedark'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

![Trofeo con Tema](.github/assets/trophy-themed.svg)

### Filtra per Titoli

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.0.0
  with:
    options: 'username=${{ github.repository_owner }}&title=Stars,Followers'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

![Filtrato per Titoli](.github/assets/trophy-filtered-titles.svg)

### Filtra per Ranghi

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.0.0
  with:
    options: 'username=${{ github.repository_owner }}&rank=S,AAA'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

![Filtrato per Ranghi](.github/assets/trophy-filtered-ranks.svg)

### Layout Personalizzato

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.0.0
  with:
    options: 'username=${{ github.repository_owner }}&column=3&row=2&margin-w=15&margin-h=15'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

![Layout Personalizzato](.github/assets/trophy-custom-layout.svg)

### Sfondo Trasparente

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.0.0
  with:
    options: 'username=${{ github.repository_owner }}&theme=gruvbox&no-bg=true&no-frame=true'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

### Opzioni JSON

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.0.0
  with:
    options: '{"username":"${{ github.repository_owner }}","theme":"gruvbox","column":7,"margin-w":15,"margin-h":15}'
    path: .github/assets/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
```

### Specifica Versione

```yaml
- name: Generate trophy card
  uses: soulteary/github-profile-trophy-action@v1.0.0
  with:
    options: 'username=${{ github.repository_owner }}&theme=gruvbox'
    path: profile/trophy.svg
    token: ${{ secrets.GITHUB_TOKEN }}
    version: v1.0.0  # Usa versione specifica
    # version: latest  # Oppure usa ultima versione
```

## 🎨 Temi Disponibili

Scegli tra oltre 20 bellissimi temi! Tutti i temi del progetto originale sono supportati.

<details>
<summary>Clicca per visualizzare tutti i temi</summary>

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

## Tipi di Trofei

### Trofei Base
- Stars, Commits, Followers, Issues, Pull Requests, Repositories, Reviews

### Trofei Segreti
- MultiLanguage (10+ lingue)
- AllSuperRank (tutti i trofei base sono rango S o superiore)
- LongTimeUser (10+ anni)
- AncientUser (prima del 2010)
- OGUser (prima del 2008)
- Joined2020 (iscritto nel 2020)
- Organizations (3+ organizzazioni)
- Experience (durata account)

## Sistema di Ranghi

I ranghi sono: `SECRET`, `SSS`, `SS`, `S`, `AAA`, `AA`, `A`, `B`, `C`, `UNKNOWN`

## Come Funziona

Questa action funziona:

1. **Rilevamento Piattaforma**: Rileva automaticamente il sistema operativo (Linux/macOS) e l'architettura (amd64/arm64)
2. **Download Binario**: Scarica il binario precompilato da GitHub Releases per la versione specificata
3. **Chiamata CLI**: Richiama la modalità CLI del binario Go con le opzioni fornite
4. **Salvataggio File**: Scrive l'SVG generato nel percorso specificato

## Differenze dalla Versione Originale

| Caratteristica | Versione Originale | Questa Versione |
|----------------|-------------------|-----------------|
| Implementazione | Node.js | Bash |
| Chiamata Servizio | Chiamata diretta funzione libreria | Chiamata CLI a binario Go |
| Dipendenze | Node.js + pacchetto npm | curl (preinstallato) |
| Build | npm install | Download da Releases |
| Sorgente Binario | pacchetto npm | GitHub Releases |

## Piattaforme Supportate

- Linux (amd64, arm64)
- macOS (amd64, arm64)

L'action rileva automaticamente la piattaforma del runner e scarica il binario appropriato.

## Note

- Questa action utilizza gli stessi renderer e fetcher di [soulteary/github-profile-trophy](https://github.com/soulteary/github-profile-trophy).
- Nessun ambiente Go richiesto - i binari sono precompilati e scaricati da Releases.
- Il binario del servizio viene temporaneamente scaricato ed eseguito durante l'esecuzione dell'action.
- Per le migliori prestazioni, specifica una versione invece di usare `latest` per evitare chiamate API.

## Licenza

MIT License
