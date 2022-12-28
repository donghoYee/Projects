from translate.translator import Translator
translator = Translator()


import torch
print("num_threads: ",torch.get_num_threads())

from diffusers import StableDiffusionPipeline
# make sure you're logged in with `huggingface-cli login`
pipe = StableDiffusionPipeline.from_pretrained("CompVis/stable-diffusion-v1-4", revision="fp16", torch_dtype=torch.float16, use_auth_token=True)  
pipe = pipe.to("cuda")
from torch import autocast
import shutil
print("ready")


def create_img(query):# query is ex) "4:a woman riding a bicycle"
    print("creating image -> ",query)
    num, query_value = query.split(":")
    
    if(query_value[0] == "%"):
        print("decoded: ", translator.decode(query_value))
        query_value = translator.papago_translate(query_value) # can use google_translate for substitude
        print("translated: ", query_value)
    
    with autocast("cuda"):
        output = pipe(query_value, num_inference_steps=50) # guidance_scale=7.5 for prompt accuracy
        image = output["sample"][0]
        nsfw = output["nsfw_content_detected"][0]
        
    # Now to display an image you can do either save it such as:
    image.save("images/" + query +".jpg")
    if nsfw:
        shutil.copyfile("ashamed.jpg","images/" + query +".jpg")

    

        
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
                try: 
                    shutil.copyfile("try_again.jpg","images/" + query +".jpg")
                except:
                    print("unfixable error")







