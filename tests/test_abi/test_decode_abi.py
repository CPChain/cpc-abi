import pytest

from cpc_abi.abi import decode_abi

from cpc_abi.exceptions import DecodingError

from cpc_abi.grammar import parse

from ..common.unit import CORRECT_TUPLE_ENCODINGS


@pytest.mark.parametrize('type_str,expected,byte_str', CORRECT_TUPLE_ENCODINGS)
def test_decode_abi(type_str, expected, byte_str):
    abi_type = parse(type_str)
    if abi_type.arrlist is not None:
        pytest.skip('ABI coding functions do not support array types')

    types = [str(t) for t in abi_type.components]

    actual = decode_abi(types, byte_str)
    assert actual == expected


def test_decode_abi_empty_data_raises():
    with pytest.raises(DecodingError):
        decode_abi(['uint32', 'uint32'], b'')


def test_decode_abi_wrong_data_type_raises():
    with pytest.raises(TypeError):
        decode_abi(['uint32', 'uint32'], '')
