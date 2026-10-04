#!/usr/bin/env python3
"""Merge a PEFT/LoRA adapter into Qwen2.5-0.5B and optionally convert/register it in Ollama.

This is intentionally a host-side worker: Flutter Android cannot safely perform
Transformers/PEFT checkpoint merging inside the APK.
"""
import argparse
import json
import os
import subprocess
from pathlib import Path

def main():
    p=argparse.ArgumentParser()
    p.add_argument("--base", default="Qwen/Qwen2.5-0.5B-Instruct")
    p.add_argument("--adapter", required=True)
    p.add_argument("--output", required=True)
    p.add_argument("--ollama", default="")
    p.add_argument("--model-name", default="mudabbir-qwen")
    args=p.parse_args()

    try:
        import torch
        from transformers import AutoModelForCausalLM, AutoTokenizer
        from peft import PeftModel
    except ImportError as e:
        raise SystemExit("Install transformers peft torch before merging: "+str(e))

    out=Path(args.output)
    out.mkdir(parents=True, exist_ok=True)
    tokenizer=AutoTokenizer.from_pretrained(args.base)
    base=AutoModelForCausalLM.from_pretrained(args.base, torch_dtype=torch.float32)
    model=PeftModel.from_pretrained(base, args.adapter)
    merged=model.merge_and_unload(safe_merge=True)
    merged.save_pretrained(out, safe_serialization=True)
    tokenizer.save_pretrained(out)

    manifest={
      "base_model": args.base,
      "adapter": os.path.abspath(args.adapter),
      "merged_model": str(out.resolve()),
      "merged": True
    }
    (out/"mudabbir_merge_manifest.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf-8")

    if args.ollama:
        modelfile=out/"Modelfile"
        modelfile.write_text("FROM "+str(out.resolve())+"\n",encoding="utf-8")
        subprocess.run(["ollama","create",args.model_name,"-f",str(modelfile)],check=True)
        manifest["ollama_model"]=args.model_name
        (out/"mudabbir_merge_manifest.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf-8")

if __name__=="__main__":
    main()
