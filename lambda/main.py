import json
import os
from twilio.rest import Client

def twilio_call(body):
  account_sid = os.environ['account_sid']
  token = os.environ['token']
  
  twilio_from_number = os.environ['twilio_from_number']
  twilio_to_number = os.environ['twilio_to_number']
  
  client = Client(account_sid, token)
  
  message = client.messages \
    .create(
         body=body,
         from_=twilio_from_number,
         to=twilio_to_number
     )

  return message.sid

def lambda_handler(event, context):

  body = event['body']

  res = twilio_call(body)

  return{
    "statusCode": 200,
    "body": res
  }