# Ruby Slackcamp

[![Dependency Status](https://gemnasium.com/jasonwells/ruby-slackcamp.svg)](https://gemnasium.com/jasonwells/ruby-slackcamp)

Ruby port of [slackcamp](https://github.com/jamescarlos/slackcamp), a simple cron job written in Ruby which finds new activity from [Basecamp](http://basecamp.com) and posts it to a specified [Slack](http://slack.com) channel.

## Requirements
- Ruby 2.2.x + (I've only testing it here, but it should work in other versions as well)
- [Slack](http://slack.com) account
- [Basecamp](http://basecamp.com) account

## Configuration on Slack

### 1. Choose a team you want to connect with Basecamp
This is the team you want to link with your Basecamp account

### 2. Configure Integrations

![Slack integration configuration](http://plopster.blob.core.windows.net/slackcamp/slack_configure_integrations.png)

### 3. Incoming Webhooks

![Slack Incoming Webhooks](http://plopster.blob.core.windows.net/slackcamp/slack_webhooks.png)

### 4. Set up webhook

![Slack webhook setup](http://plopster.blob.core.windows.net/slackcamp/slack_webhook_setup.png?123)

### 5. Integration complete

![Slack webhook active](http://plopster.blob.core.windows.net/slackcamp/slack_integration_complete.png)

## Installation
1. Clone the repository.
2. Run bundler `bundle install`
3. Copy `config/settings-example.yml` to `config/settings.yml` and modify settings.
4. Set up a cron job to run:

```bash
$ crontab -e

# run slackcamp, send basecamp activity to slack
*/1 * * * * ruby /ruby-slackcamp/slackcamp.rb
```

## Notes
slackcamp needs to be able to write to a file named `last_run_date.txt` within it's directory. This is so that when we don't get duplicate events from Basecamp.

slackcamp also relies on the accuracy of Ruby's `Time.now` and related functions. If the server time is inaccurate, you may receive duplicate (or missing) messages.

## Thanks
[jamescarlos / slackcamp](https://github.com/jamescarlos/slackcamp) - Orignal PHP implementaion of slackcamp

[birarda / logan](https://github.com/birarda/logan) - Ruby implementation of the Basecamp 2 API
