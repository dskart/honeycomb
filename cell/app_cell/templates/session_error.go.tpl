package app

import (
	appErrors "{{.GoModulePath}}/pkg/errors"
	"go.uber.org/zap"
)

func (s *Session) InternalError(err error) appErrors.SanitizedError {
	if err == nil {
		return nil
	}
	s.Logger().Error("Internal Error", zap.Error(err))
	return appErrors.NewInternalError(err)
}

func (s *Session) AuthorizationError() appErrors.SanitizedError {
	s.Logger().Warn(appErrors.AuthorizationErrorMessage)
	return appErrors.NewAuthorizationError()
}

func (s *Session) ResourceNotFoundError() appErrors.SanitizedError {
	s.Logger().Warn(appErrors.ResourceNotFoundErrorMessage)
	return appErrors.NewResourceNotFoundError()
}

func (s *Session) UserError(message string) appErrors.SanitizedError {
	s.Logger().Warn(message)
	return appErrors.NewUserError(message)
}
