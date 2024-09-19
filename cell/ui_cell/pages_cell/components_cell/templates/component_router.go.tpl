package components

import (
	"net/http"

	uiErrors "{{.GoModulePath}}/pkg/errors"
	"{{.GoModulePath}}/ui/pkg/middleware"
	"{{.GoModulePath}}/ui/pkg/router"
	"github.com/google/uuid"
	"github.com/gorilla/mux"
)

func init() {
	router.ComponentHandleFunc("/todo_form", http.MethodPost, PostTodoForm)
	router.ComponentHandleFunc("/todo_list", http.MethodGet, GetTodos)

	router.ComponentHandleFunc("/todo_item/{id}/toggle", http.MethodPut, PutToggleTodoItem)
	router.ComponentHandleFunc("/todo_item/{id}", http.MethodDelete, DeleteTodoItem)

}

func PostTodoForm(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()
	todoText := r.Form.Get("todoInput")
	if todoText == "" {
		http.Error(w, "text is required", http.StatusBadRequest)
		return
	}

	sess := middleware.CtxSession(r.Context())
	if sanitizedErr := sess.CreateTodo(todoText); sanitizedErr != nil {
		http.Error(w, sanitizedErr.Error(), uiErrors.ErrorHTTPStatus(sanitizedErr))
		return
	}

	w.Header().Add("HX-trigger", "updateTodoList")
	if err := TodoForm().Render(r.Context(), w); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}

func GetTodos(w http.ResponseWriter, r *http.Request) {
	sess := middleware.CtxSession(r.Context())
	todos, sanitizedErr := sess.GetAllTodos()
	if sanitizedErr != nil {
		http.Error(w, sanitizedErr.Error(), uiErrors.ErrorHTTPStatus(sanitizedErr))
		return
	}

	if err := TodoList(todos).Render(r.Context(), w); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
}

func PutToggleTodoItem(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	rawId := vars["id"]
	if rawId == "" {
		http.Error(w, "todo id is required", http.StatusBadRequest)
		return
	}
	id, err := uuid.Parse(rawId)
	if err != nil {
		http.Error(w, "invalid todo id", http.StatusBadRequest)
		return
	}

	sess := middleware.CtxSession(r.Context())
	sanitizedErr := sess.ToggleTodoById(id)
	if sanitizedErr != nil {
		http.Error(w, sanitizedErr.Error(), uiErrors.ErrorHTTPStatus(sanitizedErr))
		return
	}

	w.Header().Add("HX-trigger", "updateTodoList")
}

func DeleteTodoItem(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	rawId := vars["id"]
	if rawId == "" {
		http.Error(w, "todo id is required", http.StatusBadRequest)
		return
	}
	id, err := uuid.Parse(rawId)
	if err != nil {
		http.Error(w, "invalid todo id", http.StatusBadRequest)
		return
	}

	sess := middleware.CtxSession(r.Context())
	sanitizedErr := sess.DeleteTodoById(id)
	if sanitizedErr != nil {
		http.Error(w, sanitizedErr.Error(), uiErrors.ErrorHTTPStatus(sanitizedErr))
		return
	}

	w.Header().Add("HX-trigger", "updateTodoList")
}
