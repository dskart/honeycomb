package errors

import "net/http"

func ErrorHTTPStatus(err error) int {
	switch err.(type) {
	case *ResourceNotFoundError:
		return http.StatusNotFound
	case *UserError:
		return http.StatusBadRequest
	case *AuthenticationError:
		return http.StatusUnauthorized
	case *AuthorizationError:
		return http.StatusForbidden
	default:
		return http.StatusInternalServerError
	}
}
