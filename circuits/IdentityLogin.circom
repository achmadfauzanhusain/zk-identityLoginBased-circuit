pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template IdentityLogin(depth) {
    signal input identity;
    signal input proofs[depth];
    signal input pathIndexes[depth];
    signal input root;

    signal output isValid;

    signal intermediateHashes[depth + 1];
    signal leftCombination[depth];
    signal rightCombination[depth];
    signal selectedLeft[depth];
    signal selectedRight[depth];

    component leafHash = Poseidon(1);
    leafHash.inputs[0] <== identity;
    
    intermediateHashes[0] <== leafHash.out;

    for (var i = 0; i < depth; i++) {
        pathIndexes[i] * (1 - pathIndexes[i]) === 0;

        leftCombination[i] <== intermediateHashes[i] + proofs[i];
        rightCombination[i] <== proofs[i] + intermediateHashes[i];

        selectedLeft[i] <== leftCombination[i] * pathIndexes[i];
        selectedRight[i] <== rightCombination[i] * (1 - pathIndexes[i]);

        intermediateHashes[i + 1] <== selectedLeft[i] + selectedRight[i];
    }

    signal difference;
    difference <== intermediateHashes[depth] - root;
    isValid <== 1 - (difference * difference);
}

component main = IdentityLogin(2);