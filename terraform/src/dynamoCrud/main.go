package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type respModel struct {
	StatusCode int    `json:"statusCode"`
	Error      bool   `json:"error"`
	Detail     string `json:"detail"`
	Message    string `json:"message"`
}

func handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	apiResponse := events.APIGatewayProxyResponse{}

	switch request.HTTPMethod {
	case "GET":
		resp := respModel{
			StatusCode: http.StatusOK,
			Error:      false,
			Detail:     "Hi Vijay Neethipudi 1234",
			Message:    "Data Fetched Successfully",
		}
		respData, err := json.Marshal(resp)
		if err != nil {
			log.Fatal(err.Error())
			panic(err)
		}
		apiResponse = events.APIGatewayProxyResponse{
			StatusCode: http.StatusOK,
			Body:       string(respData),
		}
	}
	return apiResponse, nil
}

func main() {
	lambda.Start(handler)
}
