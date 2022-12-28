from translate.translator import Translator
translator = Translator()

from torch import autocast
import torch
from PIL import Image
from diffusers import StableDiffusionPipelineNew

# load the pipeline
device = "cuda"
model_id_or_path = "CompVis/stable-diffusion-v1-4"
pipe = StableDiffusionPipelineNew.from_pretrained(
    model_id_or_path,
    revision="fp16", 
    torch_dtype=torch.float16,
    use_auth_token=True
)

pipe = pipe.to(device)
print("ready")

    
def create_enhanced_img(query):# query is ex) "4:a woman riding a bicycle"
    print("creating image -> ",query)
    init_image = Image.open("drawn_image/"+query+".png").convert("RGB")
    init_image = init_image.resize((512, 512))
    num, query_value = query.split(":")

    
    if(query_value[0] == "%"):
        print("decoded: ", translator.decode(query_value))
        query_value = translator.papago_translate(query_value) # can use google_translate for substitude
        print("translated: ", query_value)
        
    with autocast("cuda"):
        images = pipe.image_to_image(prompt=query_value, init_image=init_image, strength=0.8, guidance_scale=15).images
#        nsfw = output["nsfw_content_detected"][0]
    image = images[0]
    image.save("generated_images/" + query +".png")
#    if nsfw:
#        shutil.copyfile("ashamed.jpg","images/" + query +".jpg")

    

        
import time
while(True):
    with open("enhance_query_stack.txt", "r+") as f:
        lines = f.readlines()
        if len(lines) == 0:
            time.sleep(0.1)
        else:
            query = lines[0][:-1]
            f.seek(0)
            f.truncate()
            f.writelines(lines[1:])
            try:
                create_enhanced_img(query)
            except:
                print("error has occured on: ", query)
                try: 
                    shutil.copyfile("try_again.jpg","generated_images/" + query +".jpg")
                except:
                    print("unfixable error")
    
