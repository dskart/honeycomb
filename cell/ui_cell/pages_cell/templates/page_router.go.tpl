package pages

import (
	"net/http"

	"{{.GoModulePath}}/ui/pkg/router"
)

func init() {
	router.PageHandleFunc("/", http.MethodGet, getPage)
}

func getPage(w http.ResponseWriter, r *http.Request) {
	if err := Page().Render(r.Context(), w); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}
