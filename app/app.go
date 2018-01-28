package sample

import (
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/urfave/cli"
)

const PORT = "8080"

type Handler struct {
	*http.ServeMux
	DBConfig *DBConfig
}

func Run() int {
	var err error
	app := FlagSet()
	app.Action = func(c *cli.Context) error {
		if c.String("config") == "" {
			return errors.New("required -c / --config option.")
		}

		if c.String("env") == "" {
			return errors.New("required -e / --env option.")
		}

		// create Handler struct
		s := &Handler{}

		// initialize DBConfig
		s.DBConfig, err = newDBConfig(c.String("config"), c.String("env"))
		if err != nil {
			return err
		}

		// run http server
		http.HandleFunc("/", s.RootHandler)
		log.Printf("[INFO] Server listening on : %s", PORT)
		if err := http.ListenAndServe(":"+PORT, nil); err != nil {
			return err
		}

		return nil
	}

	err = app.Run(os.Args)
	if err != nil {
		log.Printf("[FATAL] %s", err)
		return 1
	}
	return 0
}

func (s *Handler) RootHandler(w http.ResponseWriter, r *http.Request) {
	str := s.DBConfig
	h, err := str.newDBConnection()
	if err != nil {
		w.Write([]byte(fmt.Sprintf("not connection to db: %s\n", err)))
	}

	for _, v := range h {
		w.Write([]byte(fmt.Sprintf("%+v\n", v)))
	}

	w.Write([]byte(fmt.Sprintf("\n\nuser: %s\npassword: %s\ndatabase: %s\nhost: %s\nport: %d\n", str.Username, str.Password, str.Database, str.Host, str.Port)))
}
