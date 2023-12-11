package router

import (
	"github.com/Musuyaba/artificer-qr-code-gen/pkg/controllers"
	"github.com/gin-gonic/gin"
	"github.com/spf13/viper"
)

type Dependencies interface {
	GetConfig() *viper.Viper
}

func StartApp(config *viper.Viper) {
	dependencies := controllers.NewAppDependencies(config)

	r := gin.Default()

	r.GET("/chart", controllers.ChartHandler(dependencies))

	r.GET("/chart/help", controllers.HelpHandler())

	r.Run("0.0.0.0" + ":" + config.GetString("PORT_GOLANG"))
}
