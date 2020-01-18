resource "aws_api_gateway_rest_api" "twilio-bot-api" {
  name        = "twilio-bot-api"
  description = "twilio-bot-api"
}

resource "aws_api_gateway_resource" "twilio_proxy" {
   rest_api_id = "${aws_api_gateway_rest_api.twilio-bot-api.id}"
   parent_id   = "${aws_api_gateway_rest_api.twilio-bot-api.root_resource_id}"
   path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "twilio_proxy" {
   rest_api_id   = "${aws_api_gateway_rest_api.twilio-bot-api.id}"
   resource_id   = "${aws_api_gateway_resource.twilio_proxy.id}"
   http_method   = "ANY"
   authorization = "NONE"
 }

 resource "aws_api_gateway_integration" "twilio_lambda" {
   rest_api_id   = "${aws_api_gateway_rest_api.twilio-bot-api.id}"
   resource_id   = "${aws_api_gateway_method.twilio_proxy.resource_id}"
   http_method = "${aws_api_gateway_method.twilio_proxy.http_method}"

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = "${aws_lambda_function.twilio-bot.invoke_arn}"
 }

 resource "aws_api_gateway_method" "twilio_proxy_root" {
   rest_api_id   = "${aws_api_gateway_rest_api.twilio-bot-api.id}"
   resource_id   = "${aws_api_gateway_rest_api.twilio-bot-api.root_resource_id}"
   http_method   = "ANY"
   authorization = "NONE"
 }


resource "aws_api_gateway_integration" "twilio_lambda_root" {
   rest_api_id = "${aws_api_gateway_rest_api.twilio-bot-api.id}"
   resource_id = "${aws_api_gateway_method.twilio_proxy_root.resource_id}"
   http_method = "${aws_api_gateway_method.twilio_proxy_root.http_method}"

   integration_http_method = "POST"
   type                    = "AWS_PROXY"
   uri                     = "${aws_lambda_function.twilio-bot.invoke_arn}"
 }

 resource "aws_api_gateway_deployment" "twilio-bot-api" {
   depends_on = [
     "aws_api_gateway_integration.twilio_lambda",
     "aws_api_gateway_integration.twilio_lambda_root"
   ]

   rest_api_id = "${aws_api_gateway_rest_api.twilio-bot-api.id}"
   stage_name  = "prod"
 }

# Allowing API Gateway to Access Lambda

resource "aws_lambda_permission" "twilio-api-gw" {
   statement_id  = "AllowAPIGatewayInvoke"
   action        = "lambda:InvokeFunction"
   function_name = "${aws_lambda_function.twilio-bot.function_name}"
   principal     = "apigateway.amazonaws.com"

   # The "/*/*" portion grants access from any method on any resource
   # within the API Gateway REST API.
   source_arn = "${aws_api_gateway_rest_api.twilio-bot-api.execution_arn}/*/*"
 }

 output "base_url" {
  value = "${aws_api_gateway_deployment.twilio-bot-api.invoke_url}"
}
