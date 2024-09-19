package router

import (
	"net/http"

	"github.com/gorilla/mux"
)

var (
	pageRouter      *mux.Router
	pageHandleFuncs []HandleFunc
)

func InitPageRouter(r *mux.Router) {
	pageRouter = r
	for _, h := range pageHandleFuncs {
		pageRouter.HandleFunc(h.Path, h.Func).Methods(h.Method)
	}
}

func PageHandleFunc(path string, method string, f func(w http.ResponseWriter, r *http.Request)) {
	pageHandleFuncs = append(pageHandleFuncs, HandleFunc{
		Path:   path,
		Func:   f,
		Method: method,
	})
}
