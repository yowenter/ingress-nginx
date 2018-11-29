/*
Copyright 2018 DaoCloud DCE Infrastructure Team.
*/

package abpolicy

import (
	"encoding/json"

	"github.com/golang/glog"
	extensions "k8s.io/api/extensions/v1beta1"
	"k8s.io/ingress-nginx/internal/ingress/annotations/parser"
	"k8s.io/ingress-nginx/internal/ingress/errors"
	"k8s.io/ingress-nginx/internal/ingress/resolver"
)

type abpolicy struct {
	r resolver.Resolver
}

type Backend struct {
	Name   string `json:name, omitempty`
	Header string `json:header, omitempty`
}

type Config struct {
	Enabled  bool
	Host     string
	Path     string
	Type     string
	Header   string
	Backends []*Backend
}

// NewParser parses the ingress for canary related annotations
func NewParser(r resolver.Resolver) parser.IngressAnnotation {
	return abpolicy{r}
}

// Parse parses the annotations contained in the ingress
// rule used to indicate if the canary should be enabled and with what config
func (ab abpolicy) Parse(ing *extensions.Ingress) (interface{}, error) {
	config := &Config{}
	var err error

	config.Enabled, err = parser.GetBoolAnnotation("abpolicy", ing)
	if err != nil {
		config.Enabled = false
	}

	config.Host, err = parser.GetStringAnnotation("abpolicy-host", ing)
	if err != nil {
		config.Host = ""
	}

	config.Path, err = parser.GetStringAnnotation("abpolicy-path", ing)
	if err != nil {
		config.Path = ""
	}

	config.Header, err = parser.GetStringAnnotation("abpolicy-header", ing)
	if err != nil {
		config.Host = ""
	}

	config.Type, err = parser.GetStringAnnotation("abpolicy-type", ing)
	if err != nil {
		config.Type = ""
	}

	backendsString, err := parser.GetStringAnnotation("abpolicy-backends", ing)
	if err != nil {
		backendsString = "[]"
	}
	var backends []*Backend

	err = json.Unmarshal([]byte(backendsString), &backends)
	if err != nil {
		glog.Errorf("Unmarshal abpolicy backends failure `%v`  `%v`", backendsString, err)
	}
	config.Backends = backends

	if config.Enabled && (len(config.Backends) == 0 || len(config.Host) == 0 || len(config.Type) == 0 || len(config.Path) == 0) {
		return nil, errors.NewInvalidAnnotationContent("abpolicy", config)
	}

	return config, nil
}
