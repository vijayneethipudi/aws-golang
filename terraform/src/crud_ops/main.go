package main

import (
	"encoding/json"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"gopkg.in/go-playground/validator.v9"
)

func main() {
	lambda.Start(handler)
}

func handler(request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	apiResponse := events.APIGatewayProxyResponse{}
	switch request.HTTPMethod {
	case "GET":
		name := request.QueryStringParameters["name"]
		if name != "" {
			apiResponse = events.APIGatewayProxyResponse{
				StatusCode: 200,
				Body:       "Hi" + name,
			}
		} else {
			errorMessage := map[string]string{
				"detail": "Error Occurred while Unmarshal",
			}
			errJson, _ := json.Marshal(errorMessage)
			apiResponse = events.APIGatewayProxyResponse{
				StatusCode: 422,
				Body:       string(errJson),
			}
		}
	case "POST":
		errorMessage := make(map[string]string)
		var persons Persons
		v := validator.New()
		err := json.Unmarshal([]byte(request.Body), &persons)
		if err != nil {
			errorMessage["detail"] = "Error Occurred While Unmarshal"
			errJson, _ := json.Marshal(errorMessage)
			apiResponse = events.APIGatewayProxyResponse{
				StatusCode: 400,
				Body:       string(errJson),
			}
		} else if err := v.Struct(persons); err != nil {
			errorMessage["detail"] = err.Error()
			errJson, _ := json.Marshal(errorMessage)
			apiResponse = events.APIGatewayProxyResponse{
				StatusCode: 422,
				Body:       string(errJson),
			}
		} else {
			fmt.Println(request.Body)
			apiResponse = events.APIGatewayProxyResponse{
				StatusCode: 201,
				Body:       request.Body,
			}
		}
	}
	return apiResponse, nil
}

type Persons struct {
	PersonDetails []Persons `json:"personDetails"`
}

type Person struct {
	FirstName string `json:"firstName" validate:"required,min=2,max=100"`
	LastName  string `json:"lastName" validate:"required,min=2,max=100"`
}
