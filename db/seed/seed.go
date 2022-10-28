package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	_ "github.com/lib/pq"
	"io/ioutil"
	"net"
	"net/url"
	"os"
)

type User struct {
	Email     string `json:"email"`
	Name      string `json:"name"`
	CreatedOn string `json:"created_on"`
}

func main() {
	if len(os.Args) < 3 {
		fmt.Println("Usage:\n seed postgresql://{user}:{password}@{host}:{port}/{dbname} seed-file.json")
		os.Exit(1)
	}

	connectionString := os.Args[1]
	err, db := connect(connectionString)
	if err != nil {
		panic(err)
	}
	defer db.Close()

	path := os.Args[2]
	file, err := ioutil.ReadFile(path)
	if err != nil {
		panic(err)
	}

	var data []User
	err = json.Unmarshal(file, &data)
	if err != nil {
		panic(err)
	}

	sqlStatement := `
INSERT INTO vajeh_user (email, name, created_on)
VALUES ($1, $2, $3)`

	for _, user := range data {
		_, err = db.Exec(sqlStatement, user.Email, user.Name, user.CreatedOn)
		if err != nil {
			panic(err)
		}
	}

	fmt.Println("Finished seeding DB!")
}

func connect(connectionString string) (error, *sql.DB) {
	con, err := url.Parse(connectionString)
	if err != nil {
		panic(err)
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
