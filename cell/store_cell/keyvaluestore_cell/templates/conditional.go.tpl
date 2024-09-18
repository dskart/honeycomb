package store

import (
	"fmt"

	"github.com/ccbrown/keyvaluestore"
)

type conditional struct {
	Result keyvaluestore.AtomicWriteResult
	Error  error
}

type Conditionals []conditional

func (c *Conditionals) Append(result keyvaluestore.AtomicWriteResult, err error) {
	*c = append(*c, conditional{
		Result: result,
		Error:  err,
	})
}

func (c Conditionals) Exec(op keyvaluestore.AtomicWriteOperation) error {
	if ok, err := op.Exec(); err != nil {
		return err
	} else if !ok {
		if err := c.Error(); err != nil {
			return err
		}
		return fmt.Errorf("unknown conditional failure")
	}
	return nil
}

func (c Conditionals) Error() error {
	for _, cond := range c {
		if cond.Result.ConditionalFailed() {
			return cond.Error
		}
	}
	return nil
}
