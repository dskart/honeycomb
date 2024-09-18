package errors

const ResourceNotFoundErrorMessage = "The requested resource was not found"

type ResourceNotFoundError struct{}

func (e *ResourceNotFoundError) Error() string {
	return ResourceNotFoundErrorMessage
}

func (e *ResourceNotFoundError) SanitizedError() string {
	return ResourceNotFoundErrorMessage
}

func (e *ResourceNotFoundError) RawError() string {
	return ResourceNotFoundErrorMessage
}

func NewResourceNotFoundError() SanitizedError {
	return &ResourceNotFoundError{}
}
