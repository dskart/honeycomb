package router

import (
	"net/http"

	"github.com/gorilla/mux"
)

var (
	componentRouter      *mux.Router
	componentHandleFuncs []HandleFunc
)

func InitComponentRouter(r *mux.Router) {
	componentRouter = r.PathPrefix("/components").Subrouter()
	for _, h := range componentHandleFuncs {
		componentRouter.HandleFunc(h.Path, h.Func).Methods(h.Method)
	}
}

func ComponentHandleFunc(path string, method string, f func(w http.ResponseWriter, r *http.Request)) {
	componentHandleFuncs = append(componentHandleFuncs, HandleFunc{
		Path:   path,
		Func:   f,
		Method: method,
	})
}
