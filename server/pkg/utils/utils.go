package utils

import "encoding/json"

func TypeConverter[T any](data []byte) (T, error) {
	var result T
	err := json.Unmarshal(data, &result)

	if err != nil {
		return result, err
	}

	return result, nil
}
