package sample

import "github.com/urfave/cli"

func FlagSet() *cli.App {
	app := cli.NewApp()

	app.Flags = []cli.Flag{
		cli.StringFlag{
			Name:  "config, c",
			Usage: "Load configuration *.yaml",
		},
		cli.StringFlag{
			Name:  "env, e",
			Usage: "environment",
		},
	}
	return app
}
