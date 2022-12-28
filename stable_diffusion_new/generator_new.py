from image_enhance.translate.translator import Translator
translator = Translator()

from torch import autocast
import torch
from PIL import Image
from diffusers import StableDiffusionPipelineNew

# load the pipeline
device = "cuda"
model_id_or_path = "runwayml/stable-diffusion-v1-5"
#model_id_or_path = "../dreambooth/dreambooth/output_model"
#model_id_or_path = "../dreambooth/finetune/output_model/"

pipe = StableDiffusionPipelineNew.from_pretrained(
    model_id_or_path,
    revision="fp16", ###
    torch_dtype=torch.float16, ###
    use_auth_token=True
)

pipe = pipe.to(device)
import shutil
print("ready")

    
def create_enhanced_img(query):# query is ex) "4:a woman riding a bicycle"
    print("./creating enhanced image -> ",query)
    init_image = Image.open("./image_enhance/drawn_image/"+query+".png").convert("RGB")
    init_image = init_image.resize((512, 512))
    num, query_value, strength, guidence_score = query.split(":")
    strength_f = float(strength)
    guidence_score_f = float(guidence_score)
    
    query_value_translated = translator.papago_translate(query_value, decode=False) # can use google_translate for substitude
    print("translated: ", query_value_translated)
        
    with autocast("cuda"):
        output = pipe.image_to_image(prompt=query_value_translated, init_image=init_image, strength=strength_f, guidance_scale=guidence_score_f, check_safty=False)
    image = output.images[0]
    nsfw = output.nsfw_content_detected[0]
    if nsfw:
        shutil.copyfile("./ashamed.jpg","./image_enhance/generated_images/" + query +".png")
        return
    image.save("./image_enhance/generated_images/" + query +".png")
    
    
    
    
def create_inpaint_img(query):# query is ex) "4:a woman riding a bicycle"
    print("creating inpaint image -> ",query)
    init_image = Image.open("./image_enhance/inpaint/"+"I:"+query+".png").convert("RGB")
    mask = Image.open("./image_enhance/inpaint/"+"M:"+query+".png").convert("RGB")
    init_image = init_image.resize((512, 512))
    mask = mask.resize((512, 512))
    
    num, query_value, strength, guidence_score = query.split(":")
    strength_f = float(strength)
    guidence_score_f = float(guidence_score)
    
    query_value_translated = translator.papago_translate(query_value, decode=False) # can use google_translate for substitude
    print("translated: ", query_value_translated)
        
    with autocast("cuda"):
        output = pipe.inpaint(prompt=query_value_translated, init_image=init_image, mask_image=mask,strength=strength_f, guidance_scale=guidence_score_f, check_safty=False)
    image = output.images[0]
    nsfw = output.nsfw_content_detected[0]
    if nsfw:
        shutil.copyfile("./ashamed.jpg","./image_enhance/generated_images/" + query +".png")
        return
    image.save("./image_enhance/generated_images/" + query +".png")



def create_img(query):# query is ex) "4:a woman riding a bicycle"
    print("creating image -> ",query)
    num, query_value = query.split(":")
    
    if(query_value[0] == "%"):
        print("decoded: ", translator.decode(query_value))
        query_value = translator.papago_translate(query_value) # can use google_translate for substitude
        print("translated: ", query_value)
    
    with autocast("cuda"):
        output = pipe.text_to_image(query_value, num_inference_steps=50, check_safty=False) # guidance_scale=7.5 for prompt accuracy
    image = output.images[0]
    nsfw = output.nsfw_content_detected[0]
        
    # Now to display an image you can do either save it such as:
    if nsfw:
        shutil.copyfile("./ashamed.jpg","./../Dall-E/images/" + query +".jpg")
        return
    image.save("./../Dall-E/images/" + query +".jpg")
        
import time
while(True):
    with open("./image_enhance/enhance_query_stack.txt", "r+") as f:
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
            except Exception as e:
                print(e)
                print("error has occured on: ", query)
                try: 
                    shutil.copyfile("./try_again.jpg","./image_enhance/generated_images/" + query +".jpg")
                except:
                    print("unfixable error")

                    
                    
    with open("./../Dall-E/query_stack.txt", "r+") as f:
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
            except Exception as e:
                print(e)
                print("error has occured on: ", query)
                try: 
                    shutil.copyfile("try_again.jpg","./../Dall-E/images/" + query +".jpg")
                except:
                    print("unfixable error")
                    
                    
    with open("./image_enhance/inpaint_query_stack.txt", "r+") as f:
        lines = f.readlines()
        if len(lines) == 0:
            time.sleep(0.1)
        else:
            query = lines[0][:-1]
            f.seek(0)
            f.truncate()
            f.writelines(lines[1:])
            try:
                create_inpaint_img(query)
            except Exception as e:
                print(e)
                print("error has occured on: ", query)
                try: 
                    shutil.copyfile("try_again.jpg","./image_enhance/generated_images/" + query +".jpg")
                except:
                    print("unfixable error")    
                    
                    
    
