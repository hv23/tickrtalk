// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ajaxSend(function(event, request, settings) {
  if (typeof(AUTH_TOKEN) == "undefined") return;
  // settings.data is a serialized string like "foo=bar&baz=boink" (or null)
  settings.data = settings.data || "";
  settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
});



jQuery.ajaxSetup({ 'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} })
 
function _ajax_request(url, data, callback, type, method) {
    if (jQuery.isFunction(data)) {
        callback = data;
        data = {};
    }
    return jQuery.ajax({
        type: method,
        url: url,
        data: data,
        success: callback,
        dataType: type
        });
}
 
jQuery.extend({
    put: function(url, data, callback, type) {
        return _ajax_request(url, data, callback, type, 'PUT');
    },
    delete_: function(url, data, callback, type) {
        return _ajax_request(url, data, callback, type, 'DELETE');
    }
});
 
jQuery.fn.submitWithAjax = function() {
  this.unbind('submit', false);
  this.submit(function() {
    $.post(this.action, $(this).serialize(), null, "script");
    return false;
  })
 
  return this;
};
 
jQuery.fn.getWithAjax = function() {
  this.unbind('click', false);
  this.click(function() {
    $.get($(this).attr("href"), $(this).serialize(), null, "script");
    return false;
  })
  return this;
};

jQuery.fn.postWithAjax = function() {
  this.unbind('click', false);
  this.click(function() {
    $.post($(this).attr("href"), $(this).serialize(), null, "script");
    return false;
  })
  return this;
};
 
jQuery.fn.putWithAjax = function() {
  this.unbind('click', false);
  this.click(function() {
    $.put($(this).attr("href"), $(this).serialize(), null, "script");
    return false;
  })
  return this;
};
 
jQuery.fn.deleteWithAjax = function() {
  this.removeAttr('onclick');
  this.unbind('click', false);
  this.click(function() {
    $.delete_($(this).attr("href"), $(this).serialize(), null, "script");
    return false;
  })
  return this;
};

function ajaxLinks(){
    $('.ajaxForm').submitWithAjax();
    $('a.get').getWithAjax();
    $('a.post').postWithAjax();
    $('a.put').putWithAjax();
    $('a.delete').deleteWithAjax();
}
 
$(document).ready(function() {
// All non-GET requests will add the authenticity token
 $(document).ajaxSend(function(event, request, settings) {
       if (typeof(window.AUTH_TOKEN) == "undefined") return;
       // IE6 fix for http://dev.jquery.com/ticket/3155
       if (settings.type == 'GET' || settings.type == 'get') return;
 
       settings.data = settings.data || "";
       settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(window.AUTH_TOKEN);
     });
 
  ajaxLinks();
});

$(document).ready(function() {
  $("#new_private_gameroom").submitWithAjax();
});

var chatscroll = new Object();

chatscroll.Pane = function(scrollContainerId){
  this.bottomThreshold = 20;
  this.scrollContainerId = scrollContainerId;
  this._lastScrollPosition = 100000000;
}

chatscroll.Pane.prototype.activeScroll = function(){

  var _ref = this;
  var scrollDiv = document.getElementById(this.scrollContainerId);
  var currentHeight = 0;
  
  var _getElementHeight = function(){
    var intHt = 0;
    if(scrollDiv.style.pixelHeight)intHt = scrollDiv.style.pixelHeight;
    else intHt = scrollDiv.offsetHeight;
    return parseInt(intHt);
  }

  var _hasUserScrolled = function(){
    if(_ref._lastScrollPosition == scrollDiv.scrollTop || _ref._lastScrollPosition == null){
      return false;
    }
    return true;
  }

  var _scrollIfInZone = function(){
    if( !_hasUserScrolled || 
        (currentHeight - scrollDiv.scrollTop - _getElementHeight() <= _ref.bottomThreshold)){
        scrollDiv.scrollTop = currentHeight;
        _ref._isUserActive = false;
    }
  }


  if (scrollDiv.scrollHeight > 0)currentHeight = scrollDiv.scrollHeight;
  else if(scrollDiv.offsetHeight > 0)currentHeight = scrollDiv.offsetHeight;

  _scrollIfInZone();

  _ref = null;
  scrollDiv = null;

}

function getComputedHeight(theElt){
        var browserName=navigator.appName; 
         if (browserName=="Microsoft Internet Explorer"){
                var is_ie=true;
         } else {
                var is_ie=false;
         }
        if(is_ie){
                tmphght = document.getElementById(theElt).offsetHeight;
        }
        else{
                docObj = document.getElementById(theElt);
                var tmphght1 = document.defaultView.getComputedStyle(docObj, "").getPropertyValue("height");
                tmphght = tmphght1.split('px');
                tmphght = tmphght[0];
        }
        return tmphght;
}


function addTeam() {
	// get the team id
	var teamid = $('#teamid').val()
	var teamname = $('#teaminput').val()
	$.ajax({
		type: "POST",
		url: "/myteams/addteam/",
		data: "id=" + teamid,
		success: function(msg){
			$('#teamslist').append(msg)
			$('#no_teamslist').remove()
			document.getElementById('teamid').value = ''
			document.getElementById('teaminput').value = ''
		}
	});
}

function removeTeam(teamid) {
	$.ajax({
		type: "POST",
		url: "/myteams/removeteam/",
		data: "id=" + teamid,
		success: function(msg){
			$("#team-" + teamid).remove()
		}
	});
}

// following javascripts

// toggle
// function togglefollow(userid) {
// 	$.ajax({
// 		type: "POST",
// 		url: "/users/togglefollow/",
// 		data: "id=" + userid,
// 		success: function(msg){
// 			document.getElementById('follow').innerHTML = msg
// 		}
// 	});
// }

function enterPressed(e) {
	var characterCode
	if(e && e.which){ // Netscape Navigator 4
		e = e
		characterCode = e.which
	}
	else {
		e = event
		characterCode = e.keyCode // IE specific
	}
	if (characterCode == 13) return true   // Enter key is 13
	else return false
}

function searchGames() {
	query =  document.getElementById("upcominggamesearch").value
	$.ajax({
		type: "POST",
		url: "/games/quicksearch/",
		data: "q=" + query,
		success: function(msg){
			document.getElementById('gamesearchresult').innerHTML = msg
		}
	});
}

function searchBigGame() {
	query =  document.getElementById("biggame").value
	$.ajax({
		type: "POST",
		url: "/games/big_game_search/",
		data: "q=" + query,
		success: function(msg){
			document.getElementById('gamesearchresult').innerHTML = msg
		}
	});
}

function searchContacts() {
	query =  document.getElementById("contact").value
	$.ajax({
		type: "POST",
		url: "/private_gamerooms/fill_contacts/",
		data: "q=" + query,
		success: function(msg){
			document.getElementById('contactresult').innerHTML = msg
		}
	});
}

function searchGamesInsideUG() {
	query =  document.getElementById("upcominggamesearchug").value
	$.ajax({
		type: "POST",
		url: "/games/quicksearch/",
		data: "q=" + query,
		success: function(msg){
			document.getElementById('gamesearchresultug').innerHTML = msg
			$("#gamesearchresultug").show()
		}
	});
}

function searchTeams() {
	query =  document.getElementById("teamsearch").value
	$.ajax({
		type: "POST",
		url: "/teams/quicksearch/",
		data: "q=" + query,
		success: function(msg){
			document.getElementById('teamsearchresult').innerHTML = msg
		}
	});
}

function liveview() {
	$.getJSON("/stream/liveview", function(json){
	  if(json.updatecontent != $("#updatecontent").text()) {
			$("#liveviewpane").hide()
			$("#updatecontent").text(json.updatecontent)
			if (json.source == 1) {
				$("#updateuserlink").attr('href','http://www.twitter.com/'+ json.updateuserlink)
			} else {
				$("#updateuserlink").attr('href','/users/' + json.updateuserlink)
			}
			$("#updateuserlink").text(json.updateuserlink)
			$("#updategameroomlink").attr('href','/gameroom/' + json.updategameroomlink)
			$("#updategameroomlink").text(json.updategamename)
			$("#liveviewpane").fadeIn('slow')
		}
	}
)
} 

$(document).ready(function (){  
  $('#update_form').submit(function (){  
    $.post($(this).attr('action'), $(this).serialize(), null, "script");  
    return false;  
  });  
});

$(document).ready(function (){  
  $('#new_private_gameroom').submit(function (){  
    $.post($(this).attr('action'), $(this).serialize(), null, "script");  
    return false;  
  });  
});

function fb_connect_invite_friends(options) {

  if ( typeof options != 'object' ) { options = {} }  
  if ( options.title == undefined ) { options.title = "Invite your friends" }
  if ( options.type == undefined ) { options.type = window.location.hostname }
  if ( options.all_friends_invited == undefined ) { options.all_friends_invited = "<div style='padding: 10px; font-size: 1.2em;'>You've already invited all of your friends and they've accepted.</div>" }
  if ( options.invitation_copy == undefined ) { options.invitation_copy = "" }
  if ( options.invitation_choice_url == undefined ) { options.invitation_choice_url = window.location.protocol + '//' + window.location.host + '/' }
  if ( options.invitation_choice_label == undefined ) { options.invitation_choice_label = 'Accept' }
  if ( options.request_action_url == undefined ) { options.request_action_url = window.location.href }
  if ( options.request_action_text == undefined ) { options.request_action_text = options.title }
  if ( options.friend_selector_rows == undefined ) { options.friend_selector_rows = 3 }
  if ( options.friend_selector_email_invite == undefined ) { options.friend_selector_email_invite = 'true' }
  if ( options.friend_selector_bypass == undefined ) { options.friend_selector_bypass = 'cancel' }
  if ( isNaN(options.width) ) { options.width = 600 }
  if ( isNaN(options.height) ) { options.height = 510 }

  var api = FB.Facebook.apiClient
  var sequencer = new FB.BatchSequencer()
  var friends = api.friends_get(null, sequencer)
  var friends_app_users = api.friends_getAppUsers(sequencer)

  sequencer.execute(function() {

    var friend_ids = ''
    try {
      friend_ids = friends.result.sort().join(',')
    }catch(e) {;}

    var exclude_ids = ''
    try {
      exclude_ids = friends_app_users.result.sort().join(',')
    }catch(e) {;}

    var dialog = new FB.UI.FBMLPopupDialog(options.title, '')

    if ( friend_ids.length > 0 && exclude_ids.length > 0 && friend_ids == exclude_ids ) {
      var fbml = ''
      fbml += '<fb:fbml>'
      fbml += options.all_friends_invited
      fbml += '</fb:fbml>'

      dialog.setFBMLContent(fbml)
      dialog.setContentWidth(300)  
      dialog.setContentHeight(70)
    }else {
      var content = ''
      content += options.invitation_copy
      content += "<fb:req-choice url='" + options.invitation_choice_url + "' label='" + options.invitation_choice_label + "' />"

      var fbml = ''
      fbml += '<fb:fbml>'
      fbml += '<fb:request-form type="' + options.type + '" content="' + content + '" invite="true" action="' + options.request_action_url + '" method="post">'
      fbml += '<fb:multi-friend-selector'
      fbml += ' actiontext="' + options.request_action_text + '" '
      fbml += ' showborder="true" '
      fbml += ' rows="' + options.friend_selector_rows + '" '
      fbml += ' exclude_ids="' + exclude_ids + '" '
      fbml += ' bypass="' + options.friend_selector_bypass + '" '
      fbml += ' email_invite="' + options.friend_selector_email_invite + '" '
      fbml += '/>'
      fbml += '</fb:request-form>'
      fbml += '</fb:fbml>'

      dialog.setFBMLContent(fbml)
      dialog.setContentWidth(options.width)  
      dialog.setContentHeight(options.height)
    }
    dialog.show()
  })

}

function getWindowWidth() {
	return $("body").width()
}

function updateTicker() {
	$.get("/welcome/ticker", { place: 'holder'}, function(data)
		{ $("#tickercont").show(function() {
			$("#tickercont").fadeIn('slow');
			$("#tickercont").html(data);
			$("ul#ticker").liScroll({travelocity: 0.06});
			$(".tickercontainer").width((getWindowWidth()-151))
			$(".mask").width((getWindowWidth()-151))
			$("#tickercont").width((getWindowWidth()-151))
		})
		
	});
}

function resizeTickerView() {
	$(".tickercontainer").width((getWindowWidth()-151))
	$(".mask").width((getWindowWidth()-151))
	$("#tickercont").width((getWindowWidth()-151))
}