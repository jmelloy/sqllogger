// Copyright 2004 and onwards Google Inc.

var w="";var pa=false;var ta="";var da=false;var g="";var G="";var m="";var j=-1;var h=null;var Z=-1;var za=null;var Ca=5;var q="";var Lb="div";var Bb="span";var la=null;var a=null;var b=null;var Xa=null;var mb=null;var X=null;var ha=null;var ra=false;var kc=null;var hc=null;var Ua=new Object();var ca=1;var Aa=1;var Y=false;var na=-1;var Va=(new Date()).getTime();var Q=false;var k=null;var sa=null;var E=null;var B=null;var aa=null;var Ba=false;var Ka=false;var p=60;var ia=null;var ya=null;var W=0;InstallAC=function(frm,fld,sb,pn,rl,hd,sm,ufn){la=frm;a=fld;Xa=sb;if(!pn)pn="search";ia=pn;var Kb="en|";var Jb="zh-CN|zh-TW|ja|ko|vi|";if(!rl||Kb.indexOf(rl+"|")==-1)rl="en";ha=nb(rl);if(Jb.indexOf(ha+"|")==-1){X=true;Y=false;Ba=false}else{X=false;if(ha.indexOf("zh")==0)Y=false;else Y=true;Ba=true}if(!hd)hd=false;ya=hd;if(!sm)sm="query";w=sm;mb=ufn;ac()}
;function Yb(){ra=true;a.blur();setTimeout("sfi();",10);return}
function Fb(){if(document.createEventObject){var y=document.createEventObject();y.ctrlKey=true;y.keyCode=70;document.fireEvent("onkeydown",y)}}
function nc(vb){var y=document.createEventObject();y.ctrlKey=true;y.keyCode=vb;document.fireEvent("onkeydown",y)}
function gc(event){}
function ic(event){}
function Pb(event){if(!event&&window.event)event=window.event;if(event)na=event.keyCode;if(event&&event.keyCode==8){if(X&&(a.createTextRange&&(event.srcElement==a&&(bb(a)==0&&lb(a)==0)))){cc(a);event.cancelBubble=true;event.returnValue=false;return false}}}
function mc(){}
function Db(){if(w=="url"){Ha()}ba()}
function ba(){if(b){b.style.left=ob(a)+"px";b.style.top=Qb(a)+a.offsetHeight-1+"px";b.style.width=Ja()+"px"}}
function Ja(){if(navigator&&navigator.userAgent.toLowerCase().indexOf("msie")==-1){return a.offsetWidth-ca*2}else{return a.offsetWidth}}
function ac(){if(jb()){Q=true}else{Q=false}if(pa)E="complete";else
E="/sqllogger/"+ia;sa=E+"?hl="+ha;if(!Q){qa("qu","",0,E,null,null)}la.onsubmit=Fa;a.autocomplete="off";a.onblur=Ob;if(a.createTextRange)a.onkeyup=new Function("return okuh(event); ");else a.onkeyup=okuh;a.onsubmit=Fa;g=a.value;ta=g;b=document.createElement("DIV");b.id="completeDiv";ca=1;Aa=1;b.style.borderRight="black "+ca+"px solid";b.style.borderLeft="black "+ca+"px solid";b.style.borderTop="black "+Aa+"px solid";b.style.borderBottom="black "+Aa+"px solid";b.style.zIndex="1";b.style.paddingRight="0";b.style.paddingLeft="0";b.style.paddingTop="0";b.style.paddingBottom="0";ba();b.style.visibility="hidden";b.style.position="absolute";b.style.backgroundColor="white";document.body.appendChild(b);Ma("",new Array(),new Array());Gb(b);var s=document.createElement("DIV");s.style.visibility="hidden";s.style.position="absolute";s.style.left="-10000";s.style.top="-10000";s.style.width="0";s.style.height="0";var M=document.createElement("IFRAME");M.completeDiv=b;M.name="completionFrame";M.id="completionFrame";M.src=sa;s.appendChild(M);document.body.appendChild(s);if(frames&&(frames["completionFrame"]&&frames["completionFrame"].frameElement))B=frames["completionFrame"].frameElement;else B=document.getElementById("completionFrame");if(w=="url"){Ha();ba()}window.onresize=Db;document.onkeydown=Pb;Fb()}
function Ob(event){if(!event&&window.event)event=window.event;if(!ra){F();if(na==9){Xb();na=-1}}ra=false}
okuh=function(e){m=e.keyCode;aa=a.value;Oa()}
;function Xb(){Xa.focus()}
sfi=function(){a.focus()}
;function Wb(va){for(var f=0,oa="",zb="\n\r";f<va.length;f++)if(zb.indexOf(va.charAt(f))==-1)oa+=va.charAt(f);else oa+=" ";return oa}
function Qa(i,dc){var ga=i.getElementsByTagName(Bb);if(ga){for(var f=0;f<ga.length;++f){if(ga[f].className==dc){var value=ga[f].innerHTML;if(value=="&nbsp;")return"";else{var z=Wb(value);return z}}}}else{return""}}
function U(i){if(!i)return null;return Qa(i,"cAutoComplete")}
function wa(i){if(!i)return null;return Qa(i,"dAutoComplete")}
function F(){document.getElementById("completeDiv").style.visibility="hidden"}
function cb(){document.getElementById("completeDiv").style.visibility="visible";ba()}
function Ma(is,cs,ds){Ua[is]=new Array(cs,ds)}
sendRPCDone=function(fr,is,cs,ds,pr){if(W>0)W--;var lc=(new Date()).getTime();if(!fr)fr=B;Ma(is,cs,ds);var b=fr.completeDiv;b.completeStrings=cs;b.displayStrings=ds;b.prefixStrings=pr;rb(b,b.completeStrings,b.displayStrings);Pa(b,U);if(Ca>0)b.height=16*Ca+4;else F()}
;function Oa(){if(m==40||m==38)Yb();var N=lb(a);var v=bb(a);var V=a.value;if(X&&m!=0){if(N>0&&v!=-1)V=V.substring(0,v);if(m==13||m==3){var d=a;if(d.createTextRange){var t=d.createTextRange();t.moveStart("character",d.value.length);t.select()}else if(d.setSelectionRange){d.setSelectionRange(d.value.length,d.value.length)}}else{if(a.value!=V)S(V)}}g=V;if(Eb(m)&&m!=0)Pa(b,U)}
function Fa(){return xb(w)}
function xb(eb){da=true;if(!Q){qa("qu","",0,E,null,null)}F();if(eb=="url"){var R="";if(j!=-1&&h)R=U(h);if(R=="")R=a.value;if(q=="")document.title=R;else document.title=q;var Tb="window.frames['"+mb+"'].location = \""+R+'";';setTimeout(Tb,10);return false}else if(eb=="query"){la.submit();return true}}
newwin=function(){window.open(a.value);F();return false}
;idkc=function(e){if(Ba){var Ta=a.value;if(Ta!=aa){m=0;Oa()}aa=Ta;setTimeout("idkc()",10)}}
;setTimeout("idkc()",10);function nb(La){if(encodeURIComponent)return encodeURIComponent(La);if(escape)return escape(La)}
function yb(Mb){var H=100;for(var o=1;o<=(Mb-2)/2;o++){H=H*2}H=H+50;return H}
idfn=function(){if(ta!=g){if(!da){var Za=nb(g);var ma=Ua[g];if(ma){Va=-1;sendRPCDone(B,g,ma[0],ma[1],B.completeDiv.prefixStrings)}else{W++;Va=(new Date()).getTime();if(Q){fc(Za)}else{qa("qu",Za,null,E,null,null);frames["completionFrame"].document.location.reload(true)}}a.focus()}da=false}ta=g;setTimeout("idfn()",yb(W));return true}
;setTimeout("idfn()",10);var Cb=function(){S(U(this));q=wa(this);da=true;Fa()}
;var pb=function(){if(h)l(h,"aAutoComplete");l(this,"bAutoComplete")}
;var ec=function(){l(this,"aAutoComplete")}
;function Na(C){g=G;S(G);q=G;if(!za||Z<=0)return;cb();if(C>=Z){C=Z-1}if(j!=-1&&C!=j){l(h,"aAutoComplete");j=-1}if(C<0){j=-1;a.focus();return}j=C;h=za.item(C);l(h,"bAutoComplete");g=G;q=wa(h);S(U(h))}
function Eb(ja){if(ja==40){Na(j+1);return false}else if(ja==38){Na(j-1);return false}else if(ja==13||ja==3){return false}return true}
function Pa(K,ib){var d=a;var T=false;j=-1;var J=K.getElementsByTagName(Lb);var O=J.length;Z=O;za=J;Ca=O;G=g;if(g==""||O==0){F()}else{cb()}var Ab="";if(g.length>0){var f;var o;for(var f=0;f<O;f++){for(o=0;o<K.prefixStrings.length;o++){var Ib=K.prefixStrings[o]+g;if(Y||ib(J.item(f)).toUpperCase().indexOf(Ib.toUpperCase())==0){Ab=K.prefixStrings[o];T=true;break}}if(T){break}}}if(T)j=f;for(var f=0;f<O;f++)l(J.item(f),"aAutoComplete");if(T){h=J.item(j);q=wa(h)}else{q=g;j=-1;h=null}var ab=false;switch(m){case 8:case 33:case 34:case 35:case 35:case 36:case 37:case 39:case 45:case 46:ab=true;break;default:break}if(!ab&&h){var Da=g;l(h,"bAutoComplete");var z;if(T)z=ib(h).substr(K.prefixStrings[o].length);else z=Da;if(z!=d.value){if(d.value!=g)return;if(X){if(d.createTextRange||d.setSelectionRange)S(z);if(d.createTextRange){var t=d.createTextRange();t.moveStart("character",Da.length);t.select()}else if(d.setSelectionRange){d.setSelectionRange(Da.length,d.value.length)}}}}else{j=-1;q=g}}
function ob(r){return Ya(r,"offsetLeft")}
function Qb(r){return Ya(r,"offsetTop")}
function Ya(r,ia){var kb=0;while(r){kb+=r[ia];r=r.offsetParent}return kb}
function qa(name,value,Ra,hb,fb,Sb){var Nb=name+"="+value+(Ra?"; expires="+Ra.toGMTString():"")+(hb?"; path="+hb:"")+(fb?"; domain="+fb:"")+(Sb?"; secure":"");document.cookie=Nb}
function Ha(){var xa=document.body.scrollWidth-220;xa=0.73*xa;a.size=Math.floor(xa/6.18)}
function lb(n){var N=-1;if(n.createTextRange){var fa=document.selection.createRange().duplicate();N=fa.text.length}else if(n.setSelectionRange){N=n.selectionEnd-n.selectionStart}return N}
function bb(n){var v=0;if(n.createTextRange){var fa=document.selection.createRange().duplicate();fa.moveEnd("textedit",1);v=n.value.length-fa.text.length}else if(n.setSelectionRange){v=n.selectionStart}else{v=-1}return v}
function cc(d){if(d.createTextRange){var t=d.createTextRange();t.moveStart("character",d.value.length);t.select()}else if(d.setSelectionRange){d.setSelectionRange(d.value.length,d.value.length)}}
function jc(Zb,Ea){if(!Ea)Ea=1;if(pa&&pa<=Ea){var Ia=document.createElement("DIV");Ia.innerHTML=Zb;document.getElementById("console").appendChild(Ia)}}
function l(c,name){db();c.className=name;if(Ka){return}switch(name.charAt(0)){case "m":c.style.fontSize="13px";c.style.fontFamily="arial,sans-serif";c.style.wordWrap="break-word";break;case "l":c.style.display="block";c.style.paddingLeft="3";c.style.paddingRight="3";c.style.height="16px";c.style.overflow="hidden";break;case "a":c.style.backgroundColor="white";c.style.color="black";if(c.displaySpan){c.displaySpan.style.color="green"}break;case "b":c.style.backgroundColor="#3366cc";c.style.color="white";if(c.displaySpan){c.displaySpan.style.color="white"}break;case "c":c.style.width=p+"%";c.style.cssFloat="left";break;case "d":c.style.cssFloat="right";c.style.width=100-p+"%";if(w=="query"){c.style.fontSize="10px";c.style.textAlign="right";c.style.color="green";c.style.paddingTop="3px"}else{c.style.color="#696969"}break}}
function db(){p=65;if(w=="query"){var wb=110;var Sa=Ja();var tb=(Sa-wb)/Sa*100;p=tb}else{p=65}if(ya){p=99.99}}
function Gb(i){db();var Ub="font-size: 13px; font-family: arial,sans-serif; word-wrap:break-word;";var Vb="display: block; padding-left: 3; padding-right: 3; height: 16px; overflow: hidden;";var bc="background-color: white;";var qb="background-color: #3366cc; color: white ! important;";var ub="display: block; margin-left: 0%; width: "+p+"%; float: left;";var Ga="display: block; margin-left: "+p+"%;";if(w=="query"){Ga+="font-size: 10px; text-align: right; color: green; padding-top: 3px;"}else{Ga+="color: #696969;"}D(".mAutoComplete",Ub);D(".lAutoComplete",Vb);D(".aAutoComplete *",bc);D(".bAutoComplete *",qb);D(".cAutoComplete",ub);D(".dAutoComplete",Ga);l(i,"mAutoComplete")}
function rb(i,cs,Hb){while(i.childNodes.length>0)i.removeChild(i.childNodes[0]);for(var f=0;f<cs.length;++f){var u=document.createElement("DIV");l(u,"aAutoComplete");u.onmousedown=Cb;u.onmouseover=pb;u.onmouseout=ec;var ka=document.createElement("SPAN");l(ka,"lAutoComplete");var ua=document.createElement("SPAN");ua.innerHTML=cs[f];var ea=document.createElement("SPAN");l(ea,"dAutoComplete");l(ua,"cAutoComplete");u.displaySpan=ea;if(!ya)ea.innerHTML=Hb[f];ka.appendChild(ua);ka.appendChild(ea);u.appendChild(ka);i.appendChild(u)}}
function D(name,gb){if(Ka){var I=document.styleSheets[0];if(I.addRule){I.addRule(name,gb)}else if(I.insertRule){I.insertRule(name+" { "+gb+" }",I.cssRules.length)}}}
function jb(){var A=null;try{A=new ActiveXObject("Msxml2.XMLHTTP")}catch(e){try{A=new ActiveXObject("Microsoft.XMLHTTP")}catch(oc){A=null}}if(!A&&typeof XMLHttpRequest!="undefined"){A=new XMLHttpRequest()}return A}
function fc(Rb){if(k&&k.readyState!=0){k.abort()}k=jb();if(k){k.open("GET",sa+"&js=true&qu="+Rb,true);k.onreadystatechange=function(){if(k.readyState==4&&k.responseText){var frameElement=B;if(k.responseText.charAt(0)=="<"){W--}else{eval(k.responseText)}}}
;k.send(null)}}
function S(Wa){a.value=Wa;aa=Wa}


