const express = require("express");
const morgan = require("morgan");
const multer = require("multer");
const path = require("path");
var fs = require('fs');
const app = express();
const upload = multer({dest: 'images/'});
const spawn = require("child_process").spawn;
var cors = require('cors')
var image_num = 1;

app.set("port", process.env.PORT || 2235);

app.use(cors());
app.use(morgan("dev"));
app.use(express.json({limit : "50mb"}));
app.use(express.urlencoded({limit:"50mb",extended: false}));

app.use("/test", (req, res, next) =>{
    console.log(req.query.prompt);
    buffer = Buffer.from(req.body);
    fs.writeFileSync('upload.png', buffer); 
    res.status(200).send("good");
});

//app.use("/", (req, res, next) => {
//    res.writeHead(200, {'Access-Control-Allow-Origin': '*'});
//});

app.post("/enhance",async (req, res, next) =>{
    var prompt = req.query.prompt;
    var strength = req.query.strength;
    var guidence_score = req.query.guidence_score;
    
    //console.log(prompt, strength, guidence_score);

    buffer = Buffer.from(req.body);
    const image_name = image_num.toString() + ":" + prompt+":"+strength +":"+guidence_score +".png";
    fs.writeFileSync('drawn_image/'+ image_name, buffer); 
    fs.appendFileSync('enhance_query_stack.txt', image_num.toString() + ":" +prompt+":"+strength +":"+guidence_score+"\n");
    image_num ++;
    console.log(image_name);
    while(true){ //wait untill image is generated
        if(fs.existsSync("generated_images/"+image_name)){
				break;
		}
        await sleep(100);
	}
    console.log("exists");
    const data = fs.readFileSync("generated_images/"+image_name);

    res.writeHead(200, {'Access-Control-Allow-Origin': '*','Content-Type':'application/json'});
	res.end(JSON.stringify({"name": image_name}));
});

app.post("/inpaint",async (req, res, next) =>{
    var prompt = req.query.prompt;
    var strength = req.query.strength;
    var guidence_score = req.query.guidence_score;
    
    //console.log(prompt, strength, guidence_score);
    img_buffer = Buffer.from(req.body["img"]);
    mask_buffer = Buffer.from(req.body["mask"]);
    
    const image_name = image_num.toString() + ":" + prompt+":"+strength +":"+guidence_score +".png";
    fs.writeFileSync('inpaint/'+"I:"+image_name, img_buffer);
    fs.writeFileSync('inpaint/'+"M:"+image_name, mask_buffer);
    
    fs.appendFileSync('inpaint_query_stack.txt', image_num.toString() + ":" +prompt+":"+strength +":"+guidence_score+"\n");
    image_num ++;
    console.log(image_name);
    while(true){ //wait untill image is generated
        if(fs.existsSync("generated_images/"+image_name)){
				break;
		}
        await sleep(200);
	}
    console.log("exists");
    const data = fs.readFileSync("generated_images/"+image_name);

    res.writeHead(200, {'Access-Control-Allow-Origin': '*','Content-Type':'application/json'});
	res.end(JSON.stringify({"name": image_name}));
});




app.get("/generated", (req, res, next) =>{
    console.log(req.url);
    var name = (req.url.split("?")[1]).replace(/%20/g, " ");
    try{
       const data = fs.readFileSync("generated_images/"+name);
       res.writeHead(200, {'Access-Control-Allow-Origin': '*'});
       return res.end(data);
    } catch (error) {
    var name_forward = name.split(":")[0]
    var name_body = name.split(":")[1]
    var strength = name.split(":")[2]
    var end = name.split(":")[3]
    const pythonProcess = spawn('python',["decode.py", name_body]);
    pythonProcess.stdout.on('data', (decoded) => {
            console.log("get: "+ "generated_images/"+name_forward+":"+decoded+":"+strength+":"+end);
            const data = fs.readFileSync("generated_images/"+name_forward+":"+decoded+":"+strength+":"+end);
            res.writeHead(200, {'Access-Control-Allow-Origin': '*'});
            return res.end(data);
        });
    }
});


//app.post("/test", upload);

app.use((err, req, res, next) =>{
    console.log(err);
    res.status(500).send(err.message);
});

app.listen(app.get('port'), ()=>{
    console.log("server listening on port "+app.get('port'));
});


function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}
