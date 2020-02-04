# How to use
## 1. [https://api.slack.com/apps](https://api.slack.com/apps) に行き "Create New App" ボタンをクリックする

## 2. アプリ名とWorkspaceを入力して "Create App" をクリック
![create_app](readme_images/create_app.png)

## 3. "Basic Information" から "Incomming Webhooks" をクリック
![webhook](readme_images/webhook.png)

## 4. Webhook URLを生成してコピーしておく
![webhook_url](readme_images/webhook_url.png)

## 5. "Basic Information" から "Event Subscriptions" をクリック
![event](readme_images/event.png)

## 6. 各種設定をする
![event_setting](readme_images/event_setting.png)

- デプロイしたUtsushie-StreamのURLを入力してVerifyされるか確認する
- "Add Workspace Event" ボタンから `emoji_changed`  eventを追加

## 7. https://YOUR_TEAM.esa.io/user/applications に行きPersonal Access Tokenを取得する

Read/Write権限が必要なので注意

![esa](readme_images/esa.png)

## 8. Utsushie-Streamの環境変数を設定する
これまでの作業で下記が揃っているはずなので設定する

- ESA_ACCESS_TOKEN
  - 7．の作業で取得したもの
- ESA_TEAM_NAME
  - https://TEAM_NAME.esa.io/
- SLACK_WEBHOOK_URL
  - 4．の作業で取得したもの
