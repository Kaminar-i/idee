package utils

import (
	"github.com/NethermindEth/juno/core/felt"
	"github.com/emperorsixpacks/idee/pkg/types"
)

func NewDIDStarkDocument(address *felt.Felt, publicKeyHex *felt.Felt) *types.DIDDocument {
	did := types.StarkDid(address.String())
	doc := &types.DIDDocument{
		Context: []string{
			"https://www.w3.org/ns/did/v1",
			"https://w3id.org/security/suites/jws-2020/v1",
		},
		ID: did.DID(),
		VerificationMethod: types.VerificationMethod{
			ID:         did.KeyID(),
			Type:       "JsonWebKey2020",
			Controller: did.DID(),
			PublicKeyJwk: types.PublicKeyJwk{
				Kty: "OKP",
				Crv: "stark-curve",
				X:   publicKeyHex,
			},
		},
		AssertionMethod: []string{
			did.KeyID(),
		},
	}

	return doc
}
