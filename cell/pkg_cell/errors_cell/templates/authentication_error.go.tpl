package errors

const AuthenticationErrorMessage = "Invalid authentication."

type AuthenticationError struct{}

func NewAuthenticationError() SanitizedError {
	return &AuthenticationError{}
}

func (e *AuthenticationError) RawError() string {
	return AuthorizationErrorMessage
}

func (e *AuthenticationError) Error() string {
	return AuthorizationErrorMessage
}

func (e *AuthenticationError) SanitizedError() string {
	return AuthorizationErrorMessage
}
