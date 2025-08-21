package types

import (
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"time"

	"github.com/NethermindEth/starknet.go/typedData"
)

type StarkDid string

func (r *StarkDid) DID() string {
	prefix := "did:stark"
	return fmt.Sprintf("%s:%s", prefix, r.String())
}

func (r *StarkDid) KeyID() string {
	return fmt.Sprintf("%s#key-1", r.DID())
}

func (r StarkDid) String() string {
	return string(r)
}

type VerificationMethod struct {
	ID           string `json:"id"`
	Type         string `json:"type"`
	Controller   string `json:"controller"`
	PublicKeyHex string `json:"publicKeyhex"`
}

type DIDDocument struct {
	Context            []string           `json:"@context"`
	ID                 string             `json:"id"`
	VerificationMethod VerificationMethod `json:"verificationMethod"`
	Authentication     []string           `json:"authentication"`
	AssertionMethod    []string           `json:"assertionMethod,omitempty"`
}

func (d *DIDDocument) ToJson() (string, error) {
	bytes, err := json.MarshalIndent(d, "", "  ")
	if err != nil {
		return "", err
	}
	return string(bytes), nil
}

func (d DIDDocument) ToStarkTypedData() (*typedData.TypedData, error) {
	verificationMethodParams := []typedData.TypeParameter{
		{Name: "id", Type: "felt"},
		{Name: "type", Type: "felt"},
		{Name: "controller", Type: "felt"},
		{Name: "publicKeyX", Type: "felt"},
	}

	domainParams := []typedData.TypeParameter{
		{Name: "name", Type: "felt"},
		{Name: "version", Type: "felt"},
		{Name: "chainId", Type: "felt"},
	}

	didDocParams := []typedData.TypeParameter{
		{Name: "id", Type: "felt"},
		{Name: "verificationMethod", Type: "VerificationMethod"},
		{Name: "assertionMethod", Type: "felt"},
		{Name: "timestamp", Type: "felt"},
	}

	types := []typedData.TypeDefinition{
		{
			Name:       "StarkNetDomain",
			Parameters: domainParams,
		},
		{
			Name:       "VerificationMethod",
			Parameters: verificationMethodParams,
		},
		{
			Name:       "DIDDocument",
			Parameters: didDocParams,
		},
	}

	typeDomain := typedData.Domain{
		Name:    "StarkNet DID",
		Version: "1",
		ChainId: "1",
	}

	assertionMethodValue := ""
	if len(d.AssertionMethod) > 0 {
		assertionBytes, _ := json.Marshal(d.AssertionMethod)
		hash := sha256.Sum256(assertionBytes)
		assertionMethodValue = fmt.Sprintf("0x%x", hash[:31])
	}

	idHash := sha256.Sum256([]byte(d.ID))
	vmIDHash := sha256.Sum256([]byte(d.VerificationMethod.ID))
	vmControllerHash := sha256.Sum256([]byte(d.VerificationMethod.Controller))
	vmTypeHash := sha256.Sum256([]byte(d.VerificationMethod.Type))

	message := map[string]any{
		"id": fmt.Sprintf("0x%x", idHash[:31]),
		"verificationMethod": map[string]any{
			"id":           fmt.Sprintf("0x%x", vmIDHash[:31]),
			"type":         fmt.Sprintf("0x%x", vmTypeHash[:31]),
			"controller":   fmt.Sprintf("0x%x", vmControllerHash[:31]),
			"publicKeyHex": d.VerificationMethod.PublicKeyHex,
		},
		"assertionMethod": assertionMethodValue,
		"timestamp":       time.Now().Unix(),
	}

	// Marshal message to bytes
	msgBytes, err := json.Marshal(message)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal message: %v", err)
	}

	return typedData.NewTypedData(types, "DIDDocument", typeDomain, msgBytes)
}
