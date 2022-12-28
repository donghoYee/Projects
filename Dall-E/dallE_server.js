const http = require('http');
const PORT = 2234
const fs = require('fs');
const spawn = require('child_process').spawn;
const {execSync} = require('child_process');
var image_num = 1;

http.createServer(async (req, res) => {
	try{
		if(req.method === 'GET'){
			console.log(req.url);
			if(req.url.startsWith('/dallE?')){
				if(req.url.startsWith('/dallE?OK')){
					res.writeHead(200, {'Access-Control-Allow-Origin': '*','Content-Type': 'application/json'});
					return	res.end();
				}
				let request = req.url;
				
				var query = request.split('=')[1];
				query = query.replace(/_/g, " ");
				console.log(query);
				const image_name = image_num.toString() + ":" +query +".jpg";
				fs.appendFileSync('query_stack.txt', image_num.toString() + ":" +query+"\n");
				const query_num = image_num;
				image_num ++;

				while(true){
					if(fs.existsSync("images/"+image_name)){
						break;
					}
					//execSync('sleep 0.1');
                    await sleep(200);

				}
				console.log("exists");
				res.writeHead(200, {'Access-Control-Allow-Origin': '*','Content-Type': 'application/json'});
				res.end(JSON.stringify({ "name": image_name}));


				process.stdout.on('error', function(err){
					console.log(err);
					res.writeHead(200, {'Access-Control-Allow-Origin': '*','Content-Type': 'text/plain; charset=utf-8'});
					res.end('error');
				});



			}
			else{
				try{
					const data = fs.readFileSync(`.${req.url}`.replace(/_/g, " "));
                    res.writeHead(200, {'Access-Control-Allow-Origin': '*'});
					return res.end(data);
				}catch(err){
					console.error(err);
					res.writeHead(200, {'Access-Control-Allow-Origin': '*','Content-Type': 'text/plain; charset=utf-8'});
					res.end('error');
				}
			}
		}
	}
	catch(err){
		console.error(err);
		res.writeHead(200, {'Access-Control-Allow-Origin': '*','Content-Type': 'text/plain; charset=utf-8'});
		res.end('error');
	}
}).listen(PORT, () => {
	console.log("server listening on port ", PORT);
    });


function sleep(ms) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms);
  });
}
