package errors

const AuthorizationErrorMessage = "You are not authorized to perform this operation."

type AuthorizationError struct{}

func NewAuthorizationError() SanitizedError {
	return &AuthorizationError{}
}

func (e *AuthorizationError) RawError() string {
	return AuthorizationErrorMessage
}

func (e *AuthorizationError) Error() string {
	return AuthorizationErrorMessage
}

func (e *AuthorizationError) SanitizedError() string {
	return AuthorizationErrorMessage
}
