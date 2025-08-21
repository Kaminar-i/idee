package issuer

import (
	"context"
	"fmt"
	"time"

	"github.com/NethermindEth/juno/core/felt"
	"github.com/NethermindEth/starknet.go/account"
	"github.com/NethermindEth/starknet.go/rpc"
	"github.com/emperorsixpacks/idee/pkg/types"
	ideeUtils "github.com/emperorsixpacks/idee/pkg/utils"
)

type IssuerRegisterResp struct {
	DidDoc             *types.DIDDocument
	TxnHash            *felt.Felt
	TxnFee             *felt.Felt
	TxnFinalityStatus  rpc.TxnFinalityStatus
	TxnExecutionStatus rpc.TxnExecutionStatus
}

type AdminIssuerRegistry struct {
	admnAccount             *account.Account
	issuerAccount           *account.Account
	issuerPublicKey         *felt.Felt
	registryContractAddress *felt.Felt
}

func (a AdminIssuerRegistry) GetIssuersDID() string {
	return types.StarkDid(a.issuerAccount.Address.String()).String()
}

func (a AdminIssuerRegistry) Register(ctx context.Context) (IssuerRegisterResp, error) {
	didDoc := ideeUtils.NewDIDStarkDocument(a.issuerAccount.Address, a.issuerPublicKey)
	ttd, err := didDoc.ToStarkTypedData()
	if err != nil {
		return IssuerRegisterResp{}, err
	}

	messageHash, err := ttd.GetMessageHash(a.issuerAccount.Address.String())
	if err != nil {
		return IssuerRegisterResp{}, err
	}

	signature, err := a.issuerAccount.Sign(ctx, messageHash)
	if err != nil {
		return IssuerRegisterResp{}, err
	}
	txn := rpc.InvokeFunctionCall{
		ContractAddress: a.registryContractAddress,
		FunctionName:    "register_issuer",
		CallData:        []*felt.Felt{a.issuerAccount.Address, a.issuerPublicKey, signature[0], signature[1]},
	}

	resp, err := a.admnAccount.BuildAndSendInvokeTxn(ctx, []rpc.InvokeFunctionCall{txn}, nil)
	if err != nil {
		return IssuerRegisterResp{}, err
	}

	txnReceipt, err := a.admnAccount.WaitForTransactionReceipt(ctx, resp.Hash, time.Second)

	if err != nil {
		return IssuerRegisterResp{}, err
	}

	return IssuerRegisterResp{
		DidDoc:             didDoc,
		TxnHash:            txnReceipt.Hash,
		TxnFee:             txnReceipt.ActualFee.Amount,
		TxnFinalityStatus:  txnReceipt.FinalityStatus,
		TxnExecutionStatus: txnReceipt.ExecutionStatus,
	}, nil
}

func (a AdminIssuerRegistry) CreateVC(ctx context.Context, issue types.HolderVC) (*types.Credential, error) {
	if len(issue.CredentialType) == 0 {
		return nil, fmt.Errorf("Credential type cannot be 0")
	}
	issue.CredentialType = append(issue.CredentialType, "VerifiableCredential")
	issue.Claims["id"] = issue.HolderDID.String()
	vc := &types.Credential{
		Type:              issue.CredentialType,
		Issuer:            a.GetIssuersDID(),
		IssuanceDate:      time.Now().UTC().Format(time.RFC3339),
		CredentialSubject: issue.Claims,
	}
	signature, err := a.signVC(ctx, vc)
	if err != nil {
		return nil, err
	}
	blockNumber, err := a.admnAccount.Provider.BlockNumber(ctx)
	if err != nil {
		return nil, err
	}
	vc.CredentialProof = types.Proof{
		Signature:   signature,
		Signer:      a.issuerAccount.Address.String(),
		BlockNumber: blockNumber,
	}
	return vc, nil
}

func (a AdminIssuerRegistry) signVC(ctx context.Context, typedData *types.Credential) (string, error) {

	ttd, err := typedData.ToStarkTypedData()
	if err != nil {
		return "", err
	}

	messageHash, err := ttd.GetMessageHash(a.issuerAccount.Address.String())
	if err != nil {
		return "", err
	}

	signature, err := a.issuerAccount.Sign(ctx, messageHash)
	signatureHex, err := ideeUtils.ConvertSignatureToHex(signature)
	if err != nil {
		return "", err
	}
	return signatureHex, nil
}
