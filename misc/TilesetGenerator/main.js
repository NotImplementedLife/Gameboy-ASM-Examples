if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {  
	document.getElementById("Workspace").remove();	
	document.getElementById("MobileDeviceError").style.display="block";
}
else {
	document.getElementById("MobileDeviceError").remove();
}

var tilemapCanvas = document.getElementById("ctilemap");
var tmCtx=tilemapCanvas.getContext("2d");

var tmgridCanvas = document.getElementById("ctmgrid");
var tgmCtx= tmgridCanvas.getContext("2d");

var selectedTileX = 0, selectedTileY=0;

function updateVisualTM(tx,ty) {
	tgmCtx.clearRect(0,0,512,256);
	if(typeof(tx) !== 'undefined') {
		tgmCtx.fillStyle="rgba(255,0,0,0.5)";
		tgmCtx.beginPath();
		tgmCtx.fillRect(32*tx,32*ty,32,32);
	}
	tgmCtx.strokeStyle="black";
	tgmCtx.lineWidth=0.7;
	for(var x=0;x<=512;x+=32) {
		tgmCtx.beginPath();
		tgmCtx.moveTo(x,0);
		tgmCtx.lineTo(x,256);
		tgmCtx.stroke();
	}

	for(var y=0;y<=256;y+=32) {
		tgmCtx.beginPath();
		tgmCtx.moveTo(0,y);
		tgmCtx.lineTo(512,y);
		tgmCtx.stroke();
	}	
	tgmCtx.strokeStyle="blue";
	tgmCtx.lineWidth=1;
	tgmCtx.fillStyle="rgba(0,0,255,0.5)";
	tgmCtx.beginPath();
	tgmCtx.strokeRect(32*selectedTileX,32*selectedTileY,32,32);
}

updateVisualTM();

var tileCanvas = document.getElementById("ctile");
var tCtx=tileCanvas.getContext("2d");
tCtx.beginPath();
tCtx.fillStyle="#E0F8D0";
tCtx.fillRect(0,0,256,256);

var tgridCanvas = document.getElementById("ctgrid");
var tgCtx= tgridCanvas.getContext("2d");
tgCtx.strokeStyle="black";
tgCtx.lineWidth=1;

for(var x=0;x<=256;x+=32) {
	tgCtx.beginPath();
	tgCtx.moveTo(x,0);
	tgCtx.lineTo(x,256);
	tgCtx.stroke();
}

for(var y=0;y<=256;y+=32) {
	tgCtx.beginPath();
	tgCtx.moveTo(0,y);
	tgCtx.lineTo(512,y);
	tgCtx.stroke();
}


var tiles=[];
for(var i=0;i<128;i++) {
	tiles.push(new Array(64).fill(0));
}

function drawTileOnMap() {
	tmCtx.drawImage(tileCanvas,32*selectedTileX,32*selectedTileY,32,32);
}

for(selectedTileX=0;selectedTileX<16;selectedTileX++) {
	for(selectedTileY=0;selectedTileY<8;selectedTileY++)
		drawTileOnMap();		
}

tmgridCanvas.addEventListener('mousemove', e => {
	x = e.offsetX;
	y = e.offsetY;  
	updateVisualTM(Math.floor(x/32),Math.floor(y/32));
});

tmgridCanvas.addEventListener('mousedown', e => {
	x = e.offsetX;
	y = e.offsetY; 
	selectedTileX = Math.floor(x/32);
	selectedTileY = Math.floor(y/32);
	updateVisualTM(Math.floor(x/32),Math.floor(y/32));
	var tile=tiles[16*selectedTileY+selectedTileX];
	for(y=0;y<8;y++) {
		for(x=0;x<8;x++) {
			tCtx.fillStyle=getPenColor(tile[8*y+x]);
			tCtx.beginPath();
			tCtx.fillRect(32*x,32*y,32,32);
		}
	}
});

var pen=1;

var colors=["#E0F8D0","#88C070","#346856","#081820"];
var palette=[2,0,1,3];

function getPenColor(_pen) {
	switch(_pen) {
		case 3: return colors[palette[3]];
		case 2: return colors[palette[2]];
		case 1: return colors[palette[1]];
		case 0: return colors[palette[0]];
	}
}

function renderAllTiles() {	
	var bX=selectedTileX;
	var bY=selectedTileY;
	for(selectedTileY=0;selectedTileY<8;selectedTileY++)
		for(selectedTileX=0;selectedTileX<16;selectedTileX++) {
			var tile=tiles[16*selectedTileY+selectedTileX];
			for(y=0;y<8;y++) {
				for(x=0;x<8;x++) {
					tCtx.fillStyle=getPenColor(tile[8*y+x]);					
					tCtx.beginPath();
					tCtx.fillRect(32*x,32*y,32,32);
				}
			}
			drawTileOnMap();
		}
	selectedTileX=bX;
	selectedTileY=bY;	
	var tile=tiles[16*selectedTileY+selectedTileX];
	for(y=0;y<8;y++) {
		for(x=0;x<8;x++) {
			tCtx.fillStyle=getPenColor(tile[8*y+x]);					
			tCtx.beginPath();
			tCtx.fillRect(32*x,32*y,32,32);
		}
	}
	drawTileOnMap();
}


