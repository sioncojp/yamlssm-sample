package sample

import (
	"fmt"
	"io/ioutil"

	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/mysql"
	"github.com/suzuken/yamlssm"
)

type DBConfig struct {
	Username, Password, Database string
	Host                         string
	Port                         int
}

type UserDetails struct {
	UserID    int `gorm:"column:user_id"`
	UserName  string
	FirstName string `gorm:"column:first_name"`
	LastName  string `gorm:"column:last_name"`
	Gender    string
	Password  string
	Status    int
}

func newDBConfig(config, env string) (*DBConfig, error) {
	var t map[string]DBConfig

	buf, err := ioutil.ReadFile(config)
	if err != nil {
		return nil, err
	}

	err = yamlssm.Unmarshal(buf, &t)
	if err != nil {
		return nil, err
	}

	c := t[env]
	return &c, nil
}

func (c *DBConfig) newDBConnection() ([]UserDetails, error) {
	db, err := gorm.Open("mysql", fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8&parseTime=True&loc=Local", c.Username, c.Password, c.Host, c.Port, c.Database))
	if err != nil {
		return nil, err
	}
	defer db.Close()

	var userDetails []UserDetails
	db.Find(&userDetails)

	return userDetails, nil
}
