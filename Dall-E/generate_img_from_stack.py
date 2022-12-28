from translate.translator import Translator
translator = Translator()


DALLE_MODEL = "dalle-mini/dalle-mini/mega-1-fp16:latest"  # can be wandb artifact or Hub or local folder or google bucket
DALLE_COMMIT_ID = None

# VQGAN model
VQGAN_REPO = "dalle-mini/vqgan_imagenet_f16_16384"
VQGAN_COMMIT_ID = "e93a26e7707683d349bf5d5c41c5b0ef69b677a9"


import os
#os.environ["XLA_PYTHON_CLIENT_PREALLOCATE"] = 'false' # disable the model from taking up all gpu space
#os.environ["XLA_PYTHON_CLIENT_ALLOCATOR"] = 'platform'
os.environ["XLA_PYTHON_CLIENT_MEM_FRACTION"] = '.75'

import jax
import jax.numpy as jnp

print("local_devices: ", jax.local_device_count())
# Load models & tokenizer
from dalle_mini import DalleBart, DalleBartProcessor
from vqgan_jax.modeling_flax_vqgan import VQModel
from transformers import CLIPProcessor, FlaxCLIPModel

# Load dalle-mini
model, params = DalleBart.from_pretrained(
    DALLE_MODEL, revision=DALLE_COMMIT_ID, dtype=jnp.float16, _do_init=False
)

# Load VQGAN
vqgan, vqgan_params = VQModel.from_pretrained(
    VQGAN_REPO, revision=VQGAN_COMMIT_ID, _do_init=False
)

from flax.jax_utils import replicate

params = replicate(params)
vqgan_params = replicate(vqgan_params)

from functools import partial

# model inference
@partial(jax.pmap, axis_name="batch", static_broadcasted_argnums=(3, 4, 5, 6))
def p_generate(
    tokenized_prompt, key, params, top_k, top_p, temperature, condition_scale
):
    return model.generate(
        **tokenized_prompt,
        prng_key=key,
        params=params,
        top_k=top_k,
        top_p=top_p,
        temperature=temperature,
        condition_scale=condition_scale,
    )


# decode image
@partial(jax.pmap, axis_name="batch")
def p_decode(indices, params):
    return vqgan.decode_code(indices, params=params)

import random

# create a random key
seed = random.randint(0, 2**32 - 1)
key = jax.random.PRNGKey(seed)

from dalle_mini import DalleBartProcessor

processor = DalleBartProcessor.from_pretrained(DALLE_MODEL, revision=DALLE_COMMIT_ID)

# We can customize generation parameters (see https://huggingface.co/blog/how-to-generate)
gen_top_k = None
gen_top_p = None
temperature = None
cond_scale = 10.0

from flax.training.common_utils import shard_prng_key
import numpy as np
from PIL import Image

def create_img(query, key=key):# query is ex) "4:a woman riding a bicycle"
    print("creating image -> ",query)
    num, query_value = query.split(":")
    
    if(query_value[0] == "%"):
        print("decoded: ", translator.decode(query_value))
        query_value = translator.papago_translate(query_value) # can use google_translate for substitude
        print("translated: ", query_value)
    
    tokenized_prompts = processor([query_value])
    tokenized_prompt = replicate(tokenized_prompts)
    seed = random.randint(0, 2**32 - 1)
    key = jax.random.PRNGKey(seed)


    key, subkey = jax.random.split(key)
    
    # generate images
    encoded_images = p_generate(
        tokenized_prompt,
        shard_prng_key(subkey),
        params,
        gen_top_k,
        gen_top_p,
        temperature,
        cond_scale,
    )
    # remove BOS
    encoded_images = encoded_images.sequences[..., 1:]
    # decode images
    decoded_images = p_decode(encoded_images, vqgan_params)
    decoded_images = decoded_images.clip(0.0, 1.0).reshape((-1, 256, 256, 3))
    for decoded_img in decoded_images:
        img = Image.fromarray(np.asarray(decoded_img * 255, dtype=np.uint8))
        img.save("images/" + query +".jpg")
    
import time
while(True):
    with open("query_stack.txt", "r+") as f:
        lines = f.readlines()
        if len(lines) == 0:
            time.sleep(0.1)
        else:
            query = lines[0][:-1]
            f.seek(0)
            f.truncate()
            f.writelines(lines[1:])
            try:
                create_img(query)
            except:
                print("error has occured on: ", query)








