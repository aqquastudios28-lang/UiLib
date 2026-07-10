# bundle.py
#
# Builds the Obsidian source tree (src/) into a single, plain Lua file that can
# be loaded directly with loadstring(game:HttpGet("..."))().
#
# Output:
#   build/bundle.lua  -> plain bundled library (this is what your demo loads)
#   build/bundle_plain.lua -> readable version for debugging

import os
import re
import sys
import base64
import random
import string
import math
from pathlib import Path
from typing import Dict, Optional, Tuple, List, Any


class BundleConfig:
    """Configuration for the bundler."""
    def __init__(self):
        self.src_dir = 'src'
        self.build_dir = 'build'
        self.plain_output = 'bundle_plain.lua'
        self.obfuscated_output = 'bundle.lua'
        self.xor_key = 0x42  # Kept for compatibility, but no longer used in advanced obfuscation
        self.skip_obfuscation = False
        self.verbose = False


def resolve_require(file_path: str, require_expr: str, src_dir: str) -> Optional[str]:
    """Resolve a Roblox-style require(script.X.Y) to a module path."""
    if not require_expr or not require_expr.strip():
        return None
    
    parts = require_expr.strip().split('.')
    if not parts or parts[0] != 'script':
        return None

    try:
        rel_path = os.path.relpath(file_path, src_dir)
    except ValueError:
        return None
    
    path_parts = rel_path.replace(os.sep, '/').split('/')
    if path_parts:
        path_parts[-1] = os.path.splitext(path_parts[-1])[0]
        if path_parts[-1] == 'init':
            path_parts.pop()

    for part in parts[1:]:
        if part == 'Parent':
            if path_parts:
                path_parts.pop()
        else:
            if path_parts:
                path_parts[-1] = part
            else:
                path_parts.append(part)

    return '/'.join(path_parts) if path_parts else None


def discover_modules(src_dir: str, config: BundleConfig) -> Dict[str, str]:
    """Discover all Lua modules in the source directory."""
    if not os.path.isdir(src_dir):
        raise FileNotFoundError(f"Source directory not found: {src_dir}")
    
    modules = {}
    for root, dirs, files in os.walk(src_dir):
        for file in files:
            if file.endswith('.lua'):
                full_path = os.path.join(root, file)
                rel_path = os.path.relpath(full_path, src_dir)
                module_name = os.path.splitext(rel_path)[0].replace(os.sep, '/')
                modules[module_name] = full_path
                if config.verbose:
                    print(f"  Discovered: {module_name}")
    
    return modules


def build_case_insensitive_module_map(modules: Dict[str, str]) -> tuple[Dict[str, str], Dict[str, str]]:
    """Build case-insensitive lookup maps for module names: full-path and unique basename."""
    lowered_map = {}
    basename_map = {}
    for name in modules.keys():
        lowered_map[name.lower()] = name
        base = name.split('/')[-1].lower()
        if base not in basename_map:
            basename_map[base] = name
    return lowered_map, basename_map


def _is_in_string(s: str) -> bool:
    """Check if remainder of string is inside a string literal."""
    in_string = False
    string_char = None
    i = 0
    while i < len(s):
        char = s[i]
        if not in_string:
            if char in ('"', "'"):
                in_string = True
                string_char = char
        else:
            if char == string_char and (i == 0 or s[i-1] != '\\'):
                in_string = False
                string_char = None
        i += 1
    return in_string


