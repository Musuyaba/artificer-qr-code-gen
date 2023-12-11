package controllers

import "github.com/spf13/viper"

type Dependencies interface {
	GetConfig() *viper.Viper
}

type AppDependencies struct {
	Config *viper.Viper
}

func NewAppDependencies(config *viper.Viper) *AppDependencies {
	return &AppDependencies{Config: config}
}

func (d *AppDependencies) GetConfig() *viper.Viper {
	return d.Config
}