var msdown=false;
tgridCanvas.addEventListener('mousedown',e => {	
	x = Math.floor(e.offsetX/32);
	y = Math.floor(e.offsetY/32);
	tiles[16*selectedTileY+selectedTileX][8*y+x]=pen;	
	tCtx.fillStyle=getPenColor(pen);
	tCtx.beginPath();
	tCtx.fillRect(32*x,32*y,32,32);
	drawTileOnMap();
	msdown=true;
});

tgridCanvas.addEventListener('mousemove',e => {	
	if(!msdown) return;
	x = Math.floor(e.offsetX/32);
	y = Math.floor(e.offsetY/32);
	tiles[16*selectedTileY+selectedTileX][8*y+x]=pen;	
	tCtx.fillStyle=getPenColor(pen);
	tCtx.beginPath();
	tCtx.fillRect(32*x,32*y,32,32);
	drawTileOnMap();	
});

tgridCanvas.addEventListener('mouseup',e => {	
	msdown=false;
});

tgridCanvas.addEventListener('mouseleave',e => {	
	msdown=false;
});


var paletteButtons=[
	document.getElementById("pal0"),
	document.getElementById("pal1"),
	document.getElementById("pal2"),
	document.getElementById("pal3")
];

function setPalette(p0,p1,p2,p3) {
	palette=[p0,p1,p2,p3];
	for(i=0;i<4;i++) {
		paletteButtons[i].style.background=colors[palette[i]];
		paletteButtons[i].style.color=colors[3-palette[i]];
	}
	renderAllTiles();
}
selectedTileX=selectedTileY=0;
setPalette(0,1,2,3);

cmdBox=document.getElementById("cmdBox");
cmdBox.addEventListener('keydown',e=> {
	if(e.keyCode==13) {
		eval(cmdBox.value);
	}
});

function encode() {
	var str="";
	for(var i=0;i<128;i++) {			
		str+="DB ";
		var tile=tiles[i];
		for(var y=0;y<8;y++) {
			var b0=0;
			var b1=0;			
			for(x=0;x<8;x++) {
				b0*=2; b1*=2;
				var cl=tile[8*y+x];
				if(cl==1 || cl==3) b0++;
				if(cl==2 || cl==3) b1++;				
			}			
			str+= "$"+b0.toString(16).padStart(2,'0')+", $"+b1.toString(16).padStart(2,'0');
			if(y==7) str+="\n";
			else str+=", ";
		}		
	}
	document.getElementById("result").value=str;
}

function getFont() {
	var str="";
	for(var i=0;i<128;i++) {			
		str+="DB ";
		var tile=tiles[i];
		for(var y=0;y<8;y++) {
			var b0=0;
			var b1=0;			
			for(x=0;x<8;x++) {
				b0*=2; b1*=2;
				var cl=tile[8*y+x];
				if(cl==1 || cl==3) b0++;
				if(cl==2 || cl==3) b1++;				
			}			
			str+= "$"+b0.toString(16).padStart(2,'0');
			if(y==7) str+="\n";
			else str+=", ";
		}		
	}
	document.getElementById("result").value=str;
}

function load() {
	var k=0;
	var str=document.getElementById("result").value;
	var lines=str.match(/[^\r\n]+/g);
	for(var i in lines) {
		var line=lines[i];
		var nb=line.replace(/[^0-9a-f]/g, "");
		//console.log(nb);
		nb=hex2bin(nb);
		if(nb.length!=128) continue;		
		for(var y=0;y<8;y++) {
			for(var x=0;x<8;x++) {
				var b0=nb[16*y+x]-'0';
				var b1=nb[16*y+x+8]-'0';				
				tiles[k][8*y+x]=b1*2+b0;
			}			
		}
		updateVisualTM(k/8,k%8);
		k++;		
	}		
	renderAllTiles();
}

//https://stackoverflow.com/questions/45053624/convert-hex-to-binary-in-javascript
function hex2bin(hex){
    hex = hex.replace("0x", "").toLowerCase();
    var out = "";
    for(var c of hex) {
        switch(c) {
            case '0': out += "0000"; break;
            case '1': out += "0001"; break;
            case '2': out += "0010"; break;
            case '3': out += "0011"; break;
            case '4': out += "0100"; break;
            case '5': out += "0101"; break;
            case '6': out += "0110"; break;
            case '7': out += "0111"; break;
            case '8': out += "1000"; break;
            case '9': out += "1001"; break;
            case 'a': out += "1010"; break;
            case 'b': out += "1011"; break;
            case 'c': out += "1100"; break;
            case 'd': out += "1101"; break;
            case 'e': out += "1110"; break;
            case 'f': out += "1111"; break;
            default: return "";
        }
    }

    return out;
}


// prevent zoom:
document.body.addEventListener("wheel", e=>{if(e.ctrlKey) e.preventDefault();}, { passive: false});