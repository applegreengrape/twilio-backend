provider "aws" {
   region = "eu-west-1"
 }

// zip -g function.zip main.py 
// terraform apply -target aws_lambda_function.twilio-bot

resource "aws_lambda_function" "twilio-bot" {
   function_name = "twilio-bot"
   filename = "function.zip"
   source_code_hash = "${base64sha256(file("function.zip"))}"

   handler = "main.lambda_handler"
   runtime = "python3.7"
   role = "${aws_iam_role.lambda_exec.arn}"

   environment {
    variables = {
      account_sid = "",
      token = "",
      twilio_from_number = "",
      twilio_to_number = ""
    }
  }
}
 # IAM role which dictates what other AWS services the Lambda function
 # may access.
 
resource "aws_iam_role" "lambda_exec" {
   name = "twilio-bot"

   assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
     {
       "Action": "sts:AssumeRole",
       "Principal": {
         "Service": "lambda.amazonaws.com"
       },
       "Effect": "Allow",
       "Sid": ""
     }
   ]
 } 
 EOF
 
}

