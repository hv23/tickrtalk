jQuery.fn.sifr=function(prefs){if(prefs===false)prefs={unsifr:true};prefs=jQuery.extend({},arguments.callee.prefs,prefs);if(prefs.save){arguments.callee.prefs=jQuery.extend({absoluteOffsetX:null,aoX:null,absoluteOffsetY:null,aoY:null,relativeOffsetX:null,roX:null,relativeOffsetY:null,roY:null,path:null,font:null,fontSize:null,color:null,underline:null,textTransform:null,link:null,hover:null,backgroundColor:null,textAlign:null,content:null,width:null,height:null},arguments.callee.prefs,prefs,{save:false});}return this.each(function(){var o=jQuery(this);if(o.is('.sifr')||(prefs.unsifr&&o.is('.sifr'))){o.html(jQuery(this.firstChild).html());o.removeClass('sifr');}if(!prefs.unsifr){var s=jQuery.extend({},arguments.callee.prefs,prefs);var hex=function(N){if(N==null)return"00";N=parseInt(N);if(N==0||isNaN(N))return"00";N=Math.max(0,N);N=Math.min(N,255);N=Math.round(N);return"0123456789ABCDEF".charAt((N-N%16)/16)+"0123456789ABCDEF".charAt(N%16);};var hexed=function(color){if(!color){return false;}if(color.search('rgb')>-1){color=color.substr(4,color.length-5).split(', ');color=hex(color[0])+hex(color[1])+hex(color[2]);}color=color.replace('#','');if(color.length<6){color=color.substr(0,1)+color.substr(0,1)+color.substr(1,1)+color.substr(1,1)+color.substr(2,1)+color.substr(2,1);}return'#'+color;};o.addClass('sifr');s.font=s.font||(/([^\'\",]+)[,]?/.exec(o.css('fontFamily'))||[,])[1];s.color=hexed(s.color||o.css('color'));s.link=hexed(s.link||o.children('a').css('color'))||s.color;s.hover=hexed(s.hover)||s.link;s.underline=(s.underline||(o.css('textDecoration')=='underline'))?true:null;o.css('backgroundColor',hexed(s.backgroundColor));s.textAlign=s.textAlign||o.css('textAlign')||'left';o.html('<span style="display:inline;margin:0;padding:0;float:none;width:auto;height:auto;font-weight:inherit;">'+o.html()+'</span>');var oc=jQuery(this.firstChild);s.ieM=(o.height()-oc.height())/2;s.ieM=(jQuery.browser.msie)?'height:'+(o.height()-s.ieM)+'px;margin:'+s.ieM+'px 0 0;vertical-align:middle;':'vertical-align:middle;';if(s.fontSize)oc.css('fontSize',s.fontSize);s.textTransform=s.textTransform||o.css('textTransform');if(s.textTransform=='uppercase')s.content=oc.html().toUpperCase();if(s.textTransform=='lowercase')s.content=oc.html().toLowerCase();if(s.textTransform=='capitalize'){var c=oc.html().replace(/^\s+|\s+$/g,'').replace(/\>/g,'> ').split(' ');for(var i=0;i<c.length;i++){c[i]=c[i].charAt(0).toUpperCase()+c[i].substring(1);}s.content=c.join(' ').replace(/\> /g,'>');}s.content=s.content||oc.html();s.width=s.width||oc.width();s.height=s.height||oc.height();s.aoX=(s.aoX||0)+((s.width/100)*(s.roX||0));s.aoY=(s.aoY||0)+((s.height/100)*(s.roY||0));oc.hide();o.flash({src:s.path+s.font+'.swf',flashvars:{txt:s.content.replace(/^\s+|\s+$/g,''),w:s.width,h:s.height,offsetLeft:s.aoX,offsetTop:s.aoY,textalign:s.textAlign,textcolor:s.color,linkColor:s.link,hoverColor:s.hover,underline:s.underline}},{version:7,update:false},function(htmlOptions){htmlOptions.style=s.ieM;htmlOptions.wmode='transparent';htmlOptions.width=s.width;htmlOptions.height=s.height;o.append(jQuery.fn.flash.transform(htmlOptions));});}});};jQuery.sifr=jQuery(document).sifr;