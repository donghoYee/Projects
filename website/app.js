const express = require('express');
const morgan = require('morgan');
const cookieParser = require('cookie-parser');
const session = require('express-session');
const dotenv = require('dotenv');
const path = require('path');
const cors = require('cors');


dotenv.config();
const app = express();
app.set('port', process.env.PORT || 2240);
app.use(cors());
app.use(morgan('dev'));
app.use('/' ,express.static(__dirname +  '/template'));
app.use(express.json());
app.use(express.urlencoded({extended: false}));
app.use(cookieParser(process.env.COOKIE_SECRET));
app.use(session({
	resave: false,
	saveUninitialized: false,
	secret: process.env.COOKIE_SECRET,
	cookie: {
		httpOnly: true,
		secure: false,
	},
	name: 'session-cookie',
}));

app.listen(app.get('port'), () => {
	console.log('waiting on port ',app.get('port'));
});



