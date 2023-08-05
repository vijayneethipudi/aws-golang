package main

import (
	"context"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	lambda.Start(handler)
}

func handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	apiResponse := events.APIGatewayProxyResponse{}
	switch request.HTTPMethod {
	case "GET":
		apiResponse = events.APIGatewayProxyResponse{
			StatusCode: 200,
			Body:       "Hello World",
		}
	}
	return apiResponse, nil
}
