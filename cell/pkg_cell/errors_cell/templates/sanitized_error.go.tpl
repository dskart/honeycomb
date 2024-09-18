package errors

type SanitizedError interface {
	error
	SanitizedError() string
	RawError() string
}
