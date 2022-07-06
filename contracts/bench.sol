// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

abstract contract Setup {
    function _getTestArray() internal returns (uint[] memory array) {
        array = new uint[](50);
        uint i = 0;
        // 50 random numbers
        array[i++] = 0x6eef;
        array[i++] = 0xec13;
        array[i++] = 0x274a;
        array[i++] = 0x04c4;
        array[i++] = 0x9ae9;
        array[i++] = 0xaa53;
        array[i++] = 0x73cc;
        array[i++] = 0x31ab;
        array[i++] = 0x7859;
        array[i++] = 0xf7e6;
        array[i++] = 0x2f8d;
        array[i++] = 0xadc3;
        array[i++] = 0xc83b;
        array[i++] = 0x3a5d;
        array[i++] = 0x38bb;
        array[i++] = 0x2b21;
        array[i++] = 0xa3ff;
        array[i++] = 0x0046;
        array[i++] = 0x081c;
        array[i++] = 0x2258;
        array[i++] = 0xa7ca;
        array[i++] = 0x70fb;
        array[i++] = 0x920b;
        array[i++] = 0x3e0f;
        array[i++] = 0xf2e4;
        array[i++] = 0x2678;
        array[i++] = 0x76c1;
        array[i++] = 0xe9d1;
        array[i++] = 0xaf0b;
        array[i++] = 0x6bb6;
        array[i++] = 0xf66b;
        array[i++] = 0x87b4;
        array[i++] = 0x0d71;
        array[i++] = 0xa487;
        array[i++] = 0xe1f8;
        array[i++] = 0xb408;
        array[i++] = 0x1b65;
        array[i++] = 0x0321;
        array[i++] = 0x2908;
        array[i++] = 0x8285;
        array[i++] = 0xb8e2;
        array[i++] = 0x89d0;
        array[i++] = 0x321f;
        array[i++] = 0xda96;
        array[i++] = 0x1e5a;
        array[i++] = 0x5ad6;
        array[i++] = 0xf142;
        array[i++] = 0x5ce6;
        array[i++] = 0x01d6;
        array[i++] = 0x45f4;
    }
}

contract HeapSort is Setup {
    function bench() external {
        sort(_getTestArray());
    }

    function sort(uint256[] memory array) internal pure {
        unchecked {
            uint256 length = array.length;
            if (length < 2) return;
            // Heapify the array
            for (uint256 i = length / 2; i-- > 0; ) {
                _siftDown(array, length, i, _arrayLoad(array, i));
            }
            // Drain all elements from highest to lowest and put them at the end of the array
            while (--length != 0) {
                uint256 val = _arrayLoad(array, 0);
                _siftDown(array, length, 0, _arrayLoad(array, length));
                _arrayStore(array, length, val);
            }
        }
    }

    function _siftDown(
        uint256[] memory array,
        uint256 length,
        uint256 emptyIdx,
        uint256 inserted
    ) private pure {
        unchecked {
            while (true) {
                // The first child of empty, one level deeper in the heap
                uint256 childIdx = (emptyIdx << 1) + 1;
                // Empty has no children
                if (childIdx >= length) break;
                uint256 childVal = _arrayLoad(array, childIdx);
                uint256 otherChildIdx = childIdx + 1;
                // Pick the larger child
                if (otherChildIdx < length) {
                    uint256 otherChildVal = _arrayLoad(array, otherChildIdx);
                    if (otherChildVal > childVal) {
                        childIdx = otherChildIdx;
                        childVal = otherChildVal;
                    }
                }
                // No child is larger than the inserted value
                if (childVal <= inserted) break;
                // Move the larger child one level up and keep sifting down
                _arrayStore(array, emptyIdx, childVal);
                emptyIdx = childIdx;
            }
            _arrayStore(array, emptyIdx, inserted);
        }
    }

    function _arrayLoad(uint256[] memory array, uint256 idx) private pure returns (uint256 val) {
        /// @solidity memory-safe-assembly
        assembly {
            val := mload(add(32, add(array, shl(5, idx))))
        }
    }

    function _arrayStore(
        uint256[] memory array,
        uint256 idx,
        uint256 val
    ) private pure {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(add(32, add(array, shl(5, idx))), val)
        }
    }
}

contract QuickSort is Setup {
    function bench() external {
        _quickSort(_getTestArray());
    }

    
    function _quickSort(uint256[] memory array) private pure {
        _quickSort(array, 0, array.length);
    }

    function _quickSort(uint256[] memory array, uint256 i, uint256 j) private pure {
        if (j - i < 2) return;

        uint256 p = i;
        for (uint256 k = i + 1; k < j; ++k) {
            if (array[i] > array[k]) {
                _swap(array, ++p, k);
            }
        }
        _swap(array, i, p);
        _quickSort(array, i, p);
        _quickSort(array, p + 1, j);
    }

    function _swap(uint256[] memory array, uint256 i, uint256 j) private pure {
        (array[i], array[j]) = (array[j], array[i]);
    }
}
