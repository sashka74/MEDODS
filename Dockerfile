FROM golang:1.17.5-alpine3.15

RUN apk add git && git clone https://github.com/GreatMedivack/test_task.git
WORKDIR test_task
RUN go mod download && go build

EXPOSE 8080

ENTRYPOINT ["./go-sample-app"]
