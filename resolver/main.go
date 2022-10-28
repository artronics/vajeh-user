package main

import (
	"context"
	"database/sql"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	_ "github.com/lib/pq"
	"log"
	"net"

	"net/url"
	"os"
	"regexp"
)

type MyEvent struct {
	Name string `json:"name"`
	Age  int    `json:"age"`
}

func HandleRequest(ctx context.Context, name MyEvent) (string, error) {
	fmt.Println(ctx)
	fmt.Println(name)

	connectionString := os.Getenv("DB_CONNECTION_STRING")
	err, db := connect(connectionString)

	if err != nil {
		l := log.New(os.Stderr, "", 0)
		l.Println(err)
		os.Exit(1)
	}

	defer db.Close()

	return fmt.Sprintf(`{"message": "hello"}`), nil
}

func connect(connectionString string) (error, *sql.DB) {
	reg := `postgresql://\S+:.+@.+:\d+/.+`
	match, err := regexp.MatchString(reg, connectionString)
	if !match {
		return fmt.Errorf("the connection string doesn't match with regex: %s", reg), nil
	}
	if err != nil {
		return err, nil
	}

	con, err := url.Parse(connectionString)
	if err != nil {
		return err, nil
	}

	host, port, _ := net.SplitHostPort(con.Host)
	password, _ := con.User.Password()
	user := con.User.Username()
	dbname := con.Path[1:]

	psqlInfo := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		host, port, user, password, dbname)

	db, err := sql.Open("postgres", psqlInfo)
	if err != nil {
		return err, nil
	}

	err = db.Ping()
	if err != nil {
		return err, nil
	}

	return nil, db
}

func main() {
	lambda.Start(HandleRequest)
}