def process_module_requires(file_path: str, content: str, src_dir: str, config: BundleConfig, all_modules: Dict[str, str]) -> str:
    """Process and resolve require statements in module content."""
    lines = content.split('\n')
    cleaned_lines = []
    in_multiline = False
    
    for line in lines:
        if in_multiline:
            if ']]' in line:
                in_multiline = False
                line = line.split(']]', 1)[1]
            else:
                cleaned_lines.append('')
                continue
        
        if '[[' in line:
            before = line.split('[[', 1)[0]
            if not _is_in_string(before):
                in_multiline = True
                line = before
        
        if '--' in line:
            before = line.split('--', 1)[0]
            if not _is_in_string(before):
                line = before
        
        cleaned_lines.append(line)
    
    cleaned = '\n'.join(cleaned_lines)
    pattern = r'require\s*\(\s*(script[\w\.]*?)\s*\)'
    lowered_module_map, basename_module_map = build_case_insensitive_module_map(all_modules)
    
    def replace_req(match):
        expr = match.group(1).replace(' ', '')
        resolved = resolve_require(file_path, expr, src_dir)
        if resolved:
            if resolved in all_modules or resolved == 'init':
                return f'custom_require("{resolved}")'
            lowered = resolved.lower()
            if lowered in lowered_module_map:
                canonical = lowered_module_map[lowered]
                return f'custom_require("{canonical}")'
            base = lowered.split('/')[-1]
            if base in basename_module_map:
                canonical = basename_module_map[base]
                return f'custom_require("{canonical}")'
            print(f"Warning: Resolved module '{resolved}' not found (from {file_path})", file=sys.stderr)
        return match.group(0)
    
    result = re.sub(pattern, replace_req, cleaned)
    
    if config.verbose:
        matches = re.findall(pattern, cleaned)
        if matches:
            print(f"  Resolved {len(matches)} require(s) in {os.path.basename(file_path)}")
    
    return result


def build_plain_bundle(config: BundleConfig) -> str:
    """Resolve all requires and concatenate src/ into one Lua source string."""
    src_dir = config.src_dir
    modules = {}
    
    print(f"Discovering modules in {src_dir}/...")
    module_files = discover_modules(src_dir, config)
    
    if not module_files:
        print(f"Warning: No Lua modules found in {src_dir}/")
    else:
        print(f"Found {len(module_files)} module(s)")
    
    print("Processing modules...")
    for module_name, full_path in sorted(module_files.items()):
        try:
            with open(full_path, 'r', encoding='utf-8-sig') as f:
                content = f.read()
            processed = process_module_requires(full_path, content, src_dir, config, module_files)
            modules[module_name] = processed
        except Exception as e:
            print(f"Error processing {full_path}: {e}", file=sys.stderr)
            raise

    if 'init' not in modules:
        raise ValueError("Required init.lua not found in src/")

    bundle_code = f"""-- Obsidian UI Library (bundled build)
-- Bundled modules: {len(modules)}

local modules = {{}}
local cache = {{}}

local function custom_require(name)
    print("  [DEBUG] Requiring module: " .. tostring(name))
    if cache[name] then
        print("  [DEBUG] Returning cached module: " .. tostring(name))
        return cache[name]
    end
    local func = modules[name]
    if not func then
        error("Module not found: " .. tostring(name))
    end
    print("  [DEBUG] Executing module function: " .. tostring(name))
    local result = func()
    cache[name] = result
    print("  [DEBUG] Module loaded: " .. tostring(name))
    return result
end



"""

    for name in sorted(modules.keys()):
        if name != 'init':
            bundle_code += f'\nmodules["{name}"] = function()\n{modules[name]}\nend\n'

    bundle_code += f'\n-- Init Module\n{modules["init"]}\n'
    return bundle_code


# ═══════════════════════════════════════════════════════════════════════════════
# ADVANCED OBFUSCATION ENGINE
# ═══════════════════════════════════════════════════════════════════════════════

class SplitMix32:
    """Strong 32-bit PRNG for generating encryption sequences."""
    def __init__(self, seed):
        self.state = seed & 0xFFFFFFFF
        if self.state == 0:
            self.state = 0x9E3779B9

    def next(self):
        self.state = (self.state + 0x9E3779B9) & 0xFFFFFFFF
        z = self.state
        z = (z ^ (z >> 16)) & 0xFFFFFFFF
        z = (z * 0x85EBCA6B) & 0xFFFFFFFF
        z = (z ^ (z >> 13)) & 0xFFFFFFFF
        z = (z * 0xC2B2AE35) & 0xFFFFFFFF
        z = (z ^ (z >> 16)) & 0xFFFFFFFF
        return z


