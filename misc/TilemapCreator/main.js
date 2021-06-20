if(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {  
	document.getElementById("Workspace").remove();	
	document.getElementById("MobileDeviceError").style.display="block";
}
else {
	document.getElementById("MobileDeviceError").remove();
}

var tilemapCanvas=document.getElementById("ctilemap");
var tmCtx=tilemapCanvas.getContext("2d");

var tmGridCanvas=document.getElementById("ctmgrid");
var tgmCtx=tmGridCanvas.getContext("2d");


tgmCtx.strokeStyle="black";
tgmCtx.lineWidth=0.5;
for(var x=0;x<=512;x+=16) {
	tgmCtx.beginPath();
	tgmCtx.moveTo(x,0);
	tgmCtx.lineTo(x,512);
	tgmCtx.stroke();
}

for(var y=0;y<=512;y+=16) {
	tgmCtx.beginPath();
	tgmCtx.moveTo(0,y);
	tgmCtx.lineTo(512,y);
	tgmCtx.stroke();
}	

var bigTileset=document.createElement("canvas");
bigTileset.width=512;
bigTileset.height=512;

btsCtx=bigTileset.getContext("2d");

var tilemap=new Array(1024).fill(0);

function drawSelTile(rx,ry) {	
	var inc=0;
	if(tiles==tiles80) inc+=8;
	//console.log(selectedTileY+" "+selectedTileX);
	tilemap[32*ry+rx]=(selectedTileY+inc)*16+selectedTileX;
	tmCtx.drawImage(bigTileset,selectedTileX*32,(selectedTileY+inc)*32,32,32,rx*16,ry*16,16,16);
}

function tmdmp() {
	var str="";
	for(var y=0;y<32;y++) {			
		str+="DB ";	
		for(var x=0;x<32;x++) {		
			//console.log(tilemap[32*y+x]);
			str+= "$"+(tilemap[32*y+x].toString(16).padStart(2,'0'));
			if(x==31) str+="\n";
			else str+=", ";
		}		
	}
	document.getElementById("tsinp").value=str;
}

function $TMCPY(sx,sy,sw,sh,tx,ty) {
	for(x=sx;x<sx+sw;x++) {
		for(y=sy;y<sy+sh;y++) {
			tilemap[(ty+y)*32+(tx+x)]=tilemap[y*32+x];
			tmCtx.drawImage(tilemapCanvas,x*16,y*16,16,16,(tx+x)*16,(ty+y)*16,16,16);	
		}
	}
}

function $TMFILL(sx,sy,sw,sh,tx,ty,tw,th) {
	for(x=tx;x<tx+tw;x++) {
		for(y=ty;y<ty+th;y++) {
			var xx=sx+(x-tx)%sw;
			var yy=sy+(y-ty)%sh;
			tilemap[y*32+x]=tilemap[yy*32+xx];
			tmCtx.drawImage(tilemapCanvas,xx*16,yy*16,16,16,x*16,y*16,16,16);
		}
	}	
	for(x=sx;x<sx+sw;x++) {
		for(y=sy;y<sy+sh;y++) {
			tilemap[(ty+y)*32+(tx+x)]=tilemap[y*32+x];
			tmCtx.drawImage(tilemapCanvas,x*16,y*16,16,16,(tx+x)*16,(ty+y)*16,16,16);	
		}
	}
}

var msdown=false;

tmGridCanvas.addEventListener('mousedown',e => {	
	x = Math.floor(e.offsetX/16);
	y = Math.floor(e.offsetY/16);
	drawSelTile(x,y);
	msdown=true;
});

tmGridCanvas.addEventListener('mousemove',e => {	
	if(!msdown) return;
	x = Math.floor(e.offsetX/16);
	y = Math.floor(e.offsetY/16);
	drawSelTile(x,y);
});

tmGridCanvas.addEventListener('mouseup',e => {	
	msdown=false;
});

tmGridCanvas.addEventListener('mouseleave',e => {	
	msdown=false;
});


var tilesetCanvas = document.getElementById("ctileset");
var tsCtx=tilesetCanvas.getContext("2d");

var tsGridCanvas = document.getElementById("ctsgrid");
var tgsCtx= tsGridCanvas.getContext("2d");

var selectedTileX = 0, selectedTileY=0;

function updateVisualTM(tx,ty) {
	tgsCtx.clearRect(0,0,512,256);
	if(typeof(tx) !== 'undefined') {
		tgsCtx.fillStyle="rgba(255,0,0,0.5)";
		tgsCtx.beginPath();
		tgsCtx.fillRect(32*tx,32*ty,32,32);
	}
	tgsCtx.strokeStyle="black";
	tgsCtx.lineWidth=0.7;
	for(var x=0;x<=512;x+=32) {
		tgsCtx.beginPath();
		tgsCtx.moveTo(x,0);
		tgsCtx.lineTo(x,256);
		tgsCtx.stroke();
	}

	for(var y=0;y<=256;y+=32) {
		tgsCtx.beginPath();
		tgsCtx.moveTo(0,y);
		tgsCtx.lineTo(512,y);
		tgsCtx.stroke();
	}	
	tgsCtx.strokeStyle="blue";
	tgsCtx.lineWidth=1;
	tgsCtx.fillStyle="rgba(0,0,255,0.5)";
	tgsCtx.beginPath();
	tgsCtx.strokeRect(32*selectedTileX,32*selectedTileY,32,32);
}

updateVisualTM();

var tileCanvas = document.getElementById("ctile");
var tCtx=tileCanvas.getContext("2d");
tCtx.beginPath();
tCtx.fillStyle="#E0F8D0";
tCtx.fillRect(0,0,256,256);

var tiles00=[];
var tiles80=[];

for(var i=0;i<128;i++) {
	tiles00.push(new Array(64).fill(0));
	tiles80.push(new Array(64).fill(0));
}

var tiles=tiles00;

function drawTileOnMap() {
	tsCtx.drawImage(tileCanvas,32*selectedTileX,32*selectedTileY,32,32);
	if(tiles==tiles00) {		
		btsCtx.drawImage(tileCanvas,32*selectedTileX,32*selectedTileY,32,32);//.drawImage(tilesetCanvas,0,0,512,256,0,0,512,256);
	} 
	else if(tiles==tiles80) {		
		btsCtx.drawImage(tileCanvas,32*selectedTileX,256+32*selectedTileY,32,32);//.drawImage(tilesetCanvas,0,0,512,256,0,256,512,256);
	}	
}

for(selectedTileX=0;selectedTileX<16;selectedTileX++) {
	for(selectedTileY=0;selectedTileY<8;selectedTileY++)
		drawTileOnMap();		
}

tsGridCanvas.addEventListener('mousemove', e => {
	x = e.offsetX;
	y = e.offsetY;  
	updateVisualTM(Math.floor(x/32),Math.floor(y/32));
});

tsGridCanvas.addEventListener('mousedown', e => {
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

function load(_tiles) {
	if(_tiles==tiles80) {
		r80.click();
	}
	else {
		r00.click();
	}	
	var k=0;
	var str=document.getElementById("tsinp").value;
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
				_tiles[k][8*y+x]=b1*2+b0;
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