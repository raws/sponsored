# Sponsored

Sponsored is an IRC bot that hangs out in one or more channels, and periodically posts links to products and services based on what people are talking about. It is meant as a semi-annoying joke, and is somewhat optimized for finding the worst-possible products to advertise.

## Running the bot

To run the bot, install its Ruby gem dependencies and configure the required environment variables.

```sh
bundle install
cp .env.example .env
```

The environment variables required to start the bot are:

| Name | Description |
|------|-------------|
| `AMAZON_ASSOCIATE_ID` | Your [Amazon affiliate program](https://affiliate-program.amazon.com) associate ID. |
| `AWS_ACCESS_KEY_ID` | Your AWS access key ID. Your AWS user must have access to the [Amazon Product Advertising API](https://affiliate-program.amazon.com/gp/advertising/api/detail/main.html). |
| `AWS_SECRET_ACCESS_KEY` | Your AWS secret access key. |
| `BABELNET_API_KEY` | Your [BabelNet API key](http://babelnet.org/guide). |
| `BITLY_OAUTH_TOKEN` | Your [Bitly OAuth token](https://bitly.com/a/oauth_apps). A generic access token works. |
| `GOOGLE_API_KEY` | Your Google API key. It must have access to the [Custom Search API](https://developers.google.com/custom-search/json-api/v1/overview?hl=en_US). |
| `GOOGLE_CUSTOM_SEARCH_ENGINE_ID` | The ID of your Google Custom Search engine. |
| `IRC_CHANNELS` | A comma-separated list of IRC channels to join. |
| `IRC_NICKNAME` | The IRC nickname to use. |
| `IRC_PASSWORD` | The IRC server password. |
| `IRC_PORT` | The IRC server port. |
| `IRC_REALNAME` | The IRC connection real name. |
| `IRC_SERVER` | The IRC server address. |
| `IRC_SSL` | Set to `true` to connect using SSL/TLS. |
| `IRC_USERNAME` | The IRC connection username. |
| `IRC_VERIFY_SSL` | Set to `false` to accept an invalid SSL/TLS certificate. |

These environment variables are optional:

| Name | Description |
|------|-------------|
| `SPONSORED_IGNORED_USERS` | A comma-separated list of usernames (not nicknames) to ignore. |
| `SPONSORED_CHANNEL_AD_TTL_MESSAGES` | The minimum number of messages between ads, per channel. Default: 15 |
| `SPONSORED_CHANNEL_AD_TTL_SECONDS` | The minimum number of seconds between ads, per channel. Default: 3600 |
| `SPONSORED_QUERY_TTL_SECONDS` | The minimum number of seconds between API queries across all channels. Default: 5 |

Then, start the bot.

```sh
bin/sponsored
```

## License

MIT
