# Cat Companion — Make Your Own macOS Desktop Pet

[English](#english) · [繁體中文](#繁體中文)

Turn photos of your own cat into a private macOS desktop companion. It can walk with all four legs, jump, sit, sleep, react to petting, work beside a laptop, take a bath, and use English or Traditional Chinese controls.

**No coding experience is required.** Codex does the technical work and asks you to approve important actions. You provide the cat photos, review the generated poses, and test the finished pet.

This repository contains **no pet photos or generated pet sprites**. Your photos and finished app stay on your Mac by default.

## English

### What is Codex?

Codex is OpenAI's coding agent inside the ChatGPT desktop app. You describe the result you want, give it files such as your cat photos, and it can create, test, and package the app in a folder on your Mac.

- [Official ChatGPT desktop app guide and download](https://learn.chatgpt.com/docs/app)
- [Official OpenAI guide to Codex Skills](https://learn.chatgpt.com/docs/build-skills)

This guide uses a Mac with Apple silicon and builds a desktop pet for macOS 13 or later.

### Before you start

Prepare 6–10 clear photos of the same cat. Use photos you own or have permission to use.

- front face with eye color visible
- left and right side profiles
- full standing body with all four paws and the complete tail visible
- sitting and sleeping poses
- clear coat markings, ears, paws, and tail
- optional: a short side-view walking video

Avoid blurry photos, heavy filters, covered paws, cropped tails, and photos where another animal could confuse the cat's identity.

### Beginner setup — start here

#### 1. Install ChatGPT and open Codex

1. Open the [official desktop app page](https://learn.chatgpt.com/docs/app).
2. Download and install ChatGPT for macOS.
3. Open the app and sign in with your ChatGPT account.
4. Choose **Codex**, then start a new chat.

#### 2. Create and open a private working folder

In Finder, create an empty folder named `My Cat Companion`, for example on your Desktop. Open that folder as the working folder in Codex. Keep your cat photos in this private folder or attach them directly to the Codex chat.

#### 3. Install this Skill

Paste this into Codex:

```text
Use $skill-installer to install the make-desktop-cat skill from
https://github.com/clairelyai/catcompanion/tree/main/skills/make-desktop-cat
```

If the new Skill does not appear immediately, restart the ChatGPT desktop app and reopen Codex.

Manual fallback for Terminal users:

```bash
git clone https://github.com/clairelyai/catcompanion.git
mkdir -p ~/.agents/skills
cp -R catcompanion/skills/make-desktop-cat ~/.agents/skills/
```

#### 4. Let Codex check the Apple build tools

Paste this into Codex:

```text
Before making my desktop pet, check whether Xcode Command Line Tools are installed.
If they are missing, run xcode-select --install and tell me exactly what to click.
```

macOS may show an installer. Click **Install**, wait for it to finish, then tell Codex to continue.

#### 5. Add your cat photos and use this complete prompt

Attach the photos to the chat, or tell Codex which private folder contains them. Replace the words in brackets, then paste:

```text
Use $make-desktop-cat.

Create a private macOS desktop pet using only the photos of my own cat.
My cat's name is [NAME]. The photos are [ATTACHED / IN THE PHOTOS FOLDER].

Preserve the same cat's coat color, markings, eye color, face, ears, paws, body shape,
and tail in every pose. Do not substitute a generic cat or change the breed or color.

Make transparent sprites for sitting, sleeping, jumping, and a natural four-frame walk.
All four legs must move during walking, including the rear paws changing position and
ground contact. Add petting hearts, dragging, free roaming, Work, Bath, language switching,
and Call Cat Back.

Keep my original photos, generated sprites, app, and ZIP private and out of GitHub.
Guide me through any approvals. Continue until the app is built, signed, tested, and packaged.
At the end, tell me the exact app and ZIP locations and how to open the pet.
```

Codex should ask you to review the cat identity and walking poses before the final build. Reject a pose if the coat, face, tail, or number of legs is wrong.

#### 6. Open and use your pet

Codex will report the exact ZIP path when the build succeeds. Then:

1. Double-click the ZIP to extract it.
2. The first time you open the app, Control-click the app, choose **Open**, then confirm **Open**. This is expected for a locally signed app.
3. Click the cat to make it react or jump.
4. Move the pointer back and forth over the cat to pet it.
5. Drag the cat to move it.
6. Right-click the cat, or use the cat icon in the macOS menu bar, to choose Walk, Jump, Sit, Sleep, Work, Bath, Free Roam, language, or Call Cat Back.

Your pet belongs to you. The open-source template remains under the MIT License; your original photos and generated pet sprites are not included in this repository.

### What Codex should produce

```text
your-private-project/
├── Assets/                 # your private generated cat sprites
├── Sources/                # desktop-pet app source
├── Resources/
└── output/
    └── Your-Cat-Companion-macOS.zip
```

If image generation is unavailable in your Codex setup, Codex should stop and explain that it needs image-generation access or seven manually prepared transparent PNG sprites. It should never silently replace your cat with a generic one.

## 繁體中文

### Codex 是什麼？

Codex 是 ChatGPT 桌面 App 裡的 OpenAI 程式製作助手。你只要描述想要的結果並提供自己的貓照片，它可以在 Mac 的資料夾裡建立、測試及打包桌面寵物，不需要自己會寫程式。

- [ChatGPT 桌面 App 官方下載與教學](https://learn.chatgpt.com/docs/app)
- [Codex Skills 官方說明](https://learn.chatgpt.com/docs/build-skills)

這份教學使用 Apple 晶片 Mac，完成的桌面寵物支援 macOS 13 或以上。

### 開始前準備照片

準備同一隻貓的 6–10 張清楚照片，而且照片必須屬於你或已取得使用許可。

- 看得清楚眼睛顏色的正面臉部照
- 左右側面照
- 四隻腳和完整尾巴都入鏡的全身站姿
- 坐姿與睡姿
- 看得清楚毛色、花紋、耳朵、腳掌和尾巴的照片
- 可選：側面走路短片

避免模糊、重濾鏡、腳被遮住、尾巴被裁掉，或有其他動物一起入鏡的照片。

### 新手完整步驟

#### 1. 安裝 ChatGPT 並打開 Codex

1. 前往[官方桌面 App 頁面](https://learn.chatgpt.com/docs/app)。
2. 下載並安裝 macOS 版 ChatGPT。
3. 打開 App，登入 ChatGPT 帳號。
4. 選擇 **Codex**，建立新的對話。

#### 2. 建立私人工作資料夾

在 Finder 建立一個空的 `My Cat Companion` 資料夾，例如放在桌面，然後在 Codex 將它選為工作資料夾。把貓照片留在這個私人資料夾，或直接附加到 Codex 對話中。

#### 3. 安裝這個 Skill

將以下內容貼到 Codex：

```text
使用 $skill-installer，從下面網址安裝 make-desktop-cat skill：
https://github.com/clairelyai/catcompanion/tree/main/skills/make-desktop-cat
```

如果沒有立刻看到新的 Skill，重新啟動 ChatGPT 桌面 App，再打開 Codex。

熟悉 Terminal 的使用者也可以手動安裝：

```bash
git clone https://github.com/clairelyai/catcompanion.git
mkdir -p ~/.agents/skills
cp -R catcompanion/skills/make-desktop-cat ~/.agents/skills/
```

#### 4. 讓 Codex 檢查 Apple 編譯工具

將以下內容貼到 Codex：

```text
製作桌面寵物前，請檢查 Xcode Command Line Tools 是否已安裝。
如果尚未安裝，執行 xcode-select --install，並逐步告訴我要點哪裡。
```

macOS 可能會跳出安裝視窗。點擊「安裝」，完成後告訴 Codex 繼續。

#### 5. 加入照片並貼上完整 Prompt

把照片附加到對話，或告訴 Codex 私人照片資料夾的位置。修改方括號中的內容，再貼上：

```text
使用 $make-desktop-cat。

只使用我自己貓咪的照片，製作一個私人 macOS 桌面寵物。
我的貓叫做 [名字]，照片已經 [附加在對話／放在 Photos 資料夾]。

每個動作都必須保留同一隻貓的毛色、花紋、眼睛顏色、臉型、耳朵、腳掌、
身形和尾巴。不要換成普通素材貓，也不可以改變品種或顏色。

製作透明背景的坐姿、睡姿、跳躍，以及自然的四格走路素材。
走路時四隻腳都必須移動，後腳的位置和接觸地面的狀態也要改變。
加入摸摸愛心、拖曳、自由活動、工作、洗澡、語言切換和把貓叫回來。

我的原始照片、生成素材、App 和 ZIP 都必須保持私人，不可以上傳 GitHub。
需要我批准時請清楚引導我。持續做到 App 完成編譯、簽章、測試和打包。
最後告訴我 App 與 ZIP 的確切位置，以及如何打開桌面寵物。
```

正式編譯前，Codex 應該讓你檢查貓咪身分和走路動作。如果毛色、臉、尾巴或腳的數量不正確，就要求重新製作該動作。

#### 6. 打開和操作桌面寵物

Codex 編譯成功後會告訴你 ZIP 的確切位置：

1. 雙擊 ZIP 解壓縮。
2. 第一次開啟時，按住 Control 點擊 App，選擇「打開」，再確認「打開」。本機簽章 App 出現這個步驟是正常的。
3. 點一下貓咪，牠會回應或跳一跳。
4. 在貓咪身上來回移動游標可以摸摸牠。
5. 拖曳貓咪可以移動位置。
6. 右鍵點擊貓咪，或使用 macOS 選單列的貓咪圖示，選擇走路、跳躍、坐著、睡覺、工作、洗澡、自由活動、切換語言或把貓叫回來。

做出來的寵物屬於你。開源程式範本採用 MIT License；你的原始照片與生成的私人貓咪素材不包含在這個 repository。

### 隱私與權利

- 不要把 `Photos/`、`Assets/*.png`、`.app` 或包含寵物素材的 ZIP commit 到公開 repository。
- 生成的 App 完全離線，沒有分析、帳號、上傳或網路連線。
- 發布自己的修改前，執行內建隱私檢查。
- 如果 Codex 沒有圖像生成功能，它應該停下並說明需要取得圖像生成權限，或請你手動提供七張透明 PNG；不可以偷偷換成別的貓。

## For contributors

Manual project commands, validation rules, privacy boundaries, and troubleshooting are documented inside [`skills/make-desktop-cat`](skills/make-desktop-cat/).

```bash
bash skills/make-desktop-cat/scripts/new_project.sh --output ~/Desktop/my-cat-companion
bash skills/make-desktop-cat/scripts/validate_assets.sh ~/Desktop/my-cat-companion/Assets
bash skills/make-desktop-cat/scripts/build_app.sh \
  --project ~/Desktop/my-cat-companion \
  --app-name "My Cat Companion" \
  --bundle-id "com.example.mycat"
```

The builder produces an ad-hoc-signed ZIP in the project's `output/` directory. For public distribution without the Control-click → Open step, use your own Developer ID certificate and Apple notarization.

## Repository layout

```text
skills/make-desktop-cat/
├── SKILL.md
├── agents/openai.yaml
├── assets/macos-template/
├── references/
└── scripts/
```

## License

Source code and documentation are released under the [MIT License](LICENSE). Private photos and generated sprites are not included and remain owned by their respective creators.
