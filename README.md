![logo](logo.png)

Utsushie-Stream はSlackの [emoji_changed event](https://api.slack.com/events/emoji_changed) に反応して、Slackに登録されたEmojiをesaにコピーするツールです。

Utsushie-Stream is a tool that hooks [emoji_changed event](https://api.slack.com/events/emoji_changed) and syncs Slack Custom Emoji to esa.

## Cache
Utsushie-Streamには簡単なキャッシュ機構があります。これは、短時間に同一の絵文字追加イベントが飛んできた場合に、重複して絵文字登録を試さない為に存在します。

キャッシュにはRedisもしくはFirestoreが利用できます。.env.exampleを参考に環境変数を指定することで、キャッシュに用いるサービスを選ぶことができます。なお、RedisとFirestoreの両方が利用可能な場合はRedisが優先されます。

## Usage
[こちら](usage.md)を参照してください。

## :warning:Herokuの無料枠は終了しました:warning:
[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/FromAtom/Utsushie-Stream)

HerokuおよびHeroku Redisの無料枠は終了しました。Utsushie-StreamをHerokuでホスティングする（している）場合はご注意ください。

- https://blog.heroku.com/next-chapter

## LICENSE
[MIT](LICENSE)

## Note
Icon made by Freepik from [www.flaticon.com](https://www.flaticon.com)
