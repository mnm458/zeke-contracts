// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "./Interfaces.sol";
import "hardhat/console.sol";

contract PaypalVerifier is IVerifier {
    mapping(uint256 => address) internal verifiers;

    constructor(address[] memory _verifiers) {
        /* 
            0. -> email verifier

            1 onwards -> MDV checkers
        */

        uint256 length = _verifiers.length;
        for (uint256 index = 0; index < length; index++) {
            verifiers[index] = _verifiers[index];
        }
    }

    function extract(
        bytes calldata _input
    )
        external
        pure
        returns (
            uint[] memory,
            uint[2][] memory,
            uint[2][2][] memory,
            uint[2][] memory,
            uint[2][] memory,
            uint[2] memory,
            uint[2][2] memory,
            uint[2] memory,
            uint[10] memory
        )
    {
        // abi decode to verify() function's signature
        // then return its value
        // ensure successful decoding, else throw

        uint[] memory _mdv_verifierIndices;
        uint[2][] memory _mdv_pA;
        uint[2][] memory _mdv_pC;
        uint[2][] memory _mdv_pubSignals;
        uint[2][2][] memory _mdv_pB;

        uint[2] memory _email_pA;
        uint[2][2] memory _email_pB;
        uint[2] memory _email_pC;

        uint[10] memory _emailPubSignals;

        (
            _mdv_verifierIndices,
            _mdv_pA,
            _mdv_pB,
            _mdv_pC,
            _mdv_pubSignals,
            _email_pA,
            _email_pB,
            _email_pC,
            _emailPubSignals
        ) = abi.decode(
            _input,
            (
                uint[],
                uint[2][],
                uint[2][2][],
                uint[2][],
                uint[2][],
                uint[2],
                uint[2][2],
                uint[2],
                uint[10]
            )
        );

        return (
            _mdv_verifierIndices,
            _mdv_pA,
            _mdv_pB,
            _mdv_pC,
            _mdv_pubSignals,
            _email_pA,
            _email_pB,
            _email_pC,
            _emailPubSignals
        );
    }

    function verify(
        bytes calldata input
    ) external view returns (bool, bytes memory) {
        // abi decode to verify() function's signature
        // then return its value
        // ensure successful decoding, else throw

        uint[] memory _mdv_verifierIndices;
        uint[2][] memory _mdv_pA;
        uint[2][] memory _mdv_pC;
        uint[2][] memory _mdv_pubSignals;
        uint[2][2][] memory _mdv_pB;

        uint[2] memory _email_pA;
        uint[2][2] memory _email_pB;
        uint[2] memory _email_pC;

        uint[10] memory _emailPubSignals;

        (
            _mdv_verifierIndices,
            _mdv_pA,
            _mdv_pB,
            _mdv_pC,
            _mdv_pubSignals,
            _email_pA,
            _email_pB,
            _email_pC,
            _emailPubSignals
        ) = this.extract(input);

        
        bool mdvValid = this.mdvVerifyProof(
            _mdv_verifierIndices,
            _mdv_pA,
            _mdv_pB,
            _mdv_pC,
            _mdv_pubSignals
        );
        bool emailValid = this.emailVerifyProof(
            _email_pA,
            _email_pB,
            _email_pC,
            _emailPubSignals
        );

        // check if the email hashes are equal too
        /* 
            _emailPubSignals output description:
            1. modulus_hash;
            2. email_hash_poseidon
            3. post_compute_hash
            4. from_regex_reveal_poseidon
            5. actual_amount
            6. actual_timestamp
            7. packed_offramper_id_hashed
            8. packed_onramper_id_hashed
            9. email_nullifier
            10. intent_hash (public input)

            this is missing amount verification and timestamp verification
        */

        bool isHashVerified = (_emailPubSignals[1] ==
            _mdv_pubSignals[_mdv_pubSignals.length - 1][1]) &&
            (_emailPubSignals[2] == _mdv_pubSignals[0][0]);

        bool isTotalValid = mdvValid && emailValid && isHashVerified;
        bytes memory data = abi.encode(_emailPubSignals);
        return (isTotalValid, data);
    }

    function mdvVerifyProof(
        uint256[] calldata verifierIndices,
        uint[2][] calldata _pA,
        uint[2][2][] calldata _pB,
        uint[2][] calldata _pC,
        uint[2][] calldata _pubSignals
    ) public view returns (bool) {
        uint256 length = _pubSignals.length;
        require(length == verifierIndices.length, "incorrect verifier length!");
        require(length == _pA.length, "incorrect _pA length!");
        require(length == _pB.length, "incorrect _pB length!");
        require(length == _pC.length, "incorrect _pC length!");

        bool isValid = true;

        for (uint256 i = 0; i < length; i++) {
            bool validity =
                IMDV(verifiers[verifierIndices[i]]).verifyProof(
                    _pA[i],
                    _pB[i],
                    _pC[i],
                    _pubSignals[i]
                );

            isValid = isValid && validity;

            if (i != 0) {
                bool validity2 =
                    (_pubSignals[i - 1][1] == _pubSignals[i][0]);

                isValid = isValid && validity2;
            }
        }

        // 1st uint256 is the first precompute after the email object,
        // 2nd uint256 is the last postcompute, which must equal the email object hash
        return (isValid);
    }

    function emailVerifyProof(
        uint[2] calldata _pA,
        uint[2][2] calldata _pB,
        uint[2] calldata _pC,
        uint[10] calldata _pubSignals
    ) public view returns (bool) {
        bool isValid = 
            IEmailVerifier(verifiers[0]).verifyProof(
                _pA,
                _pB,
                _pC,
                _pubSignals
            );

        return isValid;
    }
}
