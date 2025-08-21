package utils

import (
	"encoding/json"
	"fmt"

	"github.com/NethermindEth/juno/core/felt"
)

func TypeConverter[T any](data []byte) (T, error) {
	var result T
	err := json.Unmarshal(data, &result)

	if err != nil {
		return result, err
	}

	return result, nil
}

func ConvertSignatureToHex(signature []*felt.Felt) (string, error) {
	if len(signature) != 2 {
		return "", fmt.Errorf("expected 2 signature components (r, s)")
	}

	r := signature[0].Text(16)
	s := signature[1].Text(16)

	return fmt.Sprintf("0x%s%s", r, s), nil
}
