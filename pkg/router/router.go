package router

import (
	"github.com/Musuyaba/artificer-qr-code-gen/pkg/controllers"
	"github.com/gin-gonic/gin"
	"github.com/spf13/viper"
)

type Dependencies interface {
	GetConfig() *viper.Viper
}

func StartApp(config *viper.Viper, port *string, env_file *string) {
	dependencies := controllers.NewAppDependencies(config)

	r := gin.Default()

	r.GET("/chart", controllers.ChartHandler(dependencies, env_file))

	r.GET("/chart/help", controllers.HelpHandler())

	r.Run("0.0.0.0" + ":" + *port)
}
