#!/usr/bin/env python3
"""Compare a re-contract.sh output dir against a Solidity source file.
Usage: compare-source.py <outdir-with-asm+decompiled.sol> <Source.sol>
Checks each public/external function selector in the source against bytecode PUSH4s and heimdall's names."""
import re,sys,glob
from Crypto.Hash import keccak
d,srcf=sys.argv[1],sys.argv[2]
src=re.sub(r'//.*','',open(srcf).read())
asm=''.join(open(f).read() for f in glob.glob(d+'/*.asm'))
sels=set(m.lower() for m in re.findall(r'PUSH4 (?:0x)?([0-9a-fA-F]{8})',asm))
dec=open(d+'/decompiled.sol').read()
def canon(p):
    o=[]
    for a in [x.strip() for x in p.split(',') if x.strip()]:
        t=a.split()[0]; t={'uint':'uint256','int':'int256'}.get(t,t); o.append(t)
    return ','.join(o)
hit=tot=0
for n,p,mods in re.findall(r'function\s+(\w+)\s*\(([^)]*)\)([^{;]*)',src,re.S):
    if not re.search(r'\b(external|public)\b',mods): continue
    sig=f"{n}({canon(p)})"; k=keccak.new(digest_bits=256); k.update(sig.encode()); s=k.hexdigest()[:8]
    tot+=1; inb=s in sels; hit+=inb
    named='named' if re.search(r'function\s+'+n+r'\(',dec) else ('unres' if 'Unresolved_'+s in dec else '-')
    adm=' [ADMIN]' if re.search(r'only\w+',mods) else ''
    print(f"{s} {'IN' if inb else 'NO'} {named:5} {sig}{adm}")
print(f"source fns matched in bytecode: {hit}/{tot}; bytecode PUSH4 consts: {len(sels)}")
