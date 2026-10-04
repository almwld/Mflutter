#!/usr/bin/env python3
"""Train a real Qwen2.5-0.5B LoRA adapter from JSONL and merge it immediately.

Each JSONL row may be:
{"text": "..."} or
{"prompt": "...", "response": "..."}
"""
import argparse, json, os
from pathlib import Path

def load_rows(path):
    rows=[]
    for line in Path(path).read_text(encoding="utf-8").splitlines():
        if not line.strip(): continue
        item=json.loads(line)
        if "text" in item:
            rows.append({"text": item["text"]})
        else:
            rows.append({"text": "User: "+str(item.get("prompt",""))+"\nAssistant: "+str(item.get("response",""))})
    if not rows: raise ValueError("Training dataset is empty")
    return rows

def main():
    p=argparse.ArgumentParser()
    p.add_argument("--dataset",required=True)
    p.add_argument("--base",default="Qwen/Qwen2.5-0.5B-Instruct")
    p.add_argument("--adapter",required=True)
    p.add_argument("--merged",required=True)
    p.add_argument("--epochs",type=int,default=1)
    p.add_argument("--ollama-name",default="mudabbir-qwen")
    args=p.parse_args()

    from datasets import Dataset
    from transformers import AutoModelForCausalLM, AutoTokenizer
    from trl import SFTTrainer, SFTConfig
    from peft import LoraConfig, PeftModel

    rows=load_rows(args.dataset)
    tokenizer=AutoTokenizer.from_pretrained(args.base)
    model=AutoModelForCausalLM.from_pretrained(args.base)
    ds=Dataset.from_list(rows)
    peft=LoraConfig(r=16,lora_alpha=32,lora_dropout=0.05,bias="none",
                    task_type="CAUSAL_LM",
                    target_modules=["q_proj","k_proj","v_proj","o_proj","gate_proj","up_proj","down_proj"])
    config=SFTConfig(output_dir=args.adapter,num_train_epochs=args.epochs,
                     per_device_train_batch_size=1,gradient_accumulation_steps=8,
                     learning_rate=2e-4,logging_steps=1,save_strategy="no",
                     report_to="none")
    trainer=SFTTrainer(model=model,args=config,train_dataset=ds,
                       processing_class=tokenizer,peft_config=peft)
    trainer.train()
    trainer.save_model(args.adapter)

    base=AutoModelForCausalLM.from_pretrained(args.base)
    adapter=PeftModel.from_pretrained(base,args.adapter)
    merged=adapter.merge_and_unload(safe_merge=True)
    out=Path(args.merged); out.mkdir(parents=True,exist_ok=True)
    merged.save_pretrained(out,safe_serialization=True)
    tokenizer.save_pretrained(out)

    import subprocess
    mf=out/"Modelfile"; mf.write_text("FROM "+str(out.resolve())+"\n",encoding="utf-8")
    subprocess.run(["ollama","create",args.ollama_name,"-f",str(mf)],check=True)
    (out/"mudabbir_qwen_training.json").write_text(json.dumps({
      "base":args.base,"samples":len(rows),"epochs":args.epochs,
      "adapter":str(Path(args.adapter).resolve()),"merged":str(out.resolve()),
      "ollama_model":args.ollama_name
    },ensure_ascii=False,indent=2),encoding="utf-8")

if __name__=="__main__":
    main()
