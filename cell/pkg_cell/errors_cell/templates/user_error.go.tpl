package errors

type UserError struct {
	message string
}

func (e *UserError) Error() string {
	return e.message
}

func (e *UserError) SanitizedError() string {
	return e.message
}

func (e *UserError) RawError() string {
	return e.message
}

func NewUserError(message string) SanitizedError {
	ret := &UserError{
		message: message,
	}
	return ret
}
