package types

import (
	"crypto/sha256"
	"encoding/json"
	"fmt"

	"github.com/NethermindEth/starknet.go/typedData"
)

type CredentialType string

type HolderVC struct {
	HolderDID      StarkDid
	CredentialType []CredentialType
	Claims         map[string]string
}
type Proof struct {
	Signature   string `json:"signature"`
	Signer      string `json:"signer"`
	BlockNumber uint64 `json:"blockNumber,omitempty"`
}

type Credential struct {
	Type              []CredentialType  `json:"type"`
	Issuer            string            `json:"issuer"`
	IssuanceDate      string            `json:"issuance_date"`
	CredentialSubject map[string]string `json:"credentialSubject"`
	CredentialProof   Proof             `json:"proof"`
}

func (d *Credential) ToStarkTypedData() (*typedData.TypedData, error) {
	var credentialParams []typedData.TypeParameter
	var message = make(map[string]any, len(d.CredentialSubject))

	domainParams := []typedData.TypeParameter{
		{Name: "name", Type: "felt"},
		{Name: "version", Type: "felt"},
		{Name: "chainId", Type: "felt"},
	}

	types := []typedData.TypeDefinition{
		{
			Name:       "StarkNetDomain",
			Parameters: domainParams,
		},
		{
			Name:       "Credential",
			Parameters: credentialParams,
		},
	}

	typeDomain := typedData.Domain{
		Name:    "StarkNet VC",
		Version: "1",
		ChainId: "1",
	}

	for k, _ := range d.CredentialSubject {
		credentialParams = append(credentialParams, typedData.TypeParameter{
			Name: k,
			Type: "felt",
		})
	}

	for k, v := range d.CredentialSubject {
		valueHash := sha256.Sum256([]byte(v))
		message[k] = fmt.Sprintf("0x%x", valueHash[:31])
	}

	msgBytes, err := json.Marshal(message)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal message: %v", err)
	}
	return typedData.NewTypedData(types, "Credential", typeDomain, msgBytes)
}
