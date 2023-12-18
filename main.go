package main

import (
	"flag"
	"log"

	"github.com/Musuyaba/artificer-qr-code-gen/pkg/router"
	"github.com/spf13/viper"
)

func main() {
	port := flag.String("port", "0", "Port to listen on")
	env_file := flag.String("env-file", ".env", "Env file location")
	flag.Parse()

	config := viper.New()
	config.SetConfigFile(".env")
	if err := config.ReadInConfig(); err != nil {
		log.Fatal("Error reading env file", err)
	}

	if *port == "0" {
		*port = config.GetString("PORT_GOLANG")
	}

	router.StartApp(config, port, env_file)
}
