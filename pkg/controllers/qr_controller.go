package controllers

import (
	"os"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/skip2/go-qrcode"
)

func ChartHandler(dependencies Dependencies) gin.HandlerFunc {
	return func(c *gin.Context) {
		// config := dependencies.GetConfig()

		cht := c.DefaultQuery("cht", "qr")
		chs := c.DefaultQuery("chs", "100x100")
		chl := c.DefaultQuery("chl", "Tidak ada inputan teks")
		choe := c.DefaultQuery("choe", "UTF-8")
		chld := c.DefaultQuery("chld", "L|4")

		chs_splitted := strings.Split(chs, "x")
		if chs_splitted[0] != chs_splitted[1] {
			c.AbortWithStatusJSON(504, gin.H{
				"message": "Ukuran harus sama",
			})
			return
		}

		dimension, err := strconv.Atoi(chs_splitted[0])
		if err != nil {
			c.AbortWithStatusJSON(504, gin.H{
				"message": "Error convert dimension",
			})
			return
		}

		imagePath := "./storage/" + cht + "_" + chs + "_" + chl + "_" + choe + "_" + strings.Replace(chld, "|", "", -1)
		if _, err := os.Stat(imagePath); os.IsNotExist(err) {
			err := qrcode.WriteFile(chl, qrcode.Medium, dimension, imagePath)
			if err != nil {
				c.AbortWithStatusJSON(504, gin.H{
					"message": err.Error(),
				})
				return
			}
		}
		c.Header("Content-Type", "image/png")
		c.File(imagePath)
	}
}

func HelpHandler() gin.HandlerFunc {
	return func(c *gin.Context) {
		type DefaultMessage struct {
			DefaultValue string   `json:"defaultValue"`
			Description  string   `json:"description"`
			Optional     []string `json:"optional"`
		}

		chtMessage := DefaultMessage{
			DefaultValue: "qr",
			Description:  "Untuk menyamakan endpoint dari google chart QR Code disamakan.",
			Optional:     nil,
		}

		chsMessage := DefaultMessage{
			DefaultValue: "100x100",
			Description:  "Ukuran gambar. <lebar>x<tinggi>",
			Optional:     nil,
		}

		chlMessage := DefaultMessage{
			DefaultValue: "chlTidakDiisi",
			Description:  "Teks yg diidisi",
			Optional:     nil,
		}

		choeMessage := DefaultMessage{
			DefaultValue: "UTF-8",
			Description:  "Cara mengenkode data dalam kode QR. (Sementara tidak ada pilihan)",
			Optional:     nil,
		}

		chldMessage := DefaultMessage{
			DefaultValue: "L|4",
			Description:  "<error_correction_level>:Kode QR mendukung empat tingkat koreksi error untuk memungkinkan pemulihan data yang hilang, salah membaca, atau terhalang. <margin>: Lebar batas putih di sekitar bagian data kode. <error_correction_level>|<margin> (Sementara tidak ada pilihan)",
			Optional:     nil,
		}

		c.JSON(200, gin.H{
			"message": "Ini adalah help dari api ini",
			"cht":     chtMessage,
			"chs":     chsMessage,
			"chl":     chlMessage,
			"choe":    choeMessage,
			"chld":    chldMessage,
		})
	}
}
