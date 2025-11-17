<p align="center">
  <img src="https://github.com/openpeeps/pexels-nim/blob/main/.github/pexels.png" width="210px"><br>
  👑 Nim library for the Pexels API
</p>

<p align="center">
  <code>nimble install pexels</code>
</p>

<p align="center">
  <a href="https://github.com/">API reference</a><br>
  <img src="https://github.com/openpeeps/pexels-nim/workflows/test/badge.svg" alt="Github Actions">  <img src="https://github.com/openpeeps/pexels-nim/workflows/docs/badge.svg" alt="Github Actions">
</p>

## 😍 Key Features
- [x] Search Pexels for photos & videos
- [x] Direct to Object parser
- [x] Written in Nim language

First, create your API key: https://www.pexels.com/api/

## Examples
**Search for Photos**

Search Pexels for any topic that you would like.

```nim
import pkg/pexels

let
  px: Pexels = newPexelsClient(apikey = "123abc")
  pics: PexelsPhotosResponse =
    waitFor px.search("cat", perPage = 5)
for pic in pics:
  echo pic.src.tiny
```

**Search for Videos**
```nim
import pkg/pexels
let
  px = newPexelsClient(apikey = "123abc")
  vids: PexelsVideosResponse =
    waitFor px.videos("nature")
for vid in vids:
  echo vid
```

### ❤ Contributions & Support
- 🐛 Found a bug? [Create a new Issue](/issues)
- 👋 Wanna help? [Fork it!](/fork)
- 😎 [Get €20 in cloud credits from Hetzner](https://hetzner.cloud/?ref=Hm0mYGM9NxZ4)

### 🎩 License
Pexels for Nim language | MIT license. [Made by Humans from OpenPeeps](https://github.com/openpeeps).<br>
Copyright &copy; OpenPeeps & Contributors &mdash; All rights reserved.