def custom_b64_encode(data: bytes, alphabet: str) -> str:
    """Encode bytes using a custom shuffled base64 alphabet."""
    result = []
    for i in range(0, len(data), 3):
        chunk = data[i:i+3]
        if len(chunk) == 3:
            n = (chunk[0] << 16) | (chunk[1] << 8) | chunk[2]
            result.append(alphabet[(n >> 18) & 63])
            result.append(alphabet[(n >> 12) & 63])
            result.append(alphabet[(n >> 6) & 63])
            result.append(alphabet[n & 63])
        elif len(chunk) == 2:
            n = (chunk[0] << 16) | (chunk[1] << 8)
            result.append(alphabet[(n >> 18) & 63])
            result.append(alphabet[(n >> 12) & 63])
            result.append(alphabet[(n >> 6) & 63])
            result.append('=')
        elif len(chunk) == 1:
            n = chunk[0] << 16
            result.append(alphabet[(n >> 18) & 63])
            result.append(alphabet[(n >> 12) & 63])
            result.append('==')
    return ''.join(result)


def encrypt_payload(source: str, seed: int) -> Tuple[str, dict]:
    """
    4-Layer Encryption:
    1. XOR with SplitMix32 Keystream
    2. S-Box Substitution
    3. Byte Rotation (Index-dependent)
    4. Custom Shuffled Base64 Encoding
    """
    data = source.encode('utf-8')
    
    # Layer 1: Keystream XOR
    ks_rng = SplitMix32(seed ^ 0x5A5A5A5A)
    xored = bytearray()
    for b in data:
        xored.append(b ^ (ks_rng.next() % 256))
        
    # Layer 2: S-Box Substitution
    sbox_rng = SplitMix32(seed)
    sbox = list(range(256))
    for i in range(255, 0, -1):
        j = sbox_rng.next() % (i + 1)
        sbox[i], sbox[j] = sbox[j], sbox[i]
        
    sboxed = bytearray()
    for b in xored:
        sboxed.append(sbox[b])
        
    # Layer 3: Byte Rotation
    rotated = bytearray()
    for i, b in enumerate(sboxed):
        rotated.append((b + (i * 31)) % 256)
        
    # Layer 4: Custom Base64
    b64_rng = SplitMix32(seed ^ 0xDEADBEEF)
    alphabet = list('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/')
    for i in range(63, 0, -1):
        j = b64_rng.next() % (i + 1)
        alphabet[i], alphabet[j] = alphabet[j], alphabet[i]
    custom_alphabet = ''.join(alphabet)
    
    encoded = custom_b64_encode(bytes(rotated), custom_alphabet)
    
    return encoded, {'seed': seed}


def compute_hash(s: str) -> int:
    """Simple djb2 hash for integrity verification."""
    h = 5381
    for char in s:
        h = ((h * 33) ^ ord(char)) & 0xFFFFFFFF
    return h


