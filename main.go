package main

import (
	"log"

	"github.com/Musuyaba/artificer-qr-code-gen/pkg/router"
	"github.com/spf13/viper"
)

func main() {
	config := viper.New()
	config.SetConfigFile(".env")
	if err := config.ReadInConfig(); err != nil {
		log.Fatal("Error reading env file", err)
	}

	router.StartApp(config)
}
