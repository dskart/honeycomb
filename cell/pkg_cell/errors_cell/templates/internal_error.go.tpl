package errors

type InternalError struct {
	cause error
}

func NewInternalError(err error) SanitizedError {
	return &InternalError{
		cause: err,
	}
}

func (e *InternalError) Error() string {
	return "An internal error has occurred."
}

func (e *InternalError) SanitizedError() string {
	return e.Error()
}

func (e *InternalError) RawError() string {
	return e.cause.Error()
}

func (e *InternalError) Unwrap() error {
	return e.cause
}