def generate_obfuscated_loader(encoded_payload: str, seed: int, config: BundleConfig) -> str:
    """Generates a heavily obfuscated Lua loader with control-flow flattening."""
    
    def rand_var():
        return "_" + "".join(random.choices(string.ascii_lowercase + string.digits, k=12))
        
    # Variables for Lua
    v_pc = rand_var()
    v_mem = rand_var()
    v_sbox = rand_var()
    v_inv_sbox = rand_var()
    v_full_payload = rand_var()
    v_ds = rand_var()
    v_prng = rand_var()
    v_mul = rand_var()
    v_ds_mk = rand_var()
    v_str_pool = rand_var()
    v_alpha = rand_var()
    v_rev = rand_var()
    v_dec = rand_var()
    v_res = rand_var()
    v_ls = rand_var()
    v_hash = rand_var()
    v_ret = rand_var()
    
    # Strings to encrypt
    STRINGS = [
        "loadstring", "error", "syn", "hookfunction", "getgenv", "checkcaller", 
        "getrawmetatable", "getrenv", "getreg", "bit32", "bxor", "band", "lshift", 
        "rshift", "string", "byte", "char", "sub", "len", "table", "insert", "concat",
        "math", "floor", "type"
    ]
    str_indices = {s: i+1 for i, s in enumerate(STRINGS)}
    
    # Encrypt Strings
    master_key = random.randint(1, 0xFFFFFFFF)
    def encrypt_str(s: str) -> list:
        idx = str_indices[s]
        key = (master_key ^ (idx * 2654435761)) % 256
        res = []
        for char in s:
            b = ord(char)
            res.append(b ^ key)
            key = (key * 31 + 17) % 256
        return res

    str_pool = {idx: encrypt_str(s) for s, idx in str_indices.items()}
    
    # Format Lua table for string pool
    lua_str_pool = "{\n"
    for idx, enc_bytes in str_pool.items():
        lua_str_pool += f"    [{idx}] = {{{', '.join(map(str, enc_bytes))}}},\n"
    lua_str_pool += "}"
    
    # Chunk and shuffle payload
    chunk_size = 4000
    chunks_with_idx = [(i+1, encoded_payload[i*chunk_size:(i+1)*chunk_size]) for i in range(math.ceil(len(encoded_payload)/chunk_size))]
    random.shuffle(chunks_with_idx)
    
    lua_chunk_table = "{\n"
    for orig_idx, chunk in chunks_with_idx:
        lua_chunk_table += f"    {{{orig_idx}, '{chunk}'}},\n"
    lua_chunk_table += "}"
    
    # Compute expected hash
    expected_hash = compute_hash(encoded_payload)
    
    # State Machine States (Randomized large integers)
    states = {
        'INIT': random.randint(100000, 999999),
        'CHUNKS': random.randint(100000, 999999),
        'VERIFY': random.randint(100000, 999999),
        'B64_GEN': random.randint(100000, 999999),
        'B64_DEC': random.randint(100000, 999999),
        'SBOX_GEN': random.randint(100000, 999999),
        'INV_SBOX': random.randint(100000, 999999),
        'DECRYPT': random.randint(100000, 999999),
        'EXEC': random.randint(100000, 999999),
        'JUNK1': random.randint(100000, 999999),
        'JUNK2': random.randint(100000, 999999),
        'FAIL': random.randint(100000, 999999)
    }
    
    # Ensure unique
    while len(set(states.values())) < len(states):
        states = {k: random.randint(100000, 999999) for k in states}
        
    # Generate Lua Code
    lua_code = f"""-- Obsidian UI Library (protected build)

local _env = (getfenv and getfenv()) or _G
local _bit32 = _env["bit32"]
local _bxor = _bit32["bxor"]
local _band = _bit32["band"]
local _lshift = _bit32["lshift"]
local _rshift = _bit32["rshift"]
local _string = _env["string"]
local _byte = _string["byte"]
local _char = _string["char"]
local _sub = _string["sub"]
local _len = _string["len"]
local _table = _env["table"]
local _insert = _table["insert"]
local _concat = _table["concat"]
local _math = _env["math"]
local _floor = _math["floor"]

local {v_ds_mk} = {master_key}
local {v_str_pool} = {lua_str_pool}

local function {v_ds}(idx)
    local data = {v_str_pool}[idx]
    if not data then return "" end
    local k = _bxor({v_ds_mk}, (idx * 2654435761) % 4294967296) % 256
    local res = {{}}
    for i = 1, #data do
        res[i] = _char(_bxor(data[i], k))
        k = (k * 31 + 17) % 256
    end
    return _concat(res)
end

-- 32-bit-safe multiply mod 2^32. A direct (a*b) would exceed 2^53 and lose
-- precision in Luau's float64 numbers; splitting keeps every product < 2^53.
local function {v_mul}(a, b)
    local ah = _floor(a / 65536)
    local al = a % 65536
    return (((ah * b) % 65536) * 65536 + al * b) % 4294967296
end

local function {v_prng}(state)
    local new_state = (state + 2654435769) % 4294967296
    local z = new_state
    z = _bxor(z, _rshift(z, 16))
    z = {v_mul}(z, 2246822507)
    z = _bxor(z, _rshift(z, 13))
    z = {v_mul}(z, 3266489909)
    z = _bxor(z, _rshift(z, 16))
    return z, new_state
end

local {v_pc} = {states['INIT']}
local {v_mem} = {{}}
local {v_sbox} = {{}}
local {v_inv_sbox} = {{}}
local {v_full_payload} = ""
local {v_ret} = nil

local _op1 = (type({v_ds}({str_indices['type']})) == "string")
local _op2 = (1 + 1 == 2)

while {v_pc} ~= 0 do
    if {v_pc} == {states['INIT']} and _op1 then
        {v_pc} = {states['CHUNKS']}

    elseif {v_pc} == {states['CHUNKS']} and _op2 then
        local _ct = {lua_chunk_table}
        local _pl = {{}}
        for i = 1, #_ct do _pl[_ct[i][1]] = _ct[i][2] end
        {v_full_payload} = _concat(_pl)
        {v_pc} = {states['VERIFY']}
        
    elseif {v_pc} == {states['VERIFY']} then
        local {v_hash} = 5381
        for i = 1, _len({v_full_payload}) do
            {v_hash} = _bxor(({v_hash} * 33) % 4294967296, _byte({v_full_payload}, i))
        end
        if {v_hash} ~= {expected_hash} then
            {v_pc} = {states['FAIL']}
        else
            {v_pc} = {states['B64_GEN']}
        end
        
    elseif {v_pc} == {states['B64_GEN']} then
        local _seed = {seed}
        local _b64_s = _bxor(_seed, 3735928559)
        local {v_alpha} = {{}}
        local _base = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        for i = 1, 64 do _insert({v_alpha}, _sub(_base, i, i)) end
        for i = 64, 2, -1 do
            local val
            val, _b64_s = {v_prng}(_b64_s)
            local j = (val % i) + 1
            {v_alpha}[i], {v_alpha}[j] = {v_alpha}[j], {v_alpha}[i]
        end
        {v_mem}["alpha"] = {v_alpha}
        {v_mem}["rev_alpha"] = {{}}
        for i = 1, 64 do {v_mem}["rev_alpha"][{v_alpha}[i]] = i - 1 end
        {v_pc} = {states['B64_DEC']}
        
    elseif {v_pc} == {states['B64_DEC']} then
        local {v_rev} = {v_mem}["rev_alpha"]
        local {v_dec} = {{}}
        local _i = 1
        local _len_fp = _len({v_full_payload})
        while _i <= _len_fp do
            local a = {v_rev}[_sub({v_full_payload}, _i, _i)] or 0
            local b = {v_rev}[_sub({v_full_payload}, _i+1, _i+1)] or 0
            local c = {v_rev}[_sub({v_full_payload}, _i+2, _i+2)] or 0
            local d = {v_rev}[_sub({v_full_payload}, _i+3, _i+3)] or 0
            
            local n = _lshift(a, 18) + _lshift(b, 12) + _lshift(c, 6) + d
            _insert({v_dec}, _char(_rshift(n, 16)))
            if _sub({v_full_payload}, _i+2, _i+2) ~= "=" then
                _insert({v_dec}, _char(_band(_rshift(n, 8), 255)))
            end
            if _sub({v_full_payload}, _i+3, _i+3) ~= "=" then
                _insert({v_dec}, _char(_band(n, 255)))
            end
            _i = _i + 4
        end
        {v_mem}["decoded"] = _concat({v_dec})
        {v_pc} = {states['SBOX_GEN']}
        
    elseif {v_pc} == {states['SBOX_GEN']} then
        local _sbox_s = {seed}
        for i = 0, 255 do {v_sbox}[i] = i end
        for i = 255, 1, -1 do
            local val
            val, _sbox_s = {v_prng}(_sbox_s)
            local j = val % (i + 1)
            {v_sbox}[i], {v_sbox}[j] = {v_sbox}[j], {v_sbox}[i]
        end
        {v_pc} = {states['INV_SBOX']}
        
    elseif {v_pc} == {states['INV_SBOX']} then
        for i = 0, 255 do {v_inv_sbox}[{v_sbox}[i]] = i end
        {v_pc} = {states['DECRYPT']}
        
    elseif {v_pc} == {states['DECRYPT']} then
        local _dec_str = {v_mem}["decoded"]
        local _ks_s = _bxor({seed}, 1515870810)
        local {v_res} = {{}}
        for i = 1, _len(_dec_str) do
            local val = _byte(_dec_str, i)
            val = (val - ((i - 1) * 31)) % 256
            val = {v_inv_sbox}[val]
            local ks_val
            ks_val, _ks_s = {v_prng}(_ks_s)
            val = _bxor(val, ks_val % 256)
            _insert({v_res}, _char(val))
        end
        {v_mem}["final"] = _concat({v_res})
        {v_pc} = {states['EXEC']}
        
    elseif {v_pc} == {states['EXEC']} then
        local {v_ls} = _env[{v_ds}({str_indices['loadstring']})] or loadstring
        if {v_ls} then
            local _fn, _err = {v_ls}({v_mem}["final"])
            if _fn then
                {v_ret} = _fn()
            else
                error("Obsidian failed to compile: " .. tostring(_err))
            end
        else
            error("Obsidian: loadstring is unavailable in this environment")
        end
        {v_pc} = 0

    elseif {v_pc} == {states['JUNK1']} then
        local _x = 0
        for i = 1, 100 do _x = _x + i end
        {v_pc} = {states['FAIL']}
        
    elseif {v_pc} == {states['JUNK2']} then
        local _t = {{}}
        for i = 1, 50 do _insert(_t, i) end
        {v_pc} = {states['FAIL']}
        
    elseif {v_pc} == {states['FAIL']} then
        {v_mem} = nil
        {v_pc} = 0
        
    else
        {v_pc} = 0
    end
end

return {v_ret}
"""
    return lua_code


