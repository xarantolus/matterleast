const fs=require('fs'),zlib=require('zlib');
const W=720,H=420;
const px=Buffer.alloc(W*H*3);
const mix=(a,b,t)=>a.map((v,i)=>Math.round(v+(b[i]-v)*t));
function set(x,y,c){if(x<0||y<0||x>=W||y>=H)return;const o=(y*W+x)*3;px[o]=c[0];px[o+1]=c[1];px[o+2]=c[2];}
const hz=Math.floor(H*0.62);
for(let y=0;y<H;y++)for(let x=0;x<W;x++){
 let c;
 if(y<hz){c=mix([38,52,110],[247,166,92],Math.pow(y/hz,1.4));}
 else{const t=(y-hz)/(H-hz);c=mix([232,140,96],[14,40,72],Math.min(1,t*1.3));
  const w=Math.sin(x/17+y/3)*0.5+0.5; if(w>0.93&&y%5==0)c=mix(c,[255,214,160],0.4);}
 set(x,y,c);}
// sun
for(let y=0;y<H;y++)for(let x=0;x<W;x++){const d=Math.hypot(x-470,y-hz+6);if(d<46&&y<hz)set(x,y,[255,226,170]);}
// sailboat
function tri(p1,p2,p3,c){const minx=Math.min(p1[0],p2[0],p3[0]),maxx=Math.max(p1[0],p2[0],p3[0]),miny=Math.min(p1[1],p2[1],p3[1]),maxy=Math.max(p1[1],p2[1],p3[1]);
 const s=(a,b,p)=>(a[0]-p[0])*(b[1]-p[1])-(b[0]-p[0])*(a[1]-p[1]);
 for(let y=miny;y<=maxy;y++)for(let x=minx;x<=maxx;x++){const p=[x,y];const d1=s(p1,p2,p),d2=s(p2,p3,p),d3=s(p3,p1,p);
  if(!((d1<0||d2<0||d3<0)&&(d1>0||d2>0||d3>0)))set(x,y,c);}}
tri([220,hz-120],[220,hz-8],[300,hz-8],[250,240,230]);
tri([212,hz-100],[212,hz-8],[160,hz-8],[236,220,205]);
tri([140,hz+2],[320,hz+2],[300,hz+22],[30,34,52]);tri([140,hz+2],[150,hz+22],[300,hz+22],[30,34,52]);
for(let y=hz-130;y<hz;y++){set(215,y,[30,34,52]);set(216,y,[30,34,52]);}
// lighthouse
tri([600,hz-110],[590,hz],[610,hz],[28,30,48]);
for(let y=hz-120;y<hz;y++){const hw=Math.round(8+(y-(hz-120))*0.12);for(let x=640-hw;x<=640+hw;x++)set(x,y,(Math.floor((y-hz)/16)%2)?[240,236,228]:[200,60,60]);}
for(let y=hz-140;y<hz-120;y++)for(let x=630;x<=650;x++)set(x,y,[255,236,150]);
tri([626,hz-140],[654,hz-140],[640,hz-160],[40,36,50]);
const rows=[];for(let y=0;y<H;y++){const r=Buffer.alloc(1+W*3);px.copy(r,1,y*W*3,(y+1)*W*3);rows.push(r);}
const t=Array.from({length:256},(_,n)=>{let c=n;for(let k=0;k<8;k++)c=c&1?0xedb88320^(c>>>1):c>>>1;return c>>>0;});
const crc=b=>{let c=0xffffffff;for(const x of b)c=t[(c^x)&255]^(c>>>8);return(c^0xffffffff)>>>0;};
const chunk=(ty,d)=>{const l=Buffer.alloc(4);l.writeUInt32BE(d.length);const td=Buffer.concat([Buffer.from(ty),d]);const c=Buffer.alloc(4);c.writeUInt32BE(crc(td));return Buffer.concat([l,td,c]);};
const ih=Buffer.alloc(13);ih.writeUInt32BE(W,0);ih.writeUInt32BE(H,4);ih[8]=8;ih[9]=2;
fs.writeFileSync(process.argv[2],Buffer.concat([Buffer.from([137,80,78,71,13,10,26,10]),chunk('IHDR',ih),chunk('IDAT',zlib.deflateSync(Buffer.concat(rows))),chunk('IEND',Buffer.alloc(0))]));
