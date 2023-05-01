import requests
import json

# Replace this with your own Slack webhook URL
# https://api.slack.com/messaging/webhooks
slack_webhook_url = 'https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX'

def send_slack_message(message):
    headers = {'Content-type': 'application/json'}
    payload = {'text': message}

    response = requests.post(slack_webhook_url, data=json.dumps(payload), headers=headers)

    if response.status_code != 200:
        raise ValueError('Failed to send message to Slack')

# Example usage
send_slack_message('Hello, Slackers!')