def obfuscate_lua_string(source: str, config: BundleConfig) -> str:
    """Obfuscate Lua source via complex multi-layer encryption and obfuscated loader."""
    seed = random.randint(1, 0xFFFFFFFF)
    encoded, params = encrypt_payload(source, seed)
    return generate_obfuscated_loader(encoded, seed, config)


def bundle_project(config: Optional[BundleConfig] = None) -> Tuple[bool, Optional[str]]:
    """Main bundling function. Generates build/bundle.lua from src/."""
    if config is None:
        config = BundleConfig()
    
    try:
        print("=" * 60)
        print("Obsidian Bundler")
        print("=" * 60)
        print(f"Source directory: {config.src_dir}/")
        print(f"Build directory: {config.build_dir}/")
        print()
        
        plain = build_plain_bundle(config)
        os.makedirs(config.build_dir, exist_ok=True)

        plain_path = os.path.join(config.build_dir, config.plain_output)
        with open(plain_path, 'w', encoding='utf-8') as f:
            f.write(plain)
        plain_size = os.path.getsize(plain_path)
        print(f"✓ Plain bundle saved at {plain_path} ({plain_size:,} bytes)")

        if not config.skip_obfuscation:
            print("Obfuscating bundle (Advanced Multi-Layer + VM-like Dispatch)...")
            obfuscated = obfuscate_lua_string(plain, config)

            output_path = os.path.join(config.build_dir, config.obfuscated_output)
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(obfuscated)

            if os.path.exists(output_path):
                obf_size = os.path.getsize(output_path)
                ratio = (obf_size / plain_size) * 100
                print(f"✓ Obfuscated bundle created at {output_path} ({obf_size:,} bytes, {ratio:.1f}% of plain)")
            else:
                raise IOError(f"Bundle file was not created at {output_path}")
        else:
            print("⊘ Obfuscation skipped (--no-obfuscate flag)")
            output_path = os.path.join(config.build_dir, config.obfuscated_output)
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(plain)
            print(f"✓ Plain bundle copied to {output_path}")
        
        print()
        print("=" * 60)
        print("✓ Bundle completed successfully!")
        print("=" * 60)
        return True, None
            
    except Exception as e:
        error_msg = f"Bundle failed: {e}"
        print(f"\n✗ {error_msg}", file=sys.stderr)
        return False, error_msg


def main():
    """Main entry point with argument parsing."""
    config = BundleConfig()
    
    args = sys.argv[1:]
    i = 0
    while i < len(args):
        arg = args[i]
        if arg in ('--no-obfuscate', '--plain'):
            config.skip_obfuscation = True
        elif arg in ('--verbose', '-v'):
            config.verbose = True
        elif arg.startswith('--src='):
            config.src_dir = arg.split('=', 1)[1]
        elif arg.startswith('--build='):
            config.build_dir = arg.split('=', 1)[1]
        elif arg in ('--help', '-h'):
            print(__doc__)
            print("\nUsage: python bundle.py [options]")
            print("\nOptions:")
            print("  --no-obfuscate, --plain    Skip obfuscation, output plain Lua")
            print("  --verbose, -v              Show detailed progress")
            print("  --src=DIR                  Source directory (default: src)")
            print("  --build=DIR                Build output directory (default: build)")
            print("  --help, -h                 Show this help message")
            sys.exit(0)
        else:
            print(f"Unknown argument: {arg}", file=sys.stderr)
            sys.exit(1)
        i += 1
    
    success, error = bundle_project(config)
    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()